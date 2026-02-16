// --------------------------------------------------------
// Instruction Memory - RTL (Parameterized)
// --------------------------------------------------------

module instruction_memory #(
	parameter ADDR_WIDTH = 7,                      // Address bits (2^7 = 128 depth)
	parameter DATA_WIDTH = 8                       // Data width per memory cell
)(
  input  logic             imem_req,               // Read enable
  input  logic [31:0]      imem_addr,              // Byte address (word-aligned)
  output logic [31:0]      imem_data               // Output instruction
);

  // --------------------------------------------------------
  // Memory Declaration (ROM)
  // --------------------------------------------------------
  logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

  initial begin
	$readmemh("machine_code.mem", mem); // Initialize ROM with data from memory.list file
  end
  
   // Enter your code

endmodule


