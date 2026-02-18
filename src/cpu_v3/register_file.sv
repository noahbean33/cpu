
// --------------------------------------------------------
// Register File - RTL (Refined)
// --------------------------------------------------------
module register_file (
  input  logic         clk,
  input  logic         reset_n,

  // Read register addresses
  input  logic [4:0]   rs1_addr,
  input  logic [4:0]   rs2_addr,

  // Write port
  input  logic [4:0]   rd_addr,
  input  logic         rf_wr_en,
  input  logic [31:0]  wr_data,

  // Read data outputs
  output logic [31:0]  rs1_data,
  output logic [31:0]  rs2_data
);

  // --------------------------------------------------------
  // Register file: 32 x 32-bit registers
  // --------------------------------------------------------
  logic [31:0] regs [0:31];

   // Enter your code

endmodule

