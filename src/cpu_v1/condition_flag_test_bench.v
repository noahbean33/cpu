module tb;

    integer i;

    // DUT Instance
    top dut();

    // Task to initialize GPRs
    task initialize_gprs(input [15:0] value);
        integer j;
        begin
            for (j = 0; j < 32; j = j + 1) begin
                dut.GPR[j] = value;
            end
        end
    endtask

    // Task to test flags
    task test_flag(
        input [15:0] src1,
        input [15:0] src2,
        input [4:0] op_type,
        input imm_mode,
        input [15:0] expected_result
    );
        begin
            dut.IR = 0;
            dut.`rsrc1 = src1;
            dut.`rsrc2 = src2;
            dut.`oper_type = op_type;
            dut.`imm_mode = imm_mode;
            #10;
            assert (dut.GPR[2] == expected_result) else $fatal("Test failed: SRC1 = %0d, SRC2 = %0d, OP = %b", src1, src2, op_type);
        end
    endtask

    // Main Test Sequence
    initial begin
        $display("Starting Tests...");

        // Initialize GPRs
        initialize_gprs(2);

        // Immediate Addition
        test_flag(2, 4, 5'b00010, 1, 6); // ADDI: SRC1 + Immediate

        // Register Addition
        test_flag(4, 5, 5'b00010, 0, 9); // ADD: SRC1 + SRC2

        // Immediate Move
        test_flag(0, 55, 5'b00001, 1, 55); // MOVI: Immediate Move

        // Logical AND with Immediate
        test_flag(7, 56, 5'b00110, 1, 7 & 56); // ANDI: SRC1 & Immediate

        // Logical XOR with Immediate
        test_flag(7, 56, 5'b00111, 1, 7 ^ 56); // XORI: SRC1 ^ Immediate

        // Zero Flag Test
        test_flag(0, 0, 5'b00010, 0, 0); // ADD: SRC1 + SRC2

        // Sign Flag Test
        test_flag(16'h8000, 0, 5'b00010, 0, 16'h8000); // ADD: SRC1 + SRC2

        // Carry and Overflow Test
        test_flag(16'h8000, 16'h8002, 5'b00010, 0, 16'h0002); // ADD: Overflow and Carry Test

        $display("All Tests Passed!");
        $finish; // End Simulation
    end
endmodule
