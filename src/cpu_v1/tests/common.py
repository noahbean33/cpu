# Common utilities and opcode definitions shared across tests

# Opcode encodings (from logical_unit.v / memory.v)
MOVSGPR = 0b00000
MOV     = 0b00001
ADD     = 0b00010
SUB     = 0b00011
MUL     = 0b00100
STOREREG= 0b01101
STOREDIN= 0b01110
SENDDOUT= 0b01111
SENDREG = 0b10001

# IR field bit positions (matching Verilog macros)
OPER_TYPE_SLICE = (31, 27)
RDST_SLICE      = (26, 22)
RSRC1_SLICE     = (21, 17)
IMM_MODE_BIT    = 16
RSRC2_SLICE     = (15, 11)
ISRC_SLICE      = (15, 0)


def set_bits(value: int, hi: int, lo: int, field: int) -> int:
    mask = ((1 << (hi - lo + 1)) - 1) << lo
    return (value & ~mask) | ((field << lo) & mask)


def make_ir(op: int, rdst: int = 0, rsrc1: int = 0, rsrc2: int = 0, imm: Optional[int] = None) -> int:
    """Construct a 32-bit IR matching the repo's bit layout.
    If imm is provided, IMM mode is set and ISRC takes imm (16-bit sign-extended in HW).
    """
    ir = 0
    ir = set_bits(ir, *OPER_TYPE_SLICE, op)
    ir = set_bits(ir, *RDST_SLICE, rdst & 0x1F)
    ir = set_bits(ir, *RSRC1_SLICE, rsrc1 & 0x1F)
    if imm is not None:
        # immediate mode
        ir |= (1 << IMM_MODE_BIT)
        ir = set_bits(ir, *ISRC_SLICE, imm & 0xFFFF)
    else:
        ir = set_bits(ir, *RSRC2_SLICE, rsrc2 & 0x1F)
    return ir

# ---------------- Clock / reset helpers ----------------
import cocotb
from typing import Optional
from cocotb.triggers import RisingEdge, Timer


async def start_clock(dut, signal_name: str = "clk", period_ns: int = 10):
    """Background clock generator. Call with cocotb.start_soon(start_clock(dut))."""
    clk = getattr(dut, signal_name)
    while True:
        clk.value = 0
        await Timer(period_ns // 2, units="ns")
        clk.value = 1
        await Timer(period_ns // 2, units="ns")


async def apply_reset(dut, rst_name: str = "sys_rst", cycles: int = 2):
    rst = getattr(dut, rst_name)
    rst.value = 1
    # Assume a clock is already running
    for _ in range(cycles):
        await RisingEdge(getattr(dut, "clk"))
    rst.value = 0
