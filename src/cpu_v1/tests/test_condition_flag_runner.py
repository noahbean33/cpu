import os
import pathlib
from cocotb_test.simulator import run

ROOT = pathlib.Path(__file__).resolve().parents[1]


def test_condition_flag():
    verilog_sources = [str(ROOT / "condition_flag.v")]
    run(
        verilog_sources=verilog_sources,
        toplevel="top",
        module="tests.tb_condition_flag",
        sim_build=str(ROOT / "sim_build" / "condition_flag"),
        waves=False,
        timescale="1ns/1ps",
    )
