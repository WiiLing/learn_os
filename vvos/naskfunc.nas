; naskfunc
; TAB=4

[FORMAT "WCOFF"]				; 要*.c文件的编译结果进行连接，因此使用对象文件模式
[INSTRSET "i486p"]				; 表示使用486兼容指令集
[BITS 32]						; 生成32位模式机器语言
[FILE "naskfunc.nas"]			; 源文件名

		GLOBAL	_io_hlt, _io_cli, _io_sti, _io_stihlt
		GLOBAL	_io_in8,  _io_in16,  _io_in32
		GLOBAL	_io_out8, _io_out16, _io_out32
		GLOBAL	_io_load_eflags, _io_store_eflags
		GLOBAL	_load_gdtr, _load_idtr
		GLOBAL 	_asm_inthandler21, _asm_inthandler2c, _asm_inthandler20
		EXTERN 	_inthandler21, _inthandler2c, _inthandler20
		GLOBAL 	_load_cr0, _store_cr0
		GLOBAL 	_memtest_sub
		GLOBAL 	_load_tr, _taskswitch4, _taskswitch3, _farjmp, _farcall
		EXTERN 	_cons_putchar, _hrb_api
		GLOBAL 	_asm_cons_putchar, _asm_hrb_api
		GLOBAL 	_start_up

[SECTION .text]

_io_hlt:	; void io_hlt(void);
		HLT
		RET

_io_cli:	; void io_cli(void);
		CLI
		RET

_io_sti:	; void io_sti(void);
		STI
		RET

_io_stihlt:	; void io_stihlt(void);
		STI
		HLT
		RET

_io_in8:	; int io_in8(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AL,DX
		RET

_io_in16:	; int io_in16(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AX,DX
		RET

_io_in32:	; int io_in32(int port);
		MOV		EDX,[ESP+4]		; port
		IN		EAX,DX
		RET

_io_out8:	; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		AL,[ESP+8]		; data
		OUT		DX,AL
		RET

_io_out16:	; void io_out16(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,AX
		RET

_io_out32:	; void io_out32(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,EAX
		RET

_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; PUSH EFLAGS 
		POP		EAX
		RET

_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; POP EFLAGS 
		RET

_load_gdtr:		; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LGDT	[ESP+6]
		RET

_load_idtr:		; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET

_asm_inthandler21:
		PUSH 	ES
		PUSH 	DS
		PUSHAD
		MOV 	EAX, ESP
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX
		CALL 	_inthandler21
		POP 	EAX
		POPAD
		POP 	DS
		POP 	ES
		IRETD

_asm_inthandler2c:
		PUSH 	ES
		PUSH 	DS
		PUSHAD
		MOV 	EAX, ESP
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX
		CALL 	_inthandler2c
		POP 	EAX
		POPAD
		POP 	DS
		POP 	ES
		IRETD

_asm_inthandler20:
		PUSH 	ES
		PUSH 	DS
		PUSHAD
		MOV 	EAX, ESP
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX
		CALL 	_inthandler20
		POP 	EAX
		POPAD
		POP 	DS
		POP 	ES
		IRETD

_load_cr0:
		MOV 	EAX, CR0
		RET

_store_cr0:
		MOV 	EAX, [ESP+4]
		MOV 	CR0, EAX
		RET

_memtest_sub: 	; unsigned int memtest_sub(unsigned int start, unsigned int end)
		PUSH 	ESI
		PUSH 	EDI
		PUSH 	EBX
		MOV 	ESI, 0xaa55aa55
		MOV 	EDI, 0x55aa55aa
		MOV 	EAX, [ESP+12+4]
mts_loop:
		CMP 	EAX, [ESP+12+8]
		JA	 	mts_fin
		MOV 	EBX, EAX
		ADD 	EBX, 0x0ffc
		MOV 	EDX, [EBX]
		MOV 	[EBX], ESI
		XOR 	DWORD [EBX], 0xffffffff
		CMP 	EDI, [EBX]
		JNE 	mts_rcv
		XOR 	DWORD [EBX], 0xffffffff
		CMP 	ESI, [EBX]
		JNE 	mts_rcv
		MOV 	[EBX], EDX
		ADD 	EAX, 0x1000
		JMP 	mts_loop
mts_rcv:
		MOV 	[EBX], EDX
mts_fin:
		POP 	EBX
		POP 	EDI
		POP 	ESI
		RET

_load_tr:
		LTR 	[ESP+4]
		RET

_taskswitch4:
		JMP 	4*8:0
		RET

_taskswitch3:
		JMP 	3*8:0
		RET

_farjmp: 						; void farjmp(int eip, int cs);
		JMP 	FAR [ESP+4] 	; JMP FAR指令，先从栈取4个字节放入EIP，再取2个字节放入CS
		RET

_farcall:
		CALL 	FAR [ESP+4]
		RET

_asm_cons_putchar:
		STI
		PUSHAD
		PUSH 	1
		AND 	EAX, 0xff
		PUSH 	EAX
		PUSH 	DWORD [0x0fec]
		CALL 	_cons_putchar
		ADD 	ESP, 12
		POPAD
		IRETD

_asm_hrb_api:
		STI
		PUSHAD

		PUSHAD
		CALL 	_hrb_api
		ADD 	ESP, 32

		POPAD
		IRETD

_start_up: 							; void start_app(int eip, int cs, int esp, int ds)
		PUSHAD 						; 将8*4位寄存器的值压入栈

		MOV 	EAX, [ESP+32+4] 	; 应用程序EIP
		MOV 	ECX, [ESP+32+8] 	; 应用程序CS
		MOV 	EDX, [ESP+32+12] 	; 应用程序ESP
		MOV 	EBX, [ESP+32+16] 	; 应用程序DS/SS
		MOV 	[0x0fe4], ESP 		; 操作系统ESP

		CLI
		MOV 	ES, BX
		MOV 	SS, BX
		MOV 	DS, BX
		MOV 	FS, BX
		MOV 	GS, BX
		MOV 	ESP, EDX
		STI

		PUSH 	ECX
		PUSH 	EAX
		CALL 	FAR [ESP]

		MOV 	EAX, 1*8

		CLI
		MOV 	ES, AX
		MOV 	SS, AX
		MOV 	DS, AX
		MOV 	FS, AX
		MOV 	GS, AX
		MOV 	ESP, [0x0fe4]
		STI

		POPAD
		RET