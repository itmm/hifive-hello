# hello

```
@Def(file: hello.cpp)
#include <iostream>

int main() {
	std::cout << "Hello World!\n";
}
@End(file: hello.cpp)
```

```
@Def(file: iostream.h)
#pragma once

namespace std {
	class ostream {
			volatile int *port() {
				return reinterpret_cast<
					volatile int *
				>(0x10013000);
			}
			void put(char c) {
				while (*port() < 0) { }
				*port() = c;
			}
		public:
			ostream() {
				static const int tx_control { 0x08 };
				port()[tx_control] |= 1;
			}

			ostream &operator<<(const char *s) {
				if (s) for (; *s; ++s) {
					if (*s == '\n') {
						put('\r');
					}
					put(*s);
				}
				return *this;
			}
	};

	extern ostream cout;
}
@End(file: iostream.h)
```

```
@Def(file: iostream)
#include "iostream.h"
@End(file: iostream)
```

```
@Def(file: iostream.cpp)
#include "iostream.h"

std::ostream std::cout;
@End(file: iostream.cpp)
```

```
@Def(file: init.S)
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

	call setup
	call main

	// spin to death
1:
	j 1b

// dummy trap vector
.align 2
early_trap_vector:
    j early_trap_vector

@End(file: init.S)
```

```
@Def(file: setup.cpp)
extern "C" int *_bss_begin __attribute__((weak));
extern "C" int *_bss_end __attribute__((weak));

static inline void clear_bss() {
	auto cur = _bss_begin;
	while (cur < _bss_end) {
		*cur++ = 0;
	}
}

extern "C" void (**_init_array_begin)() __attribute__((weak));
extern "C" void (**_init_array_end)() __attribute__((weak));

static inline void construct_globals() {
	auto cur = _init_array_begin;
	while (cur < _init_array_end) {
		(*(*cur++))();
	}
}

extern "C" void setup() {
	clear_bss();
	construct_globals();
}
@End(file: setup.cpp)
```

```
@Def(file: memory.lds)
OUTPUT_ARCH("riscv")

ENTRY(_enter)

MEMORY
{
	ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 0x4000
	flash (rxai!w) : ORIGIN = 0x20010000, LENGTH = 0x6a120
}

PHDRS
{
	flash PT_LOAD;
	ram PT_NULL;
}

SECTIONS
{
	__stack_size = DEFINED(__stack_size) ? __stack_size : 0x400;
	__heap_size = DEFINED(__heap_size) ? __heap_size : 0x400;

	.init 		:
	{
		*(.init)
	} >flash AT>flash :flash

	.init_array : {
		PROVIDE ( _init_array_begin = . );
		KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)));
		PROVIDE ( _init_array_end = . );
	} >flash AT>flash :flash

	. = ALIGN(8);
	.text 		:
	{
		*(.text .text*)
	} >flash AT>flash :flash


	.rodata :
	{
		*(.rodata)
		*(.sdata)
	} >flash AT>flash :flash
	
	.data 		:
	{
		*(.data)
		PROVIDE( __global_pointer$ = . + 0x800 );
	} >ram AT>ram :ram

	PROVIDE(_bss_begin = . );
	.bss 		:
	{
		*(.bss)
	} >ram AT>ram :ram
	PROVIDE(_bss_end = . );


	.stack :
	{
		PROVIDE(_stack_begin = .);
		. = __stack_size;
		PROVIDE( _sp = . );
		PROVIDE(_stack_end = .);
	} >ram AT>ram :ram


	.heap :
	{
		PROVIDE(_heap_begin = . );
		. = __heap_size;
		. = __heap_size == 0 ? 0 : ORIGIN(ram) + LENGTH(ram);
		PROVIDE( _heap_end = . );
	} >ram AT>ram :ram
}

@End(file: memory.lds)
```

```
@Def(file: Makefile)
.PHONY: all clean

HXs := $(wildcard *.x)
SRCs := $(shell hx-files.sh $(HXs))
OBJs := $(filter %.o, $(SRCs:.S=.o) $(SRCs:.cpp=.o))

all: hello.hex

hx-run: $(HXs)
	hx
	touch $@

TARGET := riscv32-unknown-elf
CC := $(TARGET)-gcc
CXX := $(TARGET)-g++
LD := $(TARGET)-ld -T memory.lds
CXXFLAGS += -MD -O2 -I.
CFLAGS += -MD

$(OBJs): hx-run

hello: $(OBJs)
	$(LD) $^ -o $@
	
hello.hex: hello
	$(TARGET)-objcopy $^ -O ihex $@

clean:
	rm -f $(OBJs) hello hello hello.hex hx-run

hxs:
	@echo ${HXs}

srcs:
	@echo ${SRCs}

objs:
	@echo ${OBJs}

iostream: iostream.h
	@echo

DEPs := $(wildcard *.d)
ifneq ($(DEPs),)
  include $(DEPs)
endif
@End(file: Makefile)
```

