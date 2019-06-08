.PHONY: all clean

TARGET := riscv32-unknown-elf
CC := $(TARGET)-gcc
CXX := $(TARGET)-g++
LD := $(TARGET)-ld -T memory.lds
CXXFLAGS := -O2

all: hello.hex

hello: hello.o startup.o
	$(LD) $^ -o $@
	
hello.hex: hello
	$(TARGET)-objcopy $^ -O ihex $@

clean:
	rm -f *.o hello *.hex
