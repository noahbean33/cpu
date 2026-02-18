# Testing with cocotb + pytest

This repo includes a pytest-friendly cocotb test suite (via `cocotb-test`). Each module is tested individually to avoid duplicate-module-name conflicts (`module top` in every file).

## Prerequisites

- A supported Verilog simulator installed and on PATH (e.g. Icarus Verilog or Verilator)
- Python 3.10+

Install Python deps:

```bash
pip install -r requirements.txt
```

## Run all tests

```bash
pytest -q
```

## Structure

- `tests/common.py` — instruction encoder and clock/reset helpers
- `tests/tb_logical_unit.py` — cocotb tests for `logical_unit.v`
- `tests/tb_condition_flag.py` — cocotb tests for `condition_flag.v`
- `tests/tb_memory.py` — cocotb tests for `memory.v` (uses clock/reset)
- `tests/test_*_runner.py` — pytest wrappers invoking `cocotb-test` to build & run sims

Notes:
- `inst_data.mem` is provided (zeroed) to satisfy `$readmemb` in `memory.v` and `branching.v`.
- The `branching.v` module is not included yet due to undefined opcodes; once fixed, add a similar runner and tb.
