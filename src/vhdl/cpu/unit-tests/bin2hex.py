#!/usr/bin/env python3
# Convert raw little-endian .bin into a hex file with one 32-bit word per line.
# The TB expects little-endian in RAM; we emit text hex (32-bit) per line.

import sys
from pathlib import Path

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.bin output.hex")
        sys.exit(1)

    src = Path(sys.argv[1]).read_bytes()
    # Pad to multiple of 4 bytes
    if len(src) % 4:
        src += b"\x00" * (4 - (len(src) % 4))

    with open(sys.argv[2], "w") as out:
        for i in range(0, len(src), 4):
            w = int.from_bytes(src[i:i+4], "little")
            out.write(f"{w:08X}\n")

if __name__ == "__main__":
    main()
