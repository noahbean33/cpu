library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

entity regfile is
    port (
        clk            : in  std_logic;
        resetn         : in  std_logic;
        RegWrite       : in  std_logic;
        rs1_addr       : in  std_logic_vector(4 downto 0); -- I[19:15]
        rs2_addr       : in  std_logic_vector(4 downto 0); -- I[24:20]
        rd_addr        : in  std_logic_vector(4 downto 0); -- I[11:7]
        rd_data        : in  std_logic_vector(31 downto 0);
        rs1_data       : out std_logic_vector(31 downto 0);
        rs2_data       : out std_logic_vector(31 downto 0);
        trace_regs     : out REGISTER_ARRAY_t
    );
end entity;

architecture rtl of regfile is

    signal regs : REGISTER_ARRAY_t := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
			if resetn = '0' then
				regs <= (others => (others => '0'));
			else
                if (RegWrite = '1') and (rd_addr /= "00000") then
                    regs(to_integer(unsigned(rd_addr))) <= rd_data;
                end if;
            end if;
        end if;
    end process;

    rs1_data <= (others => '0') when rs1_addr = "00000" else regs(to_integer(unsigned(rs1_addr)));
    rs2_data <= (others => '0') when rs2_addr = "00000" else regs(to_integer(unsigned(rs2_addr)));

    trace_regs <= regs;

end architecture;
