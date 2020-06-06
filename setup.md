# Initialize the Processor
* This section documents the steps that are needed to start executing the
  main program

## Preparing the linker

The compiled executables must be put into the right places in the flash
memory of the HiFive1.
The RAM can be accessed, but no persistent data can be stored there.

A linker definition script defines how the parts are put together into
a full image.

I also got the inspiration for this file from the Github project
`sifive/freedom-e-sdk`.
In the folder `bsp/sifive-hifive1-revb` there is the file
`metal.ramrodata.lds` that contains most of the information in this
file.
But I stripped away all definitions that I do not need (yet).

```
@Def(file: memory.lds)
	@put(lds)
@End(file: memory.lds)
```
* The linker definition script contains multiple sections.

```
@def(lds)
	OUTPUT_ARCH("riscv")
@end(lds)
```
* The architecture of the build image is RISC-V

```
@add(lds)
	ENTRY(_enter)
@end(lds)
```
* The execution will start at the label `_enter`.
* As the processor is not fully initialized at this step, the `_enter`
  code must be written in assembly language and initialize at least the
  stack and global pointer

```
@add(lds)
	MEMORY {
		ram : ORIGIN = 0x80000000, LENGTH = 0x4000
		flash : ORIGIN = 0x20010000, LENGTH = 0x6a120
	}
@end(lds)
```
* This is the main information about the memory layout.
* The flash starts at `0x20010000` and that is where the processor will
  start executing when it falls out of the boot loader.
* Also the RAM is present.

```
@add(lds)
	PHDRS {
		flash PT_LOAD;
		ram PT_NULL;
	}
@end(lds)
```
* I am not sure, what these entries do.
* TODO: read some docs.

```
@add(lds)
	SECTIONS {
		@put(sections)
	}
@end(lds)
```
* The main part of the lds file describes the sections that will be put
  in the ELF output.
* Each section has an origin, a size and may contain data (both
  executable code or static data).

```
@def(sections)
	.init : {
		*(.init)
	} >flash AT>flash :flash
@end(sections)
```
* The first section (starting at the flash start) contains the setup
  code.
* This is only a small assembly program the sets up the hardware and
  calls a C++ function for doing the main initialization.

```
@add(sections)
	.init_array : {
		PROVIDE(_init_array_begin = .);
		KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)));
		PROVIDE(_init_array_end = .);
	} >flash AT>flash :flash
@end(sections)
```
* This section is special.
* It contains a list of functions that all must be called before the
  `main` program runs.
* It contains the constructors of global variables that need to be
  invoked.
* Even our smallest program contains one of these constructors:
  `std::cout` initializes the UART.

```
@add(sections)
	. = ALIGN(8);
	.text : {
		*(.text .text*);
	} >flash AT>flash :flash
@end(sections)
```
* The `.text` section contains all the code of the `main` program.
* I am not sure, if the alignment is necessary.
* TODO: check alignment

```
@add(sections)
	.rodata : {
		*(.rodata);
		*(.sdata);
	} >flash AT>flash :flash
@end(sections)
```
* Readonly data and strings are put directly in the flash.
* So they cannot be modified directly by the running program.
* The Freedom Metal framework copies everything into RAM on startup.
* But I prefer to have more RAM available.
* It is no problem to byte-address the data in the flash.

```
@add(sections)
	.bss : {
		*(.data);
		PROVIDE(__global_pointer$ = . + 0x800);
		*(.bss);
		*(.sbss);
	} >ram AT>ram :ram
@end(sections)
```
* There is no way to have modifiable data directly in the RAM.
* All you can do is put some read-only data in the flash and copy it
  to the RAM.
* This will not be done automatically.

```
@add(sections)
	.stack : {
		. = . + 0x400;
		PROVIDE(_sp = .);
	} >ram AT>ram :ram
@end(sections)
```
* The stack has a fixed size.
* The startup code will set the stack accordingly.

## Assembly startup
* The startup code uses the information from the linker description file
  to initialize the machine accordingly.
* A special C++ function performs the high-level setup.

```
@Def(file: init.S)
	@put(init)
@End(file: init.S)
```
* An assembly file contains the startup code

```
@def(init)
	.section .init
	.global _enter
	_enter:
		@put(enter)
@end(init)
```
* The `_enter` function is the first entry point of the `.init` section.

```
@def(enter)
	.option push
	.option norelax
		la gp, __global_pointer$
	.option pop
@end(enter)
```
* To support relaxation a global pointer is set to the position specified
  in linker description file.
* Data can be fetched relative to this pointer.
* No relaxation must be performed to set this pointer.

```
@add(enter)
    la t0, early_trap_vector
    csrw mtvec, t0
@end(enter)
```
* Installs a dummy trap vector.

```
@add(init)
	.align 2
	early_trap_vector:
		j early_trap_vector
@end(init)
```
* The dummy implementation stops the processor with a busy loop.

```
@add(enter)
	la sp, _sp
	andi sp, sp, -16
@end(enter)
```
* Sets the stack pointer.
* Make sure that it is on a 16-byte boundary.

```
@add(enter)
		csrr a0, mhartid
	1:
		bnez a0, 1b
@end(enter)
```
* Only continue on core #0.

```
@add(enter)
	call setup
	call main
@end(enter)
```
* Call C++ code.

```
@add(enter)
	1:
		j 1b
@end(enter)
```
* Busy-Wait after program is finished

## C++ setup
* Calls all needed constructors

```
@Def(file: setup.cpp)
	@put(setup)
@End(file: setup.cpp)
```
* Contains setup code.

```
@def(setup)
	extern "C"
		void (**_init_array_begin)()
			__attribute__((weak));
	extern "C"
		void (**_init_array_end)()
			__attribute__((weak));
@end(setup)
```
* Begin and end of the array with setup functions.
* In very simple programs these labels may not exist (so `nullptr` will
  be used instead).

```
@add(setup)
	extern "C" void setup() {
		auto cur = _init_array_begin;
		while (cur < _init_array_end) {
			(*(*cur++))();
		}
	}
@end(setup)
```
* The setup code iterates through the array and calls the constructors.

