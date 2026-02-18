// --------------------------------------------------------
// Decode - RTL (Refined)
// --------------------------------------------------------
import risc_pkg::*;

module decode(
  input  logic [31:0]  instruction,  // 32-bit instruction from IF stage

  // Decoded fields
  output logic [4:0]   rs1_addr,
  output logic [4:0]   rs2_addr,
  output logic [4:0]   rd_addr,
  output logic [6:0]   opcode,
  output logic [2:0]   funct3,
  output logic [6:0]   funct7,
  output logic         r_type,
  output logic         i_type,
  output logic         s_type,
  output logic         b_type,
  output logic         u_type,
  output logic         j_type,
  output logic [31:0]  immediate         // Final immediate value
);

  // Enter your code

endmodule

