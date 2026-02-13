
module tx_rom #(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=2)
(
    input logic [(ADDR_WIDTH-1):0] addr,  // Address input
    input logic clk,                      // Clock input
    input logic read,                     // Read control input
    output logic [(DATA_WIDTH-1):0] q // Data output
);

    // Declare the ROM variable
    logic [DATA_WIDTH-1:0] rom [0:2**ADDR_WIDTH-1];

    initial begin
        $readmemh("memory.list", rom); // Initialize ROM with data from memory.list file
    end

	//////// Add your code here ///////////

endmodule


