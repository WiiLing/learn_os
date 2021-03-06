[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[OPTIMIZE 1]
[OPTION 1]
[BITS 32]
	EXTERN	_io_load_eflags
	EXTERN	_io_store_eflags
	EXTERN	_memtest_sub
	EXTERN	_load_cr0
	EXTERN	_store_cr0
[FILE "memory.c"]
[SECTION .text]
	GLOBAL	_memtest
_memtest:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	ESI
	PUSH	EBX
	XOR	ESI,ESI
	CALL	_io_load_eflags
	OR	EAX,262144
	PUSH	EAX
	CALL	_io_store_eflags
	CALL	_io_load_eflags
	POP	EDX
	TEST	EAX,262144
	JE	L2
	MOV	ESI,1
L2:
	AND	EAX,-262145
	PUSH	EAX
	CALL	_io_store_eflags
	POP	EAX
	MOV	EAX,ESI
	TEST	AL,AL
	JNE	L5
L3:
	PUSH	DWORD [12+EBP]
	PUSH	DWORD [8+EBP]
	CALL	_memtest_sub
	POP	EDX
	MOV	EBX,EAX
	POP	ECX
	MOV	EAX,ESI
	TEST	AL,AL
	JNE	L6
L4:
	LEA	ESP,DWORD [-8+EBP]
	MOV	EAX,EBX
	POP	EBX
	POP	ESI
	POP	EBP
	RET
L6:
	CALL	_load_cr0
	AND	EAX,-1610612737
	PUSH	EAX
	CALL	_store_cr0
	POP	EAX
	JMP	L4
L5:
	CALL	_load_cr0
	OR	EAX,1610612736
	PUSH	EAX
	CALL	_store_cr0
	POP	EBX
	JMP	L3
	GLOBAL	_memman_init
_memman_init:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,DWORD [8+EBP]
	MOV	DWORD [EAX],0
	MOV	DWORD [4+EAX],0
	MOV	DWORD [8+EAX],0
	MOV	DWORD [12+EAX],0
	POP	EBP
	RET
	GLOBAL	_memman_total
_memman_total:
	PUSH	EBP
	XOR	EAX,EAX
	MOV	EBP,ESP
	XOR	EDX,EDX
	PUSH	EBX
	MOV	EBX,DWORD [8+EBP]
	MOV	ECX,DWORD [EBX]
	CMP	EAX,ECX
	JAE	L15
L13:
	ADD	EAX,DWORD [20+EBX+EDX*8]
	INC	EDX
	CMP	EDX,ECX
	JB	L13
L15:
	POP	EBX
	POP	EBP
	RET
	GLOBAL	_memman_alloc
_memman_alloc:
	PUSH	EBP
	XOR	EDX,EDX
	MOV	EBP,ESP
	PUSH	EDI
	PUSH	ESI
	MOV	ECX,DWORD [8+EBP]
	PUSH	EBX
	MOV	ESI,DWORD [12+EBP]
	MOV	EAX,DWORD [ECX]
	CMP	EDX,EAX
	JAE	L30
L28:
	MOV	EBX,DWORD [20+ECX+EDX*8]
	CMP	EBX,ESI
	JAE	L32
	INC	EDX
	CMP	EDX,EAX
	JB	L28
L30:
	XOR	EAX,EAX
L16:
	POP	EBX
	POP	ESI
	POP	EDI
	POP	EBP
	RET
L32:
	MOV	EDI,DWORD [16+ECX+EDX*8]
	LEA	EAX,DWORD [ESI+EDI*1]
	MOV	DWORD [16+ECX+EDX*8],EAX
	MOV	EAX,EBX
	SUB	EAX,ESI
	MOV	DWORD [20+ECX+EDX*8],EAX
	TEST	EAX,EAX
	JNE	L22
	MOV	EAX,DWORD [ECX]
	DEC	EAX
	MOV	DWORD [ECX],EAX
	CMP	EDX,EAX
	JAE	L22
L27:
	MOV	EAX,DWORD [24+ECX+EDX*8]
	MOV	DWORD [16+ECX+EDX*8],EAX
	MOV	EAX,DWORD [28+ECX+EDX*8]
	MOV	DWORD [20+ECX+EDX*8],EAX
	INC	EDX
	CMP	EDX,DWORD [ECX]
	JB	L27
L22:
	MOV	EAX,EDI
	JMP	L16
	GLOBAL	_memman_free
_memman_free:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	EDI
	PUSH	ESI
	MOV	ECX,DWORD [8+EBP]
	PUSH	EBX
	XOR	EBX,EBX
	MOV	EDI,DWORD [16+EBP]
	MOV	EDX,DWORD [ECX]
	CMP	EBX,EDX
	JGE	L35
L39:
	MOV	EAX,DWORD [12+EBP]
	CMP	DWORD [16+ECX+EBX*8],EAX
	JA	L35
	INC	EBX
	CMP	EBX,EDX
	JL	L39
L35:
	TEST	EBX,EBX
	JLE	L40
	MOV	ESI,DWORD [12+ECX+EBX*8]
	MOV	EAX,DWORD [8+ECX+EBX*8]
	ADD	EAX,ESI
	CMP	EAX,DWORD [12+EBP]
	JE	L62
L40:
	CMP	EBX,EDX
	JGE	L48
	MOV	EAX,DWORD [12+EBP]
	ADD	EAX,EDI
	CMP	EAX,DWORD [16+ECX+EBX*8]
	JE	L63
L61:
	XOR	EAX,EAX
L33:
	POP	EBX
	POP	ESI
	POP	EDI
	POP	EBP
	RET
L63:
	MOV	EAX,DWORD [12+EBP]
	ADD	DWORD [20+ECX+EBX*8],EDI
	MOV	DWORD [16+ECX+EBX*8],EAX
	JMP	L61
L48:
	CMP	EDX,4089
	JG	L50
	CMP	EDX,EBX
	JLE	L60
L55:
	MOV	EAX,DWORD [8+ECX+EDX*8]
	MOV	DWORD [16+ECX+EDX*8],EAX
	MOV	EAX,DWORD [12+ECX+EDX*8]
	MOV	DWORD [20+ECX+EDX*8],EAX
	DEC	EDX
	CMP	EDX,EBX
	JG	L55
L60:
	MOV	EAX,DWORD [ECX]
	INC	EAX
	MOV	DWORD [ECX],EAX
	CMP	DWORD [4+ECX],EAX
	JLE	L56
	MOV	DWORD [4+ECX],EAX
L56:
	MOV	EAX,DWORD [12+EBP]
	MOV	DWORD [20+ECX+EBX*8],EDI
	MOV	DWORD [16+ECX+EBX*8],EAX
	JMP	L61
L50:
	ADD	DWORD [8+ECX],EDI
	OR	EAX,-1
	INC	DWORD [12+ECX]
	JMP	L33
L62:
	MOV	EAX,DWORD [12+EBP]
	LEA	EDX,DWORD [EDI+ESI*1]
	ADD	EAX,EDI
	MOV	DWORD [12+ECX+EBX*8],EDX
	CMP	EAX,DWORD [16+ECX+EBX*8]
	JNE	L61
	LEA	EAX,DWORD [EDI+EDX*1]
	MOV	EDX,EBX
	MOV	DWORD [12+ECX+EBX*8],EAX
	MOV	EAX,DWORD [ECX]
	DEC	EAX
	MOV	DWORD [ECX],EAX
	CMP	EBX,EAX
	JGE	L61
L47:
	MOV	EAX,DWORD [24+ECX+EDX*8]
	MOV	DWORD [16+ECX+EDX*8],EAX
	MOV	EAX,DWORD [28+ECX+EDX*8]
	MOV	DWORD [20+ECX+EDX*8],EAX
	INC	EDX
	CMP	EDX,DWORD [ECX]
	JL	L47
	JMP	L61
	GLOBAL	_memman_alloc_4k
_memman_alloc_4k:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,DWORD [12+EBP]
	ADD	EAX,4095
	AND	EAX,-4096
	MOV	DWORD [12+EBP],EAX
	POP	EBP
	JMP	_memman_alloc
	GLOBAL	_memman_free_4k
_memman_free_4k:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,DWORD [16+EBP]
	ADD	EAX,4095
	AND	EAX,-4096
	MOV	DWORD [16+EBP],EAX
	POP	EBP
	JMP	_memman_free
