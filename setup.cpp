
#line 252 "setup.md"

	
#line 259 "setup.md"

	extern "C"
		void (**_init_array_begin)()
			__attribute__((weak));
	extern "C"
		void (**_init_array_end)()
			__attribute__((weak));

#line 273 "setup.md"

	extern "C" void setup() {
		auto cur = _init_array_begin;
		while (cur < _init_array_end) {
			(*(*cur++))();
		}
	}

#line 253 "setup.md"

