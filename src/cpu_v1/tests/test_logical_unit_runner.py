import os
import pathlib
import pytest
from cocotb_test.simulator import run

ROOT = pathlib.Path(__file__).resolve().parents[1]


def test_logical_unit():
    verilog_sources = [str(ROOT / "logical_unit.v")]
    run(
        verilog_sources=verilog_sources,
        toplevel="top",
        module="tests.tb_logical_unit",
        sim_build=str(ROOT / "sim_build" / "logical_unit"),
        waves=False,
        timescale="1ns/1ps",
    )
