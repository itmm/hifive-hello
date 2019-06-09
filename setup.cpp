
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
