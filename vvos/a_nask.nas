;a_nask
;TAB=4

[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[BITS 32]
[FILE "a_nask.nas"]

		GLOBAL 	_api_putchar
		GLOBAL 	_api_end
		GLOBAL 	_api_putstr
		GLOBAL 	_api_openwin
		GLOBAL 	_api_putstrwin
		GLOBAL 	_api_boxfillwin
		GLOBAL 	_api_initmalloc
		GLOBAL 	_api_malloc
		GLOBAL 	_api_free
		GLOBAL 	_api_point
		GLOBAL 	_api_refreshwin
		GLOBAL 	_api_linewin
		GLOBAL 	_api_closewin

[SECTION .text]

_api_putchar: 								;void api_putchar(int c);
		MOV 	EDX, 1
		MOV 	AL, [ESP+4]
		INT 	0x40
		RET

_api_end:
		MOV 	EDX, 4
		INT 	0x40

_api_putstr:
		PUSH 	EBX
		MOV 	EDX, 2
		MOV 	EBX, [ESP+8]
		INT 	0x40
		POP 	EBX
		RET

_api_openwin: ; int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title)
		PUSH 	EDI
		PUSH 	ESI
		PUSH 	EBX
		MOV 	EDX, 5
		MOV 	EBX, [ESP+12+4] 			; buf
		MOV 	ESI, [ESP+12+8] 			; xsiz
		MOV 	EDI, [ESP+12+12] 			; ysiz
		MOV 	EAX, [ESP+12+16] 			; col_inv
		MOV 	ECX, [ESP+12+20] 			; title
		INT 	0x40
		POP 	EBX
		POP 	ESI
		POP 	EDI
		RET

_api_putstrwin: ; void api_putstrwin(int win, int x, int y, int col, int len, char *str)
		PUSH 	EDI
		PUSH 	ESI
		PUSH 	EBP
		PUSH 	EBX
		MOV 	EDX, 6
		MOV 	EBX, [ESP+16+4]
		MOV 	ESI, [ESP+16+8]
		MOV 	EDI, [ESP+16+12]
		MOV 	EAX, [ESP+16+16]
		MOV 	ECX, [ESP+16+20]
		MOV 	EBP, [ESP+16+24]
		INT 	0x40
		POP 	EBX
		POP 	EBP
		POP 	ESI
		POP 	EDI
		RET

_api_boxfillwin: ; void api_boxfillwin(int win, int x0, int y0, int x1, inty1, int col)
		PUSH 	EDI
		PUSH 	ESI
		PUSH 	EBP
		PUSH 	EBX
		MOV 	EDX, 7
		MOV 	EBX, [ESP+16+4]
		MOV 	EAX, [ESP+16+8]
		MOV 	ECX, [ESP+16+12]
		MOV 	ESI, [ESP+16+16]
		MOV 	EDI, [ESP+16+20]
		MOV 	EBP, [ESP+16+24]
		INT 	0x40
		POP 	EBX
		POP 	EBP
		POP 	ESI
		POP 	EDI
		RET

_api_initmalloc: ; void api_initmalloc(void)
		PUSH 	EBX
		MOV 	EDX, 8
		MOV 	EBX, [CS:0x0020]
		MOV 	EAX, EBX
		ADD 	EAX, 32*1024
		MOV 	ECX, [CS:0x0000]
		SUB 	ECX, EAX
		INT 	0x40
		POP 	EBX
		RET

_api_malloc: ; char *api_malloc(int size)
		PUSH 	EBX
		MOV 	EDX, 9
		MOV 	EBX, [CS:0x0020]
		MOV 	ECX, [ESP+4+4]
		INT 	0x40
		POP 	EBX
		RET

_api_free: ; void api_free(char *addr, int size)
		PUSH 	EBX
		MOV 	EDX, 10
		MOV 	EBX, [CS:0x0020]
		MOV 	EAX, [ESP+4+4]
		MOV 	ECX, [ESP+4+8]
		INT 	0x40
		POP 	EBX
		RET

_api_point: ; void api_point(int win, int x, int y, int col)
		PUSH 	EDI
		PUSH 	ESI
		PUSH 	EBX
		MOV 	EDX, 11
		MOV 	EBX, [ESP+12+4]
		MOV 	ESI, [ESP+12+8]
		MOV 	EDI, [ESP+12+12]
		MOV 	EAX, [ESP+12+16]
		INT 	0x40
		POP 	EBX
		POP 	ESI
		POP 	EDI
		RET

_api_refreshwin: ; void api_refreshwin(int win, int x0, int y0, int x1, int y1)
		PUSH 	EDI
		PUSH 	ESI
		PUSH 	EBX
		MOV 	EDX, 12
		MOV 	EBX, [ESP+12+4]
		MOV 	EAX, [ESP+12+8]
		MOV 	ECX, [ESP+12+12]
		MOV 	ESI, [ESP+12+16]
		MOV 	EDI, [ESP+12+20]
		INT 	0x40
		POP 	EBX
		POP 	ESI
		POP 	EDI
		RET

_api_linewin: ; void api_linewin(int win, int x0, int y0, int x1, int y1, int col)
		PUSH 	EDI
		PUSH 	ESI
		PUSH 	EBP
		PUSH 	EBX

		MOV 	EDX, 13
		MOV 	EBX, [ESP+16+4]
		MOV 	EAX, [ESP+16+8]
		MOV 	ECX, [ESP+16+12]
		MOV 	ESI, [ESP+16+16]
		MOV 	EDI, [ESP+16+20]
		MOV 	EBP, [ESP+16+24]
		INT 	0x40

		POP 	EBX
		POP 	EBP
		POP 	ESI
		POP 	EDI
		RET

_api_closewin: ; void api_closewin(int win)
		PUSH 	EBX

		MOV 	EDX, 14
		MOV 	EBX, [ESP+4+4]
		INT 	0x40

		POP 	EBX
		RET