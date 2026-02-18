`timescale 1ns / 1ps

// Instruction Register Fields
`define oper_type IR[31:27]
`define rdst      IR[26:22]
`define rsrc1     IR[21:17]
`define imm_mode  IR[16]
`define rsrc2     IR[15:11]
`define isrc      IR[15:0]

// Arithmetic Operations
`define movsgpr   5'b00000
`define mov       5'b00001
`define add       5'b00010
`define sub       5'b00011
`define mul       5'b00100

// Logical Operations
`define ror       5'b00101
`define rand      5'b00110
`define rxor      5'b00111
`define rxnor     5'b01000
`define rnand     5'b01001
`define rnor      5'b01010
`define rnot      5'b01011

module top();

    // Registers and Variables
    reg [31:0] IR; // Instruction Register
    reg [15:0] GPR [31:0]; // General Purpose Registers
    reg [15:0] SGPR; // Special Register for MSB of Multiplication
    reg [31:0] mul_res; // Multiplication Result

    // Condition Flags
    reg sign = 0, zero = 0, overflow = 0, carry = 0;
    reg [16:0] temp_sum;

    // Unified Flag Update Task
    task update_flags(input [15:0] result, input [15:0] msb);
        begin
            sign = result[15]; // MSB of the result
            zero = ~(result | msb); // Check if all bits are zero
        end
    endtask

    // Instruction Decoding and Execution
    always @(*) begin
        case (`oper_type)
            `movsgpr: begin
                GPR[`rdst] = SGPR;
                update_flags(GPR[`rdst], 16'b0);
            end

            `mov: begin
                if (`imm_mode)
                    GPR[`rdst] = `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1];
                update_flags(GPR[`rdst], 16'b0);
            end

            `add: begin
                if (`imm_mode) begin
                    temp_sum = GPR[`rsrc1] + `isrc;
                    carry = temp_sum[16];
                    GPR[`rdst] = temp_sum[15:0];
                end else begin
                    temp_sum = GPR[`rsrc1] + GPR[`rsrc2];
                    carry = temp_sum[16];
                    GPR[`rdst] = temp_sum[15:0];
                end
                overflow = (GPR[`rsrc1][15] == `isrc[15] && GPR[`rsrc1][15] != GPR[`rdst][15]);
                update_flags(GPR[`rdst], 16'b0);
            end

            `sub: begin
                if (`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] - `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
                overflow = (GPR[`rsrc1][15] != `isrc[15] && GPR[`rdst][15] != GPR[`rsrc1][15]);
                update_flags(GPR[`rdst], 16'b0);
            end

            `mul: begin
                if (`imm_mode)
                    mul_res = GPR[`rsrc1] * `isrc;
                else
                    mul_res = GPR[`rsrc1] * GPR[`rsrc2];
                GPR[`rdst] = mul_res[15:0];
                SGPR = mul_res[31:16];
                update_flags(GPR[`rdst], SGPR);
            end

            default: begin
                $display("Error: Unsupported operation type: %b", `oper_type);
            end
        endcase
    end

    // Debugging and Monitoring
    initial begin
        $monitor("Time: %0t, IR: %b, Flags: Sign=%b, Zero=%b, Carry=%b, Overflow=%b", 
                 $time, IR, sign, zero, carry, overflow);
    end

endmodule
