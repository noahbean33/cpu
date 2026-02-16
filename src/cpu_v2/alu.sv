// --------------------------------------------------------
// ALU - RTL (Refined, no $signed, proper default placement)
// --------------------------------------------------------
import risc_pkg::*;

module alu (
  // Operands
  input  logic [31:0] alu_a,   // ALU input A
  input  logic [31:0] alu_b,   // ALU input B

  // Operation selector
  input  alu_op_t     alu_op,      // ALU operation from risc_pkg

  // Result
  output logic [31:0] alu_res       // ALU output
);

  // Enter your code

endmodule
