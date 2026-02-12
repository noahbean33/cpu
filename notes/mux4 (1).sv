module mux4(
  input  logic S1, S0,
  input  logic X0, X1, X2, X3,
  output logic Q
);
  always_comb begin
    case ({S1, S0})      
      2'b00: Q = X0;
      2'b01: Q = X1;
      2'b10: Q = X2;
      2'b11: Q = X3;
    endcase
  end
endmodule
