# Known Issues / TODO

This document tracks the outstanding problems discovered during the initial review of the repository.

## Critical build-blocking issues

1. **Missing instruction memory image**  
   * `memory.v` and `branching.v` execute `\$readmemb("inst_data.mem", inst_mem);`, but `inst_data.mem` is **not present**.  
   * Simulation will fail immediately with a file-open error.

2. **Undefined opcode macros in `branching.v`**  
   * The decoder references ``jump`` and ``halt`` but no ``\`define`` statements exist.  
   * Leads to "macro undefined" compile errors.

3. **Duplicate module names**  
   * Four source files (`logical_unit.v`, `memory.v`, `branching.v`, `condition_flag.v`) each declare `module top`.  
   * Attempting to elaborate more than one of them together produces duplicate-definition errors.

## Design / maintenance concerns

4. **Code duplication and divergence**  
   * Opcode lists and flag calculations are copied into multiple files. They already differ (e.g. overflow logic), risking silent mismatches.  
   * Recommendation: move all common definitions into a single header `defines.vh` and `\`include` it.

5. **Flag logic inconsistencies**  
   * Overflow & carry formulas differ between modules; some modules never update certain flags.  
   * Once a unified ALU is built these inconsistencies will propagate incorrect behaviour.

## Minor technical quirks / clean-ups

6. **Program-counter sizing**  
   * Example: `integer PC` (signed 32-bit) in `branching.v` only addresses 16 words. Use a fixed-width unsigned reg, e.g. `reg [3:0] PC;`.

7. **Mixed blocking / sequential assignments**  
   * Some `always @(*)` blocks assign to regs that are also written in `always @(posedge clk)` blocks in other designs. When modules are combined, this may create unintended latch behaviour.

8. **Unreachable flag resets**  
   * Several always blocks reset `sign/zero/overflow/carry` at every combinational evaluation. If these flags are meant to be clocked, move them into synchronous logic.

---

_Last updated: 2025-08-06_
