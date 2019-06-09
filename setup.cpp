#include <cstring>
extern "C" int *_bss_begin __attribute__((weak));
extern "C" int *_bss_end __attribute__((weak));
extern "C" void (**_init_array_begin)() __attribute__((weak));
extern "C" void (**_init_array_end)() __attribute__((weak));
extern "C" void setup() {
	{
		for (auto cur = _bss_begin; cur < _bss_end; ++cur) {
			*cur = 0;
		}
	}
	{
		auto cur = _init_array_begin;
		for (; cur != _init_array_end; ++cur) {
			(**cur)();
		}
	}

}
