# Building the C++ Toolchain
* Building the C++ Toolchain on a Rasperry Pi.

## Prerequisit: More Memory
* Increase the swap size.

Building the complete toolchain takes a lot of time.
And a lot of memory.

To increase the usable memory, I adjusted the swap file size of my
Raspbian installation.

Edit the file `/etc/dphys-swapfile`.
You must have administration privileges to do that.
Change the entry `CONF_SWAPSIZE` to a bigger value.
I set mine to `10240`.

Afterwards you can activate the new swap file size with

```
$ sudo /etc/init.d/dphys-swapfile restart
```
* Activate new swap file size.

## Getting the Toolchain sources
* Cloning the Repository with the Toolchain sources.

I took the sources from Github:

```
$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
```
* Cloning source tree.

That took roughly an hour on my Raspberry Pi.

Also I installed the prerequisites mentioned on the Github page:

```
$ sudo apt-get install autoconf automake \
	autotools-dev curl libmpc-dev \
	libmpfr-dev libgmp-dev gawk \
	build-essential bison flex texinfo \
	gperf libtool patchutils bc \
	zlib1g-dev libexpat-dev
```
* Fetching tools needed to build the Toolchain

Also you need a lot of disk space for building the Toolchain.
The documentation says, that 8 GB free space are needed.

## Building the Toolchain
* Building the RISC-V specific tools.

Following the documentation I first created a directory where everything
will be installed.

```
$ sudo mkdir /opt/riscv
$ sudo chown timm:timm /opt/riscv
$ export PATH="/opt/riscv/bin:$PATH"
```
* Create directory.
* And make it accessible.
* Of course you must choose your own login name.
* And I put the directory `/opt/riscv/bin` into my `PATH`.

Then I changed into the cloned repository and build the compiler with the
following commands:

```
$ ./configure --prefix=/opt/riscv \
	--with-arch=rv32imac \
	--with-abi=ilp32
$ nice make -j 1
```
* The arch and abi specification are from the `sifive/freedom-e-sdk`
  project.
* The file `settings.mk` in the folder `bsp/sifive-hifive1-revb` contains
  the properties of the board.

I run the `make` with `nice` and only one process to avoid blocking my
box completely.
It take a couple of hours.
So be patient.

