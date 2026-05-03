    .section .text.init
    .globl  _reset
    .type   _reset, @function

_reset:
    /* ------------------------------------------------------------
     * LED base (MMIO)
     * ------------------------------------------------------------ */
    li      t4, 0x04000000          /* t4 = LED register address */
    li      t5, 0x01
    sw      t5, 0(t4)               /* LED = 0x01 : stack set */

    /* ------------------------------------------------------------
     * Set up stack
     * ------------------------------------------------------------ */
    la      sp, _stack_top
    li      t5, 0x03
    sw      t5, 0(t4)               /* LED = 0x03 : stack set */

    /* ------------------------------------------------------------
     * Copy .data from ROM (LMA) to RAM (VMA)
     *   _sidata = LOADADDR(.data)  (in ROM)
     *   _sdata  .. _edata          (in DATA_RAM)
     * ------------------------------------------------------------ */
    la      t0, _sidata             /* src (ROM) */
    la      t1, _sdata              /* dst (RAM) */
    la      t2, _edata              /* end (RAM) */

1:  beq     t1, t2, 2f
    lw      t3, 0(t0)
    sw      t3, 0(t1)
    addi    t0, t0, 4
    addi    t1, t1, 4
    j       1b

2:  li      t5, 0x7
    sw      t5, 0(t4)               /* LED = 0x07 : .data copied */

    /* ------------------------------------------------------------
     * Zero .bss in RAM
     *   _sbss .. _ebss
     * ------------------------------------------------------------ */
    la      t1, _sbss
    la      t2, _ebss
    li      t3, 0

3:  beq     t1, t2, 4f
    sw      t3, 0(t1)
    addi    t1, t1, 4
    j       3b

4:  li      t5, 0xF
    sw      t5, 0(t4)               /* LED = 0xF : .bss zeroed */

    /* ------------------------------------------------------------
     * Call main()
     * ------------------------------------------------------------ */
    li      t5, 0x1F
    sw      t5, 0(t4)               /* LED = 0x1F : calling main */
    call    main

    /* If main returns, park the CPU */
    li      t5, 0x7F
    sw      t5, 0(t4)               /* LED = 0x3F : main returned (unexpected) */
5:  j       5b

    .size _reset, . - _reset

    /* ------------------------------------------------------------
     * Linker-provided symbols
     * ------------------------------------------------------------ */
    .extern _stack_top
    .extern _sidata
    .extern _sdata
    .extern _edata
    .extern _sbss
    .extern _ebss
    .extern main
