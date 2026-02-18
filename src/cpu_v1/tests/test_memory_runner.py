import pathlib
from cocotb_test.simulator import run

ROOT = pathlib.Path(__file__).resolve().parents[1]


def test_memory():
    verilog_sources = [str(ROOT / "memory.v")]
    run(
        verilog_sources=verilog_sources,
        toplevel="top",
        module="tests.tb_memory",
        sim_build=str(ROOT / "sim_build" / "memory"),
        waves=False,
        timescale="1ns/1ps",
        toplevel_lang="verilog",
    )
