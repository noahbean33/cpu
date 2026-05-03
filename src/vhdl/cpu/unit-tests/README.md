# riscv-tests

Theses tests are directly imported and adapted from https://github.com/riscv-software-src/riscv-tests/

The target platform is much simpler (only unpriviledged instructions) and the compile process is
simplified to a simple call to `make`. The tested emulator **MUST** support two semihosting calls
for tests to work fluently.

The only supported architecture is `rv32i` so the included tests are only the RV32I instructions in
user mode.

# Using the tests

Compile the tests using `make`. For each test, a corresponding `.bin` file will be produced. This
binary file is designed to be loaded on a riscv platform that supports the following constraints:

1. the first instruction is at address 0
2. when a test fails, a semihosting call is made for the operation `0x102`. This means that when a
   test fails, the following instructions are executed :
   ```asm
   slli x0, x0, 0x1f
   ebreak
   srai x0, x0, 7
   ```
   the register `a0` (`x10`) will hold the value `0x102` and the register `a1` (`x11`) will hold the
   index of the failing test.
3. when all tests succeed, a semihosting call is made with `0x101` as operation number (in register `a0`)

The expected behavior for the tested emulator is:

- to exit with a `0` return code on operation `0x101`,
- to exit with a `>0` return code on operation `0x102` (the failing test number for example). It
  also may output the failing test number on its standard error output.

To see which test have failed, simply disassemble the `elf` file corresponding to the `bin` file
(*e.g.* `add.elf` for `add.bin`) using

```
riscv64-unknown-elf-objdump -d add.elf
```

and look for the label `test_NNNNN` where `NNNNN` is the number of the failing test.

# Running all tests

Define the `EMULATOR` environment variable to your emulator's command line. The `bin` file path will
be appended to this value. Then run

```
make test
```

You can also directly define the `EMULATOR` variable in the `make` command line instead of a
environment variable.

```
make EMULATOR=my-riscv-emu test
```

All tests will be run in sequence. If a test fails (*i.e.* the emulator process exists with an error
exit status) the remaining tests will not be run.

