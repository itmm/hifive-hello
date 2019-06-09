
OUTPUT_ARCH("riscv")

ENTRY(_enter)

MEMORY
{
	ram (wxa!ri) : ORIGIN = 0x80000000, LENGTH = 0x4000
	flash (rxai!w) : ORIGIN = 0x20010000, LENGTH = 0x6a120
}

PHDRS
{
	flash PT_LOAD;
	ram PT_NULL;
}

SECTIONS
{
	__stack_size = DEFINED(__stack_size) ? __stack_size : 0x400;
	__heap_size = DEFINED(__heap_size) ? __heap_size : 0x400;

	.init 		:
	{
		*(.init)
	} >flash AT>flash :flash

	.init_array : {
		PROVIDE ( _init_array_begin = . );
		KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)));
		PROVIDE ( _init_array_end = . );
	} >flash AT>flash :flash

	. = ALIGN(8);
	.text 		:
	{
		*(.text .text*)
	} >flash AT>flash :flash


	.rodata :
	{
		*(.rodata)
		*(.sdata)
	} >flash AT>flash :flash
	
	.data 		:
	{
		*(.data)
		PROVIDE( __global_pointer$ = . + 0x800 );
	} >ram AT>ram :ram

	PROVIDE(_bss_begin = . );
	.bss 		:
	{
		*(.bss)
	} >ram AT>ram :ram
	PROVIDE(_bss_end = . );


	.stack :
	{
		PROVIDE(_stack_begin = .);
		. = __stack_size;
		PROVIDE( _sp = . );
		PROVIDE(_stack_end = .);
	} >ram AT>ram :ram


	.heap :
	{
		PROVIDE(_heap_begin = . );
		. = __heap_size;
		. = __heap_size == 0 ? 0 : ORIGIN(ram) + LENGTH(ram);
		PROVIDE( _heap_end = . );
	} >ram AT>ram :ram
}

