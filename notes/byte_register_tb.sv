`timescale 1ns/1ps

module byte_register_tb;

  // DUT I/O
  logic       clk;
  logic       reset_n;
  logic       load;
  logic       inc;
  logic       rotate_right;
  logic [7:0] D;
  logic [7:0] Q;

  int errors = 0;
  logic [7:0] prev, exp;

  // Clock: 10ns period
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // Instantiate DUT
  byte_register dut (
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .inc(inc),
    .rotate_right(rotate_right),
    .D(D),
    .Q(Q)
  );

  initial begin
    // Defaults
    reset_n = 1'b1;
    load = 1'b0; inc = 1'b0; rotate_right = 1'b0;
    D = 8'h00;

    // -------- Asynchronous reset (low-active) --------
    #1; reset_n = 1'b0; #1;                     // assert
    if (Q !== 8'h00) errors++;
    reset_n = 1'b1; @(negedge clk);             // deassert
    if (Q !== 8'h00) errors++;

    // -------- LOAD --------
    D = 8'hA5; load = 1'b1; @(negedge clk); load = 1'b0;
    if (Q !== 8'hA5) errors++;

    // -------- INC --------
    inc = 1'b1; @(negedge clk); inc = 1'b0;
    if (Q !== 8'hA6) errors++;                  // 0xA5 + 1 = 0xA6

    // -------- ROTATE RIGHT (circular) --------
    prev = Q;
    rotate_right = 1'b1; @(negedge clk); rotate_right = 1'b0;
    exp = {prev[0], prev[7:1]};
    if (Q !== exp) errors++;

    // -------- HOLD (no enables) --------
    prev = Q; @(negedge clk);
    if (Q !== prev) errors++;

    // -------- Priority: load over inc --------
    D = 8'h3C; load = 1'b1; inc = 1'b1; @(negedge clk);
    load = 1'b0; inc = 1'b0;
    if (Q !== 8'h3C) errors++;

    // -------- Priority: inc over rotate_right --------
    prev = Q; inc = 1'b1; rotate_right = 1'b1; @(negedge clk);
    inc = 1'b0; rotate_right = 1'b0;
    if (Q !== (prev + 8'd1)) errors++;

    // -------- Async reset mid-cycle (no clock edge needed to clear) --------
    prev = Q; #2; reset_n = 1'b0; #1;
    if (Q !== 8'h00) errors++;
    reset_n = 1'b1; @(negedge clk);
    if (Q !== 8'h00) errors++;

    // -------- Summary --------
    if (errors == 0) $display("TEST PASSED");
    else             $display("TEST FAILED -- %0d errors", errors);

    $finish;
  end

endmodule
