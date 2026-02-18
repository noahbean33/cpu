import cocotb
from cocotb.triggers import Timer
from tests.common import make_ir, MOV, ADD, SUB, MUL

# Helper to write a GPR value via hierarchical access
async def set_gpr(dut, idx, value):
    # GPR is an unpacked array: GPR[31:0] each 16-bit
    getattr(dut, "GPR")[idx].value = value & 0xFFFF
    await Timer(1, units="ns")

async def read_gpr(dut, idx):
    await Timer(1, units="ns")
    return int(getattr(dut, "GPR")[idx].value)

@cocotb.test()
async def test_mov_imm(dut):
    # mov r1, #0x1234
    dut.IR.value = make_ir(MOV, rdst=1, rsrc1=0, imm=0x1234)
    await Timer(1, units="ns")
    assert await read_gpr(dut, 1) == 0x1234

@cocotb.test()
async def test_add_imm(dut):
    # r2 = 0x0001; add r3, r2, #0x0002 => 0x0003
    await set_gpr(dut, 2, 0x0001)
    dut.IR.value = make_ir(ADD, rdst=3, rsrc1=2, imm=0x0002)
    await Timer(1, units="ns")
    assert await read_gpr(dut, 3) == 0x0003

@cocotb.test()
async def test_sub_imm(dut):
    # r4 = 5; sub r5, r4, #3 => 2
    await set_gpr(dut, 4, 5)
    dut.IR.value = make_ir(SUB, rdst=5, rsrc1=4, imm=3)
    await Timer(1, units="ns")
    assert await read_gpr(dut, 5) == 2

@cocotb.test()
async def test_mul_imm_and_sgpr(dut):
    # r6 = 0x1234; mul r7, r6, #0x0011 => 0x1234*0x11 = 0x13574
    await set_gpr(dut, 6, 0x1234)
    dut.IR.value = make_ir(MUL, rdst=7, rsrc1=6, imm=0x0011)
    await Timer(1, units="ns")
    low = await read_gpr(dut, 7)
    sgpr = int(dut.SGPR.value)
    prod = 0x1234 * 0x11
    assert low == (prod & 0xFFFF)
    assert sgpr == ((prod >> 16) & 0xFFFF)
