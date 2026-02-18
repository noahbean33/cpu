// --------------------------------------------------------
// Data Memory - RTL (Refined, Parameterized)
// --------------------------------------------------------

import risc_pkg::*;

module data_memory #(
  parameter ADDR_WIDTH = 6,  // 2^6 = 64
  parameter DATA_WIDTH = 8    // Byte-wide RAM
)(
  input logic 				  clk,
  input  logic                dmem_req,                 
  input  logic                dmem_wr_en,               
  input mem_size_t		      dmem_data_size,           
  input  logic [31:0]         dmem_addr,                
  input  logic [31:0]         dmem_wr_data,             
  input  logic                dmem_zero_extend,         

  output logic [31:0]         dmem_rd_data              
);

  // --------------------------------------------------------
  // RAM Declaration
  // --------------------------------------------------------
  logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];
 
   // Enter your code

endmodule
