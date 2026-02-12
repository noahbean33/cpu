`timescale 1ns/1ps
module adder4_struct_tb;
  logic a0,a1,a2,a3;
  logic b0,b1,b2,b3;
  logic sum0,sum1,sum2,sum3,Cout;

  adder4_struct dut (
    .a0(a0), .a1(a1), .a2(a2), .a3(a3),
    .b0(b0), .b1(b1), .b2(b2), .b3(b3),
    .sum0(sum0), .sum1(sum1), .sum2(sum2), .sum3(sum3),
    .Cout(Cout)
  );

  task run_case(input [3:0] A, input [3:0] B);
    logic [4:0] expected;
    begin
      {a3,a2,a1,a0} = A;
      {b3,b2,b1,b0} = B;
      #1;
      expected = A + B; // Cin = 0
      if ({Cout,sum3,sum2,sum1,sum0} !== expected)
        $display("FAIL: A=%0d B=%0d -> got=%b%b%b%b%b expected=%b",
                 A,B,Cout,sum3,sum2,sum1,sum0,expected);
      else
        $display("PASS: A=%0d B=%0d -> {Cout,Sum}=%b%b%b%b%b",
                 A,B,Cout,sum3,sum2,sum1,sum0);
    end
  endtask

  initial begin
    run_case(4'd0, 4'd0);
    run_case(4'd1, 4'd1);
    run_case(4'd7, 4'd9);
    run_case(4'd15, 4'd1);
    $finish;
  end
endmodule
