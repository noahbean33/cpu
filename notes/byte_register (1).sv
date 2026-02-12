module byte_register (
  input  logic       clk,
  input  logic       reset_n,       // Active-low async reset
  input  logic       load,          // Load enable
  input  logic       inc,           // Increment enable
  input  logic       rotate_right,  // Rotate-right enable
  input  logic [7:0] D,             // Data input
  output logic [7:0] Q              // Register output
);

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      Q <= 8'b0;                    // Asynchronous reset
    end else if (load) begin
      Q <= D;                       // Load has highest priority
    end else if (inc) begin
      Q <= Q + 8'd1;                // Increment by 1
    end else if (rotate_right) begin
      Q <= {Q[0], Q[7:1]};          // Circular rotate right
    end else begin
      Q <= Q;                       // Hold value
    end
  end

endmodule
