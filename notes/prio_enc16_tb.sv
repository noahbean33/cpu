`timescale 1ns/1ps

module prio_enc16_tb;

  // DUT ports
  logic A0,  A1,  A2,  A3;
  logic A4,  A5,  A6,  A7;
  logic A8,  A9,  A10, A11;
  logic A12, A13, A14, A15;
  logic V;
  logic Q3, Q2, Q1, Q0;

  int error_count = 0;

  // Instantiate DUT
  prio_enc16 dut (
    .A0(A0), .A1(A1), .A2(A2), .A3(A3),
    .A4(A4), .A5(A5), .A6(A6), .A7(A7),
    .A8(A8), .A9(A9), .A10(A10), .A11(A11),
    .A12(A12), .A13(A13), .A14(A14), .A15(A15),
    .V(V), .Q3(Q3), .Q2(Q2), .Q1(Q1), .Q0(Q0)
  );

  initial begin
    // T1: none set -> V=0, code=0000
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h0000; #5;
    if (V !== 1'b0 || {Q3,Q2,Q1,Q0} !== 4'b0000) error_count++;

    // T2: A0 -> index 0 -> V=1, 0000
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h0001; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b0000) error_count++;

    // T3: A3 -> index 3 -> V=1, 0011
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h0008; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b0011) error_count++;

    // T4: A4 -> index 4 -> V=1, 0100
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h0010; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b0100) error_count++;

    // T5: A7 -> index 7 -> V=1, 0111
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h0080; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b0111) error_count++;

    // T6: A9 -> index 9 -> V=1, 1001
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h0200; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b1001) error_count++;

    // T7: A15 -> index 15 -> V=1, 1111
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h8000; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b1111) error_count++;

    // T8: multiple set (A13 & A5) -> highest=13 -> V=1, 1101
    {A15,A14,A13,A12,A11,A10,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0} = 16'h2020; #5;
    if (V !== 1'b1 || {Q3,Q2,Q1,Q0} !== 4'b1101) error_count++;

    // Final summary
    if (error_count == 0) $display("TEST PASSED");
    else                  $display("TEST FAILED -- %0d errors", error_count);

    $finish;
  end

endmodule
