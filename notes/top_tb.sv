
	`timescale 1ns/1ps
	`include "uvm_macros.svh"
	`include "coffee_pkg.sv"

	module top_tb;
	  import uvm_pkg::*; 
	  import coffee_pkg::*; 

	  logic clk = 0;

	  // Clock generation
	  always #5 clk = ~clk;

	  // Interface instantiation and binding
	  coffee_if cif(.clk(clk));

	  // DUT instantiation
	  coffee_machine dut(
		.clk         (clk),
		.size        (cif.size),
		.with_milk   (cif.with_milk),
		.with_foam   (cif.with_foam),
		.coffee_type (cif.coffee_type)
	  );

	  // UVM configuration and run
	  initial begin
		// Set virtual interface for UVM components
		uvm_config_db#(virtual coffee_if)::set(null, "uvm_test_top.env.agt.drv", "vif", cif);
		uvm_config_db#(virtual coffee_if)::set(null, "uvm_test_top.env.agt.mon", "vif", cif); 
		run_test("coffee_test");
	  end

	endmodule

	
	
	