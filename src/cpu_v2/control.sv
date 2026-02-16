// --------------------------------------------------------
// Control Unit - RTL (Aligned with refined risc_pkg)
// --------------------------------------------------------
import risc_pkg::*;

module control (
  // Instruction type flags
  input  logic       r_type,
  input  logic       i_type,
  input  logic       s_type,
  input  logic       b_type,
  input  logic       u_type,
  input  logic       j_type,

  // Instruction fields
  input  logic [2:0] funct3,
  input  logic [6:0] funct7,
  input  logic [6:0] opcode,

  // Outputs
  output logic        pc_sel,
  output logic        op1_sel,
  output logic        op2_sel,
  output alu_op_t	  alu_op,
  output wb_src_t	  rf_wr_data_sel,
  output logic        dmem_req,
  output mem_size_t   dmem_size,
  output logic        dmem_wr_en,
  output logic        dmem_zero_extend,
  output logic        rf_wr_en
);

   // Enter your code

endmodule
