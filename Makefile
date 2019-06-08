.PHONY: all clean

TARGET := riscv32-unknown-elf
CC := $(TARGET)-gcc
LD := $(TARGET)-ld -T memory.lds

all: hello.hex

hello: hello.o
	$(LD) $^ -o $@
	
hello.hex: hello
	$(TARGET)-objcopy $^ -O ihex $@

clean:
	rm -f *.o hello *.hex
