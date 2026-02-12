//===========================================================
// Module: alu
// Description: Implement an 8-bit ALU
// Complete the code below the "add your code here" lines
//===========================================================

module alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    input  logic [2:0] op,
    output logic [7:0] y,
    output logic       cout
);

    always_comb begin
        //defaults
        y    = '0;
        cout = 1'b0;

        case (op)
            3'b000: begin // AND
                y    = a & b;
                cout = 1'b0;
            end
            3'b001: begin // OR
                y    = a | b;
                cout = 1'b0;
            end
            3'b010: begin // COMP
                y    = ~a;
                cout = 1'b0;
            end
            3'b011: begin // RRC
                y    = {cin, a[7:1]};
                cout = a[0];
            end
            3'b100: begin // RLC
                y    = {a[6:0], cin};
                cout = a[7];
            end
            3'b101: begin // ADD with carry
                {cout, y} = {1'b0, a} + {1'b0, b} + cin;
            end
            3'b110: begin // SUB with borrow
                {cout, y} = {1'b0, a} - {1'b0, b} - cin;
            end
            3'b111: begin // MOVE
                y    = b;
                cout = 1'b0;
            end
        endcase
    end
endmodule

