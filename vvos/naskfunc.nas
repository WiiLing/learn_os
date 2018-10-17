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
		GLOBAL 	_asm_inthandler21, _asm_inthandler2c, _asm_inthandler20, _asm_inthandler0d, _asm_inthandler0c
		EXTERN 	_inthandler21, _inthandler2c, _inthandler20, _inthandler0d, _inthandler0c
		GLOBAL 	_load_cr0, _store_cr0
		GLOBAL 	_memtest_sub
		GLOBAL 	_load_tr, _taskswitch4, _taskswitch3, _farjmp, _farcall
		EXTERN 	_cons_putchar, _hrb_api
		GLOBAL 	_asm_cons_putchar, _asm_hrb_api
		GLOBAL 	_start_app, _asm_end_app

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

_asm_inthandler0d:
		STI
		PUSH 	ES
		PUSH 	DS
		PUSHAD
		MOV 	EAX, ESP
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX
		CALL 	_inthandler0d
		CMP 	EAX, 0
		JNE 	_asm_end_app
		POP 	EAX
		POPAD
		POP 	DS
		POP 	ES
		ADD 	ESP, 4
		IRETD

_asm_inthandler0c:
		STI
		PUSH 	ES
		PUSH 	DS
		PUSHAD
		MOV 	EAX, ESP
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX
		CALL 	_inthandler0c
		CMP 	EAX, 0
		JNE 	_asm_end_app
		POP 	EAX
		POPAD
		POP 	DS
		POP 	ES
		ADD 	ESP, 4
		IRETD

;_asm_inthandler21:
		PUSH 	ES
		PUSH 	DS
		PUSHAD

		; 用户态需要特殊处理
		MOV 	AX, SS
		CMP 	AX, 1*8
		JNE 	.from_app_i21

		; 入栈ESP、SS
		MOV 	EAX, ESP
		PUSH 	SS
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX

		CALL 	_inthandler21

		; 丢弃SS、ESP
		ADD 	ESP, 8

		POPAD
		POP 	DS
		POP 	ES
		IRETD

.from_app_i21:
		MOV 	EAX, 1*8
		; 数据段寄存器指向系统段
		MOV 	DS, AX

		; 读取系统栈的高度
		MOV 	ECX, [0x0fe4]

		; 保存应用程序的SS、ESP
		ADD 	ECX, -8
		MOV 	[ECX+4], SS
		MOV 	[ECX], ESP

		; 填入系统的段寄存器
		MOV 	SS, AX
		MOV 	ES, AX
		; 设置系统的栈指针
		MOV 	ESP, ECX

		; 进入系统调用
		CALL 	_inthandler21

		; 恢复应用程序的SS、ESP
		POP 	ECX
		POP 	EAX
		MOV 	SS, AX
		MOV 	ESP, ECX

		POPAD
		POP 	DS
		POP 	ES
		IRETD

;_asm_inthandler2c:
		PUSH 	ES
		PUSH 	DS
		PUSHAD

		; 用户态需要特殊处理
		MOV 	AX, SS
		CMP 	AX, 1*8
		JNE 	.from_app_i2c

		; 入栈ESP、SS
		MOV 	EAX, ESP
		PUSH 	SS
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX

		CALL 	_inthandler2c

		; 丢弃SS、ESP
		ADD 	ESP, 8

		POPAD
		POP 	DS
		POP 	ES
		IRETD

.from_app_i2c:
		MOV 	EAX, 1*8
		; 数据段寄存器指向系统段
		MOV 	DS, AX

		; 读取系统栈的高度
		MOV 	ECX, [0x0fe4]

		; 保存应用程序的SS、ESP
		ADD 	ECX, -8
		MOV 	[ECX+4], SS
		MOV 	[ECX], ESP

		; 填入系统的段寄存器
		MOV 	SS, AX
		MOV 	ES, AX
		; 设置系统的栈指针
		MOV 	ESP, ECX

		; 进入系统调用
		CALL 	_inthandler2c

		; 恢复应用程序的SS、ESP
		POP 	ECX
		POP 	EAX
		MOV 	SS, AX
		MOV 	ESP, ECX

		POPAD
		POP 	DS
		POP 	ES
		IRETD

;_asm_inthandler20:
		PUSH 	ES
		PUSH 	DS
		PUSHAD

		; 用户态需要特殊处理
		MOV 	AX, SS
		CMP 	AX, 1*8
		JNE 	.from_app_i20

		; 入栈ESP、SS
		MOV 	EAX, ESP
		PUSH 	SS
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX

		CALL 	_inthandler20

		; 丢弃SS、ESP
		ADD 	ESP, 8

		POPAD
		POP 	DS
		POP 	ES
		IRETD

.from_app_i20:
		MOV 	EAX, 1*8
		; 数据段寄存器指向系统段
		MOV 	DS, AX

		; 读取系统栈的高度
		MOV 	ECX, [0x0fe4]

		; 保存应用程序的SS、ESP
		ADD 	ECX, -8
		MOV 	[ECX+4], SS
		MOV 	[ECX], ESP

		; 填入系统的段寄存器
		MOV 	SS, AX
		MOV 	ES, AX
		; 设置系统的栈指针
		MOV 	ESP, ECX

		; 进入系统调用
		CALL 	_inthandler20

		; 恢复应用程序的SS、ESP
		POP 	ECX
		POP 	EAX
		MOV 	SS, AX
		MOV 	ESP, ECX

		POPAD
		POP 	DS
		POP 	ES
		IRETD

;_asm_inthandler0d:
		STI
		PUSH 	ES
		PUSH 	DS
		PUSHAD

		; 用户态需要特殊处理
		MOV 	AX, SS
		CMP 	AX, 1*8
		JNE 	.from_app_i0d

		; 入栈ESP、SS
		MOV 	EAX, ESP
		PUSH 	SS
		PUSH 	EAX
		MOV 	AX, SS
		MOV 	DS, AX
		MOV 	ES, AX

		CALL 	_inthandler0d

		; 丢弃SS、ESP
		ADD 	ESP, 8

		POPAD
		POP 	DS
		POP 	ES
		ADD 	ESP, 4
		IRETD

.from_app_i0d:
		CLI
		MOV 	EAX, 1*8
		; 数据段寄存器指向系统段
		MOV 	DS, AX

		; 读取系统栈的高度
		MOV 	ECX, [0x0fe4]

		; 保存应用程序的SS、ESP
		ADD 	ECX, -8
		MOV 	[ECX+4], SS
		MOV 	[ECX], ESP

		; 填入系统的段寄存器
		MOV 	SS, AX
		MOV 	ES, AX
		; 设置系统的栈指针
		MOV 	ESP, ECX
		STI

		; 进入系统调用
		CALL 	_inthandler0d

		CLI
		CMP 	EAX, 0
		JNE 	.kill_i0d
		; 恢复应用程序的SS、ESP
		POP 	ECX
		POP 	EAX
		MOV 	SS, AX
		MOV 	ESP, ECX

		POPAD
		POP 	DS
		POP 	ES
		ADD 	ESP, 4
		IRETD

.kill_i0d:
		MOV 	AX, 1*8
		MOV 	ES, AX
		MOV 	SS, AX
		MOV 	DS, AX
		MOV 	FS, AX
		MOV 	GS, AX
		MOV 	ESP, [0x0fe4]
		STI
		POPAD
		RET

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

;_asm_hrb_api:
		STI
		PUSHAD
		PUSHAD
		CALL 	_hrb_api
		ADD 	ESP, 32
		POPAD
		IRETD

_asm_hrb_api:
		STI

		; 将要从用户态转到系统态，想从系统态恢复回用户态，就要入栈应用程序的寄存器
		PUSH 	DS
		PUSH 	ES
		; 保存应用程序的寄存器
		PUSHAD
		; 向hrb_api传值
		PUSHAD

		MOV 	AX, SS
		; 填入操作系统的段寄存器
		MOV 	DS, AX
		MOV 	ES, AX

		; 进入系统调用
		CALL 	_hrb_api

		; 当EAX不为0时程序结束
		CMP 	EAX, 0
		JNE 	_asm_end_app

		ADD 	ESP, 32
		; 恢复应用程序的栈指针
		POPAD
		POP 	ES
		POP 	DS

		;从中断返回指令(IRET)自动执行STI
		IRETD

_asm_end_app:
		; EAX为tss.esp0的地址
		MOV 	ESP, [EAX]
		MOV 	DWORD [EAX+4], 0
		POPAD
		; 返回cmd_app
		RET

_start_app: 						; void start_app(int eip, int cs, int esp, int ds, int *tss_esp0)
		; 将要从系统态转到用户态，想从用户态恢复回系统态，就要入栈操作系统的寄存器
		PUSHAD

		; 读取参数，用户态的代码段和数据段
		MOV 	EAX, [ESP+32+4] 	; 应用程序EIP 		指令指针寄存器
		MOV 	ECX, [ESP+32+8] 	; 应用程序CS 		代码段寄存器
		MOV 	EDX, [ESP+32+12] 	; 应用程序ESP 		堆栈指针寄存器
		MOV 	EBX, [ESP+32+16] 	; 应用程序DS/SS 		数据段寄存器、堆栈段寄存器
		MOV 	EBP, [ESP+32+20] 	; tss.esp0的地址

		; 保存操作系统的栈指针
		MOV 	[EBP], ESP
		MOV 	[EBP+4], SS

		; 填入应用程序的段寄存器
		MOV 	ES, BX
		MOV 	DS, BX
		MOV 	FS, BX
		MOV 	GS, BX

		; 下面调整栈，以免用RETF跳转到应用程序
		OR 		ECX, 3 				; 将应用程序的段号和3进行OR运算
		OR 		EBX, 3 				; 将应用程序的段号和3进行OR运算

		PUSH 	EBX 				; 应用程序的SS
		PUSH 	EDX 				; 应用程序的ESP
		PUSH 	ECX 				; 应用程序的CS
		PUSH 	EAX 				; 应用程序的EIP

		; retf应用程序，进入用户调用
		RETF
		; 应用程序结束后不会回到这里