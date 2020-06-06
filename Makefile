
	
.PHONY: all clean

all: hello.hex

HXs := $(shell hx-srcs.sh)

SRCs := $(shell hx-files.sh $(HXs))

OBJs := $(filter %.o, $(SRCs:.S=.o) $(SRCs:.cpp=.o))

hx-run: $(HXs)
	hx
	touch $@

$(SRCs): hx-run

CC := clang-9
CXX := clang++-9
LD := ld.lld-9 -T memory.lds

CXXFLAGS += -fno-exceptions --target=riscv32 -march=rv32imac -MD -Wall -O2 -I.
ASFLAGS += --target=riscv32 -march=rv32imac -MD -Wall -O2

hello: $(OBJs)
	$(LD) $^ -o $@

hello.hex: hello
	objcopy $^ -O ihex $@

iostream: iostream.h
	@echo >/dev/null

DEPs := $(wildcard *.d)
ifneq ($(DEPs),)
  include $(DEPs)
endif

clean:
	rm -f $(OBJs) $(DEPs) hello
	rm -f hello.hex hx-run

