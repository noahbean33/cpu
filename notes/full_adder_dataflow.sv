
// Full Adder - Dataflow Style

module full_adder_dataflow (
    input  logic a,      // First input
    input  logic b,      // Second input
    input  logic cin,    // Carry in
    output logic sum,    // Sum output
    output logic cout    // Carry out
);


assign sum = a ^ b ^ cin;
assign cout = (a & b) | (a & cin) | (b & cin);

endmodule


