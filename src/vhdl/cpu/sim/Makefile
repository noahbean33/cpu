# ===========================================================
# Simple RTL simulation Makefile (GHDL|ModelSim)
# - run:     make run TEST=addi [GUI=yes] [SIM=ghdl|modelsim]
# - run-all: runs all rv32ui tests; regenerates memory_pkg each time
#

SHELL := /bin/bash

# ---------------- Simulator select ----------------
SIM ?= ghdl   # ghdl (default) | modelsim

# ---------------- Paths ----------------
BUILD_DIR  := build
LOGDIR     := logs

UNIT_MKDIR := ../unit-tests
UNIT_DIR   := $(UNIT_MKDIR)/rv32ui

RTL_DIR    := ../sources
TB_DIR     := ../testbench

WORKLIB    := work
TB_TOP     := tb_cpu

MEM_PKG    := $(RTL_DIR)/memory_pkg.vhd

# ---------------- Tools ----------------
PYTHON := py -3

# ModelSim / Questa
VSIM ?= vsim
VCOM ?= vcom
VLIB ?= vlib
VMAP ?= vmap

# GHDL
GHDL      ?= ghdl
GHDL_FLAGS?= --std=08
GHDL_WORK ?= ghdl_work
VCD       ?= waves.vcd

# ---------------- Simulation knobs ----------------
TEST       ?= addi
MAX_CYCLES ?= 200000
GUI        ?= no

# Address map
INST_ROM_BASE_ADDR ?= 0x00000000
DATA_ROM_BASE_ADDR ?= 0x01000000
DATA_RAM_BASE_ADDR ?= 0x02000000
DATA_RAM_SIZE      ?= 0x1000   # bytes

# ---------------- Sources (packages first) ----------------
PKG_SRCS := \
  $(RTL_DIR)/cpu_pkg.vhd

RTL_SRCS := \
  $(RTL_DIR)/alu.vhd \
  $(RTL_DIR)/control_unit.vhd \
  $(RTL_DIR)/decode.vhd \
  $(RTL_DIR)/regfile.vhd \
  $(RTL_DIR)/inst_memory.vhd \
  $(RTL_DIR)/data_ram.vhd \
  $(RTL_DIR)/data_rom.vhd \
  $(RTL_DIR)/data_memory.vhd \
  $(RTL_DIR)/cpu.vhd \
  $(TB_DIR)/tb_cpu.vhd

# ---------------- Test discovery ----------------
UNIT_INST_HEX := $(wildcard $(UNIT_DIR)/*.inst_rom.hex)
ALL_TESTS     := $(patsubst $(UNIT_DIR)/%.inst_rom.hex,%,$(UNIT_INST_HEX))

# ---------------- ModelSim vsim flags ----------------
ifeq ($(GUI),yes)
  VSIM_MODE :=
  VSIM_DO   :=
else
  VSIM_MODE := -c
  VSIM_DO   := -do "run -all; quit -f"
endif

.PHONY: all dirs gen-mem-pkg compile run run-all waves clean

all: run

dirs:
	@mkdir -p $(BUILD_DIR) $(LOGDIR)

# ---------------- Unit tests build ----------------
unit-tests:
	@$(MAKE) -C $(UNIT_MKDIR)

# ---------------- Generate memory_pkg.vhd for TEST ----------------
# Uses hex files directly from UNIT_DIR (no copy to build/)
gen-mem-pkg: unit-tests | dirs
	@inst="$(UNIT_DIR)/$(TEST).inst_rom.hex"; \
	data="$(UNIT_DIR)/$(TEST).data_rom.hex"; \
	if [ ! -f "$$inst" ]; then echo "ERROR: missing $$inst"; exit 1; fi; \
	if [ ! -f "$$data" ]; then echo "ERROR: missing $$data"; exit 1; fi; \
	echo "[gen] $(MEM_PKG) (TEST=$(TEST))"; \
	$(PYTHON) $(RTL_DIR)/gen_memory_pkg.py \
	  "$$inst" "$$data" "$(MEM_PKG)" \
	  --inst-rom-base "$(INST_ROM_BASE_ADDR)" \
	  --data-rom-base "$(DATA_ROM_BASE_ADDR)" \
	  --data-ram-base "$(DATA_RAM_BASE_ADDR)" \
	  --data-ram-len  "$(DATA_RAM_SIZE)"

# ===========================================================
# Compile flows
# ===========================================================
.PHONY: compile_msim compile_ghdl

# ---- ModelSim compile ----
compile_msim: gen-mem-pkg
	@$(VLIB) -quiet $(WORKLIB) >/dev/null 2>&1 || true
	@$(VMAP) -quiet $(WORKLIB) $(WORKLIB) >/dev/null 2>&1 || true

	@for f in $(PKG_SRCS); do \
	  echo "[vcom] $$f"; \
	  $(VCOM) -quiet -suppress 1514 -2008 -work $(WORKLIB) $$f || exit 1; \
	done

	@echo "[vcom] $(MEM_PKG)"; \
	$(VCOM) -quiet -suppress 1514 -2008 -work $(WORKLIB) $(MEM_PKG) || exit 1

	@for f in $(RTL_SRCS); do \
	  echo "[vcom] $$f"; \
	  $(VCOM) -quiet -suppress 1514 -2008 -work $(WORKLIB) $$f || exit 1; \
	done

# ---- GHDL compile (VHDL-only) ----
compile_ghdl: gen-mem-pkg
	@mkdir -p $(GHDL_WORK)
	@echo "[ghdl] analyze"
	@$(GHDL) -i $(GHDL_FLAGS) --workdir=$(GHDL_WORK) $(PKG_SRCS) $(MEM_PKG) $(RTL_SRCS)
	@echo "[ghdl] elaborate"
	@$(GHDL) -m $(GHDL_FLAGS) --workdir=$(GHDL_WORK) $(TB_TOP)

compile:
ifeq ($(SIM),modelsim)
	@$(MAKE) --no-print-directory compile_msim
else
	@$(MAKE) --no-print-directory compile_ghdl
endif

# ===========================================================
# Run flows
# ===========================================================
.PHONY: run_msim run_ghdl

run_msim: compile | dirs
	@log="$(LOGDIR)/$(TEST).log"; \
	echo "[vsim] TEST=$(TEST) GUI=$(GUI) -> $$log"; \
	$(VSIM) $(VSIM_MODE) -quiet $(WORKLIB).$(TB_TOP) \
	  -gMAX_CYCLES=$(MAX_CYCLES) \
	  $(VSIM_DO) -l "$$log"; \
	if [ -f "$$log" ]; then sed -i '/^#    Time:/d' "$$log" || true; fi

run_ghdl: compile | dirs
	@log="$(LOGDIR)/$(TEST).log"; \
	echo "[ghdl] TEST=$(TEST) -> $$log (VCD=$(VCD))"; \
	rm -f "$(VCD)"; \
	( $(GHDL) -r $(GHDL_FLAGS) --workdir=$(GHDL_WORK) $(TB_TOP) \
	    --vcd="$(VCD)" \
	  2>&1 | tee "$$log" ) ; \
	true

run:
ifeq ($(SIM),modelsim)
	@$(MAKE) --no-print-directory run_msim
else
	@$(MAKE) --no-print-directory run_ghdl
endif

# Optional: open waves (GTKWave for GHDL, vsim -view for ModelSim)
waves:
ifeq ($(SIM),modelsim)
	@test -f "vsim.wlf" || test -f "waves.wlf" || { echo "ERROR: no .wlf found. Run with SIM=modelsim first."; exit 1; }
	@$(VSIM) -view vsim.wlf || $(VSIM) -view waves.wlf
else
	@test -f "$(VCD)" || { echo "ERROR: missing $(VCD). Run 'make run'
endif

# ---------------- Run all tests ----------------
run-all: unit-tests | dirs
	@echo "[run-all] Found $(words $(ALL_TESTS)) tests (SIM=$(SIM))"
	@passes=0; fails=0; pass_list=""; fail_list=""; missing_logs=""; \
	for t in $(ALL_TESTS); do \
	  echo; \
	  echo "================== [TEST] $$t =================="; \
	  if ! $(MAKE) --no-print-directory run TEST=$$t GUI=no SIM=$(SIM); then \
	    echo "FAIL $$t (run target returned error)"; \
	    fails=$$((fails+1)); fail_list="$$fail_list $$t"; \
	  fi; \
	  log="$(LOGDIR)/$$t.log"; \
	  if [ ! -f "$$log" ]; then \
	    echo "WARN: missing log $$log"; \
	    missing_logs="$$missing_logs $$t"; \
	    continue; \
	  fi; \
	  if grep -Eiq '(Failure:|Fatal:|Error:)' "$$log"; then \
	    echo "FAIL $$t"; \
	    fails=$$((fails+1)); fail_list="$$fail_list $$t"; \
	    grep -nEi '(Failure:|Fatal:|Error:)' "$$log" || true; \
	  else \
	    echo "PASS $$t"; \
	    passes=$$((passes+1)); pass_list="$$pass_list $$t"; \
	  fi; \
	done; \
	total=$$((passes+fails)); echo; \
	echo "================== [SUMMARY] =================="; \
	echo "Total : $$total"; echo "Pass  : $$passes"; echo "Fail  : $$fails"; \
	[ -n "$$pass_list" ] && echo "PASSED:$$pass_list" || true; \
	[ -n "$$fail_list" ] && echo "FAILED:$$fail_list" || true; \
	[ -n "$$missing_logs" ] && echo "NO_LOG:$$missing_logs" || true; \
	echo "==============================================="; \
	[ $$fails -eq 0 ]

clean:
	@rm -rf $(WORKLIB) transcript modelsim.ini vsim.wlf vsim.dbg vsim.dbg.tcl \
				*.cf *.vstf *.mpf *.mti \
				$(BUILD_DIR) \
				$(GHDL_WORK) \
				$(VCD)