
#line 13 "iostream.x"

	#pragma once

	namespace std {
		
#line 50 "iostream.x"

	class ostream {
			
#line 104 "iostream.x"

	using uart_t = volatile int *;
	uart_t uart() {
		return reinterpret_cast<uart_t>(
			0x10013000
		);
	};

#line 126 "iostream.x"

	void put(char c) {
		static const int tx_data { 0x00 };
		while (uart()[tx_data] < 0) { }
		uart()[tx_data] = c;
	}

#line 52 "iostream.x"

		public:
			
#line 61 "iostream.x"

	
#line 68 "iostream.x"

	ostream() {
		
#line 117 "iostream.x"

	static const int tx_control { 0x02 };
	uart()[tx_control] |= 1;

#line 7 "read.x"

	static const int rx_control { 0x03 };
	uart()[rx_control] |= 1;

#line 70 "iostream.x"
;
	}

#line 77 "iostream.x"

	ostream &operator<<(const char *s) {
		
#line 144 "iostream.x"

	if (s) for (; *s; ++s) {
		if (*s == '\n') {
			put('\r');
		}
		put(*s);
	}

#line 79 "iostream.x"
;
		return *this;
	}

#line 62 "iostream.x"


#line 16 "read.x"

	int get() {
		static const int rx_data { 0x01 };
		int res = -1;
		while (res < 0) {
			res = uart()[rx_data];
		}
		return res & 0xff;
	}

#line 29 "read.x"

	void write_num(int v) {
		int next = v / 10;
		if (next) { write_num(next); }
		put((v % 10) + '0');
	}

#line 39 "read.x"

	ostream &operator<<(int v) {
		if (v < 0) { put('-'); }
		write_num(v);
		return *this;
	}

#line 54 "iostream.x"

	};

#line 163 "iostream.x"

	#if iostream_IMPL
		ostream cout;
	#else
		extern ostream cout;
	#endif

#line 17 "iostream.x"

	}
