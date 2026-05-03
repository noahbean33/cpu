

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    G_FPGA  : boolean := true  -- false for simulation, true for FPGA
  );
  port (
    clk     : in  std_logic;
    resetn  : in  std_logic;
    ser_tx  : out std_logic;
    ser_rx  : in  std_logic;
    leds    : out std_logic_vector(7 downto 0)
  );
end entity top;

architecture rtl of top is

	signal iomem_valid      : std_logic;
	signal iomem_ready      : std_logic := '0';
	signal iomem_wben       : std_logic_vector(3 downto 0);
	signal iomem_addr       : std_logic_vector(31 downto 0);
	signal iomem_wdata      : std_logic_vector(31 downto 0);
	signal iomem_rdata      : std_logic_vector(31 downto 0);
    signal resetn_sync      : std_logic;
	signal rstn_raw  		: std_logic;
	signal rstn_ff1  		: std_logic := '0';
	signal rstn_ff2  		: std_logic := '0';
	signal gpio 		    : std_logic_vector(31 downto 0);
	signal cnt 			    : integer;
	signal leds_0 		    : std_logic;
	signal clk_10MHz 	    : std_logic;
	signal locked		 	: std_logic;
	
	component clk_wiz is
	port
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT1          : out    std_logic;
	  -- Status and control signals
	  LOCKED            : out    std_logic
	 );
	end component;

begin

	-- Raw reset: async assert, held low until locked
	rstn_raw <= resetn and locked;

	-- Sync deassertion to clk_10MHz (async assert)
	process(clk_10MHz, rstn_raw)
	begin
	  if rstn_raw = '0' then
		rstn_ff1 <= '0';
		rstn_ff2 <= '0';
	  elsif rising_edge(clk_10MHz) then
		rstn_ff1 <= '1';
		rstn_ff2 <= rstn_ff1;
	  end if;
	end process;

	resetn_sync <= rstn_ff2;

	gen_clk_wiz : if G_FPGA = true generate
		clknetwork : clk_wiz
		port map
		(
			CLK_IN1            => clk,
			CLK_OUT1           => clk_10MHz,
			locked 			   => locked
		);
	end generate gen_clk_wiz;
	
	gen_no_clk_wiz : if G_FPGA = false generate
		clk_10MHz <= clk;
		locked <= '1';
	end generate gen_no_clk_wiz;

	process(clk_10MHz)
	begin
		if rising_edge(clk_10MHz) then
			if resetn_sync = '0' then
				cnt <= 0;
				leds_0 <= '0';
			else
				if cnt = 10_000_000 then
					cnt   <= 0;
					leds_0 <= not leds_0;
				else
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;
	  
	leds(7 downto 0) <= gpio(7 downto 0);	

	p_gpio_mmio : process(clk_10MHz)
	begin
		if rising_edge(clk_10MHz) then
			if resetn_sync = '0' then
				gpio        <= (others => '0');
				iomem_ready <= '0';
				iomem_rdata <= (others => '0');
			else
				iomem_ready <= '0';
				if (iomem_valid = '1') and (iomem_ready = '0') and (iomem_addr(31 downto 24) = x"04") then
				  iomem_ready <= '1';
				  iomem_rdata <= gpio;
				  if iomem_wben(0) = '1' then gpio(7 downto 0)   <= iomem_wdata(7 downto 0);   end if;
				  if iomem_wben(1) = '1' then gpio(15 downto 8)  <= iomem_wdata(15 downto 8);  end if;
				  if iomem_wben(2) = '1' then gpio(23 downto 16) <= iomem_wdata(23 downto 16); end if;
				  if iomem_wben(3) = '1' then gpio(31 downto 24) <= iomem_wdata(31 downto 24); end if;
				end if;
			end if;
		end if;
	end process;

  -- SoC instance
  u_soc : entity work.soc
    port map (
      clk         => clk_10MHz,
      resetn      => resetn_sync,
      iomem_valid => iomem_valid,
      iomem_ready => iomem_ready,
      iomem_wben  => iomem_wben,
      iomem_addr  => iomem_addr,
      iomem_wdata => iomem_wdata,
      iomem_rdata => iomem_rdata,
      ser_tx      => ser_tx,
      ser_rx      => ser_rx
    );
	

end architecture rtl;
