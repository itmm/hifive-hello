
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
		static const int tx_data { 0x00 };
		while (uart()[tx_data] < 0) { }
		uart()[tx_data] = c;
	}

		public:
			
	
	ostream() {
		
	static const int tx_control { 0x02 };
	uart()[tx_control] |= 1;

	static const int rx_control { 0x03 };
	uart()[rx_control] |= 1;
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


	int get() {
		static const int rx_data { 0x01 };
		int res = -1;
		while (res < 0) {
			res = uart()[rx_data];
		}
		return res & 0xff;
	}

	void write_num(int v) {
		int next = v / 10;
		if (next) { write_num(next); }
		put((v % 10) + '0');
	}

	ostream &operator<<(int v) {
		if (v < 0) { put('-'); }
		write_num(v);
		return *this;
	}

	};

	#if iostream_IMPL
		ostream cout;
	#else
		extern ostream cout;
	#endif

	}
