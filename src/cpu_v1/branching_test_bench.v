module tb;

    // Inputs and Outputs
    reg clk = 0, sys_rst = 0;
    reg [15:0] din = 0;
    wire [15:0] dout;

    // DUT Instantiation
    top dut(clk, sys_rst, din, dout);

    // Clock Generation
    always #5 clk = ~clk;

    // Task to test branching instructions
    task test_branching(input [15:0] din_value, input [15:0] expected_PC);
        begin
            din = din_value;
            #10; // Wait for DUT to process
            assert (dut.PC == expected_PC) else $fatal("Branching Test Failed: DIN = %0d, Expected PC = %0d, Got PC = %0d", din_value, expected_PC, dut.PC);
        end
    endtask

    // Main Test Sequence
    initial begin
        $display("Starting Branching Tests...");

        // Apply Reset
        sys_rst = 1'b1;
        repeat(5) @(posedge clk);
        sys_rst = 1'b0;

        // Branching Test Cases
        test_branching(16'h0010, 16'h0010); // Example: Simple jump
        test_branching(16'h0000, 16'h0004); // Example: Jump with carry flag
        test_branching(16'hFF00, 16'hFF00); // Example: Overflow scenario

        // Additional tests can be added here...

        $display("All Branching Tests Passed!");
        $finish; // End Simulation
    end
endmodule
