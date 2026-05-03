#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path
from typing import List, Tuple, Optional

NOP_WORD = 0x00000013  # RV32I nop: addi x0, x0, 0


def parse_int_auto(s: str) -> int:
    """Parse decimal or 0x-prefixed hex."""
    return int(s, 0)


def round_down4(x: int) -> int:
    return x & ~0x3


def round_up4(x: int) -> int:
    return (x + 3) & ~0x3


def fmt_hex32(w: int) -> str:
    return f"{w & 0xFFFFFFFF:08X}"


def fmt_byte(b: int) -> str:
    return f"{b & 0xFF:02X}"


def word_to_bytes_le(w: int) -> Tuple[int, int, int, int]:
    """Return (b0,b1,b2,b3) where b0 is lowest address byte (little-endian)."""
    b0 = (w >> 0) & 0xFF
    b1 = (w >> 8) & 0xFF
    b2 = (w >> 16) & 0xFF
    b3 = (w >> 24) & 0xFF
    return b0, b1, b2, b3


def read_hex_words_32(hex_path: Path) -> List[int]:
    """
    Read a simple HEX file containing one 32-bit word per line.
    Accepts:
      - "1234ABCD"
      - "0x1234ABCD"
      - underscores inside: "1234_ABCD"
    Ignores blank lines and lines starting with '#' or '//'.
    """
    words: List[int] = []

    with hex_path.open("r") as f:
        for lineno, line in enumerate(f, start=1):
            s = line.strip()
            if not s:
                continue
            if s.startswith("#") or s.startswith("//"):
                continue

            if s.lower().startswith("0x"):
                s = s[2:]
            s = s.replace("_", "")

            if len(s) > 8:
                raise ValueError(f"{hex_path}:{lineno}: '{s}' too long (expected 8 hex chars)")

            s = s.zfill(8)

            try:
                w = int(s, 16) & 0xFFFFFFFF
            except ValueError:
                raise ValueError(f"{hex_path}:{lineno}: invalid hex word '{s}'")

            words.append(w)

    if not words:
        raise ValueError(f"{hex_path}: file is empty (no 32-bit words found)")
    return words


def pad_or_truncate_words(words: List[int], target_words: int, pad_word: int) -> List[int]:
    if len(words) < target_words:
        return words + [pad_word] * (target_words - len(words))
    return words[:target_words]


def main() -> int:
    p = argparse.ArgumentParser(
        description=(
            "Generate memory_pkg.vhd from two HEX files:\n"
            "  - instr_rom.hex: 32-bit words per line -> INSTRUCTION_MEMORY_CONTENT\n"
            "  - data_rom.hex : 32-bit words per line -> DATA_ROM_MEMORY_CONTENT (byte addressable)\n\n"
            "Defaults:\n"
            "  INST_ROM base = 0x00000000, length = size of instr_rom.hex\n"
            "  DATA_ROM base = 0x01000000, length = size of data_rom.hex\n"
            "  DATA_RAM base = 0x02000000, length = 0x1000\n"
        )
    )

    p.add_argument("instr_hex", type=Path, help="Input instr_rom.hex (32-bit word per line)")
    p.add_argument("data_hex", type=Path, help="Input data_rom.hex (32-bit word per line)")
    p.add_argument("output_vhd", type=Path, help="Output VHDL package file")

    p.add_argument("--inst-rom-base", type=parse_int_auto, default=0x00000000,
                   help="INST_ROM base address (default 0x00000000)")
    p.add_argument("--data-rom-base", type=parse_int_auto, default=0x01000000,
                   help="DATA_ROM base address (default 0x01000000)")
    p.add_argument("--data-ram-base", type=parse_int_auto, default=0x02000000,
                   help="DATA_RAM base address (default 0x02000000)")

    p.add_argument("--inst-rom-len", type=parse_int_auto, default=None,
                   help="INST_ROM length in bytes (default: derived from instr_rom.hex)")
    p.add_argument("--data-rom-len", type=parse_int_auto, default=None,
                   help="DATA_ROM length in bytes (default: derived from data_rom.hex)")
    p.add_argument("--data-ram-len", type=parse_int_auto, default=0x1000,
                   help="DATA_RAM length in bytes (default 0x1000)")

    args = p.parse_args()

    # ---- basic file checks
    if not args.instr_hex.is_file():
        print(f"ERROR: instr_hex '{args.instr_hex}' not found", file=sys.stderr)
        return 1
    if not args.data_hex.is_file():
        print(f"ERROR: data_hex '{args.data_hex}' not found", file=sys.stderr)
        return 1

    # ---- read content
    try:
        instr_words = read_hex_words_32(args.instr_hex)
        data_words = read_hex_words_32(args.data_hex)
    except ValueError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1

    # ---- derive default lengths (bytes)
    inst_len_bytes: int = args.inst_rom_len if args.inst_rom_len is not None else (len(instr_words) * 4)
    data_len_bytes: int = args.data_rom_len if args.data_rom_len is not None else (len(data_words) * 4)
    ram_len_bytes: int = args.data_ram_len

    # ---- enforce alignment
    if args.inst_rom_base % 4 != 0:
        print(f"WARNING: inst-rom-base 0x{args.inst_rom_base:X} not 4B aligned, rounding down.", file=sys.stderr)
        args.inst_rom_base = round_down4(args.inst_rom_base)

    if args.data_rom_base % 4 != 0:
        print(f"WARNING: data-rom-base 0x{args.data_rom_base:X} not 4B aligned, rounding down.", file=sys.stderr)
        args.data_rom_base = round_down4(args.data_rom_base)

    if args.data_ram_base % 4 != 0:
        print(f"WARNING: data-ram-base 0x{args.data_ram_base:X} not 4B aligned, rounding down.", file=sys.stderr)
        args.data_ram_base = round_down4(args.data_ram_base)

    if inst_len_bytes % 4 != 0:
        print(f"WARNING: INST_ROM length {inst_len_bytes} not multiple of 4, rounding up.", file=sys.stderr)
        inst_len_bytes = round_up4(inst_len_bytes)

    if data_len_bytes % 4 != 0:
        print(f"WARNING: DATA_ROM length {data_len_bytes} not multiple of 4, rounding up.", file=sys.stderr)
        data_len_bytes = round_up4(data_len_bytes)

    if ram_len_bytes % 4 != 0:
        print(f"WARNING: DATA_RAM length {ram_len_bytes} not multiple of 4, rounding down.", file=sys.stderr)
        ram_len_bytes = round_down4(ram_len_bytes)

    inst_words_target = inst_len_bytes // 4
    data_words_target = data_len_bytes // 4

    # ---- pad/truncate to match requested image sizes
    instr_words = pad_or_truncate_words(instr_words, inst_words_target, NOP_WORD)
    data_words = pad_or_truncate_words(data_words, data_words_target, 0x00000000)

    out = args.output_vhd
    with out.open("w") as f:
        f.write("-- Auto-generated by gen_memory_pkg.py\n")
        f.write(f"-- Source instr HEX: {args.instr_hex.name}\n")
        f.write(f"-- Source data  HEX: {args.data_hex.name}\n")
        f.write("-- Do not edit by hand.\n\n")

        f.write("library ieee;\n")
        f.write("use ieee.std_logic_1164.all;\n\n")

        f.write("package memory_pkg is\n\n")

        # ---------------------------------------------------------------------
        # Instruction memory
        # ---------------------------------------------------------------------
        f.write("  -----------------------------------------------------------------------------\n")
        f.write("  -- Instruction memory\n")
        f.write("  -----------------------------------------------------------------------------\n")
        f.write(f"  constant INST_ROM_BASE_ADDRESS          : integer := 16#{args.inst_rom_base:08X}#;\n")
        f.write(f"  constant INSTRUCTION_MEMORY_SIZE_BYTES  : integer := {inst_len_bytes};\n")
        f.write("  constant INSTRUCTION_MEMORY_SIZE_WORDS  : integer := INSTRUCTION_MEMORY_SIZE_BYTES / 4;\n\n")

        f.write("  type INSTRUCTION_MEMORY_ARRAY_t is array (0 to INSTRUCTION_MEMORY_SIZE_WORDS-1)\n")
        f.write("    of std_logic_vector(31 downto 0);\n\n")

        f.write("  constant INSTRUCTION_MEMORY_CONTENT : INSTRUCTION_MEMORY_ARRAY_t := (\n")
        for i, w in enumerate(instr_words):
            comma = "," if i != len(instr_words) - 1 else ""
            f.write(f"    x\"{fmt_hex32(w)}\"{comma}  -- word {i}\n")
        f.write("  );\n\n")

        # ---------------------------------------------------------------------
        # Data RAM
        # ---------------------------------------------------------------------
        f.write("  -----------------------------------------------------------------------------\n")
        f.write("  -- Data RAM\n")
        f.write("  -----------------------------------------------------------------------------\n")
        f.write(f"  constant DATA_RAM_BASE_ADDRESS        : integer := 16#{args.data_ram_base:08X}#;\n")
        f.write(f"  constant DATA_RAM_MEMORY_SIZE_BYTES   : integer := {ram_len_bytes};\n")
        f.write("  constant DATA_RAM_MEMORY_SIZE_WORDS   : integer := DATA_RAM_MEMORY_SIZE_BYTES / 4;\n\n")

        f.write("  type DATA_RAM_MEMORY_ARRAY_t is array (0 to DATA_RAM_MEMORY_SIZE_WORDS-1)\n")
        f.write("    of std_logic_vector(31 downto 0);\n\n")

        # ---------------------------------------------------------------------
        # Data ROM
        # ---------------------------------------------------------------------
        f.write("  -----------------------------------------------------------------------------\n")
        f.write("  -- Data ROM\n")
        f.write("  -----------------------------------------------------------------------------\n")
        f.write(f"  constant DATA_ROM_BASE_ADDRESS        : integer := 16#{args.data_rom_base:08X}#;\n")
        f.write(f"  constant DATA_ROM_MEMORY_SIZE_BYTES   : integer := {data_len_bytes};\n")
        f.write("  constant DATA_ROM_MEMORY_SIZE_WORDS   : integer := DATA_ROM_MEMORY_SIZE_BYTES / 4;\n\n")

        f.write("  type DATA_ROM_MEMORY_ARRAY_t is array (0 to DATA_ROM_MEMORY_SIZE_WORDS-1)\n")
        f.write("    of std_logic_vector(31 downto 0);\n\n")

        f.write("  constant DATA_ROM_MEMORY_CONTENT : DATA_ROM_MEMORY_ARRAY_t := (\n")
        for i, w in enumerate(data_words):
            comma = "," if i != len(data_words) - 1 else ""
            f.write(f"    x\"{fmt_hex32(w)}\"{comma}  -- word {i}\n")
        f.write("  );\n\n")

        f.write("end package memory_pkg;\n\n")
        f.write("package body memory_pkg is\n")
        f.write("end package body memory_pkg;\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
