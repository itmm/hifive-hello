
	#include <iostream>

	int main() {
		
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
;
	}
