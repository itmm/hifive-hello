.section .init
.global _enter
_enter:

.option push
.option norelax
	// set global pointer to enable indexed access
	la gp, __global_pointer$
.option pop

	// install dummy trap vector
    la t0, early_trap_vector
    csrw mtvec, t0
	
	// set stack pointer; make sure that it is on a 16-byte boundary
	la sp, _stack_end
	andi sp, sp, -16
	
	// only continue on core #0
	csrr a0, mhartid
1:
	bnez a0, 1b

	// zero BSS segment
  	la t1, _bss_begin
 	la t2, _bss_end
	bge t1, t2, 2f
1:
	sw x0, (t1)
	addi t1, t1, 4
	blt t1, t2, 1b
2:

	// main program
	call main

	// spin to death
1:
	j 1b

// dummy trap vector
.align 2
early_trap_vector:
    j early_trap_vector

