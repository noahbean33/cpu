-- ============================================
-- Module: ALU (RV32I)
-- ============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

entity alu is
    port (
        op1     : in  std_logic_vector(31 downto 0);
        op2     : in  std_logic_vector(31 downto 0);
        ALUop   : in  ALU_OP_TYPE_t;
        result  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of alu is

begin

    process(op1, op2, ALUop)
    begin
        case ALUop is
            when ALU_OP_TYPE_ADD =>
                result <= std_logic_vector(unsigned(op1) + unsigned(op2));

            when ALU_OP_TYPE_PASS =>
                result <= op2;

            when ALU_OP_TYPE_SUB =>
                result <= std_logic_vector(unsigned(op1) - unsigned(op2));

            when ALU_OP_TYPE_AND =>
                result <= op1 and op2;

            when ALU_OP_TYPE_OR =>
                result <= op1 or op2;

            when ALU_OP_TYPE_XOR =>
                result <= op1 xor op2;

            when ALU_OP_TYPE_SLL =>
                result <= std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))));

            when ALU_OP_TYPE_SRL =>
                result <= std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))));

            when ALU_OP_TYPE_SRA =>
                result <= std_logic_vector(shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0)))));

            when ALU_OP_TYPE_SLT =>
                if signed(op1) < signed(op2) then
                    result <= x"00000001";
                else
                    result <= x"00000000";
                end if;

            when ALU_OP_TYPE_SLTU =>
                if unsigned(op1) < unsigned(op2) then
                    result <= x"00000001";
                else
                    result <= x"00000000";
                end if;

            when others =>
                result <= (others => '0');
        end case;
    end process;
end architecture;

