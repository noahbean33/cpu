`timescale 1ns/1ns

module tx_rx_tb ();

    logic tx_finish_tb;
    logic rx_finish_tb;
    logic clk_tb;
    logic rst_n_tb;

    // Clock generation
    initial clk_tb = 0;
    always #5 clk_tb = ~clk_tb;

    // Reset sequence
    initial begin
        rst_n_tb = 1;
        #10;
        rst_n_tb = 0;  // Assert reset
        #20;
        rst_n_tb = 1;  // De-assert reset
    end

    // Instantiate DUT
    tx_rx DUT (
        .clk(clk_tb),
        .rst_n(rst_n_tb),
        .tx_finish(tx_finish_tb),
        .rx_finish(rx_finish_tb)
    );


    // Simulation monitor
    always @(posedge clk_tb) begin

        if (DUT.u_rx.rx_ready) begin
            $display("time:%0t   rx_ready:%b", $time, DUT.u_rx.rx_ready);
        end

        if (DUT.u_tx.tx_valid) begin
            $display("time:%0t   tx_valid:%b   tx_data:%h", $time, DUT.u_tx.tx_valid, DUT.u_tx.tx_data);
        end

        if (DUT.u_rx.inc) begin
            $display("time:%0t              Ram_Address:%h", $time, DUT.u_rx.addr);
        end

        if (DUT.u_rx.rx_finish) begin
            $display("time:%0t              rx_finish:%b", $time, DUT.u_rx.rx_finish);

    
        $finish;
        end
    end

endmodule
