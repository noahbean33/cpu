    .globl  _reset
    .type   _reset, @function

_reset:
    /* ------------------------------------------------------------
     * Set up stack
     * ------------------------------------------------------------ */
    la      sp, _stack_top

    /* ------------------------------------------------------------
     * Copy .data from ROM (LMA) to RAM (VMA)
     *   _sidata = LOADADDR(.data)  (in ROM)
     *   _sdata  .. _edata          (in DATA_RAM)
     * ------------------------------------------------------------ */
    la      t0, _sidata      /* src (ROM) */
    la      t1, _sdata       /* dst (RAM) */
    la      t2, _edata       /* end (RAM) */

1:  beq     t1, t2, 2f
    lw      t3, 0(t0)
    sw      t3, 0(t1)
    addi    t0, t0, 4
    addi    t1, t1, 4
    j       1b

    /* ------------------------------------------------------------
     * Zero .bss in RAM
     *   _sbss .. _ebss
     * ------------------------------------------------------------ */
2:  la      t1, _sbss
    la      t2, _ebss
    li      t3, 0

3:  beq     t1, t2, 4f
    sw      t3, 0(t1)
    addi    t1, t1, 4
    j       3b

    /* ------------------------------------------------------------
     * Call main()
     * ------------------------------------------------------------ */
4:  call    main

    /* If main returns, park the CPU */
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
