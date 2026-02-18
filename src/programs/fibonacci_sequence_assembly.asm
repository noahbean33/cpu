
					###################################################
					# STEP 0: Set x10 = data memory base address      #
					#         Base address = 0x00000000               #
					###################################################
	0x0000:         lui     x10, 0x00000
	0x0004:         addi    x10, x10, 0           # x10 = 0x00000000

					###################################################
					# STEP 1: Initialize first two Fibonacci values   #
					#         fib_0 = 0, fib_1 = 1                    #
					#         Stored in registers x11, x12            #
					###################################################
	0x0008:         addi    x11, x0, 0            # x11 = fib_0 = 0
	0x000C:         addi    x12, x0, 1            # x12 = fib_1 = 1

					###################################################
					# STEP 2: Store fib[0] and fib[1] into memory     #
					#         mem[0] = 0, mem[1] = 1                  #
					###################################################
	0x0010:         sw      x11, 0(x10)           # store fib[0] at mem[0]
	0x0014:         sw      x12, 4(x10)           # store fib[1] at mem[1]

					###################################################
					# STEP 3: Loop Setup                              #
					#         x13 = i = 2 (next index)                #
					#         x14 = loop limit = 10                   #
					###################################################
	0x0018:         addi    x13, x0, 2            # i = 2

	0x001C: loop_cond: addi x14, x0, 10           # x14 = 10 (number of terms)
	0x0020:           bge  x13, x14, done         # if i >= 10, jump to done

					###################################################
					# STEP 4: Compute fib[i] = fib_0 + fib_1          #
					#         Store result at memory[i]               #
					#         x15 = fib_n, x16 = offset, x17 = address#
					###################################################
	0x0024:         add     x15, x11, x12         # x15 = fib_n = fib_0 + fib_1
	0x0028:         slli    x16, x13, 2           # x16 = i * 4 (byte offset)
	0x002C:         add     x17, x10, x16         # x17 = address = base + offset
	0x0030:         sw      x15, 0(x17)           # store fib[i] = fib_n

					###################################################
					# STEP 5: Update previous two Fibonacci values    #
					#         fib_0 = fib_1, fib_1 = fib_n            #
					###################################################
	0x0034:         add     x11, x12, x0          # fib_0 = fib_1
	0x0038:         add     x12, x15, x0          # fib_1 = fib_n

					###################################################
					# STEP 6: Increment loop index i and repeat       #
					###################################################
	0x003C:         addi    x13, x13, 1           # i++
	0x0040:         jal     x0, loop_cond         # jump to loop_cond

					###################################################
					# STEP 7: Done — all Fibonacci terms generated    #
					#         Program ends (no real halt in RV32I)    #
					###################################################
	0x0044: done:   addi    x0, x0, 0             # nop (acts as halt here)
