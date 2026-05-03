MEMORY
{
  INST_ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 0x1000
  DATA_ROM (rx)  : ORIGIN = 0x01000000, LENGTH = 0x1000
  DATA_RAM (rwx) : ORIGIN = 0x02000000, LENGTH = 0x1000
}

SECTIONS
{
  /* -------------------- ROM -------------------- */
  .text : ALIGN(4)
  {
    _stext = .;
    KEEP(*(.text.init))
    *(.text .text.*)
    . = ALIGN(4);
    _etext = .;
  } > INST_ROM

  .rodata : ALIGN(4)
  {
    _srodata = .;
    *(.rodata .rodata.*)
    *(.srodata .srodata.*)
    . = ALIGN(4);
    _erodata = .;
  } > DATA_ROM

  /* -------------------- RAM -------------------- */
  .data : ALIGN(4)
  {
    _sdata = .;
    *(.data .data.*)
    *(.sdata .sdata.*)
    . = ALIGN(4);
    _edata = .;
  } > DATA_RAM AT > DATA_ROM
  _sidata = LOADADDR(.data);

  .bss (NOLOAD) : ALIGN(4)
  {
    _sbss = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > DATA_RAM

  _stack_top = ORIGIN(DATA_RAM) + LENGTH(DATA_RAM);
}
