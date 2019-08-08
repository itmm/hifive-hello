
#line 251 "setup.x"

	
#line 258 "setup.x"

	extern "C"
		void (**_init_array_begin)()
			__attribute__((weak));
	extern "C"
		void (**_init_array_end)()
			__attribute__((weak));

#line 272 "setup.x"

	extern "C" void setup() {
		auto cur = _init_array_begin;
		while (cur < _init_array_end) {
			(*(*cur++))();
		}
	}

#line 252 "setup.x"

