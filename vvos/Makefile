OBJS_BOOTPACK = bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj \
		int.obj fifo.obj keyboard.obj mouse.obj memory.obj sheet.obj timer.obj mtask.obj \
		window.obj console.obj file.obj

TOOLPATH 	= ../z_tools/
INCPATH 	= ../z_tools/haribote/

#*.c 			C语言码
#*.gas 			中间码
#*.nas 			汇编码
#*.obj 			机器码，由C语言编译出来
#*.bin 			机器码
#*.bim 			机器码，多个*.obj或*.bin链接而成
#*.hrb 			机器码，能在HRB系统跑的程序
#*.sys 			机器码，操作系统
#Make命令
MAKE 		= $(TOOLPATH)make.exe -r
#汇编码【编译】机器码
NASK 		= $(TOOLPATH)nask.exe
#C文件【编译】GAS中间码
CC1 		= $(TOOLPATH)cc1.exe -I$(INCPATH) -Os -Wall -quiet
#GAS中间码【编译】汇编码
GAS2NASK 	= $(TOOLPATH)gas2nask.exe -a
#多个机器码【链接】成一个机器码
OBJ2BIM 	= $(TOOLPATH)obj2bim.exe
#【链接规则】，包括的库、启动函数Label
RULEFILE 	= $(TOOLPATH)haribote/haribote.rul
#字库【解释】字库无文件信息机器码
MAKEFONT 	= $(TOOLPATH)makefont.exe
#字库无文件信息机器码【包装】机器码
BIN2OBJ 	= $(TOOLPATH)bin2obj.exe
#机器码【填充】HRB机器码
BIM2HRB 	= $(TOOLPATH)bim2hrb.exe
#机器码【拼接】镜像
EDIMG 		= $(TOOLPATH)edimg.exe
#镜像【写入】软盘
IMGTOL 		= $(TOOLPATH)imgtol.com
#二进制【拼接】二进制
COPY 		= copy
#【删除】
DEL 		= del

#默认指令
default:
	$(MAKE) img

#生成依赖和规则
ipl.bin : ipl.nas Makefile
	$(NASK) ipl.nas ipl.bin ipl.lst

asmhead.bin : asmhead.nas Makefile
	$(NASK) asmhead.nas asmhead.bin asmhead.lst

hankaku.bin:hankaku.txt Makefile
	$(MAKEFONT) hankaku.txt hankaku.bin

hankaku.obj:hankaku.bin Makefile
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

# 3MB + 64KB = 3136KB
bootpack.bim: $(OBJS_BOOTPACK) Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map $(OBJS_BOOTPACK)

bootpack.hrb: bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

haribote.sys:asmhead.bin bootpack.hrb Makefile
	$(COPY) /B asmhead.bin+bootpack.hrb haribote.sys

hello.hrb:hello.nas Makefile
	$(NASK) hello.nas hello.hrb hello.lst

hello2.hrb:hello2.nas Makefile
	$(NASK) hello2.nas hello2.hrb hello2.lst

a.bim:a.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:a.bim map:a.map a.obj a_nask.obj

a.hrb:a.bim Makefile
	$(BIM2HRB) a.bim a.hrb 0

hello3.bim:hello3.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:hello3.bim map:hello3.map hello3.obj a_nask.obj

hello3.hrb:hello3.bim Makefile
	$(BIM2HRB) hello3.bim hello3.hrb 0

hello4.bim:hello4.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:hello4.bim stack:1k map:hello4.map hello4.obj a_nask.obj

hello4.hrb:hello4.bim Makefile
	$(BIM2HRB) hello4.bim hello4.hrb 0

hello5.bim:hello5.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:hello5.bim stack:1k map:hello5.map hello5.obj

hello5.hrb:hello5.bim Makefile
	$(BIM2HRB) hello5.bim hello5.hrb 0

winhello.bim:winhello.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:winhello.bim stack:1k map:winhello.map winhello.obj a_nask.obj

winhello.hrb:winhello.bim Makefile
	$(BIM2HRB) winhello.bim winhello.hrb 0

winhello2.bim:winhello2.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:winhello2.bim stack:1k map:winhello2.map winhello2.obj a_nask.obj

winhelo2.hrb:winhello2.bim Makefile
	$(BIM2HRB) winhello2.bim winhelo2.hrb 0

winhelo3.bim:winhelo3.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:winhelo3.bim stack:1k map:winhelo3.map winhelo3.obj a_nask.obj

winhelo3.hrb:winhelo3.bim Makefile
	$(BIM2HRB) winhelo3.bim winhelo3.hrb 40k

crack1.bim:crack1.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:crack1.bim map:crack1.map crack1.obj a_nask.obj

crack1.hrb:crack1.bim Makefile
	$(BIM2HRB) crack1.bim crack1.hrb 0

crack2.hrb:crack2.nas Makefile
	$(NASK) crack2.nas crack2.hrb crack2.lst

crack3.hrb:crack3.nas Makefile
	$(NASK) crack3.nas crack3.hrb crack3.lst

crack4.hrb:crack4.nas Makefile
	$(NASK) crack4.nas crack4.hrb crack4.lst

crack5.hrb:crack5.nas Makefile
	$(NASK) crack5.nas crack5.hrb crack5.lst

crack6.hrb:crack6.nas Makefile
	$(NASK) crack6.nas crack6.hrb crack6.lst

bug1.bim:bug1.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bug1.bim map:bug1.map bug1.obj a_nask.obj

bug1.hrb:bug1.bim Makefile
	$(BIM2HRB) bug1.bim bug1.hrb 0

bug2.bim:bug2.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bug2.bim map:bug2.map bug2.obj a_nask.obj

bug2.hrb:bug2.bim Makefile
	$(BIM2HRB) bug2.bim bug2.hrb 0

bug3.bim:bug3.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bug3.bim map:bug3.map bug3.obj a_nask.obj

bug3.hrb:bug3.bim Makefile
	$(BIM2HRB) bug3.bim bug3.hrb 0

star1.bim:star1.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:star1.bim stack:1k map:star1.map star1.obj a_nask.obj

star1.hrb:star1.bim Makefile
	$(BIM2HRB) star1.bim star1.hrb 47k

stars.bim:stars.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:stars.bim stack:1k map:stars.map stars.obj a_nask.obj

stars.hrb:stars.bim Makefile
	$(BIM2HRB) stars.bim stars.hrb 47k

stars2.bim:stars2.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:stars2.bim stack:1k map:stars2.map stars2.obj a_nask.obj

stars2.hrb:stars2.bim Makefile
	$(BIM2HRB) stars2.bim stars2.hrb 47k

lines.bim:lines.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:lines.bim stack:1k map:lines.map lines.obj a_nask.obj

lines.hrb:lines.bim Makefile
	$(BIM2HRB) lines.bim lines.hrb 47k

walk.bim:walk.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:walk.bim stack:1k map:walk.map walk.obj a_nask.obj

walk.hrb:walk.bim Makefile
	$(BIM2HRB) walk.bim walk.hrb 47k

haribote.img : ipl.bin haribote.sys ipl.nas make.bat hello.hrb hello2.hrb a.hrb hello3.hrb hello4.hrb \
				hello5.hrb winhello.hrb winhelo2.hrb winhelo3.hrb crack1.hrb crack2.hrb crack3.hrb crack4.hrb crack5.hrb crack6.hrb \
				bug1.hrb bug2.hrb bug3.hrb star1.hrb stars.hrb stars2.hrb lines.hrb walk.hrb Makefile
	$(EDIMG) imgin:..\z_tools\fdimg0at.tek wbinimg \
		src:ipl.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		copy from:ipl.nas to:@: \
		copy from:make.bat to:@: \
		copy from:hello.hrb to:@: \
		copy from:hello2.hrb to:@: \
		copy from:a.hrb to:@: \
		copy from:hello3.hrb to:@: \
		copy from:hello4.hrb to:@: \
		copy from:hello5.hrb to:@: \
		copy from:winhello.hrb to:@: \
		copy from:winhelo2.hrb to:@: \
		copy from:winhelo3.hrb to:@: \
		copy from:crack1.hrb to:@: \
		copy from:crack2.hrb to:@: \
		copy from:crack3.hrb to:@: \
		copy from:crack4.hrb to:@: \
		copy from:crack5.hrb to:@: \
		copy from:crack6.hrb to:@: \
		copy from:bug1.hrb to:@: \
		copy from:bug2.hrb to:@: \
		copy from:bug3.hrb to:@: \
		copy from:star1.hrb to:@: \
		copy from:stars.hrb to:@: \
		copy from:stars2.hrb to:@: \
		copy from:lines.hrb to:@: \
		copy from:walk.hrb to:@: \
		imgout:haribote.img

%.gas: %.c bootpack.h Makefile
	$(CC1) -o $*.gas $*.c

%.nas: %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj: %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst

#指令
img :
	$(MAKE) haribote.img

run:
	$(MAKE) img
	$(COPY) haribote.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ..\z_tools\qemu

install:
	$(MAKE) img
	$(IMGTOL) w a:haribote.img

clean:
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.obj
	-$(DEL) *.map
	-$(DEL) *.bim
	-$(DEL) *.hrb
	-$(DEL) haribote.sys

src_only:
	$(MAKE) clean
	-$(DEL) haribote.img