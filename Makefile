
	
.PHONY: all clean

all: hello.hex

HXs := $(wildcard *.x)

SRCs := $(shell hx-files.sh $(HXs))

OBJs := $(filter %.o, $(SRCs:.S=.o) $(SRCs:.cpp=.o))

hx-run: $(HXs)
	hx
	touch $@

$(SRCs): hx-run

TARGET := riscv32-unknown-elf

CC := $(TARGET)-gcc
CXX := $(TARGET)-g++
LD := $(TARGET)-ld -T memory.lds

CXXFLAGS += -MD -Wall -O2 -I.
CFLAGS += -MD -Wall -O2

hello: $(OBJs)
	$(LD) $^ -o $@

hello.hex: hello
	$(TARGET)-objcopy $^ -O ihex $@

iostream: iostream.h
	@echo >/dev/null

DEPs := $(wildcard *.d)
ifneq ($(DEPs),)
  include $(DEPs)
endif

clean:
	rm -f $(OBJs) $(DEPs) hello
	rm -f hello.hex hx-run

