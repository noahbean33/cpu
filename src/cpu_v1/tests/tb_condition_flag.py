import cocotb
from cocotb.triggers import Timer
from tests.common import make_ir, MOV, ADD, SUB, MUL

@cocotb.test()
async def test_mov_updates_flags(dut):
    # mov r1, #0 -> zero=1, sign=0
    dut.IR.value = make_ir(MOV, rdst=1, imm=0)
    await Timer(1, units="ns")
    assert int(dut.zero.value) == 1
    assert int(dut.sign.value) == 0

@cocotb.test()
async def test_add_carry_and_overflow(dut):
    # Set r2=0x7FFF; add r3, r2, #1 => 0x8000; sign=1, zero=0
    # Overflow for signed addition from + to -
    dut.GPR[2].value = 0x7FFF
    dut.IR.value = make_ir(ADD, rdst=3, rsrc1=2, imm=1)
    await Timer(1, units="ns")
    assert int(dut.GPR[3].value) == 0x8000
    assert int(dut.sign.value) == 1
    assert int(dut.zero.value) == 0

@cocotb.test()
async def test_mul_sets_zero_when_product_zero(dut):
    # r4=0; mul r5, r4, #ANY => product 0 -> zero=1
    dut.GPR[4].value = 0
    dut.IR.value = make_ir(MUL, rdst=5, rsrc1=4, imm=0x1234)
    await Timer(1, units="ns")
    assert int(dut.zero.value) == 1
