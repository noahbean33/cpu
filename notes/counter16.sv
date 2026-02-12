// ------------------------------------------------------------
// 16-bit counter composed of two 8-bit registers.
// - Low byte increments when inc=1
// - High byte increments only when low byte overflows (q_lo==8'hFF)
// ------------------------------------------------------------

//=============================================================
// Module: counter16
// Description: Implement counter16 using two 8-bit registers
// Complete the code below the "add your code here" lines
//=============================================================

module counter16 (
  input  logic       clk,
  input  logic       reset_n,
  input  logic       inc,
  output logic [15:0] Q
);

 //////// Add your code here ///////////

endmodule

