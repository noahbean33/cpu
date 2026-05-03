
					###################################################
					# STEP 0: Set x10 = data memory base address      #
					#         Base address = 0x00000000               #
					###################################################
	0x0000:         lui     x10, 0x00000
	0x0004:         addi    x10, x10, 0           # x10 = 0x00000000 (data memory base)

					###################################################
					# STEP 1: Initialize array in data memory         #
					#         Array = [7, 2, 9, 4]                    #
					#         Stored at: mem[0]=7, mem[1]=2, ...      #
					###################################################
	0x0008:         addi    x11, x0, 7
	0x000C:         sw      x11, 0(x10)           # mem[0] = 7

	0x0010:         addi    x11, x0, 2
	0x0014:         sw      x11, 4(x10)           # mem[1] = 2

	0x0018:         addi    x11, x0, 9
	0x001C:         sw      x11, 8(x10)           # mem[2] = 9

	0x0020:         addi    x11, x0, 4
	0x0024:         sw      x11, 12(x10)          # mem[3] = 4

					###################################################
					# STEP 2: Initialize loop variables               #
					#   x11 = size = 4                                #
					#   x12 = size - 1 = 3 (outer loop upper bound)   #
					###################################################
	0x0028:         addi    x11, x0, 4            # total array size
	0x002C:         addi    x12, x11, -1          # x12 = 3 (loop limit for i)

	0x0030:         addi    x13, x0, 0            # x13 = i = 0 (outer loop counter)

					###################################################
					# STEP 3: Outer loop (i = 0 → size - 2)           #
					#   Each pass bubbles up the largest value        #
					#   remaining unsorted at the end of the array    #
					###################################################
	0x0034: outer_loop_cond: bge     x13, x12, sort_done     # if i >= size-1, all done
	0x0038:                  addi    x14, x0, 0              # x14 = j = 0 (inner loop counter)

					###################################################
					# STEP 4: Inner loop (j = 0 → size - i - 2)       #
					#   Compare array[j] and array[j+1]               #
					#   Swap if out of order                          #
					###################################################
	0x003C: inner_loop_cond: sub     x15, x11, x13           # x15 = size - i
	0x0040:                  addi    x15, x15, -1            # x15 = size - i - 1
	0x0044:                  bge     x14, x15, outer_loop_incr   # if j >= size-i-1 → next i

					###################################################
					# STEP 5: Load elements for comparison            #
					#   x16 = j * 4 (byte offset)                     #
					#   x17 = base address + offset                   #
					#   x18 = array[j], x19 = array[j+1]              #
					###################################################
	0x0048:                  slli    x16, x14, 2             # offset = j * 4
	0x004C:                  add     x17, x10, x16           # address of array[j]
	0x0050:                  lw      x18, 0(x17)             # load array[j]
	0x0054:                  lw      x19, 4(x17)             # load array[j+1]

					###################################################
					# STEP 6: Compare and Swap if Needed              #
					#   if array[j] >= array[j+1], skip swap          #
					#   else, swap values in memory                   #
					###################################################
	0x0058:                  bge     x18, x19, no_swap       # skip if already ordered

	0x005C:                  sw      x19, 0(x17)             # array[j]   = array[j+1]
	0x0060:                  sw      x18, 4(x17)             # array[j+1] = array[j]

					###################################################
					# STEP 7: Increment inner counter (j++)           #
					#   Repeat until j reaches size - i - 1           #
					###################################################
	0x0064: no_swap:         addi    x14, x14, 1             # j++
	0x0068:                  jal     x0, inner_loop_cond     # jump back to start of inner loop

					###################################################
					# STEP 8: Increment outer counter (i++)           #
					#   Start next pass of bubble sort                #
					###################################################
	0x006C: outer_loop_incr: addi    x13, x13, 1             # i++
	0x0070:                  jal     x0, outer_loop_cond     # repeat outer loop

					###################################################
					# STEP 9: Sorting Done                            #
					#   All elements sorted in ascending order        #
					###################################################
	0x0074: sort_done:       addi    x0, x0, 0               # nop / halt



