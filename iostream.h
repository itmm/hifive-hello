
	#pragma once

	namespace std {
		
	class ostream {
			
	using uart_t = volatile int *;
	uart_t uart() {
		return reinterpret_cast<uart_t>(
			0x10013000
		);
	};

	void put(char c) {
		while (*uart() < 0) { }
		*uart() = c;
	}

		public:
			
	ostream() {
		
	static const int tx_control { 0x08 };
	uart()[tx_control] |= 1;
;
	}

	ostream &operator<<(const char *s) {
		
	if (s) for (; *s; ++s) {
		if (*s == '\n') {
			put('\r');
		}
		put(*s);
	}
;
		return *this;
	}

	};

	#if iostream_IMPL
		ostream cout;
	#else
		extern ostream cout;
	#endif

	}
