`timescale 1ns/1ps

module moore_1101_tb;

  // DUT I/O
  logic clk;
  logic rst_n;
  logic x;
  logic z;

  // Self-checking
  int   errors = 0;
  int   i;
  logic [3:0] hist;   // last 3 bits (hist[2:0]) + current x for expected
  logic       exp_z;

  // 10 ns clock
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // DUT
  moore_1101 dut (
    .clk  (clk),
    .rst_n(rst_n),
    .x    (x),
    .z    (z)
  );

  // Fixed pattern with overlaps: "1101 1101 00 1101"
  localparam int N = 14;
  logic pattern [0:N-1] = '{
    1,1,0,1,
    1,1,0,1,
    0,0,
    1,1,0,1
  };

  initial begin
    // Reset
    x = 1'b0;
    hist = 4'b0000;
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    #2 rst_n = 1'b1;

    // Drive x on negedge, sample z on posedge (Moore output valid after edge)
    for (i = 0; i < N; i++) begin
      @(negedge clk);
      x = pattern[i];

      @(posedge clk); #1;
      exp_z = ({hist[2:0], x} == 4'b1101); // Moore: z=1 in the cycle we enter S4
      if (z !== exp_z) begin
        $display("FAIL i=%0d: x=%0b hist=%04b  z=%0b exp=%0b",
                  i, x, hist, z, exp_z);
        errors++;
      end

      // Update history after sampling
      hist = {hist[2:0], x};
    end

    // Summary
    if (errors == 0) $display("TEST PASSED");
    else             $display("TEST FAILED -- %0d mismatches", errors);

    $finish;
  end

endmodule
