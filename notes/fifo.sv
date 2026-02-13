module fifo #(
    parameter int ADDR_WIDTH = 3,
    parameter int DATA_WIDTH = 8
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   push,
    input  logic                   pop,
    input  logic [DATA_WIDTH-1:0]  wr_data,
    output logic                   full,
    output logic                   empty,
    output logic [DATA_WIDTH-1:0]  rd_data
);

// ---------------------------------------------------------
// Local parameters and internal declarations
// ---------------------------------------------------------
logic [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];
logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;          // pointers
logic                  wrote_flag;              // last operation was write or read

// ---------------------------------------------------------
// Status Flags
// ---------------------------------------------------------
assign empty = (wr_ptr == rd_ptr) && !wrote_flag;
assign full  = (wr_ptr == rd_ptr) &&  wrote_flag;

// ---------------------------------------------------------
// Sequential Logic
// ---------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr     <= '0;
        rd_ptr     <= '0;
        wrote_flag <= 1'b0;
        rd_data    <= '0;
    end
    else begin
        // Read Operation
        if (pop && !empty) begin
            rd_data    <= mem[rd_ptr];
            rd_ptr     <= rd_ptr + 1;
            wrote_flag <= 1'b0;
        end

        // Write Operation
        if (push && !full) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr      <= wr_ptr + 1;
            wrote_flag  <= 1'b1;
        end
    end
end

endmodule