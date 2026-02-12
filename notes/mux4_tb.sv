`timescale 1ns/1ps

module mux4_tb;

  // Testbench signals
  logic S1, S0;
  logic X0, X1, X2, X3;
  logic Q;

  int error_count = 0;

  // Instantiate the DUT
  mux4 dut (
    .S1(S1), .S0(S0),
    .X0(X0), .X1(X1), .X2(X2), .X3(X3),
    .Q(Q)
  );

  // Task for checking
  task check_output(input logic [1:0] sel, input logic expected);
    begin
      {S1, S0} = sel;
      #5; // small delay for propagation
      if (Q !== expected) begin
        error_count++;
        $display("Mismatch: S1S0=%b -> Q=%b (Expected=%b)", sel, Q, expected);
      end
    end
  endtask

  // Stimulus
  initial begin
    // Set inputs
    X0 = 0; X1 = 1; X2 = 0; X3 = 1;

    // Run checks
    check_output(2'b00, X0);
    check_output(2'b01, X1);
    check_output(2'b10, X2);
    check_output(2'b11, X3);

    // Final result
    if (error_count == 0)
      $display("TEST PASSED");
    else
      $display("TEST FAILED -- %0d errors found", error_count);

    $finish;
  end

endmodule
