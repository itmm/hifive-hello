# Putting the executable on the HiFive1
* This section describes the Makefile that is used to build the image.

```
@Def(file: Makefile)
	@put(entries)
@End(file: Makefile)
```
* Entries in the `Makefile`.

```
@def(entries)
.PHONY: all clean
@end(entries)
```
* There exist two main targets in the `Makefile`.
* The `all` target builds everything.
* The `clean` target removes all temporary files.

```
@add(entries)
all: hello.hex
@end(entries)
```
* The main target is an Intel Hex file of the image that can be copied on
  the device.

## `hx` part
* Generates source files from the `hx` sources

```
@add(entries)
HXs := $(wildcard *.x)
@end(entries)
```
* The `hx` sources are all files ending in `.x`.

```
@add(entries)
SRCs := $(shell hx-files.sh $(HXs))
@end(entries)
```
* The sources are all files that are generated from the `hx` files.
* `hx` provides a script to get these filenames.

```
@add(entries)
OBJs := $(filter %.o, $(SRCs:.S=.o) $(SRCs:.cpp=.o))
@end(entries)
```
* Object files are only generated from assembler and C++ sources.

```
@add(entries)
hx-run: $(HXs)
	hx
	touch $@
@end(entries)
```
* A special dummy file is used to check if `hx` must run again.
* As `hx` is not touching files that are not changed it will be otherwise
  invoked too often.

```
@add(entries)
$(SRCs): hx-run
@end(entries)
```
* The generated files can be treated as up to date, if the dummy file is
  newer than the `hx` files.

## Building for RISC-V

```
@add(entries)
TARGET := riscv32-unknown-elf
@end(entries)
```
* The target is a prefix of all programs in the toolchain.

```
@add(entries)
CC := $(TARGET)-gcc
CXX := $(TARGET)-g++
LD := $(TARGET)-ld -T memory.lds
@end(entries)
```
* The compilers and linker are changed to build for RISC-V.
* The C compiler is used to assemble the assembly files.

```
@add(entries)
CXXFLAGS += -MD -Wall -O2 -I.
CFLAGS += -MD -Wall -O2
@end(entries)
```
* The compilers are optimizing for size.
* All warnings will be printed.
* Dependency files will be generated.
* The C++ compiler will include files from the local directory before
  using system includes.
* This is needed, because the C++ library is not build for the HiFive1.

```
@add(entries)
hello: $(OBJs)
	$(LD) $^ -o $@
@end(entries)
```
* Link executable

```
@add(entries)
hello.hex: hello
	$(TARGET)-objcopy $^ -O ihex $@
@end(entries)
```
* Generate Intel Hex file.

```
@add(entries)
iostream: iostream.h
	@echo >/dev/null
@end(entries)
```
* `make` treats `iostream` as the name of an executable.
* An empty rule is provided, so that the default linking rule will not be
  used.

## Dependency management
* Include dependency files

```
@add(entries)
DEPs := $(wildcard *.d)
ifneq ($(DEPs),)
  include $(DEPs)
endif
@end(entries)
```
* If there are dependency files, they will be included.

## Clean
* Remove temporary files

```
@add(entries)
clean:
	rm -f $(OBJs) $(DEPs) hello
	rm -f hello.hex hx-run
@end(entries)
```
* Remove all temporary files

