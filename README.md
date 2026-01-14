# RISC-V RV32I Processor

An implementation of a RISC-V 32-bit integer processor written in SystemVerilog, featuring an FSM-based design verified for FPGA synthesis.

## Features

### Supported Instruction Set (RV32I Base)
- **R-type**: ADD, SUB, XOR, OR, AND, SLT, SLTU, SLL, SRL, SRA
- **I-type**: ADDI, XORI, ORI, ANDI, SLTI, SLTIU, SLLI, SRLI, SRAI
- **Load**: LW, LH, LB, LHU, LBU
- **Store**: SW, SH, SB
- **Branch**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **Jump**: JAL, JALR
- **Upper Immediate**: LUI, AUIPC
- **System**: ECALL (halt)

### Architecture
- **Design Style**: 5-stage FSM (RESET → WAIT → FETCH → DECODE → EXECUTE)
- **Register File**: 32 general-purpose registers (x0-x31)
- **Memory**: 1024-word program memory with byte-addressable load/store
- **ALU**: Full arithmetic, logic, comparison, and shift operations
- **Cycle Counter**: Built-in performance monitoring

## Project Structure

```
verilog_processor/
├── src/
│   └── cpu/
│       ├── cpu.sv         # Main CPU module (FSM, ALU, control logic)
│       ├── progmem.sv     # Program memory (1024 x 32-bit)
│       ├── top.sv         # Top-level module connecting CPU and memory
│       ├── testbench.sv   # Simulation testbench
│       └── firmware.hex   # Example program (hex format)
├── docs/                  # RISC-V reference materials
└── requirements.txt       # Python dependencies for testing
```

## Design Details

### State Machine
1. **RESET**: Initialize registers and program counter
2. **WAIT**: Memory read strobe assertion (1-cycle delay)
3. **FETCH**: Latch instruction from memory
4. **DECODE**: Decode instruction and read register file
5. **EXECUTE**: Perform ALU operation and update PC
6. **BYTE**: Memory address calculation for load/store
7. **WAIT_LOADING**: Complete load/store operation
8. **HLT**: Halt state (triggered by ECALL)

### Memory Interface
- **Address Bus**: 32-bit byte-addressable
- **Data Bus**: 32-bit bidirectional
- **Control Signals**: 
  - `mem_rstrb`: Read strobe
  - `mem_wstrb[3:0]`: Write strobe mask (byte-level granularity)

### ALU Operations
All standard RISC-V ALU operations with proper signed/unsigned handling:
- Arithmetic: ADD, SUB
- Logic: XOR, OR, AND
- Comparison: SLT, SLTU
- Shifts: SLL, SRL, SRA (logical left, logical right, arithmetic right)

## Performance

Typical instruction timing:
- **R-type/I-type**: 5 cycles (WAIT → FETCH → DECODE → EXECUTE → WAIT)
- **Branch taken**: 5 cycles
- **Load/Store**: 7 cycles (includes BYTE and WAIT_LOADING states)
- **Jump**: 5 cycles


