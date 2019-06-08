static volatile int *port = (int *) 268513280ul;

static inline void enable_out() {
	port[0x08] |= 1;
	port[0x0c] |= 1;
}

static inline void my_putc(char c) {
	while ((*port & (1 << 31)) != 0) { }
	    *port = c;
}

static inline void my_puts(const char *s) {
	for (; *s; ++s) {
		my_putc(*s);
	}
}

static const char msg[] = "Hello World!\r\n";

void main() {
	enable_out();
	my_puts(msg);
	for (;;) {}
}
