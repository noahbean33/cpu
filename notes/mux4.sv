//===========================================================
// Module: mux4
// Description: 4-to-1 Multiplexer
// Complete the code below the "add your code here" lines
// Use an always_comb block or assign statements
//===========================================================

module mux4(
  input  logic S1, S0,
  input  logic X0, X1, X2, X3,
  output logic Q
);

always_comb begin
if (!S1 && !S0) Q = X0;
else if (!S1 && S0) Q = x1;
else if (S1 && !S0) Q = X2;
else Q = X3;
end        


endmodule



