static volatile int *port = (int *) 268513280ul;

static inline void enable_out() {
	port[0x08] |= 1;
	port[0x0c] |= 1;
}

static inline void my_putc(char c) {
	while ((*port & (1 << 31)) != 0) { }
	    *port = c;
}

static inline void my_msg() {
	my_putc('H');
	my_putc('e');
	my_putc('l');
	my_putc('l');
	my_putc('o');
	my_putc(' ');
	my_putc('W');
	my_putc('o');
	my_putc('r');
	my_putc('l');
	my_putc('d');
	my_putc('!');
	my_putc('\r');
	my_putc('\n');
}

static const char msg[] = "Hello World!";

void _start() {
	enable_out();
	my_msg();
	for (;;) {}
}
