`timescale 1ns/1ps

module mealy_1101_tb;

  // DUT I/O
  logic clk;
  logic rst_n;
  logic x;
  logic z;

  // Self-checking
  int   errors = 0;
  int   i;
  logic [3:0] hist;   // previous 3 bits history
  logic       exp_z;

  // 10 ns clock
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // DUT
  mealy_1101 dut (
    .clk  (clk),
    .rst_n(rst_n),
    .x    (x),
    .z    (z)
  );

  // Fixed directed sequence with overlaps: "1101 1101 00 1101"
  localparam int N = 14;
  logic pattern [0:N-1] = '{
    1,1,0,1,
    1,1,0,1,
    0,0,
    1,1,0,1
  };

  initial begin
    // Reset
    x = 1'b0; hist = 4'b0000;
    rst_n = 1'b0;
    @(posedge clk);
    @(posedge clk);
    #2 rst_n = 1'b1;

    // Drive and check on NEGEDGE (Mealy output valid here)
    for (i = 0; i < N; i++) begin
      @(negedge clk);
      x = pattern[i];
      #1; // allow combinational settle

      // Mealy: z = 1 when {last3, current} == 1101
      exp_z = ({hist[2:0], x} == 4'b1101);
      if (z !== exp_z) begin
        $display("FAIL i=%0d: x=%0b hist=%04b  z=%0b exp=%0b",
                 i, x, hist, z, exp_z);
        errors++;
      end

      // update history; state will advance on the coming posedge
      hist = {hist[2:0], x};

      @(posedge clk); // advance state
    end

    // Summary
    if (errors == 0) $display("TEST PASSED");
    else             $display("TEST FAILED -- %0d mismatches", errors);

    $finish;
  end

endmodule
