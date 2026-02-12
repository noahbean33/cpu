// Full Adder - Behavioral Style
module full_adder_behavioral (
    input  logic a,      // First input
    input  logic b,      // Second input
    input  logic cin,    // Carry in
    output logic sum,    // Sum output
    output logic cout    // Carry out
);

    always_comb begin
        // Behavioral description using procedural block
        {cout, sum} = a + b + cin;
    end

endmodule