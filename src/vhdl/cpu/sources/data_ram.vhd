
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_pkg.all;
use work.memory_pkg.all;


entity data_ram is
    port(
        clk            : in std_logic;
        addr           : in std_logic_vector(31 downto 0);
        en             : in std_logic;
        we             : in std_logic;
        access_width   : MEM_ACCESS_WIDTH_t;
        di             : in std_logic_vector(31 downto 0);
        do             : out std_logic_vector(31 downto 0)
    );
end data_ram;


architecture Behavioral of data_ram is

    signal memory                 : DATA_RAM_MEMORY_ARRAY_t;

    signal word_index             : integer;
    signal halfword_index         : integer range 0 to 2;
    signal byte_index             : integer range 0 to 3;

    signal access_enable          : std_logic;

begin

    word_index      <= to_integer(unsigned(addr(31 downto 2)));
    halfword_index  <= to_integer(unsigned(addr(1 downto 0) and "10"));
    byte_index      <= to_integer(unsigned(addr(1 downto 0)));

    access_enable   <= '0' when      (word_index >= DATA_RAM_MEMORY_SIZE_WORDS)
                                  or (access_width = MEM_ACCESS_WIDTH_16 and addr(0) = '1')
                                  or (access_width = MEM_ACCESS_WIDTH_32 and addr(1 downto 0) /= "00") else
                       en;

    do              <= memory(word_index)                                                                  when access_width = MEM_ACCESS_WIDTH_32 and access_enable = '1' else
                       x"0000" & memory(word_index)(8 * halfword_index + 16 - 1 downto 8 * halfword_index) when access_width = MEM_ACCESS_WIDTH_16 and access_enable = '1' else
                       x"000000" & memory(word_index)(8 * (byte_index+1) - 1 downto 8 * byte_index)        when access_width = MEM_ACCESS_WIDTH_8  and access_enable = '1' else
                       x"FFFFFFFF";

    -- writing
    process(clk)
    begin
        if rising_edge(clk) then
            if access_enable = '1' and we = '1' then
                case access_width is
                    when MEM_ACCESS_WIDTH_16 =>
                        memory(word_index)(8 * halfword_index + 16 - 1 downto 8 * halfword_index) <= di(15 downto 0);
                    when MEM_ACCESS_WIDTH_32 =>
                        memory(word_index) <= di(31 downto 0);
                    when others =>
                        memory(word_index)(8 * (byte_index+1) - 1 downto 8 * byte_index) <= di(7 downto 0);
                end case;
            end if;
        end if;
    end process;

end Behavioral;