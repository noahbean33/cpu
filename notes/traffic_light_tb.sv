`timescale 1ns/1ps
module traffic_light_tb;
  logic clk, rst_n;
  logic red, green, yellow;

  traffic_light dut(.clk(clk), .rst_n(rst_n), .red(red), .green(green), .yellow(yellow));

  // Clock
  initial clk = 0;
  always #5 clk = ~clk; // 10ns period

  initial begin
    rst_n = 0;
    repeat(2) @(posedge clk);
    rst_n = 1;

    // Observe a few full cycles
    repeat(100) begin
      @(posedge clk);
      $display("t=%0t | RED=%0b GREEN=%0b YELLOW=%0b", $time, red, green, yellow);
    end

    $finish;
  end
endmodule
