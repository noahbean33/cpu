library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.cpu_pkg.all;

entity cpu is
  port (
    clk                : in  std_logic;
    resetn             : in  std_logic;

    imem_ready         : in  std_logic;
    imem_valid         : out std_logic;
    imem_addr          : out std_logic_vector(31 downto 0);
    imem_rdata         : in  std_logic_vector(31 downto 0);

    dmem_ready         : in  std_logic;
    dmem_valid         : out std_logic;
    dmem_addr          : out std_logic_vector(31 downto 0);
    dmem_write_enable  : out std_logic;
    dmem_access_width  : out MEM_ACCESS_WIDTH_t;
    dmem_wdata         : out std_logic_vector(31 downto 0);
    dmem_rdata         : in  std_logic_vector(31 downto 0);

    trace_regs         : out REGISTER_ARRAY_t
  );
end entity;

architecture rtl of cpu is

  -- Decoder
  signal instruction      : std_logic_vector(31 downto 0);
  signal rs1_addr         : std_logic_vector(4 downto 0);
  signal rs2_addr         : std_logic_vector(4 downto 0);
  signal rd_addr          : std_logic_vector(4 downto 0);
  signal imm              : std_logic_vector(31 downto 0);
  signal opcode           : std_logic_vector(6 downto 0);
  signal funct3           : std_logic_vector(2 downto 0);
  signal funct7           : std_logic_vector(6 downto 0);
  -- Regfile
  signal rs1_data         : std_logic_vector(31 downto 0);
  signal rs2_data         : std_logic_vector(31 downto 0);
  signal rd_data          : std_logic_vector(31 downto 0);
  -- ALU
  signal op1              : std_logic_vector(31 downto 0);
  signal op2              : std_logic_vector(31 downto 0);
  signal alu_result       : std_logic_vector(31 downto 0);
  -- Control Unit
  signal take_branch      : std_logic;
  signal jump             : std_logic;
  signal alu_use_imm      : std_logic;
  signal write_mem        : std_logic;
  signal write_rd         : std_logic;
  signal rd_data_src      : RD_DATA_SRC_t;
  signal ALUop            : ALU_OP_TYPE_t;
  signal MemToReg         : RD_DATA_SRC_t;
  -- Program Counter
  signal pc_imm           : std_logic_vector(31 downto 0);
  signal pc_4             : std_logic_vector(31 downto 0);
  signal pc               : std_logic_vector(31 downto 0);
  signal pc_next          : std_logic_vector(31 downto 0);
  signal pc_next_sel      : PC_NEXT_SRC_t;
  -- Memory
  signal mem_data         : std_logic_vector(31 downto 0);
  signal mem_access       : std_logic;
  signal mem_access_width : MEM_ACCESS_WIDTH_t;
  -- Stall
  signal enable           : std_logic;


begin

  decoder_inst: entity work.decode
    port map (
      instr            => instruction,
      rs1              => rs1_addr,
      rs2              => rs2_addr,
      rd               => rd_addr,
      imm              => imm,
      opcode           => opcode,
      funct3           => funct3,
      funct7           => funct7
    );

  control_unit_inst: entity work.control_unit
    port map (
      opcode           => opcode,
      funct3           => funct3,
      funct7           => funct7,
      alu_result       => alu_result,
      alu_use_imm      => alu_use_imm,
      write_rd         => write_rd,
      write_mem        => write_mem,
      take_branch      => take_branch,
      rd_data_src      => rd_data_src,
      jump             => jump,
      ALUop            => ALUop,
      mem_access       => mem_access,
      mem_access_width => mem_access_width
    );

  regfile_inst: entity work.regfile
    port map (
      resetn           => resetn,
      clk              => clk,
      RegWrite         => write_rd,
      rs1_addr         => rs1_addr,
      rs2_addr         => rs2_addr,
      rd_addr          => rd_addr,
      rd_data          => rd_data,
      rs1_data         => rs1_data,
      rs2_data         => rs2_data,
      trace_regs       => trace_regs
    );

  op1 <= rs1_data;
  op2 <= imm when alu_use_imm = '1' else rs2_data;

  alu_inst: entity work.alu
    port map (
      op1    => op1,
      op2    => op2,
      ALUop  => ALUop,
      result => alu_result
    );


  pc_imm <= std_logic_vector(unsigned(pc) + unsigned(imm));
  pc_4   <= std_logic_vector(unsigned(pc) + 4);

  pc_next_sel <=  PC_NEXT_SRC_PC_ALU_RES    when    (jump = '1' and opcode = INSTR_OP_JALR) else
                  PC_NEXT_SRC_PC_IMM        when    (jump = '1' and opcode = INSTR_OP_JAL)
                                                 or (take_branch = '1')                     else
                  PC_NEXT_SRC_PC_4;

  pc_next <=  alu_result(31 downto 1) & '0' when pc_next_sel = PC_NEXT_SRC_PC_ALU_RES else
              pc_imm                        when pc_next_sel = PC_NEXT_SRC_PC_IMM     else
              pc_4;

  with rd_data_src select
      rd_data <=  imm                       when RD_DATA_SRC_IMM,
                  mem_data                  when RD_DATA_SRC_MEM_DATA_OUT,
                  pc_4                      when RD_DATA_SRC_PC_4,
                  pc_imm                    when RD_DATA_SRC_PC_IMM,
                  alu_result                when others;


  -- I/D Memory access
  --------------------------------------------------------------------
  imem_valid          <= '1';
  imem_addr           <= pc;
  instruction         <= imem_rdata;

  dmem_valid          <= mem_access;
  dmem_addr           <= alu_result;
  dmem_wdata          <= rs2_data;
  dmem_write_enable   <= write_mem;
  dmem_access_width   <= mem_access_width;

  mem_data <= std_logic_vector(resize(signed(dmem_rdata(15 downto 0)), 32))   when (opcode = INSTR_OP_LOAD and funct3 = INSTR_F3_LH)  else
              std_logic_vector(resize(signed(dmem_rdata(7 downto 0)), 32))    when (opcode = INSTR_OP_LOAD and funct3 = INSTR_F3_LB)  else
              dmem_rdata;

  enable <= imem_ready and ((not mem_access) or dmem_ready);

  process(clk)
  begin
    if rising_edge(clk) then
      if resetn = '0' then
        pc <= (others => '0');
      else
        if enable = '1' then
          pc <= pc_next;
        end if;
      end if;
    end if;
  end process;

end architecture;
