//===========================================================
// Module: single_port_ram
// Description: Implement single_port_ram
// Complete the code below the "Add your code here" sections
//===========================================================

module single_port_ram #(
  parameter ADDR_WIDTH = 4,
  parameter DATA_WIDTH = 8
)(
  input  logic                   clk,
  input  logic                   we,       
  input  logic [ADDR_WIDTH-1:0]  addr,
  input  logic [DATA_WIDTH-1:0]  din,
  output logic [DATA_WIDTH-1:0]  dout
);

//////// Add your code here ///////////

endmodule

