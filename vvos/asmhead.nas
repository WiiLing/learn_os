; sys
; tab=4

[INSTRSET "i486p"] 							; "想要使用486指令"的叙述

VBEMODE	EQU 	0x105 						; 画面模式号码

BOTPAK	EQU		0x00280000		; 加载bootpack
DSKCAC	EQU		0x00100000		; 磁盘缓存的位置
DSKCAC0	EQU		0x00008000		; 磁盘缓存的位置（实模式）

; 有关BOOT_INFO
CYLS 	EQU 	0x0ff0						; 设定启动区
LEDS 	EQU 	0x0ff1
VMODE 	EQU 	0x0ff2						; 关于颜色数目的信息。颜色的位数
SCRNX 	EQU 	0x0ff4						; 分辨率的X
SCRNY 	EQU 	0x0ff6						; 分辨率的Y
VRAM 	EQU 	0x0ff8						; 图像缓冲区的开始地址

; 这个程序将要被装载到内存的什么地方呢
		ORG 	0xc200

; 确认VBE(VESA BIOS extension)是否存在
		MOV 	AX, 0x9000
		MOV 	ES, AX
		MOV 	DI, 0
		MOV 	AX, 0x4f00
		INT 	0x10
		CMP 	AX, 0x004f
		JNE 	scrn320

; 检查VBE版本，不是2.0以上，不能使用高分辨率
		MOV 	AX, [ES:DI+4]
		CMP 	AX, 0x0200
		JB 		scrn320 					; if(AX < 0x0200) goto scrn320

; 取得画面模式信息，是否支持某画面模式号码
		MOV 	CX, VBEMODE
		MOV 	AX, 0x4f01
		INT 	0x10
		CMP 	AX, 0x004f
		JNE 	scrn320

; 画面模式信息的确认
		CMP 	BYTE [ES:DI+0x19], 8 		; 颜色数必须为8
		JNE 	scrn320
		CMP 	BYTE [ES:DI+0x1b], 4 		; 颜色的指定方法必须为4，调色板模式
		JNE 	scrn320
		MOV 	AX, [ES:DI+0x00] 			; 模式属性的bit7必须为1
		AND 	AX, 0x0080
		JZ 		scrn320

; 画面模式的切换
		MOV 	BX, VBEMODE+0x4000
		MOV 	AX, 0x4f02
		INT 	0x10
		MOV 	BYTE [VMODE], 8
		MOV 	AX, [ES:DI+0x12]
		MOV 	[SCRNX], AX
		MOV 	AX, [ES:DI+0x14]
		MOV 	[SCRNY], AX
		MOV 	EAX, [ES:DI+0x28]
		MOV 	[VRAM], EAX
		JMP 	keystatus

scrn320:
; 显示
; 320 * 200
		MOV		AL, 0x13 					; 画面模式号码
		MOV 	AH, 0x00 					; 旧画面模式
		INT 	0x10
; 记录画面模式
		MOV 	BYTE [VMODE], 8
; 320 * 200
		MOV 	WORD [SCRNX], 320
		MOV 	WORD [SCRNY], 200
		MOV		DWORD [VRAM], 0x000a0000

keystatus:
; 用BIOS取得键盘上各种LED指示灯的状态
		MOV 	AH, 0x02
		INT 	0x16						; keyboard BIOS
		MOV 	[LEDS], AL

; PIC关闭一切中断
;	根据AT兼容机的规格，如果要初始化PIC，
;	必须在CLI之前进行，否则有时会挂起。
;	进行PIC的初始化：

		MOV 	AL, 0xff
		OUT 	0x21, AL 					; PIC0_IMR(io_out8(PIC0_IMR, 0xff))
		NOP 								; 如果连续执行OUT指令，有些机制会无法正常运行
		OUT 	0xa1, AL 					; PIC1_IMR(io_out8(PIC1_IMR, 0xff))

		CLI 								; 禁止CPU级别的中断(io_cli())

; 为了让CPU能够访问1MB以上的内存空间，设定A20GATE
		CALL 	waitkbdout 					; wait_KBC_sendready()
		MOV 	AL, 0xd1
		OUT 	0x64, AL 					; io_out8(PORT_KEYCMD, KEYCMD_WRITE_OUTPORT)
		CALL 	waitkbdout 					; wait_KBC_sendready()
		MOV 	AL, 0xdf
		OUT 	0x60, AL 					; io_out8(PORT_KEYDAT, KBC_OUTPORT_A20G_ENABLE)
		CALL 	waitkbdout 					; wait_KBC_sendready() 这句话是为了等待完成执行指令

; 切换到保护模式
[INSTRSET "i486p"] 							; "想要使用486指令"的叙述
		LGDT 	[GDTR0] 					; 设定临时GDT
		MOV 	EAX, CR0
		AND 	EAX, 0x7fffffff 			; 设bit31为0（禁止分页）
		OR 		EAX, 0x00000001 			; 设bit0为1（切换到保护模式）
		MOV 	CR0, EAX
		JMP 	pipelineflush

; 管道刷新
; 管道机制：前一条指令还在执行的时候，就开始解释下一条甚至是再一下条指令
pipelineflush:
		MOV 	AX, 1*8 					; 可读写段号<<3 系统段
		MOV 	DS, AX
		MOV 	ES, AX
		MOV 	FS, AX
		MOV 	GS, AX
		MOV 	SS, AX

; bootpack的转送
; memcpy(bootpack, BOTPAK, 512*1024/4)
		MOV 	ESI, bootpack 				; 转送源
		MOV 	EDI, BOTPAK 				; 转送目的地
		MOV 	ECX, 512*1024/4
		CALL 	memcpy

; 磁盘数据最终转送到它本来的位置去

; 启动扇区的转送
; memcpy(0x7c00, DSKCAC, 512/4)
		MOV 	ESI, 0x7c00
		MOV 	EDI, DSKCAC
		MOV 	ECX, 512/4
		CALL 	memcpy

; 其他的转送
; memcpy(DSKCAC0+512, DSKCAC+512, cyls*512*18*2/4 - 512/4)
		MOV 	ESI, DSKCAC0+512
		MOV 	EDI, DSKCAC+512
		MOV 	ECX, 0
		MOV 	CL, BYTE [CYLS]
		IMUL 	ECX, 512*18*2/4 			; 剩余柱面
		SUB 	ECX, 512/4 					; 减去IPL
		CALL 	memcpy

; 必须由asmhead来完成的工作，至此全部完毕
; 以后就交由bootpack来完成

; bootpack启动

		MOV 	EBX, BOTPAK
		MOV 	ECX, [EBX+16]
		ADD 	ECX, 3
		SHR 	ECX, 2
		JZ 		skip 						; 没有要转送的东西时
		MOV 	ESI, [EBX+20]
		ADD 	ESI, EBX
		MOV 	EDI, [EBX+12]
		CALL 	memcpy
skip:
		MOV 	ESP, [EBX+12] 				; 栈初始值
		JMP 	DWORD 2*8:0x0000001b 		; 跳转到段号2的0x001b

waitkbdout:
		IN 		AL, 0x64
		AND 	AL, 0x02
		IN 		AL, 0x60 					; 空读（为了清空数据接收缓冲区中的垃圾数据）
		JNZ 	waitkbdout 					; AND的结果如果不是0，就跳到waitkbdout
		RET

memcpy:
		MOV 	EAX, [ESI]
		ADD 	ESI, 4
		MOV 	[EDI], EAX
		ADD 	EDI, 4
		SUB 	ECX, 1
		JNZ 	memcpy 						; 减法运算的结果如果不是0，就跳转到memcpy
		RET

; 双字节对齐，填充字符为0x00
		ALIGNB 	16
GDT0:
		RESB 	8 									; 第0段为空
		DW 		0xffff, 0x0000, 0x9200, 0x00cf 		; 第1段的数据结构值 set_segmdesc(gdt + 1, 0xffffffff, 0x00000000, AR_DATA32_RW)
		DW 		0xffff, 0x0000, 0x9a28, 0x0047 		; 第2段的数据结构值 set_segmdesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER)

		DW 		0 									; 为什么要空一格？是为了校验越界吗？
GDTR0:
		DW 		8*3-1 								; 段数据结构大小*个数-1、段信息表的有效大小-1、LIMIT_GDT
		DD 		GDT0 								; 段信息表的地址、ADR_GDT load_gdtr(LIMIT_GDT, ADR_GDT)

		ALIGNB 	16
bootpack: