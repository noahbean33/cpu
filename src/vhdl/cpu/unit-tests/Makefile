TOOLCHAIN=/opt/TOOL_CHAIN_COREV/bin/riscv32-corev-elf
PYTHON  = python3

CC      = $(TOOLCHAIN)-gcc
OBJCOPY = $(TOOLCHAIN)-objcopy
OBJDUMP = $(TOOLCHAIN)-objdump

ARCH    ?= rv32i
ABI     ?= ilp32

LINK_SCRIPT = link.ld

# Compile flags
CFLAGS  += -march=$(ARCH)
CFLAGS  += -mabi=$(ABI)
CFLAGS  += -ffreestanding
CFLAGS  += -I.

# Link flags
LDFLAGS  = -Wl,-T,$(LINK_SCRIPT)
LDFLAGS += -nostartfiles
LDFLAGS += -nostdlib
LDFLAGS += -march=$(ARCH)
LDFLAGS += -mabi=$(ABI)

# Tool flags
OBJCOPYFLAGS = -S -O binary

ifeq ($(ARCH), rv32i)
  S_FILES = $(wildcard rv32ui/*.S)
else
  S_FILES = $(wildcard rv32ui/*.S rv32um/*.S)
endif

ELF_FILES          = $(S_FILES:.S=.elf)
DUMP_FILES         = $(S_FILES:.S=.dump)
INST_ROM_BIN_FILES = $(S_FILES:.S=.inst_rom.bin)
DATA_ROM_BIN_FILES = $(S_FILES:.S=.data_rom.bin)
INST_ROM_HEX_FILES = $(S_FILES:.S=.inst_rom.hex)
DATA_ROM_HEX_FILES = $(S_FILES:.S=.data_rom.hex)

.PHONY: clean
all: $(DATA_ROM_HEX_FILES) $(INST_ROM_HEX_FILES)

.PRECIOUS: %.elf
%.elf: %.S $(LINK_SCRIPT) riscv_test.h test_macros.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

%.dump: %.elf
	$(OBJDUMP) -d -M no-aliases -M numeric $< > $@

# ---------------- Instruction ROM (.text.init) ----------------
%.inst_rom.bin: %.elf
	@$(OBJCOPY) $(OBJCOPYFLAGS) -j .text $< $@

%.inst_rom.hex: %.inst_rom.bin
	@$(PYTHON) bin2hex.py $< $@

# ---------------- Data ROM (.rodata + .data) ----------------
%.data_rom.bin: %.elf
	@$(OBJCOPY) $(OBJCOPYFLAGS) -j .rodata -j .data $< $@
	@if [ ! -s $@ ]; then printf '\x00\x00\x00\x00\x00\x00\x00\x00' > $@; fi

%.data_rom.hex: %.data_rom.bin
	@$(PYTHON) bin2hex.py $< $@

clean:
	$(RM) $(ELF_FILES) $(DUMP_FILES) \
	      $(INST_ROM_BIN_FILES) $(DATA_ROM_BIN_FILES) \
	      $(INST_ROM_HEX_FILES) $(DATA_ROM_HEX_FILES)
