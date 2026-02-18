module tb;

    // DUT Inputs and Outputs
    reg clk = 0, sys_rst = 0;
    reg [15:0] din = 0;
    wire [15:0] dout;

    // DUT Instantiation
    top dut(clk, sys_rst, din, dout);

    // Clock Generation
    always #5 clk = ~clk;

    // Task to write to memory
    task write_memory(input [15:0] address, input [15:0] data);
        begin
            din = data;
            dut.data_mem[address] = din;
            #10; // Wait for one clock cycle
        end
    endtask

    // Task to read from memory
    task read_memory(input [15:0] address, output [15:0] data_out);
        begin
            data_out = dut.data_mem[address];
            #10; // Wait for one clock cycle
        end
    endtask

    // Task to test memory operations
    task test_memory();
        integer i;
        reg [15:0] data_read;
        begin
            // Write and Read Test
            for (i = 0; i < 16; i = i + 1) begin
                write_memory(i, i * 10); // Write i * 10 to memory
                read_memory(i, data_read); // Read back from memory
                assert (data_read == i * 10) else $fatal("Memory Test Failed at address %0d", i);
            end

            $display("Memory Test Passed!");
        end
    endtask

    // Testbench Sequence
    initial begin
        // Apply Reset
        sys_rst = 1'b1;
        repeat (5) @(posedge clk);
        sys_rst = 1'b0;

        // Run Memory Tests
        test_memory();

        // Finish Simulation
        $finish;
    end
endmodule
