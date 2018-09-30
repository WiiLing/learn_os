[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[OPTIMIZE 1]
[OPTION 1]
[BITS 32]
	EXTERN	_init_gdtidt
	EXTERN	_init_pic
	EXTERN	_init_pit
	EXTERN	_io_sti
	EXTERN	_fifo32_init
	EXTERN	_init_keyboard
	EXTERN	_enable_mouse
	EXTERN	_io_out8
	EXTERN	_memtest
	EXTERN	_memman_init
	EXTERN	_memman_free
	EXTERN	_task_init
	EXTERN	_task_run
	EXTERN	_init_palette
	EXTERN	_shtctl_init
	EXTERN	_sheet_alloc
	EXTERN	_memman_alloc_4k
	EXTERN	_sheet_setbuf
	EXTERN	_init_screen8
	EXTERN	_make_window8
	EXTERN	_make_textbox8
	EXTERN	_task_alloc
	EXTERN	_console_task
	EXTERN	_timer_alloc
	EXTERN	_timer_init
	EXTERN	_timer_settime
	EXTERN	_init_mouse_cursor8
	EXTERN	_sheet_slide
	EXTERN	_sheet_updown
	EXTERN	_fifo32_put
	EXTERN	_fifo32_status
	EXTERN	_io_cli
	EXTERN	_fifo32_get
	EXTERN	_boxfill8
	EXTERN	_sheet_refresh
	EXTERN	_putfonts8_asc_sht
	EXTERN	_mouse_decode
	EXTERN	_keytable0.0
	EXTERN	_make_wtitle8
	EXTERN	_wait_KBC_sendready
	EXTERN	_keytable1.1
	EXTERN	_task_sleep
[FILE "bootpack.c"]
[SECTION .data]
_keytable0.0:
	DB	0
	DB	0
	DB	49
	DB	50
	DB	51
	DB	52
	DB	53
	DB	54
	DB	55
	DB	56
	DB	57
	DB	48
	DB	45
	DB	94
	DB	0
	DB	0
	DB	81
	DB	87
	DB	69
	DB	82
	DB	84
	DB	89
	DB	85
	DB	73
	DB	79
	DB	80
	DB	64
	DB	91
	DB	0
	DB	0
	DB	65
	DB	83
	DB	68
	DB	70
	DB	71
	DB	72
	DB	74
	DB	75
	DB	76
	DB	59
	DB	58
	DB	0
	DB	0
	DB	93
	DB	90
	DB	88
	DB	67
	DB	86
	DB	66
	DB	78
	DB	77
	DB	44
	DB	46
	DB	47
	DB	0
	DB	42
	DB	0
	DB	32
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	55
	DB	56
	DB	57
	DB	45
	DB	52
	DB	53
	DB	54
	DB	43
	DB	49
	DB	50
	DB	51
	DB	48
	DB	46
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	92
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	92
	DB	0
	DB	0
_keytable1.1:
	DB	0
	DB	0
	DB	33
	DB	34
	DB	35
	DB	36
	DB	37
	DB	38
	DB	39
	DB	40
	DB	41
	DB	126
	DB	61
	DB	126
	DB	0
	DB	0
	DB	81
	DB	87
	DB	69
	DB	82
	DB	84
	DB	89
	DB	85
	DB	73
	DB	79
	DB	80
	DB	96
	DB	123
	DB	0
	DB	0
	DB	65
	DB	83
	DB	68
	DB	70
	DB	71
	DB	72
	DB	74
	DB	75
	DB	76
	DB	43
	DB	42
	DB	0
	DB	0
	DB	125
	DB	90
	DB	88
	DB	67
	DB	86
	DB	66
	DB	78
	DB	77
	DB	60
	DB	62
	DB	63
	DB	0
	DB	42
	DB	0
	DB	32
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	55
	DB	56
	DB	57
	DB	45
	DB	52
	DB	53
	DB	54
	DB	43
	DB	49
	DB	50
	DB	51
	DB	48
	DB	46
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	95
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	0
	DB	124
	DB	0
	DB	0
LC0:
	DB	"console",0x00
LC1:
	DB	"task_a",0x00
LC4:
	DB	"3[Sec]",0x00
LC3:
	DB	"10[Sec]",0x00
LC2:
	DB	" ",0x00
[SECTION .text]
	GLOBAL	_HariMain
_HariMain:
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	EDI
	PUSH	ESI
	PUSH	EBX
	SUB	ESP,1128
	MOV	DWORD [-1124+EBP],0
	MOV	DWORD [-1128+EBP],0
	MOV	AL,BYTE [4081]
	SAR	AL,4
	MOV	EDX,EAX
	AND	EDX,7
	MOV	DWORD [-1132+EBP],EDX
	MOV	DWORD [-1136+EBP],-1
	CALL	_init_gdtidt
	CALL	_init_pic
	CALL	_init_pit
	CALL	_io_sti
	LEA	EAX,DWORD [-844+EBP]
	PUSH	0
	PUSH	EAX
	LEA	EAX,DWORD [-1020+EBP]
	PUSH	128
	PUSH	EAX
	CALL	_fifo32_init
	LEA	EDX,DWORD [-1052+EBP]
	PUSH	0
	LEA	EAX,DWORD [-972+EBP]
	PUSH	EAX
	PUSH	32
	PUSH	EDX
	CALL	_fifo32_init
	LEA	EAX,DWORD [-1020+EBP]
	ADD	ESP,32
	PUSH	256
	PUSH	EAX
	CALL	_init_keyboard
	LEA	EDX,DWORD [-1020+EBP]
	LEA	EAX,DWORD [-988+EBP]
	PUSH	EAX
	PUSH	512
	PUSH	EDX
	CALL	_enable_mouse
	PUSH	248
	PUSH	33
	CALL	_io_out8
	PUSH	239
	PUSH	161
	CALL	_io_out8
	ADD	ESP,36
	PUSH	-1073741825
	PUSH	4194304
	CALL	_memtest
	PUSH	3932160
	MOV	DWORD [-1092+EBP],EAX
	CALL	_memman_init
	PUSH	647168
	PUSH	4096
	PUSH	3932160
	CALL	_memman_free
	MOV	EAX,DWORD [-1092+EBP]
	SUB	EAX,4194304
	PUSH	EAX
	PUSH	4194304
	PUSH	3932160
	CALL	_memman_free
	ADD	ESP,36
	PUSH	3932160
	CALL	_task_init
	PUSH	0
	PUSH	1
	PUSH	EAX
	MOV	DWORD [-1108+EBP],EAX
	MOV	DWORD [-996+EBP],EAX
	CALL	_task_run
	CALL	_init_palette
	MOVSX	EAX,WORD [4086]
	PUSH	EAX
	MOVSX	EAX,WORD [4084]
	PUSH	EAX
	PUSH	DWORD [4088]
	PUSH	3932160
	CALL	_shtctl_init
	ADD	ESP,32
	MOV	ESI,EAX
	PUSH	EAX
	CALL	_sheet_alloc
	MOVSX	EDX,WORD [4086]
	MOV	DWORD [-1072+EBP],EAX
	MOVSX	EAX,WORD [4084]
	IMUL	EAX,EDX
	PUSH	EAX
	PUSH	3932160
	CALL	_memman_alloc_4k
	PUSH	-1
	MOV	EBX,EAX
	MOVSX	EAX,WORD [4086]
	PUSH	EAX
	MOVSX	EAX,WORD [4084]
	PUSH	EAX
	PUSH	EBX
	PUSH	DWORD [-1072+EBP]
	CALL	_sheet_setbuf
	ADD	ESP,32
	MOVSX	EAX,WORD [4086]
	PUSH	EAX
	MOVSX	EAX,WORD [4084]
	PUSH	EAX
	PUSH	EBX
	LEA	EBX,DWORD [-284+EBP]
	CALL	_init_screen8
	PUSH	ESI
	CALL	_sheet_alloc
	PUSH	42240
	PUSH	3932160
	MOV	DWORD [-1080+EBP],EAX
	CALL	_memman_alloc_4k
	PUSH	-1
	PUSH	165
	MOV	DWORD [-1088+EBP],EAX
	PUSH	256
	PUSH	EAX
	PUSH	DWORD [-1080+EBP]
	CALL	_sheet_setbuf
	ADD	ESP,44
	PUSH	0
	PUSH	LC0
	PUSH	165
	PUSH	256
	PUSH	DWORD [-1088+EBP]
	CALL	_make_window8
	PUSH	0
	PUSH	128
	PUSH	240
	PUSH	28
	PUSH	8
	PUSH	DWORD [-1080+EBP]
	CALL	_make_textbox8
	ADD	ESP,44
	CALL	_task_alloc
	PUSH	65536
	PUSH	3932160
	MOV	DWORD [-1112+EBP],EAX
	CALL	_memman_alloc_4k
	MOV	EDX,DWORD [-1112+EBP]
	ADD	EAX,65524
	MOV	DWORD [100+EDX],EAX
	MOV	DWORD [76+EDX],_console_task
	MOV	DWORD [116+EDX],8
	MOV	DWORD [120+EDX],16
	MOV	DWORD [124+EDX],8
	MOV	DWORD [128+EDX],8
	MOV	DWORD [132+EDX],8
	MOV	DWORD [136+EDX],8
	MOV	EDX,DWORD [-1080+EBP]
	MOV	DWORD [4+EAX],EDX
	MOV	EDX,DWORD [-1112+EBP]
	MOV	EAX,DWORD [100+EDX]
	MOV	EDX,DWORD [-1092+EBP]
	MOV	DWORD [8+EAX],EDX
	PUSH	2
	PUSH	2
	PUSH	DWORD [-1112+EBP]
	CALL	_task_run
	PUSH	ESI
	CALL	_sheet_alloc
	PUSH	8320
	PUSH	3932160
	MOV	EDI,EAX
	CALL	_memman_alloc_4k
	ADD	ESP,32
	PUSH	-1
	MOV	DWORD [-1084+EBP],EAX
	PUSH	52
	PUSH	144
	PUSH	EAX
	PUSH	EDI
	CALL	_sheet_setbuf
	PUSH	1
	PUSH	LC1
	PUSH	52
	PUSH	144
	PUSH	DWORD [-1084+EBP]
	CALL	_make_window8
	ADD	ESP,40
	PUSH	7
	PUSH	16
	PUSH	128
	PUSH	28
	PUSH	8
	PUSH	EDI
	CALL	_make_textbox8
	MOV	DWORD [-1100+EBP],8
	MOV	DWORD [-1104+EBP],7
	CALL	_timer_alloc
	PUSH	1
	MOV	DWORD [-1096+EBP],EAX
	LEA	EAX,DWORD [-1020+EBP]
	PUSH	EAX
	PUSH	DWORD [-1096+EBP]
	CALL	_timer_init
	ADD	ESP,36
	PUSH	50
	PUSH	DWORD [-1096+EBP]
	CALL	_timer_settime
	PUSH	ESI
	CALL	_sheet_alloc
	PUSH	99
	PUSH	16
	PUSH	16
	MOV	DWORD [-1076+EBP],EAX
	PUSH	EBX
	PUSH	EAX
	CALL	_sheet_setbuf
	ADD	ESP,32
	PUSH	99
	PUSH	EBX
	MOV	EBX,2
	CALL	_init_mouse_cursor8
	MOVSX	EAX,WORD [4084]
	LEA	ECX,DWORD [-16+EAX]
	MOV	EAX,ECX
	CDQ
	IDIV	EBX
	MOV	DWORD [-1116+EBP],EAX
	MOVSX	EAX,WORD [4086]
	PUSH	0
	LEA	ECX,DWORD [-44+EAX]
	PUSH	0
	MOV	EAX,ECX
	CDQ
	IDIV	EBX
	PUSH	DWORD [-1072+EBP]
	MOV	DWORD [-1120+EBP],EAX
	CALL	_sheet_slide
	PUSH	4
	PUSH	32
	PUSH	DWORD [-1080+EBP]
	CALL	_sheet_slide
	ADD	ESP,32
	PUSH	DWORD [-1120+EBP]
	PUSH	DWORD [-1116+EBP]
	PUSH	DWORD [-1076+EBP]
	CALL	_sheet_slide
	PUSH	56
	PUSH	64
	PUSH	EDI
	CALL	_sheet_slide
	PUSH	0
	PUSH	DWORD [-1072+EBP]
	CALL	_sheet_updown
	ADD	ESP,32
	PUSH	1
	PUSH	DWORD [-1080+EBP]
	CALL	_sheet_updown
	PUSH	2
	PUSH	EDI
	CALL	_sheet_updown
	PUSH	3
	PUSH	DWORD [-1076+EBP]
	CALL	_sheet_updown
	LEA	EDX,DWORD [-1052+EBP]
	PUSH	237
	PUSH	EDX
	CALL	_fifo32_put
	LEA	EAX,DWORD [-1052+EBP]
	ADD	ESP,32
	PUSH	DWORD [-1132+EBP]
	PUSH	EAX
	CALL	_fifo32_put
	POP	ECX
	POP	EBX
L2:
	LEA	EBX,DWORD [-1052+EBP]
	PUSH	EBX
	CALL	_fifo32_status
	POP	EDX
	TEST	EAX,EAX
	JLE	L5
	CMP	DWORD [-1136+EBP],0
	JS	L64
L5:
	LEA	EBX,DWORD [-1020+EBP]
	CALL	_io_cli
	PUSH	EBX
	CALL	_fifo32_status
	POP	ESI
	TEST	EAX,EAX
	JE	L65
	PUSH	EBX
	CALL	_fifo32_get
	MOV	ESI,EAX
	CALL	_io_sti
	POP	ECX
	LEA	EAX,DWORD [-256+ESI]
	CMP	EAX,255
	JBE	L66
	LEA	EAX,DWORD [-512+ESI]
	CMP	EAX,255
	JBE	L67
	CMP	ESI,10
	JE	L68
	CMP	ESI,3
	JE	L69
	CMP	ESI,1
	JG	L2
	TEST	ESI,ESI
	JE	L54
	PUSH	0
	PUSH	EBX
	PUSH	DWORD [-1096+EBP]
	CALL	_timer_init
	ADD	ESP,12
	CMP	DWORD [-1104+EBP],0
	JS	L56
	MOV	DWORD [-1104+EBP],0
L56:
	PUSH	50
	PUSH	DWORD [-1096+EBP]
	CALL	_timer_settime
	POP	EAX
	POP	EDX
L63:
	CMP	DWORD [-1104+EBP],0
	JS	L58
	MOV	EAX,DWORD [-1100+EBP]
	PUSH	43
	ADD	EAX,7
	PUSH	EAX
	PUSH	28
	PUSH	DWORD [-1100+EBP]
	MOVZX	EAX,BYTE [-1104+EBP]
	PUSH	EAX
	PUSH	DWORD [4+EDI]
	PUSH	DWORD [EDI]
	CALL	_boxfill8
	ADD	ESP,28
L58:
	MOV	EAX,DWORD [-1100+EBP]
	PUSH	44
	ADD	EAX,8
	PUSH	EAX
	PUSH	28
	PUSH	DWORD [-1100+EBP]
	PUSH	EDI
	CALL	_sheet_refresh
	ADD	ESP,20
	JMP	L2
L54:
	PUSH	1
	PUSH	EBX
	PUSH	DWORD [-1096+EBP]
	CALL	_timer_init
	ADD	ESP,12
	CMP	DWORD [-1104+EBP],0
	JS	L56
	MOV	DWORD [-1104+EBP],7
	JMP	L56
L69:
	PUSH	6
	PUSH	LC4
	PUSH	14
	PUSH	7
	PUSH	80
L60:
	PUSH	0
	PUSH	DWORD [-1072+EBP]
	CALL	_putfonts8_asc_sht
	ADD	ESP,28
	JMP	L2
L68:
	PUSH	7
	PUSH	LC3
	PUSH	14
	PUSH	7
	PUSH	64
	JMP	L60
L67:
	MOV	EDX,ESI
	MOVZX	EAX,DL
	PUSH	EAX
	LEA	EAX,DWORD [-988+EBP]
	PUSH	EAX
	CALL	_mouse_decode
	POP	ECX
	POP	EBX
	TEST	EAX,EAX
	JE	L2
	MOV	EAX,DWORD [-980+EBP]
	MOV	EDX,DWORD [-984+EBP]
	ADD	DWORD [-1120+EBP],EAX
	ADD	DWORD [-1116+EBP],EDX
	JS	L70
L43:
	CMP	DWORD [-1120+EBP],0
	JS	L71
L44:
	MOVSX	EAX,WORD [4084]
	DEC	EAX
	CMP	DWORD [-1116+EBP],EAX
	JLE	L45
	MOV	DWORD [-1116+EBP],EAX
L45:
	MOVSX	EAX,WORD [4086]
	DEC	EAX
	CMP	DWORD [-1120+EBP],EAX
	JLE	L46
	MOV	DWORD [-1120+EBP],EAX
L46:
	PUSH	DWORD [-1120+EBP]
	PUSH	DWORD [-1116+EBP]
	PUSH	DWORD [-1076+EBP]
	CALL	_sheet_slide
	ADD	ESP,12
	TEST	DWORD [-976+EBP],1
	JE	L2
	MOV	EAX,DWORD [-1120+EBP]
	SUB	EAX,8
	PUSH	EAX
	MOV	EAX,DWORD [-1116+EBP]
	SUB	EAX,80
	PUSH	EAX
	PUSH	EDI
	CALL	_sheet_slide
	ADD	ESP,12
	JMP	L2
L71:
	MOV	DWORD [-1120+EBP],0
	JMP	L44
L70:
	MOV	DWORD [-1116+EBP],0
	JMP	L43
L66:
	CMP	ESI,383
	JG	L9
	CMP	DWORD [-1128+EBP],0
	JNE	L10
	MOV	AL,BYTE [_keytable0.0-256+ESI]
L61:
	MOV	BYTE [-332+EBP],AL
L12:
	MOV	DL,BYTE [-332+EBP]
	LEA	EAX,DWORD [-65+EDX]
	CMP	AL,25
	JA	L13
	TEST	DWORD [-1132+EBP],4
	JNE	L59
	CMP	DWORD [-1128+EBP],0
	JE	L15
L13:
	MOV	AL,BYTE [-332+EBP]
	TEST	AL,AL
	JE	L17
	CMP	DWORD [-1124+EBP],0
	JNE	L18
	CMP	DWORD [-1100+EBP],127
	JG	L17
	PUSH	1
	LEA	EAX,DWORD [-332+EBP]
	PUSH	EAX
	PUSH	7
	PUSH	0
	PUSH	28
	PUSH	DWORD [-1100+EBP]
	PUSH	EDI
	MOV	BYTE [-331+EBP],0
	CALL	_putfonts8_asc_sht
	ADD	ESP,28
	ADD	DWORD [-1100+EBP],8
L17:
	CMP	ESI,284
	JE	L72
L21:
	CMP	ESI,314
	JE	L73
L23:
	CMP	ESI,325
	JE	L74
L24:
	CMP	ESI,326
	JE	L75
L25:
	CMP	ESI,506
	JE	L76
L26:
	CMP	ESI,510
	JE	L77
L27:
	CMP	ESI,270
	JE	L78
L28:
	CMP	ESI,271
	JE	L79
L32:
	CMP	ESI,298
	JE	L80
L35:
	CMP	ESI,310
	JE	L81
L36:
	CMP	ESI,426
	JE	L82
L37:
	CMP	ESI,438
	JNE	L63
	AND	DWORD [-1128+EBP],-3
	JMP	L63
L82:
	AND	DWORD [-1128+EBP],-2
	JMP	L37
L81:
	OR	DWORD [-1128+EBP],2
	JMP	L36
L80:
	OR	DWORD [-1128+EBP],1
	JMP	L35
L79:
	CMP	DWORD [-1124+EBP],0
	JNE	L33
	PUSH	0
	PUSH	LC1
	PUSH	DWORD [4+EDI]
	PUSH	DWORD [-1084+EBP]
	MOV	DWORD [-1124+EBP],1
	CALL	_make_wtitle8
	MOV	EDX,DWORD [-1080+EBP]
	PUSH	1
	PUSH	LC0
	PUSH	DWORD [4+EDX]
	PUSH	DWORD [-1088+EBP]
	CALL	_make_wtitle8
	MOV	EAX,DWORD [-1100+EBP]
	ADD	ESP,32
	ADD	EAX,7
	MOV	DWORD [-1104+EBP],-1
	PUSH	43
	PUSH	EAX
	PUSH	28
	PUSH	DWORD [-1100+EBP]
	PUSH	7
	PUSH	DWORD [4+EDI]
	PUSH	DWORD [EDI]
	CALL	_boxfill8
	MOV	EAX,DWORD [-1112+EBP]
	PUSH	2
	ADD	EAX,16
	PUSH	EAX
	CALL	_fifo32_put
	ADD	ESP,36
L34:
	PUSH	21
	PUSH	DWORD [4+EDI]
	PUSH	0
	PUSH	0
	PUSH	EDI
	CALL	_sheet_refresh
	MOV	EDX,DWORD [-1080+EBP]
	PUSH	21
	PUSH	DWORD [4+EDX]
	PUSH	0
	PUSH	0
	PUSH	EDX
	CALL	_sheet_refresh
	ADD	ESP,40
	JMP	L32
L33:
	PUSH	1
	PUSH	LC1
	PUSH	DWORD [4+EDI]
	PUSH	DWORD [-1084+EBP]
	MOV	DWORD [-1124+EBP],0
	CALL	_make_wtitle8
	MOV	EAX,DWORD [-1080+EBP]
	PUSH	0
	PUSH	LC0
	PUSH	DWORD [4+EAX]
	PUSH	DWORD [-1088+EBP]
	CALL	_make_wtitle8
	MOV	EAX,DWORD [-1112+EBP]
	ADD	ESP,32
	ADD	EAX,16
	MOV	DWORD [-1104+EBP],0
	PUSH	3
	PUSH	EAX
	CALL	_fifo32_put
	POP	EAX
	POP	EDX
	JMP	L34
L78:
	CMP	DWORD [-1124+EBP],0
	JNE	L29
	CMP	DWORD [-1100+EBP],8
	JLE	L28
	PUSH	1
	PUSH	LC2
	PUSH	7
	PUSH	0
	PUSH	28
	PUSH	DWORD [-1100+EBP]
	PUSH	EDI
	CALL	_putfonts8_asc_sht
	ADD	ESP,28
	SUB	DWORD [-1100+EBP],8
	JMP	L28
L29:
	MOV	EAX,DWORD [-1112+EBP]
	PUSH	264
	ADD	EAX,16
	PUSH	EAX
	CALL	_fifo32_put
	POP	ECX
	POP	EBX
	JMP	L28
L77:
	CALL	_wait_KBC_sendready
	PUSH	DWORD [-1136+EBP]
	PUSH	96
	CALL	_io_out8
	POP	EAX
	POP	EDX
	JMP	L27
L76:
	MOV	DWORD [-1136+EBP],-1
	JMP	L26
L75:
	PUSH	237
	LEA	EBX,DWORD [-1052+EBP]
	PUSH	EBX
	XOR	DWORD [-1132+EBP],1
	CALL	_fifo32_put
	PUSH	DWORD [-1132+EBP]
	PUSH	EBX
	CALL	_fifo32_put
	ADD	ESP,16
	JMP	L25
L74:
	PUSH	237
	LEA	EBX,DWORD [-1052+EBP]
	PUSH	EBX
	XOR	DWORD [-1132+EBP],2
	CALL	_fifo32_put
	PUSH	DWORD [-1132+EBP]
	PUSH	EBX
	CALL	_fifo32_put
	ADD	ESP,16
	JMP	L24
L73:
	PUSH	237
	LEA	EBX,DWORD [-1052+EBP]
	PUSH	EBX
	XOR	DWORD [-1132+EBP],4
	CALL	_fifo32_put
	PUSH	DWORD [-1132+EBP]
	PUSH	EBX
	CALL	_fifo32_put
	ADD	ESP,16
	JMP	L23
L72:
	CMP	DWORD [-1124+EBP],0
	JE	L21
	MOV	EAX,DWORD [-1112+EBP]
	PUSH	266
	ADD	EAX,16
	PUSH	EAX
	CALL	_fifo32_put
	POP	ECX
	POP	EBX
	JMP	L21
L18:
	MOVSX	EAX,AL
	ADD	EAX,256
	PUSH	EAX
	MOV	EAX,DWORD [-1112+EBP]
	ADD	EAX,16
	PUSH	EAX
	CALL	_fifo32_put
	POP	EAX
	POP	EDX
	JMP	L17
L15:
	LEA	EAX,DWORD [32+EDX]
	MOV	BYTE [-332+EBP],AL
	JMP	L13
L59:
	CMP	DWORD [-1128+EBP],0
	JE	L13
	JMP	L15
L10:
	MOV	AL,BYTE [_keytable1.1-256+ESI]
	JMP	L61
L9:
	MOV	BYTE [-332+EBP],0
	JMP	L12
L65:
	PUSH	DWORD [-1108+EBP]
	CALL	_task_sleep
	CALL	_io_sti
	POP	EBX
	JMP	L2
L64:
	PUSH	EBX
	CALL	_fifo32_get
	MOV	DWORD [-1136+EBP],EAX
	CALL	_wait_KBC_sendready
	PUSH	DWORD [-1136+EBP]
	PUSH	96
	CALL	_io_out8
	ADD	ESP,12
	JMP	L5
