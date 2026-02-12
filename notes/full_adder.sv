// Full Adder - Dataflow Style
module full_adder (
    input  logic a,      // First input
    input  logic b,      // Second input
    input  logic cin,    // Carry in
    output logic sum,    // Sum output
    output logic cout    // Carry out
);

  // Dataflow modeling with assign statements
  assign sum  = a ^ b ^ cin;                  // XOR for sum
  assign cout = (a & b) | (b & cin) | (a & cin); // Carry logic

endmodule
