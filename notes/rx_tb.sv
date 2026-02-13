`timescale 1ns/1ns

module rx_tb;

    // Clock & reset
    logic clk;
    logic rst_n;

    // Inputs to RX
    logic tx_valid;
    logic tx_data;

    // Outputs from RX
    logic rx_ready;
    logic rx_finish;

    // Instantiate DUT
    rx dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .rx_ready(rx_ready),
        .rx_finish(rx_finish)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // Reset
    initial begin
        rst_n = 0;
        tx_valid = 0;
        tx_data = 0;

        #20;
        rst_n = 1;
        $display("De-assert reset at time %0t", $time);
    end

    // Stimulus
    initial begin
        wait (rst_n == 1);
		@(posedge clk);
		send_byte(8'b11010101);  // Byte 0
		send_byte(8'b00110011);  // Byte 1
		send_byte(8'b10101010);  // Byte 2
		send_byte(8'b11110000);  // Byte 3

        wait (rx_finish);
        $display("RX finished receiving data at time %0t", $time);
        #5;
        $finish;
    end

    // Task to send a byte LSB-first over tx_data/tx_valid
    task send_byte(input logic [7:0] data);
        integer i;
        begin
            for (i = 0; i < 7; i = i + 1) begin
                @(posedge clk);
                tx_valid = 1;
                tx_data = data[i];  // Send LSB first
                $display("Sending bit %0d = %b at time %0t", i, data[i], $time);
            end
            @(posedge clk);
			@(posedge clk);
			@(posedge clk);
            tx_valid = 0;
        end
    endtask

    // Monitor RX
    always @(posedge clk) begin
        if (rx_ready)
            $display("time:%0t | rx_ready asserted", $time);
    end

endmodule
