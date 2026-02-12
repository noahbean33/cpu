module prio_enc4 (
  input  logic A0, A1, A2, A3, // A3 highest priority
  output logic V,              // valid output
  output logic Q1, Q0          // encoded index
);

  always_comb begin
    // Default
    Q1 = 1'b0;
    Q0 = 1'b0;
    V  = 1'b0;

    // Priority logic (A3 highest)
    if (A3) begin
      Q1 = 1'b1; 
      Q0 = 1'b1; 
      V  = 1'b1;
    end 
    else if (A2) begin
      Q1 = 1'b1; 
      Q0 = 1'b0; 
      V  = 1'b1;
    end 
    else if (A1) begin
      Q1 = 1'b0; 
      Q0 = 1'b1; 
      V  = 1'b1;
    end 
    else if (A0) begin
      Q1 = 1'b0; 
      Q0 = 1'b0; 
      V  = 1'b1;
    end
  end

endmodule
