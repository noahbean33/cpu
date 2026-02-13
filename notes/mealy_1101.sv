//===========================================================
// Module: mealy_1101
// Description: Implement Mealy FSM "1101" sequence detector
// Tips:
//     - Mealy = output depends on {state + input}, so z can change between clocks
//     - Use async active-low reset to S0
//     - Allow overlaps (e.g., 1101101 -> two detections)
// Complete the code below the "add your code here" lines
//===========================================================

module mealy_1101 (
  input  logic clk,
  input  logic rst_n,     
  input  logic x,         
  output logic z          
);

  typedef enum logic [1:0] { S0, S1, S2, S3 } state_e;
  state_e state, next; // state registers

  //////// Add your code here ///////////

endmodule

