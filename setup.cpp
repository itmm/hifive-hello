
	
	extern "C"
		void (**_init_array_begin)()
			__attribute__((weak));
	extern "C"
		void (**_init_array_end)()
			__attribute__((weak));

	extern "C" void setup() {
		auto cur = _init_array_begin;
		while (cur < _init_array_end) {
			(*(*cur++))();
		}
	}

