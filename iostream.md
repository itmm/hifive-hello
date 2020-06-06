# simple `@s(iostream)` implementation

As we have no standard library support for our small embedded processor,
we need to build everything that we need from scratch.

In this chapter we will cover a very rudimentary implementation of the
standard `@s(iostream)` library.

## File Structure
* Which files are needed for the implementation

```
@Def(file: iostream.h)
	#pragma once

	namespace std {
		@put(declarations)
	}
@End(file: iostream.h)
```
* All declarations are encapsulated in the `std` namespace.
* The header file is introduced to make editing easier.
* A lot of editors work not well with the extension-less headers of C++.

```
@Def(file: iostream)
	#include "iostream.h"
@End(file: iostream)
```
* To comply to the standard, there is also an extension-less header file.
* It simply includes the normal header.

```
@Def(file: iostream.cpp)
	#define iostream_IMPL 1
	#include "iostream.h"
@End(file: iostream.cpp)
```
* An implementation is needed to define global elements
* It defines a macro that can be used by the header to decide if a symbol
  must be declared or defined.

## The `ostream` class
* The `ostream` class encapsulates everything that is needed to write a
  string to the UART.
* The constructor ensures that the UART is setup.
* The `<<` operator sends a string to the UART.

```
@def(declarations)
	class ostream {
			@put(privates)
		public:
			@Put(ostream methods)
	};
@end(declarations)
```
* The class has `public` and `private` attributes

```
@Def(ostream methods)
	@put(methods)
@End(ostream methods)
```
* Make methods of `ostream` class available globally

```
@def(methods)
	ostream() {
		@Put(setup uart);
	}
@end(methods)
```
* A default constructor will setup the UART for writing

```
@add(methods)
	ostream &operator<<(const char *s) {
		@put(send string);
		return *this;
	}
@end(methods)
```
* The `<<`-operator will send a C-style string to the UART

## Communicating with the UART
* Implementing the low-level communication with the UART

The UART is addressed via a bunch of words in memory.
Starting at the address `0x10013000` some words are an interface to the
UART.

I have found this address in the file `metal.h` in the
`sifive/freedom-e-sdk` project on Github in the directory
`bsp/sifive-hifive1-revb`.

An important part is to treat this pointer as `volatile` because its
contents is not only modified by our program.
The hardware itself can change values by its own.
So it is important not to optimize away repeated accesses, but to fetch
the values again and again from memory.

```
@def(privates)
	using uart_t = volatile int *;
	uart_t uart() {
		return reinterpret_cast<uart_t>(
			0x10013000
		);
	};
@end(privates)
```
* Accessor returns a pointer to the first register as a `volatile`
  variable

```
@Def(setup uart)
	static const int tx_control { 0x02 };
	uart()[tx_control] |= 1;
@end(setup uart)
```
* Bit `1` of the `tx_control` word must be set on to enable output of
  the UART

```
@add(privates)
	void put(char c) {
		static const int tx_data { 0x00 };
		while (uart()[tx_data] < 0) { }
		uart()[tx_data] = c;
	}
@end(privates)
```
* Writing is done with the first UART control word.
* As long as this word is negative the buffer is full and nothing can be
  written
* As soon as the buffer has space, the new byte is put into the buffer
* That is all for writing one character.

## Sending a string
* Writes a string character by character

```
@def(send string)
	if (s) for (; *s; ++s) {
		if (*s == '\n') {
			put('\r');
		}
		put(*s);
	}
@end(send string)
```
* Sending a string is simply the sending of individual characters.
* As a small complication my terminal distinguished between newline and
  carriage return.
* To get the right look function must write an additional carriage
  return for each newline that occurs in the string.

## The `cout` global
* Global variable for handling output

```
@add(declarations)
	#if iostream_IMPL
		ostream cout;
	#else
		extern ostream cout;
	#endif
@end(declarations)
```
* The variable must only be defined once.
* The indicator of the implementation file assures this.

