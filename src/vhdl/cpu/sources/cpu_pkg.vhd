library ieee;
use ieee.std_logic_1164.all;

package cpu_pkg is

  type REGISTER_ARRAY_t is array(0 to 31) of std_logic_vector(31 downto 0);

  type MEM_ACCESS_WIDTH_t is (
      MEM_ACCESS_WIDTH_8,
      MEM_ACCESS_WIDTH_16,
      MEM_ACCESS_WIDTH_32
  );

  type PC_NEXT_SRC_t is (
      PC_NEXT_SRC_PC_ALU_RES,
      PC_NEXT_SRC_PC_IMM,
      PC_NEXT_SRC_PC_4
  );

  type BRANCH_TYPE_t is (
      BRANCH_TYPE_NONE,
      BRANCH_TYPE_BEQ,
      BRANCH_TYPE_BNE,
      BRANCH_TYPE_BLT,
      BRANCH_TYPE_BGE
  );

  type RD_DATA_SRC_t is (
      RD_DATA_SRC_PC_IMM,
      RD_DATA_SRC_PC_4,
      RD_DATA_SRC_IMM,
      RD_DATA_SRC_ALU_RESULT,
      RD_DATA_SRC_MEM_DATA_OUT);

  type ALU_OP_TYPE_t is (
      ALU_OP_TYPE_ADD,
      ALU_OP_TYPE_SUB,
      ALU_OP_TYPE_SLT,
      ALU_OP_TYPE_SLTU,
      ALU_OP_TYPE_AND,
      ALU_OP_TYPE_OR,
      ALU_OP_TYPE_XOR,
      ALU_OP_TYPE_SLL,
      ALU_OP_TYPE_SRL,
      ALU_OP_TYPE_SRA,
      ALU_OP_TYPE_PASS
  );

  type ALU_OP_SRC_t is (
      ALU_OP_SRC_IMM,
      ALU_OP_SRC_ALU_RES,
      ALU_OP_SRC_REG,
      ALU_OP_SRC_PC_IMM,
      ALU_OP_SRC_PC_4,
      ALU_OP_SRC_RD_DATA
  );

  constant INSTR_NOP           : std_logic_vector(31 downto 0) := x"00000013"; -- ADDI x0, x0, 0

  -- Opcodes (RV32I base)
  constant INSTR_OP_LUI        : std_logic_vector(6 downto 0) := "0110111";
  constant INSTR_OP_AUIPC      : std_logic_vector(6 downto 0) := "0010111";
  constant INSTR_OP_JAL        : std_logic_vector(6 downto 0) := "1101111";
  constant INSTR_OP_JALR       : std_logic_vector(6 downto 0) := "1100111";
  constant INSTR_OP_BRANCH     : std_logic_vector(6 downto 0) := "1100011";
  constant INSTR_OP_LOAD       : std_logic_vector(6 downto 0) := "0000011";
  constant INSTR_OP_STORE      : std_logic_vector(6 downto 0) := "0100011";
  constant INSTR_OP_REG_IMM    : std_logic_vector(6 downto 0) := "0010011";
  constant INSTR_OP_REG_REG    : std_logic_vector(6 downto 0) := "0110011";
  constant INSTR_OP_FENCE      : std_logic_vector(6 downto 0) := "0001111"; -- FENCE
  constant INSTR_OP_SYSTEM     : std_logic_vector(6 downto 0) := "1110011"; -- ECALL, EBREAK

  -- Funct3
  constant INSTR_F3_ADD        : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_SUB        : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_SLL        : std_logic_vector(2 downto 0) := "001";
  constant INSTR_F3_SLT        : std_logic_vector(2 downto 0) := "010";
  constant INSTR_F3_SLTU       : std_logic_vector(2 downto 0) := "011";
  constant INSTR_F3_XOR        : std_logic_vector(2 downto 0) := "100";
  constant INSTR_F3_SRL        : std_logic_vector(2 downto 0) := "101";
  constant INSTR_F3_SRA        : std_logic_vector(2 downto 0) := "101";
  constant INSTR_F3_OR         : std_logic_vector(2 downto 0) := "110";
  constant INSTR_F3_AND        : std_logic_vector(2 downto 0) := "111";
  constant INSTR_F3_ADDI       : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_SLLI       : std_logic_vector(2 downto 0) := "001";
  constant INSTR_F3_SLTI       : std_logic_vector(2 downto 0) := "010";
  constant INSTR_F3_SLTIU      : std_logic_vector(2 downto 0) := "011";
  constant INSTR_F3_XORI       : std_logic_vector(2 downto 0) := "100";
  constant INSTR_F3_SRLI       : std_logic_vector(2 downto 0) := "101";
  constant INSTR_F3_SRAI       : std_logic_vector(2 downto 0) := "101";
  constant INSTR_F3_ORI        : std_logic_vector(2 downto 0) := "110";
  constant INSTR_F3_ANDI       : std_logic_vector(2 downto 0) := "111";
  constant INSTR_F3_LB         : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_LH         : std_logic_vector(2 downto 0) := "001";
  constant INSTR_F3_LW         : std_logic_vector(2 downto 0) := "010";
  constant INSTR_F3_LBU        : std_logic_vector(2 downto 0) := "100";
  constant INSTR_F3_LHU        : std_logic_vector(2 downto 0) := "101";
  constant INSTR_F3_SB         : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_SH         : std_logic_vector(2 downto 0) := "001";
  constant INSTR_F3_SW         : std_logic_vector(2 downto 0) := "010";
  constant INSTR_F3_BEQ        : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_BNE        : std_logic_vector(2 downto 0) := "001";
  constant INSTR_F3_BLT        : std_logic_vector(2 downto 0) := "100";
  constant INSTR_F3_BGE        : std_logic_vector(2 downto 0) := "101";
  constant INSTR_F3_BLTU       : std_logic_vector(2 downto 0) := "110";
  constant INSTR_F3_BGEU       : std_logic_vector(2 downto 0) := "111";
  constant INSTR_F3_FENCE      : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_ECALL      : std_logic_vector(2 downto 0) := "000";
  constant INSTR_F3_EBREAK     : std_logic_vector(2 downto 0) := "000";

  constant INSTR_F7_SLLI       : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SRLI       : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SRAI       : std_logic_vector(6 downto 0) := "0100000";
  constant INSTR_F7_ADD        : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SUB        : std_logic_vector(6 downto 0) := "0100000";
  constant INSTR_F7_SLL        : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SLT        : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SLTU       : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_XOR        : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SRL        : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_SRA        : std_logic_vector(6 downto 0) := "0100000";
  constant INSTR_F7_OR         : std_logic_vector(6 downto 0) := "0000000";
  constant INSTR_F7_AND        : std_logic_vector(6 downto 0) := "0000000";

end package;

package body cpu_pkg is end package body;
