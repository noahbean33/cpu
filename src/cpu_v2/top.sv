`include "cpu.sv"
`include "progmem.sv"
module top(
    input logic rst, clk,
    output logic [31:0] cycle
  );
  logic [31:0] mem_rdata, mem_wdata, addr;
  logic rstrb;
  logic [3:0] wr_strobe;
  
  //Instantiate sub modules
  cpu cpu0(
        .rst(rst), .clk(clk),
        .mem_rdata(mem_rdata),
        .mem_addr(addr),
        .cycle(cycle),
        .mem_rstrb(rstrb),
        .mem_wdata(mem_wdata),
        .mem_wstrb(wr_strobe)
      );

  progmem mem0(
            .rst(rst), .clk(clk),
            .addr(addr),
            .data_in(mem_wdata),
            .rd_strobe(rstrb),
            .wr_strobe(wr_strobe),
            .data_out(mem_rdata)
          );
endmodule
