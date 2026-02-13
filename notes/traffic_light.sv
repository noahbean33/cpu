module traffic_light (
    input  logic clk,
    input  logic rst_n,
    output logic red,
    output logic green,
    output logic yellow
);

  // States
  typedef enum { S1_RED, S2_GREEN, S3_YELLOW } state_t;
  state_t state, next;

  logic [4:0] timer; // counts cycles

  // State register and timer
  always_ff @(posedge clk or negedge rst_n) begin
   
   // Write your code here
   
  end

  // Next-state logic
  always_comb begin
     
   // Write your code here
   
  end

  // Moore outputs
  always_comb begin
     
   // Write your code here
   
  end

endmodule




