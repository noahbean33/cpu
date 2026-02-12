

module fifo #(
  parameter int ADDR_WIDTH = 3,              
  parameter int DATA_WIDTH = 8               
)(
  input  logic              	 clk,
  input  logic                 	 rst_n,     
  input  logic              	 push,       
  input  logic             	 	 pop,        
  input  logic [DATA_WIDTH-1:0]  wr_data,    
  output logic               	 full,       
  output logic              	 empty,      
  output logic [DATA_WIDTH-1:0]  rd_data     
);

 // Write your code here
  
endmodule
