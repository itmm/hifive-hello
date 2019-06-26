# Read Characters and Numbers

## Enable UART
* First the UART must be enabled to support reading from it

```
@Add(setup uart)
	static const int rx_control { 0x03 };
	uart()[rx_control] |= 1;
@End(setup uart)
```

## Reading a character

```
@Add(ostream methods)
	int get() {
		static const int rx_data { 0x01 };
		int res = -1;
		while (res < 0) {
			res = uart()[rx_data];
		}
		return res & 0xff;
	}
@End(ostream methods)
```

```
@Add(ostream methods)
	void write_num(int v) {
		int next = v / 10;
		if (next) { write_num(next); }
		put((v % 10) + '0');
	}
@End(ostream methods)
```

```
@Add(ostream methods)
	ostream &operator<<(int v) {
		if (v < 0) { put('-'); }
		write_num(v);
		return *this;
	}
@End(ostream methods)
```

## Simple echo

```
@Rep(main)
	char buf[2];
	buf[1] = '\0';
	for (;;) {
		int ch = std::cout.get();
		if (ch < 0) { break; }
		buf[0] = ch;
		std::cout << buf;
		if (ch == '\r') {
			std::cout << "\n";
		}
	}
@End(main)
```
