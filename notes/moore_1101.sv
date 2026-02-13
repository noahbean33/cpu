//===========================================================
// Module: moore_1101
// Description: Implement Moore FSM "1101" sequence detector
//   Tips:
//     - Moore = output depends on {state only}; z changes on clock edges
//     - Detection is **one cycle later** than Mealy (z asserted in a DETECT state)
//     - Allow overlaps (e.g., 1101101 has two detections)
//     - Use async active-low reset to S0
// Complete the code below the "Add your code here" sections
//===========================================================

module moore_1101 (
  input  logic clk,
  input  logic rst_n,   // active-low reset
  input  logic x,       // serial input bit
  output logic z        // Moore output: 1 when "1101" was seen (1 cycle later)
);

  typedef enum logic [2:0] { S0, S1, S2, S3, S4 } state_e;
  
  state_e state, next;

   //////// Add your code here ///////////

endmodule

