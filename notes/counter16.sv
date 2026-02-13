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
    input  logic        clk,
    input  logic        reset_n,
    input  logic        inc,
    output logic [15:0] Q
);

    logic [7:0] q_lo, q_hi;
    assign Q = {q_hi, q_lo};

    // Carry from low byte when incrementing and q_lo is all 1s
    logic carry_lo;
    assign carry_lo = inc & (&q_lo);  // (&q_lo) is reduction-AND

    // Low byte: increment when inc = 1
    byte_register reg_lo (
        .clk          (clk),
        .reset_n      (reset_n),
        .load         (1'b0),
        .inc          (inc),
        .rotate_right (1'b0),
        .D            (8'h00),
        .Q            (q_lo)
    );

    // High byte: increment only when low byte overflows
    byte_register reg_hi (
        .clk          (clk),
        .reset_n      (reset_n),
        .load         (1'b0),
        .inc          (carry_lo),
        .rotate_right (1'b0),
        .D            (8'h00),
        .Q            (q_hi)
    );

endmodule