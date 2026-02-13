`timescale 1ns/1ps

module single_port_ram_tb;

  // Choose a small RAM for quick sim
  localparam int AW = 4;  // 16 locations
  localparam int DW = 8;  // 8-bit data

  // DUT I/O
  logic                   clk;
  logic                   we;
  logic [AW-1:0]          addr;
  logic [DW-1:0]          din;
  logic [DW-1:0]          dout;

  int errors = 0;
  int i;
  logic [DW-1:0] exp;

  // 10 ns clock
  initial clk = 1'b0;
  always  #5 clk = ~clk;

  // DUT
  single_port_ram #(.ADDR_WIDTH(AW), .DATA_WIDTH(DW)) dut (
    .clk (clk),
    .we  (we),
    .addr(addr),
    .din (din),
    .dout(dout)
  );

  initial begin
    // Defaults
    we   = 1'b0;
    addr = '0;
    din  = '0;

    // ------------------ Initialize RAM to 0 ------------------
    for (i = 0; i < (1<<AW); i++) begin
      addr = i[AW-1:0];
      din  = '0;
      we   = 1'b1;
      @(posedge clk); #1;
    end
    we = 1'b0;
    @(posedge clk); #1;

    // ------------------ Write/Readback test ------------------
    for (i = 0; i < (1<<AW); i++) begin
      addr = i[AW-1:0];
      exp  = (DW)'(i*3 + 5);

      // ------------------ WRITE ------------------
      din = exp;
      we  = 1'b1;
      @(posedge clk); #1;

      // RAM may output previous cycle data during write
      // so we do NOT compare dout here.

      // ------------------ READ BACK ------------------
      we = 1'b0;
      @(posedge clk); #1;

      if (dout !== exp) begin
        $display("FAIL readback i=%0d: dout=%0h exp=%0h", i, dout, exp);
        errors++;
      end
    end

    // ------------------ Summary ------------------
    if (errors == 0) $display("TEST PASSED");
    else             $display("TEST FAILED -- %0d errors", errors);

    $finish;
  end

endmodule
