static inline void my_putc(char c) {
	static volatile int *port = (int *) 268513280ul;
	while ((*port & (1 << 31)) != 0) { }
	    *port = c;
}

static inline void my_puts(const char *c) {
	for (; *c; ++c) {
		my_putc(*c);
	}
	my_putc('\n');
}

void _enter() {
	my_puts("Hello, World!");
	for (;;) {}
}
