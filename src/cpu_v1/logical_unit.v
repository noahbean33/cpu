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

module top();

    // Registers and Variables
    reg [31:0] IR; // Instruction Register
    reg [15:0] GPR [31:0]; // General Purpose Registers
    reg [15:0] SGPR; // Special Register for Multiplication MSB
    reg [31:0] mul_res; // Multiplication Result

    // Flags
    reg sign, zero, overflow, carry;

    // Instruction Decoding and Execution
    always @(*) begin
        // Reset flags
        sign = 0;
        zero = 0;
        overflow = 0;
        carry = 0;

        case (`oper_type)
            `movsgpr: begin
                GPR[`rdst] = SGPR;
            end

            `mov: begin
                if (`imm_mode)
                    GPR[`rdst] = `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1];
            end

            `add: begin
                if (`imm_mode) begin
                    {carry, GPR[`rdst]} = GPR[`rsrc1] + `isrc; // Addition with immediate
                end else begin
                    {carry, GPR[`rdst]} = GPR[`rsrc1] + GPR[`rsrc2]; // Register addition
                end
                zero = (GPR[`rdst] == 16'b0); // Zero flag
                sign = GPR[`rdst][15]; // Sign flag
                overflow = (GPR[`rsrc1][15] == `isrc[15] && GPR[`rsrc1][15] != GPR[`rdst][15]);
            end

            `sub: begin
                if (`imm_mode) begin
                    GPR[`rdst] = GPR[`rsrc1] - `isrc; // Subtraction with immediate
                end else begin
                    GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2]; // Register subtraction
                end
                zero = (GPR[`rdst] == 16'b0); // Zero flag
                sign = GPR[`rdst][15]; // Sign flag
                overflow = (GPR[`rsrc1][15] != `isrc[15] && GPR[`rdst][15] != GPR[`rsrc1][15]);
            end

            `mul: begin
                if (`imm_mode) begin
                    mul_res = GPR[`rsrc1] * `isrc; // Multiplication with immediate
                end else begin
                    mul_res = GPR[`rsrc1] * GPR[`rsrc2]; // Register multiplication
                end
                GPR[`rdst] = mul_res[15:0];
                SGPR = mul_res[31:16];
                zero = ~(|mul_res); // Zero flag for multiplication
            end

            default: begin
                $display("Error: Unsupported operation type: %b", `oper_type);
                GPR[`rdst] = 16'b0; // Set destination register to 0
            end
        endcase
    end

    // Debugging and Monitoring
    initial begin
        $monitor("Time: %0t, OP: %b, Rdst: %0d, Result: %0d, Flags - Zero: %b, Sign: %b, Carry: %b, Overflow: %b",
                 $time, `oper_type, `rdst, GPR[`rdst], zero, sign, carry, overflow);
    end

endmodule
