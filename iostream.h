
#line 13 "iostream.md"

	#pragma once

	namespace std {
		
#line 50 "iostream.md"

	class ostream {
			
#line 104 "iostream.md"

	using uart_t = volatile int *;
	uart_t uart() {
		return reinterpret_cast<uart_t>(
			0x10013000
		);
	};

#line 126 "iostream.md"

	void put(char c) {
		static const int tx_data { 0x00 };
		while (uart()[tx_data] < 0) { }
		uart()[tx_data] = c;
	}

#line 52 "iostream.md"

		public:
			
#line 61 "iostream.md"

	
#line 68 "iostream.md"

	ostream() {
		
#line 117 "iostream.md"

	static const int tx_control { 0x02 };
	uart()[tx_control] |= 1;

#line 7 "read.md"

	static const int rx_control { 0x03 };
	uart()[rx_control] |= 1;

#line 70 "iostream.md"
;
	}

#line 77 "iostream.md"

	ostream &operator<<(const char *s) {
		
#line 144 "iostream.md"

	if (s) for (; *s; ++s) {
		if (*s == '\n') {
			put('\r');
		}
		put(*s);
	}

#line 79 "iostream.md"
;
		return *this;
	}

#line 62 "iostream.md"


#line 16 "read.md"

	int get() {
		static const int rx_data { 0x01 };
		int res = -1;
		while (res < 0) {
			res = uart()[rx_data];
		}
		return res & 0xff;
	}

#line 29 "read.md"

	void write_num(int v) {
		int next = v / 10;
		if (next) { write_num(next); }
		put((v % 10) + '0');
	}

#line 39 "read.md"

	ostream &operator<<(int v) {
		if (v < 0) { put('-'); }
		write_num(v);
		return *this;
	}

#line 54 "iostream.md"

	};

#line 163 "iostream.md"

	#if iostream_IMPL
		ostream cout;
	#else
		extern ostream cout;
	#endif

#line 17 "iostream.md"

	}
