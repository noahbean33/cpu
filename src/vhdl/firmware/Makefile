# ---------------- Toolchain ----------------
CROSS   ?= /opt/TOOL_CHAIN_COREV/bin/riscv32-corev-elf-
CC      = $(CROSS)gcc
OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump
NM      = $(CROSS)nm
READELF = $(CROSS)readelf
SIZE    = $(CROSS)size
PYTHON  = python3

# Force pure RV32I
ARCH   ?= rv32i
ABI    ?= ilp32

LINK_SCRIPT = link.ld

# Compile flags
CFLAGS  += -march=$(ARCH)
CFLAGS  += -mabi=$(ABI)
CFLAGS  += -ffreestanding
CFLAGS  += -I.
CFLAGS  += -O2

# Link flags
LDFLAGS  = -Wl,-T,$(LINK_SCRIPT)
LDFLAGS += -nostartfiles
LDFLAGS += -nostdlib
LDFLAGS += -march=$(ARCH)
LDFLAGS += -mabi=$(ABI)


# ---------------- Firmware sources ----------------
FW_DIR   = ./
FW_SRCS  = $(FW_DIR)/start.s $(FW_DIR)/firmware.c

FW_ELF   = firmware.elf
FW_MAP   = firmware.map
FW_DUMP  = firmware.dump
FW_BIN	 = firmware.bin

# ---------------- ROM outputs ----------------
INST_ROM_BIN = inst_rom.bin
INST_ROM_HEX = inst_rom.hex

DATA_ROM_BIN = data_rom.bin
DATA_ROM_HEX = data_rom.hex

# ---------------- Info ----------------
INFO_DIR        = info
ELF_HDR         = $(INFO_DIR)/readelf.txt
SECTIONS_TXT    = $(INFO_DIR)/sections.txt
SYMBOLS_TXT     = $(INFO_DIR)/symbols.txt
SIZE_TXT        = $(INFO_DIR)/size.txt
DISASM_TXT      = $(INFO_DIR)/disasm.txt
SECT_TEXT_TXT   = $(INFO_DIR)/text.txt
SECT_RODATA_TXT = $(INFO_DIR)/rodata.txt
SECT_DATA_TXT   = $(INFO_DIR)/data.txt
SECT_BSS_TXT    = $(INFO_DIR)/bss.txt

# Default build: generate both ROM images
all: $(INST_ROM_HEX) $(DATA_ROM_HEX) info

# ---------------- Link ----------------
$(FW_ELF): $(FW_SRCS)
	@$(CC) $(CFLAGS) -o $@ $(FW_SRCS) $(LDFLAGS) -Wl,-Map=$(FW_MAP),--cref

# ---------------- Disassembly ----------------
$(FW_DUMP): $(FW_ELF)
	@$(OBJDUMP) -d -j .text -M no-aliases -M numeric $< > $@

# ---------------- Instruction ROM (.text) ----------------
$(INST_ROM_BIN): $(FW_ELF)
	@$(OBJCOPY) -O binary -j .text $< $@

$(INST_ROM_HEX): $(INST_ROM_BIN)
	@$(PYTHON) bin2hex.py $< $@

# ---------------- Data ROM (.rodata + .data) ----------------
$(DATA_ROM_BIN): $(FW_ELF)
	@$(OBJCOPY) -O binary -j .rodata -j .data $< $@

$(DATA_ROM_HEX): $(DATA_ROM_BIN)
	@$(PYTHON) bin2hex.py $< $@

# ---------------- Info bundle ----------------
info: $(FW_ELF)
	@mkdir -p $(INFO_DIR)
	@$(SIZE) -A -x $(FW_ELF)                          > $(SIZE_TXT)
	@$(NM) -n $(FW_ELF)                               > $(SYMBOLS_TXT)
	@$(READELF) -h -l -S $(FW_ELF)                    > $(ELF_HDR)
	@$(OBJDUMP) -h $(FW_ELF)                          > $(SECTIONS_TXT)
	@$(OBJDUMP) -d -M no-aliases -M numeric $(FW_ELF) > $(DISASM_TXT)
	@$(OBJDUMP) -s -j .text   $(FW_ELF)               > $(SECT_TEXT_TXT)
	@$(OBJDUMP) -s -j .rodata $(FW_ELF)               > $(SECT_RODATA_TXT)
	@$(OBJDUMP) -s -j .data   $(FW_ELF)               > $(SECT_DATA_TXT)
	@$(OBJDUMP) -h $(FW_ELF) | egrep '\.bss|\.sbss'   > $(SECT_BSS_TXT)

clean:
	@rm -f $(FW_ELF) $(FW_MAP) $(FW_BIN) $(FW_DUMP)
	@rm -f $(INST_ROM_BIN) $(INST_ROM_HEX)
	@rm -f $(DATA_ROM_BIN) $(DATA_ROM_HEX)
	@rm -rf $(INFO_DIR)

.PHONY: all clean
