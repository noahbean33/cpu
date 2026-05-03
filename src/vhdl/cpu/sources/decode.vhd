library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

entity decode is
    port (
        instr        : in  std_logic_vector(31 downto 0);
        rs1          : out std_logic_vector(4 downto 0);
        rs2          : out std_logic_vector(4 downto 0);
        rd           : out std_logic_vector(4 downto 0);
        imm          : out std_logic_vector(31 downto 0);
        opcode       : out std_logic_vector(6 downto 0);
        funct3       : out std_logic_vector(2 downto 0);
        funct7       : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of decode is

    signal imm_j : std_logic_vector(31 downto 0);
    signal imm_u : std_logic_vector(31 downto 0);
    signal imm_s : std_logic_vector(31 downto 0);
    signal imm_b : std_logic_vector(31 downto 0);
    signal imm_i : std_logic_vector(31 downto 0);

	signal opcode_int : std_logic_vector(6 downto 0);
	
begin

    opcode_int <= instr(6 downto 0);
	opcode	<= opcode_int;
    rd     <= instr(11 downto 7);
    rs1    <= instr(19 downto 15);
    rs2    <= instr(24 downto 20);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

    imm_u(31 downto 12) <= instr(31 downto 12);
    imm_u(11 downto 0)  <= (others => '0');

    imm_j(0)            <= '0';
    imm_j(10 downto 1)  <= instr(30 downto 21);
    imm_j(11)           <= instr(20);
    imm_j(19 downto 12) <= instr(19 downto 12);
    imm_j(31 downto 20) <= (others => instr(31));

    imm_i(10 downto 0)  <= instr(30 downto 20);
    imm_i(31 downto 11) <= (others => instr(31));

    imm_b(0)            <= '0';
    imm_b(4 downto 1)   <= instr(11 downto 8);
    imm_b(10 downto 5)  <= instr(30 downto 25);
    imm_b(11)           <= instr(7);
    imm_b(31 downto 12) <= (others => instr(31));

    imm_s(4 downto 0)   <= instr(11 downto 7);
    imm_s(10 downto 5)  <= instr(30 downto 25);
    imm_s(31 downto 11) <= (others => instr(31));

    imm <=  imm_u when opcode_int = INSTR_OP_LUI or opcode_int = INSTR_OP_AUIPC                                 else
            imm_j when opcode_int = INSTR_OP_JAL                                                                else
            imm_i when opcode_int = INSTR_OP_JALR or opcode_int = INSTR_OP_LOAD or opcode_int = INSTR_OP_REG_IMM    else
            imm_b when opcode_int = INSTR_OP_BRANCH                                                         else
            imm_s when opcode_int = INSTR_OP_STORE                                                          else
            (others => '0');


end architecture;
