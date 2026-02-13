`timescale 1ns/1ns

module tx_tb;

    // Clock and Reset
    logic clk;
    logic rst_n;

    // RX interface signal
    logic rx_ready;

    // Outputs from DUT
    logic tx_data;
    logic tx_valid;
    logic tx_finish;

    // Instantiate DUT
    tx dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_ready(rx_ready),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_finish(tx_finish)
    );

    // Clock Generation: 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $display("Starting TX Testbench...");

        // Initialize
        rx_ready = 0;
        rst_n = 0;

        // Apply reset
        #20;
        rst_n = 1;
        $display("De-asserting reset at time %0t", $time);

        // Wait before enabling rx_ready
        #20;
        rx_ready = 1;
        $display("RX is ready at time %0t", $time);

        // Run simulation until TX finishes
        wait (tx_finish);
        $display("TX finished transmission at time %0t", $time);

        #20;
        $finish;
    end

    // Monitor tx activity
    always @(posedge clk) begin
        if (tx_valid) begin
            $display("time:%0t | tx_valid=1 | tx_data=%b", $time, tx_data);
        end
    end

endmodule
