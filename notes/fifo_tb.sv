`timescale 1ns/1ps

module fifo_tb;

  // Parameters
  parameter ADDR_WIDTH = 3;  // FIFO depth = 2^3 = 8
  parameter DATA_WIDTH = 8;
  parameter DEPTH = 2 ** ADDR_WIDTH;

  // DUT signals
  logic clk;
  logic rst_n;
  logic push;
  logic pop;
  logic [DATA_WIDTH-1:0] wr_data;
  logic [DATA_WIDTH-1:0] rd_data;
  logic full, empty;

  // Instantiate the FIFO DUT
  fifo #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .push(push),
    .pop(pop),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Reset procedure
  task reset_fifo();
    rst_n = 0;
    push = 0;
    pop = 0;
    wr_data = 0;
    #20;
    rst_n = 1;
    #10;
  endtask

  // Write task
  task write_data(input logic [DATA_WIDTH-1:0] data);
    @(posedge clk);
    if (!full) begin
      push = 1;
      wr_data = data;
    end
    @(posedge clk);
    push = 0;
  endtask

  // Read task
  task read_data();
    @(posedge clk);
    if (!empty) begin
      pop = 1;
    end
    @(posedge clk);
    pop = 0;
    $display("Time %0t: Read data = %0d", $time, rd_data);
  endtask

  // Main test logic
  initial begin
    $display("=== Starting FIFO Test (ADDR_WIDTH = 3, DEPTH = 8) ===");
    clk = 0;
    reset_fifo();

    $display("\n--- Writing to FIFO (1st round, fill to full) ---");
    for (int i = 0; i < DEPTH; i++) begin
      write_data(i + 1);
    end

    $display("\n--- Reading from FIFO (1st round, empty it) ---");
    for (int i = 0; i < DEPTH; i++) begin
      read_data();
    end

    $display("\n--- Writing to FIFO (2nd round, test wrap-around) ---");
    for (int i = 0; i < DEPTH; i++) begin
      write_data(i + 100);
    end

    $display("\n--- Reading from FIFO (2nd round, wrap-around read) ---");
    for (int i = 0; i < DEPTH; i++) begin
      read_data();
    end

    $display("\n=== FIFO Test Completed ===");
    $finish;
  end

endmodule
