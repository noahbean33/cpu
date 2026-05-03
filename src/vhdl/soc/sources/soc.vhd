

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;
use work.memory_pkg.all;

entity soc is
  port (
    clk         : in  std_logic;
    resetn      : in  std_logic;
    iomem_valid : out std_logic;
    iomem_ready : in  std_logic;
    iomem_wben  : out std_logic_vector(3 downto 0);
    iomem_addr  : out std_logic_vector(31 downto 0);
    iomem_wdata : out std_logic_vector(31 downto 0);
    iomem_rdata : in  std_logic_vector(31 downto 0);
    ser_tx      : out std_logic;
    ser_rx      : in  std_logic
  );
end entity soc;

architecture rtl of soc is

  -- -------------------- Parameters --------------------
  constant UART_DIV_ADDR         : std_logic_vector(31 downto 0) := x"03000004";
  constant UART_DAT_ADDR         : std_logic_vector(31 downto 0) := x"03000008";

  -- -------------------- CPU interfaces --------------------
  signal mem_valid               : std_logic;
  signal mem_ready               : std_logic;
  signal mem_addr                : std_logic_vector(31 downto 0);
  signal mem_wdata               : std_logic_vector(31 downto 0);
  signal mem_ben                 : std_logic_vector(3 downto 0);
  signal mem_rdata               : std_logic_vector(31 downto 0);
  signal mem_write_enable        : std_logic;
  signal mem_access_width        : MEM_ACCESS_WIDTH_t;

  signal inst_addr               : std_logic_vector(31 downto 0);
  signal inst_rdata              : std_logic_vector(31 downto 0);

  -- -------------------- Decoding --------------------
  signal data_mem_sel            : std_logic;
  signal uart_div_sel            : std_logic;
  signal uart_dat_sel            : std_logic;
  signal ext_sel                 : std_logic;

  -- -------------------- UART --------------------
  signal simpleuart_reg_div_do   : std_logic_vector(31 downto 0);
  signal simpleuart_reg_dat_do   : std_logic_vector(31 downto 0);
  signal simpleuart_reg_dat_wait : std_logic;

  signal uart_div_we             : std_logic_vector(3 downto 0);
  signal uart_dat_we             : std_logic;
  signal uart_dat_re             : std_logic;

  -- -------------------- Data RAM --------------------
  signal data_mem_rdata          : std_logic_vector(31 downto 0);
  signal data_mem_addr           : std_logic_vector(31 downto 0);
  signal data_mem_write_enable   : std_logic;
  signal data_mem_access_width   : MEM_ACCESS_WIDTH_t;
  signal data_mem_access_enable  : std_logic;

begin

  data_mem_sel <=      '1' when mem_addr(31 downto 24) = x"01" or mem_addr(31 downto 24) = x"02"
                  else '0';
  uart_div_sel <=      '1' when (mem_addr = UART_DIV_ADDR)
                  else '0';
  uart_dat_sel <=      '1' when (mem_addr = UART_DAT_ADDR)
                  else '0';
  ext_sel      <=      '1' when mem_addr(31 downto 24) = x"04"
                  else '0';

  -- -------------------- External bus --------------------
  iomem_valid <= ext_sel and mem_valid;
  iomem_wben  <= (others => '1') when ext_sel = '1' else (others => '0');
  iomem_addr  <= mem_addr;
  iomem_wdata <= mem_wdata;

  -- -------------------- UART write enables --------------------
  uart_div_we <= (others => '1') when uart_div_sel = '1' and mem_write_enable = '1' and mem_valid = '1' else (others => '0');
  uart_dat_we <= (uart_dat_sel and mem_valid and     mem_write_enable);
  uart_dat_re <= (uart_dat_sel and mem_valid and not mem_write_enable);
  
  -- -------------------- UART instance --------------------
  u_uart : entity work.simpleuart
    port map (
      clk          => clk,
      resetn       => resetn,
      ser_tx       => ser_tx,
      ser_rx       => ser_rx,

      reg_div_we   => uart_div_we,
      reg_div_di   => mem_wdata,
      reg_div_do   => simpleuart_reg_div_do,

      reg_dat_we   => uart_dat_we,
      reg_dat_re   => uart_dat_re,
      reg_dat_di   => mem_wdata,
      reg_dat_do   => simpleuart_reg_dat_do,
      reg_dat_wait => simpleuart_reg_dat_wait
    );

  -- -------------------- Data memory instance --------------------
  data_mem_addr          <= mem_addr         when data_mem_sel = '1' else (others => '0');
  data_mem_access_width  <= mem_access_width when data_mem_sel = '1' else MEM_ACCESS_WIDTH_32;
  data_mem_access_enable <= data_mem_sel and mem_valid;
  data_mem_write_enable  <= data_mem_sel and mem_valid and mem_write_enable;

  u_data_memory : entity work.data_memory
    port map (
      clk                => clk,
      addr               => data_mem_addr,
      write_enable       => data_mem_write_enable,
      access_width       => data_mem_access_width,
      access_enable      => data_mem_access_enable,
      rdata              => data_mem_rdata,
      wdata              => mem_wdata
    );

  -- -------------------- Instruction memory instance --------------------
  u_inst_memory : entity work.inst_memory
    port map (
      addr               => inst_addr,
      en                 => '1',
      data               => inst_rdata
    );
		
  -- -------------------- Read data mux --------------------
  mem_rdata <= simpleuart_reg_div_do          when uart_div_sel = '1' else
               simpleuart_reg_dat_do          when uart_dat_sel = '1' else
               iomem_rdata                    when ext_sel      = '1' else
               data_mem_rdata                 when data_mem_sel = '1' else
               (others => '1');
			   
  -- -------------------- Ready mux --------------------
  mem_ready <= '1'                            when uart_div_sel = '1' else
               (not simpleuart_reg_dat_wait)  when uart_dat_sel = '1' else
               iomem_ready                    when ext_sel      = '1' else
               '1'                            when data_mem_sel = '1' else
               '1';

  -- -------------------- CPU instance --------------------
  u_cpu : entity work.cpu
    port map (
      clk                => clk,
      resetn             => resetn,

      imem_ready         => '1',
      imem_valid         => open,
      imem_addr          => inst_addr,
      imem_rdata         => inst_rdata,

      dmem_ready         => mem_ready,
      dmem_valid         => mem_valid,
      dmem_addr          => mem_addr,
      dmem_write_enable  => mem_write_enable,
      dmem_access_width  => mem_access_width,
      dmem_wdata         => mem_wdata,
      dmem_rdata         => mem_rdata,

      trace_regs         => open
    );

end architecture rtl;
