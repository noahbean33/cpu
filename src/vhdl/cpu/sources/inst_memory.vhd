library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.memory_pkg.all;

entity inst_memory is
  port (
    en        : in  std_logic;
    addr      : in  std_logic_vector(31 downto 0);
    data      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of inst_memory is

  signal memory                 : INSTRUCTION_MEMORY_ARRAY_t := INSTRUCTION_MEMORY_CONTENT;

  signal word_index             : integer;
  signal access_enable          : std_logic;

begin

    word_index <= to_integer(unsigned(addr(31 downto 2)));

    access_enable <= '0' when word_index >= INSTRUCTION_MEMORY_SIZE_WORDS or addr(1 downto 0) /= "00" else en;

    data <= memory(word_index) when access_enable = '1' else x"00000013";


end architecture;
