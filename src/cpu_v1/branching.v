`timescale 1ns / 1ps

// Instruction Register Fields
`define oper_type IR[31:27]
`define rdst      IR[26:22]
`define rsrc1     IR[21:17]
`define imm_mode  IR[16]
`define rsrc2     IR[15:11]
`define isrc      IR[15:0]

// FSM States
parameter idle = 0, fetch_inst = 1, dec_exec_inst = 2, delay_next_inst = 3, next_inst = 4, sense_halt = 5;

module top(
    input clk,
    input sys_rst,
    input [15:0] din,
    output reg [15:0] dout
);

    // Memories and Registers
    reg [31:0] inst_mem [15:0]; // Program Memory
    reg [15:0] data_mem [15:0]; // Data Memory
    reg [31:0] IR; // Instruction Register
    reg [15:0] GPR [31:0]; // General Purpose Registers
    reg [15:0] SGPR; // Special Register
    reg [31:0] mul_res; // Multiplication Result

    // Flags
    reg sign, zero, overflow, carry;

    // Program Counter and FSM
    integer PC;
    reg [2:0] state, next_state;
    reg [2:0] count;

    // Jump and Stop Signals
    reg jmp_flag, stop;

    // Reset and Initialization
    always @(posedge clk or posedge sys_rst) begin
        if (sys_rst) begin
            state <= idle;
            PC <= 0;
            IR <= 32'h0;
            GPR <= '{default: 16'h0};
            SGPR <= 16'h0;
            mul_res <= 32'h0;
            sign <= 1'b0;
            zero <= 1'b0;
            overflow <= 1'b0;
            carry <= 1'b0;
            jmp_flag <= 1'b0;
            stop <= 1'b0;
            dout <= 16'h0;
            count <= 3'd0;
        end else begin
            state <= next_state;

            case (state)
                idle: begin
                    next_state <= fetch_inst;
                end

                fetch_inst: begin
                    if (PC < 16) begin
                        IR <= inst_mem[PC];
                        next_state <= dec_exec_inst;
                    end else begin
                        $fatal("PC out of bounds: %d", PC);
                    end
                end

                dec_exec_inst: begin
                    decode_inst();
                    decode_condflag();
                    next_state <= delay_next_inst;
                end

                delay_next_inst: begin
                    if (count < 3'd4)
                        count <= count + 1;
                    else
                        next_state <= next_inst;
                end

                next_inst: begin
                    if (jmp_flag)
                        PC <= `isrc;
                    else
                        PC <= PC + 1;
                    next_state <= sense_halt;
                end

                sense_halt: begin
                    if (stop)
                        $finish;
                    else
                        next_state <= fetch_inst;
                end

                default: begin
                    $display("Error: Undefined state");
                    next_state <= idle;
                end
            endcase
        end
    end

    // Instruction Decoding Task
    task decode_inst();
    begin
        jmp_flag = 1'b0;
        stop = 1'b0;

        case (`oper_type)
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

            `jump: begin
                jmp_flag = 1'b1;
            end

            `halt: begin
                stop = 1'b1;
            end

            default: begin
                $display("Error: Undefined opcode %b", `oper_type);
                stop = 1'b1;
            end
        endcase
    end
    endtask

    // Condition Flag Task
    task decode_condflag();
    begin
        zero = ~|GPR[`rdst];
        sign = GPR[`rdst][15];
    end
    endtask

    // Initialize Program Memory
    initial begin
        $readmemb("inst_data.mem", inst_mem);
    end

endmodule
