	
	// -------------------------------------------
	// Interface: coffee_if
	// -------------------------------------------
	interface coffee_if(
	  input logic         clk
	);
	  logic         size;         // 0: SMALL, 1: LARGE
	  logic         with_milk;
	  logic         with_foam;
	  logic [1:0]  coffee_type;  // Output: 0=NONE, 1=ESPRESSO, 2=LATTE, 3=CAPPUCCINO
	endinterface


		// -------------------------------------------
		// DUT: coffee_machine
		// -------------------------------------------
		module coffee_machine(
		  input logic         clk,
		  input logic         size,         // 0: SMALL, 1: LARGE
		  input logic         with_milk,
		  input logic         with_foam,
		  output logic [1:0]  coffee_type  // Output: 0=NONE, 1=ESPRESSO, 2=LATTE, 3=CAPPUCCINO
		);

		  typedef enum logic {
			SMALL = 1'b0,
			LARGE = 1'b1
		  } size_e;

		  typedef enum logic [1:0] {
			NONE       = 2'd0,
			ESPRESSO   = 2'd1,
			LATTE      = 2'd2,
			CAPPUCCINO = 2'd3
		  } coffee_type_e;

		  always_ff @(posedge clk) begin
			case ({size, with_milk, with_foam})
			  3'b001:  coffee_type <= ESPRESSO;         // SMALL, no milk, no foam here we have intentional error
			  3'b110:  coffee_type <= LATTE;            // LARGE, with milk , no foam
			  3'b111:  coffee_type <= CAPPUCCINO;       // LARGE, with milk and foam
			  default: coffee_type <= NONE;             // Invalid combination
			endcase
		  end

		endmodule

		