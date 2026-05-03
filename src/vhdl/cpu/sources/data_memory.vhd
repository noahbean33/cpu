library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.memory_pkg.all;
use work.cpu_pkg.all;

entity data_memory is
  port (
    clk           : in  std_logic;
    addr          : in  std_logic_vector(31 downto 0);
    write_enable  : in  std_logic;
    access_enable : in  std_logic;
    access_width  : in  MEM_ACCESS_WIDTH_t;
    wdata         : in  std_logic_vector(31 downto 0);
    rdata         : out std_logic_vector(31 downto 0)
  );
end entity;

architecture Behavioral of data_memory is

    signal data_out_ram_signal  : std_logic_vector(31 downto 0);
    signal data_out_rom_signal  : std_logic_vector(31 downto 0);
    signal addr_relative        : std_logic_vector(31 downto 0);

    signal rom_access_en        : std_logic;
    signal ram_access_en        : std_logic;

begin

    --synthesis translate_off
    -- process(clk)
    -- begin
        -- if rising_edge(clk) then
            -- if access_enable = '1' then
                -- report "RAM access at : " & to_hstring(std_logic_vector(addr));
            -- end if;
        -- end if;
    -- end process;
    -- synthesis translate_on

    addr_relative <= std_logic_vector(unsigned(addr) - to_unsigned(DATA_RAM_BASE_ADDRESS, addr'length))
                        when (unsigned(addr) >= DATA_RAM_BASE_ADDRESS) and (unsigned(addr) < DATA_RAM_BASE_ADDRESS + DATA_RAM_MEMORY_SIZE_BYTES) else

                     std_logic_vector(unsigned(addr) - to_unsigned(DATA_ROM_BASE_ADDRESS, addr'length))
                        when (unsigned(addr) >= DATA_ROM_BASE_ADDRESS) and (unsigned(addr) < DATA_ROM_BASE_ADDRESS + DATA_ROM_MEMORY_SIZE_BYTES) else

                     (others => '0');

    ram_access_en <= access_enable when (unsigned(addr) >= DATA_RAM_BASE_ADDRESS) and (unsigned(addr) < DATA_RAM_BASE_ADDRESS + DATA_RAM_MEMORY_SIZE_BYTES) else '0';
    rom_access_en <= access_enable when (unsigned(addr) >= DATA_ROM_BASE_ADDRESS) and (unsigned(addr) < DATA_ROM_BASE_ADDRESS + DATA_ROM_MEMORY_SIZE_BYTES) else '0';


    data_ram : entity work.data_ram(Behavioral)
        port map(
            clk           => clk,
            addr          => addr_relative,
            access_width  => access_width,
            en            => ram_access_en,
            we            => write_enable,
            di            => wdata,
            do            => data_out_ram_signal
        );

    data_rom : entity work.data_rom(Behavioral)
        port map(
            addr          => addr_relative,
            en            => rom_access_en,
            access_width  => access_width,
            dout          => data_out_rom_signal
        );

	rdata <= data_out_rom_signal when rom_access_en = '1' else
			 data_out_ram_signal when ram_access_en = '1' else
			 (others => '1');

end Behavioral;