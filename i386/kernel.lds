/* Halos: a light operating system
 * Copyright (c) 2004, Ronald Landheer-Cieslak
 * All rights reserved
 * 
 * This is free software. You may distribute it and/or modify it and
 * distribute modified forms provided that the following terms are met:
 *
 * * Redistributions of the source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer;
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in
 *   the documentation and/or other materials provided with the distribution;
 * * None of the names of the authors of this software may be used to endorse
 *   or promote this software, derived software or any distribution of this 
 *   software or any distribution of which this software is part, without 
 *   prior written permission from the authors involved;
 * * Unless you have received a written statement from Ronald Landheer-Cieslak
 *   that says otherwise, the terms of the GNU General Public License, as 
 *   published by the Free Software Foundation, version 2 or (at your option)
 *   any later version, also apply.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
ENTRY(_start)
OUTPUT_ARCH("i386")

SECTIONS
{
	. = 0x200000;
	__b_load = .;
	.multiboot : 
	{ 
		*(.multiboot); 
		LONG(0); /* force allocation of the section */
	}
	
	. = ALIGN(4096);
	__b_kernel = .;
	
	.text ALIGN(4096) :
	{
		*(.text)
		PROVIDE(__etext = .);
	}
	.rodata : 
	{ 
		*(.rodata) 
		PROVIDE(__erodata = .);
	}
	.data : 
	{
		*(.data) 
		PROVIDE(__edata = .);
		PROVIDE(__end_data = .);
	}
	__e_load = .;
	.bss ALIGN(4096):
	{
		*(.bss)
		*(COMMON)
		. = ALIGN(4096);
		*(.init_stack)

		PROVIDE(__e_bss = .);
	}

	__e_kernel = .;
	__kernel_end = .;

/*	/DISCARD/ : {
		*(.node*)
		*(.indent)
		*(.comment)
		*(.stab)
		*(.stabstr)
	} */
}

