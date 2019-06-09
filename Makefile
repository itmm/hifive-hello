
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
