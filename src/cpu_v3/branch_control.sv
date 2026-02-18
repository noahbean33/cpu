// --------------------------------------------------------
// Branch Control - RTL (Refined)
// --------------------------------------------------------
import risc_pkg::*;

module branch_control (
  // Operands to compare
  input  logic [31:0] opr_a,
  input  logic [31:0] opr_b,

  // Branch instruction info
  input  logic        is_b_type,
  input  logic [2:0]  funct3,

  // Result: branch taken?
  output logic        branch_taken
);
 
  // Enter your code

endmodule
