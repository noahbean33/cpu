SHELL := /bin/bash
PYTHON ?= python3

# ==============================================================================
# Simulator selection
#   - SIM=modelsim (default) or SIM=ghdl
#   - Examples:
#       make tb_top              # GHDL
#       make tb_top SIM=modelsim      # Modelsim
# ==============================================================================
SIM ?= ghdl

# ---------------- Paths ----------------
FW_DIR      ?= ../firmware
CPU_DIR     ?= ../cpu/sources

# ROM images produced by firmware build
INST_HEX    ?= $(FW_DIR)/inst_rom.hex
DATA_HEX    ?= $(FW_DIR)/data_rom.hex

# Generated VHDL package (local)
MEM_PKG     ?= ./sources/memory_pkg.vhd

# ---------------- Address map defaults ----------------
INST_ROM_BASE_ADDR ?= 0x00000000
DATA_ROM_BASE_ADDR ?= 0x01000000
DATA_RAM_BASE_ADDR ?= 0x02000000
DATA_RAM_SIZE      ?= 96

# ---------------- GUI / waves ----------------
GUI       ?= no
DOFILE    ?= waves.do
WAVEFILE  ?= waves.wlf
TB_TOP    ?= testbench

# For GHDL waves
VCD       ?= waves.vcd
GHDL_WAVE ?= waves.ghw
GTKWAVE   ?= gtkwave

# ==============================================================================
# ModelSim / Questa (default)
# ==============================================================================
VLIB     ?= vlib
VMAP     ?= vmap
VCOM     ?= vcom
VSIM     ?= vsim
WORKLIB  ?= work

VCOMFLAGS ?= -2008 -work $(WORKLIB) -quiet

# ==============================================================================
# GHDL
# ==============================================================================
GHDL      ?= ghdl
# adjust standard if you need: --std=08 is typical
GHDLFLAGS ?= --std=08
# GHDL library/workdir
GHDL_WORK ?= work-obj08

# ---------------- Firmware build ----------------
.PHONY: firmware roms

firmware:
	@echo "[fw] build ROM hex images in $(FW_DIR)"
	@$(MAKE) -C $(FW_DIR) clean all

roms:
	@test -f "$(INST_HEX)" || { echo "ERROR: missing $(INST_HEX)"; exit 1; }
	@test -f "$(DATA_HEX)" || { echo "ERROR: missing $(DATA_HEX)"; exit 1; }
	@echo "[fw] OK: $(INST_HEX)"
	@echo "[fw] OK: $(DATA_HEX)"

# ---------------- Generate memory_pkg.vhd ----------------
$(MEM_PKG): gen_memory_pkg.py
	@echo "[gen] $@ from:"
	@echo "      - $(INST_HEX)"
	@echo "      - $(DATA_HEX)"
	@$(PYTHON) gen_memory_pkg.py "$(INST_HEX)" "$(DATA_HEX)" "$@" \
		--inst-rom-base "$(INST_ROM_BASE_ADDR)" \
		--data-rom-base "$(DATA_ROM_BASE_ADDR)" \
		--data-ram-base "$(DATA_RAM_BASE_ADDR)" \
		--data-ram-len  "$(DATA_RAM_SIZE)"

# ==============================================================================
# Source list (single point of truth)
# ==============================================================================
RTL_VHDL = \
	./sources/uart.vhd \
	$(CPU_DIR)/cpu_pkg.vhd \
	$(MEM_PKG) \
	$(CPU_DIR)/alu.vhd \
	$(CPU_DIR)/decode.vhd \
	$(CPU_DIR)/regfile.vhd \
	$(CPU_DIR)/control_unit.vhd \
	$(CPU_DIR)/inst_memory.vhd \
	$(CPU_DIR)/data_rom.vhd \
	$(CPU_DIR)/data_ram.vhd \
	$(CPU_DIR)/data_memory.vhd \
	$(CPU_DIR)/cpu.vhd \
	./sources/soc.vhd \
	./sources/top.vhd \
	./testbench/tb_top.vhd

# ==============================================================================
# Compile (dispatch by SIM)
# ==============================================================================
.PHONY: compile compile_modelsim compile_ghdl

compile: compile_$(SIM)

compile_modelsim: $(MEM_PKG)
	@echo "[rtl] compile (ModelSim/Questa)"
	@$(VLIB) $(WORKLIB) >/dev/null 2>&1 || true
	@$(VMAP) $(WORKLIB) $(WORKLIB) >/dev/null 2>&1 || true
	@for f in $(RTL_VHDL); do \
		echo "  vcom $$f"; \
		$(VCOM) $(VCOMFLAGS) $$f; \
	done

compile_ghdl: $(MEM_PKG)
	@echo "[rtl] compile (GHDL)"
	@mkdir -p "$(GHDL_WORK)"
	@for f in $(RTL_VHDL); do \
		echo "  ghdl -a $$f"; \
		$(GHDL) -a $(GHDLFLAGS) --workdir="$(GHDL_WORK)" $$f; \
	done
	@echo "  ghdl -e $(TB_TOP)"
	@$(GHDL) -e $(GHDLFLAGS) --workdir="$(GHDL_WORK)" $(TB_TOP)

# ==============================================================================
# waves.do generation (ModelSim only)
# ==============================================================================
$(DOFILE):
	@echo "[gen] $@"
	@{ \
		echo "add wave -r /*"; \
		echo "run -all"; \
		echo "quit -f"; \
	} > "$(DOFILE)"

# ==============================================================================
# Simulation entrypoint (dispatch by SIM)
# ==============================================================================
.PHONY: tb_top tb_top_modelsim tb_top_ghdl waves

tb_top: tb_top_$(SIM)

tb_top_modelsim: $(DOFILE) compile_modelsim
ifeq ($(GUI),yes)
	@echo "[vsim] GUI, writing $(WAVEFILE)"
	@$(VSIM) -quiet -wlf "$(WAVEFILE)" -do "do $(DOFILE)" $(TB_TOP)
else
	@echo "[vsim] batch, writing $(WAVEFILE)"
	@$(VSIM) -c -quiet -wlf "$(WAVEFILE)" -do "do $(DOFILE)" $(TB_TOP)
endif

tb_top_ghdl: compile_ghdl
	@echo "[ghdl] run, writing $(VCD) and/or $(GHDL_WAVE)"
	@rm -f "$(VCD)" "$(GHDL_WAVE)"
	@# Choose ONE (VCD is most universal). Keep both if you like.
	@$(GHDL) -r $(GHDLFLAGS) --workdir="$(GHDL_WORK)" $(TB_TOP) --vcd="$(VCD)"
	@# Alternatively (comment VCD line above and use this):
	@# $(GHDL) -r $(GHDLFLAGS) --workdir="$(GHDL_WORK)" $(TB_TOP) --wave="$(GHDL_WAVE)"

waves:
ifeq ($(SIM),modelsim)
	@test -f "$(WAVEFILE)" || { echo "ERROR: missing $(WAVEFILE). Run 'make tb_top' first."; exit 1; }
	@$(VSIM) -view "$(WAVEFILE)"
else
	@test -f "$(VCD)" -o -f "$(GHDL_WAVE)" || { echo "ERROR: missing $(VCD) or $(GHDL_WAVE). Run 'make tb_top SIM=ghdl' first."; exit 1; }
	@if test -f "$(VCD)"; then \
		echo "[wave] opening $(VCD)"; \
		$(GTKWAVE) "$(VCD)"; \
	else \
		echo "[wave] opening $(GHDL_WAVE)"; \
		$(GTKWAVE) "$(GHDL_WAVE)"; \
	fi
endif

# ==============================================================================
# Clean
# ==============================================================================
.PHONY: clean

clean:
	@rm -f transcript vsim.wlf *.wlf *.vcd *.ghw "$(DOFILE)" "$(MEM_PKG)"
	@rm -rf work "$(GHDL_WORK)"
