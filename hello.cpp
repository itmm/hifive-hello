static volatile int *port = (int *) 0x10013000;

inline void enable_out() {
	static const int tx_control { 0x08 };
	port[tx_control] |= 1;
}

inline void putc(char c) {
	while (*port < 0) { }
	*port = c;
}

inline void puts(const char *s) {
	if (s) for (; *s; ++s) {
		putc(*s);
	}
	putc('\r');
	putc('\n');
}

static const char msg[] = "Hello World!";

int main() {
	enable_out();
	puts(msg);
}
