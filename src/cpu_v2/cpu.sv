/* CPU Version 5.0 - SystemVerilog Port
Support RV-32I extension only
Ported to SystemVerilog syntax (basic conversion)
Verified for synthesis in FPGA
FSM based design
R-type, I type and Branch instr included
Shift operator implemented (SLL/SLLI, SRL/SRLI)
Load and store implemented
Jump implementing
Bug: Arithmetic right shift SRA, SRAI not working
Bug: LH, LB, SH, SB, LBU, LHU not working
Revised on: 16/04/2025
Bug fixed on 24/4/2025: LB, SB, LH, SH tested 
LBU, LHU: implemented but not tested
Reordering of state variable, No of state reduced
*/
module cpu(
    input logic rst, clk,
    input logic [31:0] mem_rdata,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_wdata,
    output logic mem_rstrb,
    output logic [31:0] cycle,
    output logic [3:0] mem_wstrb
  );

  typedef enum logic [3:0] {
    RESET       = 4'd0,
    WAIT        = 4'd1,
    FETCH       = 4'd2,
    DECODE      = 4'd3,
    EXECUTE     = 4'd4,
    BYTE        = 4'd5,
    WAIT_LOADING = 4'd6,
    HLT         = 4'd7
  } state_t;

  logic [31:0] regfile[0:31];
  logic [31:0] addr, data_rs1, data_rs2;
  logic [31:0] data;
  state_t state;
  logic [4:0] opcode;
  logic [4:0] rd;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:0] I_data;
  logic [31:0] B_data;
  logic [31:0] S_data;
  logic [31:0] J_data;
  logic [31:0] U_data;

  always_comb begin
    opcode = data[6:2];
    rd = data[11:7];
    funct3 = data[14:12];
    funct7 = data[31:25];
    I_data = {{21{data[31]}},data[30:20]};
    B_data = {{20{data[31]}},data[7],data[30:25],data[11:8],1'b0};
    S_data = {{21{data[31]}},data[30:25],data[11:7]};
    J_data = {{12{data[31]}},data[19:12],data[20],data[30:21],1'b0};
    U_data = {data[31],data[30:12],12'h000};
  end

  logic isRtype, isItype, isBtype, isSystype, isStype, isLtype;
  logic isJAL, isJALR, isLUI, isAUIPC;

  always_comb begin
    isRtype = (opcode == 5'b01100);
    isItype = (opcode == 5'b00100);
    isBtype = (opcode == 5'b11000);
    isSystype = (opcode == 5'b11100);
    isStype = (opcode == 5'b01000);
    isLtype = (opcode == 5'b00000);
    isJAL = (opcode == 5'b11011);
    isJALR = (opcode == 5'b11001);
    isLUI = (opcode == 5'b01101);
    isAUIPC = (opcode == 5'b00101);
  end

  logic [31:0] ADD, XOR, OR, AND;
  logic [32:0] SUB;
  logic [31:0] shift_data_2;
  logic [31:0] SLL, SRL, SRA;

  always_comb begin
    ADD = alu_in1 + alu_in2;
    XOR = alu_in1 ^ alu_in2;
    OR = alu_in1 | alu_in2;
    AND = alu_in1 & alu_in2;
    SUB = {1'b0,alu_in1} + {1'b1, ~alu_in2} + 1'b1;
    shift_data_2 = isRtype ? alu_in2 : isItype ? {7'b0,alu_in2[4:0]} : 32'b0;
    SLL = alu_in1 << shift_data_2;
    SRL = alu_in1 >> shift_data_2;
    SRA = $signed(alu_in1) >>> shift_data_2;
  end

  logic EQUAL, NEQUAL, LESS_THAN, LESS_THAN_U;
  logic GREATER_THAN, GREATER_THAN_U, TAKE_BRANCH;

  always_comb begin
    EQUAL = (SUB[31:0] == 0);
    NEQUAL = !EQUAL;
    LESS_THAN = (alu_in1[31] ^ alu_in2[31]) ? alu_in1[31] : SUB[32];
    LESS_THAN_U = SUB[32];
    GREATER_THAN = !LESS_THAN;
    GREATER_THAN_U = !LESS_THAN_U;
    TAKE_BRANCH = ((funct3==3'b000) & EQUAL) |
                  ((funct3==3'b111) & GREATER_THAN_U) |
                  ((funct3==3'b001) & NEQUAL) |
                  ((funct3==3'b100) & LESS_THAN) |
                  ((funct3==3'b101) & GREATER_THAN) |
                  ((funct3==3'b110) & LESS_THAN_U);
  end

  logic [31:0] alu_result;

  always_comb begin
    if ((funct3==3'b000) & isRtype & ~funct7[5])
      alu_result = ADD;
    else if ((funct3==3'b000) & isItype)
      alu_result = ADD;
    else if ((funct3==3'b000) & ~(isStype|isLtype) & funct7[5])
      alu_result = SUB[31:0];
    else if (funct3==3'b100)
      alu_result = XOR;
    else if (funct3==3'b110)
      alu_result = OR;
    else if (funct3==3'b111)
      alu_result = AND;
    else if ((funct3==3'b010) & !(isStype|isLtype))
      alu_result = {31'b0, LESS_THAN};
    else if (funct3==3'b011)
      alu_result = {31'b0, LESS_THAN_U};
    else if ((funct3==3'b001) & (!isStype))
      alu_result = SLL;
    else if ((funct3==3'b101) & (~funct7[5]))
      alu_result = SRL;
    else if ((funct3==3'b101) & funct7[5])
      alu_result = SRA;
    else if (isStype | isLtype | isJALR)
      alu_result = ADD;
    else
      alu_result = 32'b0;
  end

  logic [31:0] alu_in1, alu_in2;
  logic [31:0] pcplus4, pcplusimm;

  always_comb begin
    alu_in1 = data_rs1;
    alu_in2 = (isRtype | isBtype) ? data_rs2 : (isItype | isLtype | isJALR) ? I_data : S_data;
    pcplus4 = addr + 4;
    pcplusimm = addr + (isBtype ? B_data : isJAL ? J_data : isAUIPC ? U_data : 32'b0);
  end
  logic load_store_state_flag;
  logic [31:0] load_store_addr;
  logic mem_byteAccess, mem_halfwordAccess;
  logic LOAD_sign;
  logic [31:0] load_data_tmp;
  logic [15:0] LOAD_halfword;
  logic [7:0] LOAD_byte;

  always_comb begin
    load_store_state_flag = (state==BYTE);
    load_store_addr = (load_store_state_flag | (state==WAIT_LOADING)) ? alu_result : 32'b0;
    mem_byteAccess = data[13:12] == 2'b00;
    mem_halfwordAccess = data[13:12] == 2'b01;
    LOAD_halfword = load_store_addr[1] ? mem_rdata[31:16] : mem_rdata[15:0];
    LOAD_byte = load_store_addr[0] ? LOAD_halfword[15:8] : LOAD_halfword[7:0];
    LOAD_sign = !data[14] & (mem_byteAccess ? LOAD_byte[7] : LOAD_halfword[15]);
    load_data_tmp = mem_byteAccess ? {{24{LOAD_sign}}, LOAD_byte} :
                    mem_halfwordAccess ? {{16{LOAD_sign}}, LOAD_halfword} : mem_rdata;
  end

  logic [3:0] STORE_wmask;

  always_comb begin
    if (mem_byteAccess)
      STORE_wmask = load_store_addr[1] ?
                    (load_store_addr[0] ? 4'b1000 : 4'b0100) :
                    (load_store_addr[0] ? 4'b0010 : 4'b0001);
    else if (mem_halfwordAccess)
      STORE_wmask = load_store_addr[1] ? 4'b1100 : 4'b0011;
    else
      STORE_wmask = 4'b1111;

    mem_wstrb = {4{(state==WAIT_LOADING) & isStype}} & STORE_wmask;
    mem_addr = ((isStype | isLtype) & (load_store_state_flag | (state==WAIT_LOADING))) ? load_store_addr : addr;
    mem_rstrb = (state==WAIT) | (isLtype & load_store_state_flag);

    mem_wdata[7:0] = data_rs2[7:0];
    mem_wdata[15:8] = load_store_addr[0] ? data_rs2[7:0] : data_rs2[15:8];
    mem_wdata[23:16] = load_store_addr[1] ? data_rs2[7:0] : data_rs2[23:16];
    mem_wdata[31:24] = load_store_addr[0] ? data_rs2[7:0] :
                       load_store_addr[1] ? data_rs2[15:8] : data_rs2[31:24];
  end


  initial begin
    cycle = 0;
    state = RESET;
    addr = 0;
    regfile[0] = 0;
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      addr <= 0;
      state <= RESET;
      data <= 32'h0;
    end else begin
      case(state)
        RESET: begin
          if (rst)
            state <= RESET;
          else
            state <= WAIT;
        end

        WAIT: begin
          state <= FETCH;
        end

        FETCH: begin
          data <= mem_rdata;
          state <= DECODE;
        end

        DECODE: begin
          data_rs1 <= regfile[data[19:15]];
          data_rs2 <= regfile[data[24:20]];
          state <= ~isSystype ? EXECUTE : HLT;
        end

        EXECUTE: begin
          addr <= (isBtype & TAKE_BRANCH) | isJAL ? pcplusimm : isJALR ? alu_result : pcplus4;
          state <= !(isStype|isLtype|isJAL|isJALR) ? WAIT : BYTE;
        end

        BYTE: begin
          state <= WAIT_LOADING;
        end

        WAIT_LOADING: begin
          state <= WAIT;
        end

        default: begin
          state <= RESET;
        end
      endcase
    end
  end
 
  always_ff @(posedge clk) begin
    if (rst)
      cycle <= 0;
    else if (state != HLT)
      cycle <= cycle + 1;
  end


  logic write_reg_en;
  logic [31:0] write_reg_data;

  always_comb begin
    write_reg_en = ((isItype|isRtype|isJAL|isJALR|isLUI|isAUIPC) & (state==EXECUTE)) |
                   (isLtype & (state==WAIT_LOADING));

    if (isItype | isRtype)
      write_reg_data = alu_result;
    else if (isLtype)
      write_reg_data = load_data_tmp;
    else if (isJAL | isJALR)
      write_reg_data = pcplus4;
    else if (isLUI)
      write_reg_data = U_data;
    else if (isAUIPC)
      write_reg_data = pcplusimm;
    else
      write_reg_data = 32'b0;
  end

  always_ff @(posedge clk) begin
    if (write_reg_en && rd != 0)
      regfile[rd] <= write_reg_data;
  end

endmodule
