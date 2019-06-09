
#pragma once

namespace std {
	class ostream {
			volatile int *port() {
				return reinterpret_cast<
					volatile int *
				>(0x10013000);
			}
			void put(char c) {
				while (*port() < 0) { }
				*port() = c;
			}
		public:
			ostream() {
				static const int tx_control { 0x08 };
				port()[tx_control] |= 1;
			}

			ostream &operator<<(const char *s) {
				if (s) for (; *s; ++s) {
					if (*s == '\n') {
						put('\r');
					}
					put(*s);
				}
				return *this;
			}
	};

	extern ostream cout;
}
