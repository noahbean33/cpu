`include "top.sv"
module top_test;
  logic rst, clk;
  logic [31:0] cycle;
  int i;
  logic [10:0] loc = 1000;
  //instantiate DUT
  top dut (rst, clk, cycle);
  initial begin
    $dumpfile("test.vcd");
    $dumpvars;
    rst = 1;
    clk = 0;
    #50;
    rst = 0;
    #5000;

    $display("*** Printing register content ***");
    for (i = 0; i < 7; i = i + 1)
      $display("X[%0d] = %0d ", i, $signed(dut.cpu0.regfile[i]));
    $display("Clock cycle=%0d", cycle);
    $display("Data at location %d = %d", loc, dut.mem0.PROGMEM[loc[10:2]]);
    $finish;
  end
  /*
  initial begin
  $monitor("Time=%0d, X[0]=%0d, X[1]=%0d, X[2]=%0d, X[3]=%0d, X[4]=%0d,  X[5]=%0d, Cycle=%0d",$time, dut.cpu0.regfile[0],dut.cpu0.regfile[1],dut.cpu0.regfile[2],dut.cpu0.regfile[3],dut.cpu0.regfile[4],dut.cpu0.regfile[5], cycle);
  end
  */
  always #5 clk = ~clk;
endmodule
