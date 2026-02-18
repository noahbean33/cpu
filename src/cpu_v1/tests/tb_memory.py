import cocotb
from cocotb.triggers import RisingEdge, Timer
from tests.common import make_ir, STOREDIN, SENDDOUT, STOREREG, SENDREG, start_clock, apply_reset

@cocotb.test()
async def test_storedin_and_senddout(dut):
    # Start clock and reset
    cocotb.start_soon(start_clock(dut))
    await apply_reset(dut)

    # Program: inst_mem[0] = storedin [imm=3], then inst_mem[1] = senddout [imm=3]
    dut.inst_mem[0].value = make_ir(STOREDIN, rsrc1=0, rdst=0, imm=3)
    dut.inst_mem[1].value = make_ir(SENDDOUT, rsrc1=0, rdst=0, imm=3)

    # Drive din value
    dut.din.value = 0x00AB

    # Let a few cycles elapse to execute both instructions
    for _ in range(12):
        await RisingEdge(dut.clk)

    assert int(dut.dout.value) == 0x00AB

@cocotb.test()
async def test_storereg_and_sendreg(dut):
    cocotb.start_soon(start_clock(dut))
    await apply_reset(dut)

    # r1 <- 0x55AA via direct GPR poke, then store to mem[2], then load back into r2
    dut.GPR[1].value = 0x55AA
    dut.inst_mem[0].value = make_ir(STOREREG, rsrc1=1, imm=2)
    dut.inst_mem[1].value = make_ir(SENDREG, rdst=2, imm=2)

    for _ in range(12):
        await RisingEdge(dut.clk)

    assert int(dut.GPR[2].value) == 0x55AA
