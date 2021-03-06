[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[OPTIMIZE 1]
[OPTION 1]
[BITS 32]
	EXTERN	_io_out8
	EXTERN	_io_in8
	EXTERN	_fifo32_put
	EXTERN	_mouse_rate
	EXTERN	_wait_KBC_sendready
[FILE "mouse.c"]
[SECTION .data]
	ALIGNB	4
_mouse_rate:
	DD	2
[SECTION .text]
	GLOBAL	_inthandler2c
_inthandler2c:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	100
	PUSH	160
	CALL	_io_out8
	PUSH	98
	PUSH	32
	CALL	_io_out8
	PUSH	96
	CALL	_io_in8
	ADD	EAX,DWORD [_mousedata0]
	PUSH	EAX
	PUSH	DWORD [_mousefifo]
	CALL	_fifo32_put
	LEAVE
	RET
	GLOBAL	_mouse_decode
_mouse_decode:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	EDI
	PUSH	ESI
	PUSH	EBX
	PUSH	ECX
	MOV	EBX,DWORD [8+EBP]
	MOV	EDX,DWORD [12+EBP]
	MOV	ESI,EDX
	MOV	AL,BYTE [3+EBX]
	TEST	AL,AL
	JNE	L3
	CMP	DL,-6
	JE	L15
L14:
	XOR	EAX,EAX
L2:
	POP	EDX
	POP	EBX
	POP	ESI
	POP	EDI
	POP	EBP
	RET
L15:
	MOV	BYTE [3+EBX],1
	JMP	L14
L3:
	CMP	AL,1
	JE	L16
	CMP	AL,2
	JE	L17
	CMP	AL,3
	JE	L18
	OR	EAX,-1
	JMP	L2
L18:
	MOV	CL,BYTE [EBX]
	AND	ESI,255
	MOV	EAX,ECX
	MOV	BYTE [2+EBX],DL
	AND	EAX,7
	MOV	DWORD [8+EBX],ESI
	MOV	DWORD [12+EBX],EAX
	MOV	AL,CL
	MOVZX	EDX,BYTE [1+EBX]
	AND	EAX,16
	MOV	DWORD [4+EBX],EDX
	MOV	BYTE [3+EBX],1
	TEST	AL,AL
	JE	L12
	OR	EDX,-256
	MOV	DWORD [4+EBX],EDX
L12:
	AND	ECX,32
	TEST	CL,CL
	JE	L13
	OR	DWORD [8+EBX],-256
L13:
	MOV	EAX,DWORD [4+EBX]
	MOV	EDI,DWORD [_mouse_rate]
	CDQ
	IDIV	EDI
	MOV	ECX,DWORD [8+EBX]
	MOV	DWORD [4+EBX],EAX
	NEG	ECX
	MOV	EAX,ECX
	MOV	DWORD [8+EBX],ECX
	CDQ
	IDIV	EDI
	MOV	DWORD [8+EBX],EAX
	MOV	EAX,1
	JMP	L2
L17:
	MOV	BYTE [1+EBX],DL
	MOV	BYTE [3+EBX],3
	JMP	L14
L16:
	AND	ESI,-56
	MOV	EAX,ESI
	CMP	AL,8
	JNE	L14
	MOV	BYTE [EBX],DL
	MOV	BYTE [3+EBX],2
	JMP	L14
	GLOBAL	_enable_mouse
_enable_mouse:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,DWORD [8+EBP]
	MOV	DWORD [_mousefifo],EAX
	MOV	EAX,DWORD [12+EBP]
	MOV	DWORD [_mousedata0],EAX
	CALL	_wait_KBC_sendready
	PUSH	212
	PUSH	100
	CALL	_io_out8
	CALL	_wait_KBC_sendready
	PUSH	244
	PUSH	96
	CALL	_io_out8
	MOV	EAX,DWORD [16+EBP]
	MOV	BYTE [3+EAX],0
	LEAVE
	RET
	GLOBAL	_mousefifo
[SECTION .data]
	ALIGNB	4
_mousefifo:
	RESB	4
	GLOBAL	_mousedata0
[SECTION .data]
	ALIGNB	4
_mousedata0:
	RESB	4
