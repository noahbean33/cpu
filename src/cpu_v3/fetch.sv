// --------------------------------------------------------
// Fetch - RTL (Refined)
// --------------------------------------------------------

module fetch (
  input  logic         clk,
  input  logic         reset_n,

  input  logic [31:0]  pc,               // Program Counter input

  output logic         imem_req,    // Instruction memory request
  output logic [31:0]  imem_addr,   // Address to instruction memory

  input  logic [31:0]  imem_data,        // Data read from memory
  output logic [31:0]  instruction       // Decoded instruction
);

   // Enter your code

endmodule


