`timescale 1ns/1ps

module hello_world_tb;

  // Instantiate the DUT
  hello_world dut();

  // End the simulation after a short delay
  initial begin
    #10;
    $finish;
  end

endmodule

