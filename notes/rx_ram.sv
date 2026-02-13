
module rx_ram #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=2)(
    // Module ports
    input logic [(DATA_WIDTH-1):0] data,    // Data input for write operation
    input logic[(ADDR_WIDTH-1):0] addr,    // Address input for read and write operations
    input logic we,                        // Write enable input
    input logic clk,                       // Clock input for synchronous operation
    output logic [(DATA_WIDTH-1):0] q  // Data output for read operation
);

    // Declare the RAM variable
    logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];

   //////// Add your code here /////////// 
    end

endmodule


