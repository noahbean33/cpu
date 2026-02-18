module tb;

    integer i;

    // DUT instance
    top dut();

    // Initialize all GPRs to a known value
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            dut.GPR[i] = 2;
        end
    end

    // Test various operations
    initial begin
        $display("Starting tests...");

        // Test immediate addition
        dut.IR = 0;
        dut.`imm_mode = 1;
        dut.`oper_type = `add;
        dut.`rsrc1 = 2; // GPR[2] = 2
        dut.`rdst = 0;  // GPR[0]
        dut.`isrc = 4;  // Immediate value
        #10;
        assert (dut.GPR[0] == 6) else $fatal("Immediate ADD failed");

        // Test register addition
        dut.IR = 0;
        dut.`imm_mode = 0;
        dut.`oper_type = `add;
        dut.`rsrc1 = 4; // GPR[4] = 2
        dut.`rsrc2 = 5; // GPR[5] = 2
        dut.`rdst = 0;  // GPR[0]
        #10;
        assert (dut.GPR[0] == 4) else $fatal("Register ADD failed");

        // More tests...

        $display("All tests passed!");
        $finish;
    end
endmodule
