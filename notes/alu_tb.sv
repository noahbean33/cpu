`timescale 1ns/1ps

module alu_tb;

  // DUT I/O
  logic [7:0] a, b;
  logic       cin;
  logic [2:0] op;
  logic [7:0] y;
  logic       cout;

  int errors = 0;

  // Instantiate DUT
  alu dut (
    .a(a), .b(b), .cin(cin),
    .op(op),
    .y(y), .cout(cout)
  );

  initial begin
    // ---------- AND ----------
    a=8'hA5; b=8'h3C; cin=1'b0; op=3'b000; #1;
    if (y!== (8'hA5 & 8'h3C) || cout!==1'b0) errors++;

    // ---------- OR ----------
    a=8'hA5; b=8'h3C; cin=1'b0; op=3'b001; #1;
    if (y!== (8'hA5 | 8'h3C) || cout!==1'b0) errors++;

    // ---------- COMP (~a) ----------
    a=8'h55; b=8'h00; cin=1'b0; op=3'b010; #1;
    if (y!== ~8'h55 || cout!==1'b0) errors++;

    // ---------- RRC (rotate right through carry) ----------
    // a=0x01, cin=0 -> y=0x00, cout=1
    a=8'h01; b='0; cin=1'b0; op=3'b011; #1;
    if (y!==8'h00 || cout!==1'b1) errors++;
    // a=0x5A, cin=1 -> y=0xAD, cout=0
    a=8'h5A; b='0; cin=1'b1; op=3'b011; #1;
    if (y!==8'hAD || cout!==1'b0) errors++;

    // ---------- RLC (rotate left through carry) ----------
    // a=0x81, cin=0 -> y=0x02, cout=1
    a=8'h81; b='0; cin=1'b0; op=3'b100; #1;
    if (y!==8'h02 || cout!==1'b1) errors++;
    // a=0x01, cin=1 -> y=0x03, cout=0
    a=8'h01; b='0; cin=1'b1; op=3'b100; #1;
    if (y!==8'h03 || cout!==1'b0) errors++;

    // ---------- ADD with carry ----------
    // 0x14 + 0x27 + 0 -> 0x3B, carry=0
    a=8'h14; b=8'h27; cin=1'b0; op=3'b101; #1;
    if (y!==8'h3B || cout!==1'b0) errors++;
    // 0xFF + 0x01 + 0 -> 0x00, carry=1
    a=8'hFF; b=8'h01; cin=1'b0; op=3'b101; #1;
    if (y!==8'h00 || cout!==1'b1) errors++;

    // ---------- SUB with borrow ----------
    // NOTE: This ALU sets cout=1 when a borrow occurs (from the 9th bit).
    // 0x10 - 0x01 - 0 -> 0x0F, no borrow => cout=0
    a=8'h10; b=8'h01; cin=1'b0; op=3'b110; #1;
    if (y!==8'h0F || cout!==1'b0) errors++;
    // 0x00 - 0x01 - 0 -> 0xFF, borrow => cout=1
    a=8'h00; b=8'h01; cin=1'b0; op=3'b110; #1;
    if (y!==8'hFF || cout!==1'b1) errors++;

    // ---------- MOVE ----------
    a=8'hAA; b=8'h5C; cin=1'b0; op=3'b111; #1;
    if (y!==8'h5C || cout!==1'b0) errors++;

    // Final summary
    if (errors==0) $display("TEST PASSED");
    else           $display("TEST FAILED -- %0d errors", errors);

    $finish;
  end

endmodule
