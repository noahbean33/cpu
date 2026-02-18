`timescale 1ns / 1ps

// Instruction Register Fields
`define oper_type IR[31:27]
`define rdst      IR[26:22]
`define rsrc1     IR[21:17]
`define imm_mode  IR[16]
`define rsrc2     IR[15:11]
`define isrc      IR[15:0]

// Operation Definitions
`define movsgpr   5'b00000
`define mov       5'b00001
`define add       5'b00010
`define sub       5'b00011
`define mul       5'b00100
`define storereg  5'b01101
`define storedin  5'b01110
`define senddout  5'b01111
`define sendreg   5'b10001

module top(
    input clk,
    input sys_rst,
    input [15:0] din,
    output reg [15:0] dout
);

    // Memory Arrays
    reg [31:0] inst_mem [15:0]; // Instruction Memory
    reg [15:0] data_mem [15:0]; // Data Memory

    // Registers and Intermediate Variables
    reg [31:0] IR; // Instruction Register
    reg [15:0] GPR [31:0]; // General Purpose Registers
    reg [15:0] SGPR; // Special Register
    reg [31:0] mul_res; // Multiplication Result

    // Flags
    reg sign = 0, zero = 0, overflow = 0, carry = 0;

    // Program Counter
    reg [2:0] count = 0;
    integer PC = 0;

    // Decode Instruction Task
    task decode_inst();
    begin
        case (`oper_type)
            `movsgpr: GPR[`rdst] = SGPR;

            `mov: begin
                if (`imm_mode)
                    GPR[`rdst] = `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1];
            end

            `add: begin
                if (`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] + `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] + GPR[`rsrc2];
            end

            `sub: begin
                if (`imm_mode)
                    GPR[`rdst] = GPR[`rsrc1] - `isrc;
                else
                    GPR[`rdst] = GPR[`rsrc1] - GPR[`rsrc2];
            end

            `mul: begin
                if (`imm_mode)
                    mul_res = GPR[`rsrc1] * `isrc;
                else
                    mul_res = GPR[`rsrc1] * GPR[`rsrc2];
                GPR[`rdst] = mul_res[15:0];
                SGPR = mul_res[31:16];
            end

            `storedin: data_mem[`isrc] = din;

            `storereg: data_mem[`isrc] = GPR[`rsrc1];

            `senddout: dout = data_mem[`isrc];

            `sendreg: GPR[`rdst] = data_mem[`isrc];

            default: $display("Warning: Undefined operation: %b", `oper_type);
        endcase
    end
    endtask

    // Decode Condition Flags Task
    task decode_condflag();
    begin
        zero = (GPR[`rdst] == 0);
        sign = GPR[`rdst][15];
        carry = (GPR[`rsrc1] + GPR[`rsrc2]) > 16'hFFFF;
        overflow = ((GPR[`rsrc1][15] == GPR[`rsrc2][15]) && (GPR[`rdst][15] != GPR[`rsrc1][15]));
    end
    endtask

    // Instruction Fetch and Decode Logic
    always @(posedge clk or posedge sys_rst) begin
        if (sys_rst) begin
            count <= 0;
            PC <= 0;
        end else if (count < 4) begin
            count <= count + 1;
        end else begin
            count <= 0;
            PC <= PC + 1;
        end
    end

    always @(*) begin
        if (sys_rst)
            IR = 0;
        else begin
            IR = inst_mem[PC];
            decode_inst();
            decode_condflag();
        end
    end

    // Load Instructions into Program Memory
    initial begin
        $readmemb("inst_data.mem", inst_mem);
    end
endmodule
