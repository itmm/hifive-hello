# Building my first program for HiFive1 Rev. B

This is the documentation for my first bare metal project for the HiFive1
board.
The repository is hosted at https://github.com/itmm/hifive-hello.

It is a bit difficult to build a project for the HiFive1 board
(see https://wwww.SiFive.com).
At least for me.
I only use Raspberry Pis (see https://www.raspberrypi.com) to do my
development.
And the building tools do not support to build on an ARM platform.
So I have to do it the hard way.

This document describes how to build the tools needed to program the
HiFive1 from scratch on a Rasperry Pi 3B+.

The goal is to make the following C++ program run on the HiFive1 and
print the message over the UART.

```
@Def(file: hello.cpp)
	#include <iostream>

	int main() {
		@put(main);
		std::cout << "Hello World!\n";
	}
@End(file: hello.cpp)
```
* Print a simple message and terminate.

```
@def(main)
	std::cout << "Hello World!\n";
@end(main)
```
* The main body is encapsulated in a special fragment.
* So it can easily be replaced later.

You can build the program on the Raspberry Pi with the command

```
$ @k(g++) @k(-Wall) @s(hello.cpp) @k(-o) @s(hello)
```
* Build the program locally.

If the commando is not working maybe you need to install the C++
compiler with

```
$ @k(sudo) @k(apt) @k(intall) @s(g++)
```
* Install the GCC C++ compiler for Rasperry Pi.

But that is not working for the HiFive1.
The HiFive1 is running a RISC-V processor (see https://www.riscv.org).

So I need a C++ compiler that writes RISC-V assembly.
But not only that: the Metal Framework used by SiFive to build examples
for the HiFive1 needs special extensions of the RISC-V instruction set
to compile.
And the toolset to build this augmented compiler is only available for
Windows, macOS and Intel-Linux.
And it only builds on these platforms.

But the official RISC-V compiler from the RISC-V Foundation can also be
build on the Rasperry Pi.
And instead of using a multilayered framework I extracted the relevant
information to build my example program.

So here are the next steps:

```
@inc(toolset.x)
```
* Build the GCC C++ Compiler for HiFive1.

```
@inc(iostream.x)
```
* Write a minimal implementation of `std::cout` that writes a C-style
  string to the UART.

```
@inc(setup.x)
```
* Write Startup-Code (in RISC-V assembly and C++) to make the processor
  ready for calling `main`.

```
@inc(deploy.x)
```
* Put the resulting program on the HiFive1 and watch the result.

I hope that this story will motivate you to also try to develop for a
RISC-V board.
It is a cool processor that is not complicated by all the heritage of
ARM and Intel designs.

Hopefully we can use it in the future not only on boards for embedded
devices but as a replacement for the ARM in Raspberry Pis or similar
boards.
I love to invest my programming time on open technology and not depend on
companies that can crash whole companies on the tweets of totalitarian
presidents.

## About this document

This document was created with `hx` (see https://github.com/itmm/hex).
It consists of `.x`-files that can be converted into a HTML presentation.
Also it contains code fragments that are part of the presentation.

The code fragments will also be processed by `hx` with a simple macro
language to generate the source code that is needed by this project.
The generated source code is part of this repository, but only intended
for the compiler.

The human users should use the HTML documentation instead.
So don't argue about the indentation levels and long functions of the
generated code.
Only if it is clumpsy, not readable or wrong in the HTML presentation I
am willing to change the representation.

