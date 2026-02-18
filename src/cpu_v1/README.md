
# **Verilog Processor**

This repository contains the Verilog implementation of a simple processor, including its modules, testbenches, and detailed instructions on its functionality.

---

## **Processor Overview**
The Verilog Processor is a basic custom-designed CPU that supports arithmetic and logical operations, branching, memory access, and condition flag updates. It provides a minimal instruction set and modular design for educational and experimental purposes.

---

## **Features**
1. **Instruction Set:**
   - Support for basic arithmetic and logical operations.
   - Immediate and register-based addressing modes.
   - Multiplication with MSB stored in a special-purpose register (`SGPR`).

2. **Condition Flags:**
   - **Zero:** Set when the result of an operation is zero.
   - **Sign:** Set if the result is negative.
   - **Carry:** Set if an addition or subtraction operation generates a carry/borrow.
   - **Overflow:** Set if an operation results in an arithmetic overflow.

3. **Modules:**
   - **Logical Unit:** Performs operations like addition, subtraction, and logical functions (`AND`, `OR`, `XOR`, etc.).
   - **Memory Unit:** Handles instruction and data memory.
   - **Branching Logic:** Implements conditional and unconditional branching.
   - **Condition Flag Handling:** Updates condition flags based on the results of operations.

4. **Testbenches:**
   - Comprehensive testbenches for each module.
   - Automated validation of operations with `assert` statements for robust testing.

---

## **Instruction Set**

| **Instruction**  | **Format**                         | **Description**                                    |
|-------------------|------------------------------------|----------------------------------------------------|
| `movsgpr`         | `movsgpr rdst`                    | Copies `SGPR` value (MSB of `mul`) to `rdst`.      |
| `mov`             | `mov rdst, rsrc`                  | Moves value from `rsrc` to `rdst`.                |
| `add`             | `add rdst, rsrc1, rsrc2`          | Adds `rsrc1` and `rsrc2`, stores in `rdst`.        |
| `sub`             | `sub rdst, rsrc1, rsrc2`          | Subtracts `rsrc2` from `rsrc1`, stores in `rdst`.  |
| `mul`             | `mul rdst, rsrc1, rsrc2`          | Multiplies `rsrc1` and `rsrc2`, stores LSB in `rdst` and MSB in `SGPR`. |

---

## **Files and Directory Structure**

### **Source Files**
- `logical_unit.v`: Implements arithmetic and logical operations.
- `memory.v`: Manages instruction and data memory.
- `branching.v`: Handles conditional and unconditional branching.
- `condition_flag.v`: Updates and maintains condition flags.

### **Testbenches**
- `logical_unit_test_bench.v`: Verifies operations in the logical unit.
- `memory_test_bench.v`: Tests memory read/write operations.
- `branching_test_bench.v`: Tests branching instructions and program counter behavior.
- `condition_flag_test_bench.v`: Validates the behavior of condition flags for various operations.

---

## **How to Run**

### **1. Prerequisites**
- Verilog simulation tool (e.g., ModelSim, Verilator, or Xilinx Vivado).

### **2. Steps**
1. Clone this repository:
   ```bash
   git clone https://github.com/noahbean33/verilog_processor.git
   cd verilog_processor
   ```
2. Run the simulation for a specific testbench:
   ```bash
   verilator --cc --exe --build logical_unit_test_bench.v logical_unit.v
   ./obj_dir/Vlogical_unit_test_bench
   ```

3. Observe the simulation output and validate results.

---

## **Future Possibilities**

This processor serves as a foundational implementation that can be extended with the following features:

1. **Pipelining:**
   - Add instruction pipelining to improve processor efficiency and throughput by overlapping instruction fetch, decode, and execute stages.

2. **Interrupt and Exception Handling:**
   - Implement mechanisms to handle hardware and software interrupts, exceptions, and error recovery.

3. **Cache Memory:**
   - Integrate caching to optimize memory access and reduce latency.

4. **Peripheral Interfaces:**
   - Add interfaces to communicate with peripherals such as I/O devices, UART, or GPIO.

5. **Advanced Arithmetic:**
   - Extend the instruction set to include division, floating-point operations, and other advanced arithmetic.

6. **Dynamic Branch Prediction:**
   - Implement branch prediction to reduce control hazards during branching.

7. **Multithreading:**
   - Introduce multithreading capabilities to execute multiple instruction streams concurrently.

8. **Instruction Expansion:**
   - Add support for complex instructions, including bit manipulation, shifts, and specialized operations.

9. **Enhanced Testing:**
   - Include formal verification and additional corner-case test scenarios to ensure robustness.

10. **FPGA Deployment:**
    - Adapt the design for implementation on FPGA hardware for practical demonstrations.

---

## **Contributions**
Contributions to improve the design or add new features are welcome! Please create a pull request or open an issue with your suggestions.

---

## **License**
This project is licensed under the MIT License. See the `LICENSE` file for more details.

---

## **Acknowledgments**
Special thanks to the contributors and the Verilog community for their valuable feedback and resources.
