#include <stdio.h>
#include <string.h>
#include "bootpack.h"

void console_task(struct SHEET *sht, unsigned int memtotal)
{
	struct TIMER *timer;
	struct TASK *task = task_now();
	struct MEMMAN *memman = (struct MEMMAN *)MEMMAN_ADDR;
	int i, fifobuf[128], *fat = (int *)memman_alloc_4k(memman, 4 * 2880);
	struct CONSOLE cons;
	char cmdline[30];
	cons.sht = sht;
	cons.cur_x = 8;
	cons.cur_y = 28;
	cons.cur_c = -1;
	*((int *)0x0fec) = (int)&cons;

	fifo32_init(&task->fifo, 128, fifobuf, task);
	timer = timer_alloc();
	timer_init(timer, &task->fifo, 1);
	timer_settime(timer, 50);
	file_readfat(fat, (unsigned char *)(ADR_DISKIMG + 0x000200));

	cons_putchar(&cons, '>', 1);
	for (;;)
	{
		io_cli();
		if(fifo32_status(&task->fifo) == 0)
		{
			task_sleep(task);
			io_sti();
		}
		else
		{
			i = fifo32_get(&task->fifo);
			io_sti();
			if(i <= 1)
			{
				if(i != 0)
				{
					timer_init(timer, &task->fifo, 0);
					if(cons.cur_c >= 0)
					{
						cons.cur_c = COL8_FFFFFF;
					}
				}
				else
				{
					timer_init(timer, &task->fifo, 1);
					if(cons.cur_c >= 0)
					{
						cons.cur_c = COL8_000000;
					}
				}
				timer_settime(timer, 50);
			}
			if(i == 2)
			{
				cons.cur_c =COL8_FFFFFF;
			}
			if(i == 3)
			{
				cons.cur_c = -1;
				boxfill8(sht->buf, sht->bxsize, cons.cur_c, cons.cur_x, cons.cur_y, cons.cur_x + 8 - 1, cons.cur_y + 16 - 1);
			}
			if(256 <= i && i <= 511)
			{
				if(i == 8 + 256)
				{
					if(cons.cur_x > 16)
					{
						cons_putchar(&cons, ' ', 0);
						cons.cur_x -= 8;
					}
				}
				else if(i == 10 + 256)
				{
					cons_putchar(&cons, ' ', 0);
					cmdline[cons.cur_x / 8 - 2] = 0;
					cons_newline(&cons);
					cons_runcmd(cmdline, &cons, fat, memtotal);
					cons_putchar(&cons, '>', 1);
				}
				else
				{
					if(cons.cur_x < 240)
					{
						cmdline[cons.cur_x / 8 - 2] = i - 256;
						cons_putchar(&cons, i - 256, 1);
					}
				}
			}
			if(cons.cur_c >= 0)
			{
				boxfill8(sht->buf, sht->bxsize, cons.cur_c, cons.cur_x, cons.cur_y, cons.cur_x + 8 - 1, cons.cur_y + 16 - 1);
			}
			sheet_refresh(sht, cons.cur_x, cons.cur_y, cons.cur_x + 8, cons.cur_y + 16);
		}
	}
}

void cons_putchar(struct CONSOLE *cons, char chr, char move)
{
	char s[2];
	s[0] = chr;
	s[1] = 0;
	if(s[0] == 0x09)
	{
		for (;;)
		{
			putfonts8_asc_sht(cons->sht, cons->cur_x, cons->cur_y, COL8_FFFFFF, COL8_000000, " ", 1);
			cons->cur_x += 8;
			if(cons->cur_x == 8 +240)
			{
				cons_newline(cons);
			}
			if(((cons->cur_x - 8) & 0x1f) == 0)
			{
				break;
			}
		}
	}
	else if(s[0] == 0x0a)
	{
		cons_newline(cons);
	}
	else if(s[0] == 0x0d)
	{

	}
	else
	{
		putfonts8_asc_sht(cons->sht, cons->cur_x, cons->cur_y, COL8_FFFFFF, COL8_000000, s, 1);
		if(move != 0)
		{
			cons->cur_x += 8;
			if(cons->cur_x == 8 + 240)
			{
				cons_newline(cons);
			}
		}
	}
	return;
}

void cons_newline(struct CONSOLE *cons)
{
	int x, y;
	struct SHEET *sht = cons->sht;
	if(cons->cur_y < 28 + 112)
	{
		cons->cur_y += 16;
	}
	else
	{
		for (y = 28; y < 28 + 112; ++y)
		{
			for (x = 8; x < 8+ 240; ++x)
			{
				sht->buf[x + y * sht->bxsize] = sht->buf[x + (y + 16) * sht->bxsize];
			}
		}
		for (y = 28 + 112; y < 28 + 128; ++y)
		{
			for (x = 8; x < 8+ 240; ++x)
			{
				sht->buf[x + y * sht->bxsize] = COL8_000000;
			}
		}
		sheet_refresh(sht, 8, 28, 8 + 240, 28 + 128);
	}
	cons->cur_x = 8;
	return;
}

void cons_putstr(struct CONSOLE *cons, char *s)
{
	for (; *s != 0; ++s)
	{
		cons_putchar(cons, *s, 1);
	}
	return;
}

void cons_putnstr(struct CONSOLE *cons, char *s, int n)
{
	int i;
	for (i = 0; i < n; ++i)
	{
		cons_putchar(cons, s[i], 1);
	}
	return;
}

void cons_runcmd(char *cmdline, struct CONSOLE *cons, int *fat, unsigned int memtotal)
{
	if(strcmp(cmdline, "mem") == 0)
	{
		cmd_mem(cons, memtotal);
	}
	else if(strcmp(cmdline, "cls") == 0)
	{
		cmd_cls(cons);
	}
	else if(strcmp(cmdline, "dir") == 0)
	{
		cmd_dir(cons);
	}
	else if(strncmp(cmdline, "type ", 5) == 0)
	{
		cmd_type(cons, fat, cmdline);
	}
	// else if(strcmp(cmdline, "hlt") == 0)
	// {
	// 	cmd_hlt(cons, fat);
	// }
	else if(cmdline[0] != 0)
	{
		if(cmd_app(cons, fat, cmdline) == 0)
		{
			// putfonts8_asc_sht(cons->sht, 8, cons->cur_y, COL8_FFFFFF, COL8_000000, "Bad command.", 12);
			// cons_newline(cons);
			// cons_newline(cons);
			cons_putstr(cons, "Bad command.\n\n");
		}
	}
	return;
}

void cmd_mem(struct CONSOLE *cons, unsigned int memtotal)
{
	struct MEMMAN *memman = (struct MEMMAN *)MEMMAN_ADDR;
	char s[60];
	sprintf(s, "total %dMB\nfree %dKB\n\n", memtotal / (1024 * 1024), memman_total(memman)/ 1024);
	cons_putstr(cons, s);
	return;
}

void cmd_cls(struct CONSOLE *cons)
{
	int x, y;
	struct SHEET *sht = cons->sht;
	for (y = 28; y < 28 + 128; ++y)
	{
		for (x = 8; x < 8+ 240; ++x)
		{
			sht->buf[x + y * sht->bxsize] = COL8_000000;
		}
	}
	sheet_refresh(sht, 8, 28, 8 + 240, 28 + 128);
	cons->cur_y = 28;
	return;
}

void cmd_dir(struct CONSOLE *cons)
{
	struct FILEINFO *finfo = (struct FILEINFO *)(ADR_DISKIMG + 0x002600);
	int x, y;
	char s[30];
	for (x = 0; x < 224; ++x)
	{
		if(finfo[x].name[0] == 0x00)
		{
			break;
		}
		if(finfo[x].name[0] != 0xe5)
		{
			if((finfo[x].type & 0x18) == 0)
			{
				sprintf(s, "filename.ext %7d\n", finfo[x].size);
				for (y = 0; y < 8; ++y)
				{
					s[y] = finfo[x].name[y];
				}
				s[9] = finfo[x].ext[0];
				s[10] = finfo[x].ext[1];
				s[11] = finfo[x].ext[2];
				cons_putstr(cons, s);
			}
		}
	}
	cons_newline(cons);
	return;
}

void cmd_type(struct CONSOLE *cons, int *fat, char *cmdline)
{
	struct MEMMAN *memman = (struct MEMMAN *)MEMMAN_ADDR;
	struct FILEINFO *finfo = file_search(cmdline + 5, (struct FILEINFO *)(ADR_DISKIMG + 0x002600), 224);
	char *p;
	int y;

	if(finfo != 0)
	{
		p = (char *)memman_alloc_4k(memman, finfo->size);
		file_loadfile(finfo->clustno, finfo->size, p, fat, (char *)(ADR_DISKIMG + 0x003e00));
		cons_putnstr(cons, p, finfo->size);
		for (y = 0; y < finfo->size; ++y)
		{
			cons_putchar(cons, p[y], 1);
		}
		memman_free_4k(memman, (int)p, finfo->size);
	}
	else
	{
		cons_putstr(cons, "File not found.\n");
	}
	cons_newline(cons);
	return;
}

void cmd_hlt(struct CONSOLE *cons, int *fat)
{
	struct MEMMAN *memman = (struct MEMMAN *)MEMMAN_ADDR;
	struct FILEINFO *finfo = file_search("HLT.HRB", (struct FILEINFO *)(ADR_DISKIMG + 0x002600), 224);
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *)ADR_GDT;
	char *p;

	if(finfo != 0)
	{
		p = (char *)memman_alloc_4k(memman, finfo->size);
		file_loadfile(finfo->clustno, finfo->size, p, fat, (char *)(ADR_DISKIMG + 0x003e00));
		set_segmdesc(gdt + 1003, finfo->size - 1, (int)p, AR_CODE32_ER);
		farcall(0, 1003 * 8);
		memman_free_4k(memman, (int)p, finfo->size);
	}
	else
	{
		putfonts8_asc_sht(cons->sht, 8, cons->cur_y, COL8_FFFFFF, COL8_000000, "File not found.", 15);
		cons_newline(cons);
	}
	cons_newline(cons);
	return;
}

int cmd_app(struct CONSOLE *cons, int *fat, char *cmdline)
{
	struct MEMMAN *memman = (struct MEMMAN *)MEMMAN_ADDR;
	struct FILEINFO *finfo;
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *)ADR_GDT;
	char *p, name[18], *q;
	int i;
	struct TASK *task = task_now();
	int segsiz, datsiz, esp, dathrb;

	for (i = 0; i < 13; ++i)
	{
		if(cmdline[i] <= ' ')
		{
			break;
		}
		name[i] = cmdline[i];
	}
	name[i] = 0;

	finfo = file_search(name, (struct FILEINFO *)(ADR_DISKIMG + 0x002600), 224);
	if(finfo == 0 && name[i - 1] != '.')
	{
		name[i + 0] = '.';
		name[i + 1] = 'H';
		name[i + 2] = 'R';
		name[i + 3] = 'B';
		name[i + 4] = 0;
		finfo = file_search(name, (struct FILEINFO *)(ADR_DISKIMG + 0x002600), 224);
	}

	if(finfo != 0)
	{
		p = (char *)memman_alloc_4k(memman, finfo->size);
		file_loadfile(finfo->clustno, finfo->size, p, fat, (char *)(ADR_DISKIMG + 0x003e00));
		if(finfo->size >= 2 * 16 + 4 && strncmp(p + 4, "Hari", 4) == 0 && *p == 0x00)
		{
			segsiz = *((int *)(p + 0x0000));
			esp = *((int *)(p + 0x000c));
			datsiz = *((int *)(p + 0x0010));
			dathrb = *((int *)(p + 0x0014));
			q = (char *)memman_alloc_4k(memman, segsiz);
			*((int *)0x0fe8) = (int)q;
			set_segmdesc(gdt + 1003, finfo->size - 1, (int)p, AR_CODE32_ER + 0x60);
			set_segmdesc(gdt + 1004, segsiz - 1, (int)q, AR_DATA32_RW + 0x60);
			for(i = 0; i < datsiz; ++i)
			{
				q[esp + i] = p[dathrb + i];
			}
			start_app(0x1b, 1003 * 8, esp, 1004 * 8, &(task->tss.esp0));
			memman_free_4k(memman, (int)q, segsiz);
		}
		else
		{
			cons_putstr(cons, ".hrb file format error.\n");
		}
		memman_free_4k(memman, (int)p, finfo->size);
		cons_newline(cons);
		return 1;
	}
	return 0;
}

int *hrb_api(int edi, int esi, int ebp, int esp, int ebx, int edx, int ecx, int eax)
{
	int ds_base = *((int *)0x0fe8);
	struct TASK *task = task_now();
	struct CONSOLE *cons = (struct CONSOLE *)*((int *)0x0fec);
	struct SHTCTL *shtctl = (struct SHTCTL *)*((int *)0x0fe4);
	struct SHEET *sht;
	int *reg = &eax + 1;
	/* 强行改写通过_asm_hrb_api第一个PUSHAD保存的值
		reg[0]:EDI, 	reg[1]:ESI, 	reg[2]:EBP, 	reg[3]:ESP
		reg[4]:EBX, 	reg[5]:EDX, 	reg[6]:ECX, 	reg[7]:EAX
	*/

	if(edx == 1)
	{
		cons_putchar(cons, eax & 0xff, 1);
	}
	else if(edx == 2)
	{
		cons_putstr(cons, (char *)ebx + ds_base);
	}
	else if(edx == 3)
	{
		cons_putnstr(cons, (char *)ebx + ds_base, ecx);
	}
	else if(edx == 4)
	{
		return &(task->tss.esp0);
	}
	else if(edx == 5)
	{
		sht = sheet_alloc(shtctl);
		sheet_setbuf(sht, (char *)ebx + ds_base, esi, edi, eax);
		make_window8((char *)ebx + ds_base, esi, edi, (char *)ecx + ds_base, 0);
		sheet_slide(sht, 100, 50);
		sheet_updown(sht, 4);
		reg[7] = (int)sht;
	}
	else if(edx == 6)
	{
		sht = (struct SHEET *)(ebx & 0xfffffffe);
		putfonts8_asc(sht->buf, sht->bxsize, esi, edi, eax, (char *)ebp + ds_base);
		if((ebx & 1) == 0)
		{
			sheet_refresh(sht, esi, edi, esi + ecx * 8, edi + 16);
		}
	}
	else if(edx == 7)
	{
		sht = (struct SHEET *)(ebx & 0xfffffffe);
		boxfill8(sht->buf, sht->bxsize, ebp, eax, ecx, esi, edi);
		if((ebx & 1) == 0)
		{
			sheet_refresh(sht, eax, ecx, esi + 1, edi + 1);
		}
	}
	else if(edx == 8)
	{
		memman_init((struct MEMMAN *)(ebx + ds_base));
		ecx &= 0xfffffff0;
		memman_free((struct MEMMAN *)(ebx + ds_base), eax, ecx);
	}
	else if(edx == 9)
	{
		ecx = (ecx + 0x0f) & 0xfffffff0;
		reg[7] = memman_alloc((struct MEMMAN *)(ebx + ds_base), ecx);
	}
	else if(edx == 10)
	{
		ecx = (ecx + 0x0f) & 0xfffffff0;
		memman_free((struct MEMMAN *)(ebx + ds_base), eax, ecx);
	}
	else if(edx == 11)
	{
		sht = (struct SHEET *)(ebx & 0xfffffffe);
		sht->buf[sht->bxsize * edi + esi] = eax;
		if((ebx & 1) == 0)
		{
			sheet_refresh(sht, esi, edi, esi + 1, edi + 1);
		}
	}
	else if(edx == 12)
	{
		sht = (struct SHEET *)ebx;
		sheet_refresh(sht, eax, ecx, esi, edi);
	}
	else if(edx == 13)
	{
		sht = (struct SHEET *)(ebx & 0xfffffffe);
		hrb_api_linewin(sht, eax, ecx, esi, edi, ebp);
		if((ebx & 1) == 0)
		{
			sheet_refresh(sht, eax, ecx, esi + 1, edi + 1);			
		}
	}
	// else if(edx == 1000000)
	// {
	// 	*((char *)0x00102600) = 0;
	// }
	return 0;
}

void hrb_api_linewin(int win, int x0, int y0, int x1, int y1, int col)
{
	int i, x, y;
	
}

/*
	在这个系统中，当CPU产生异常时其他寄存器的值为：
	esp[0]	: EDI 		esp[0~7]为_asm_inthandler中PUSHAD的结果
	esp[1]	: ESI
	esp[2]	: EBP
	esp[3]	: 
	esp[4]	: EBX
	esp[5]	: EDX
	esp[6]	: ECX
	esp[7]	: EAX
	esp[8]	: DS 		esp[8~9]为_asm_inthandler中PUSH的结果
	esp[9]	: ES
	esp[10] : 			错误编号(基本上是0，显示出来也没什么意思)
	esp[11] : EIP 		esp[10~15]为异常产生时CPU自动PUSH的结果
	esp[12] : CS
	esp[13] : EFLAGS
	esp[14] : ESP 		应用程序的ESP
	esp[15] : SS 		应用程序的SS
*/

int inthandler0d(int *esp)
{
	struct CONSOLE *cons = (struct CONSOLE *)*((int *)0x0fec);
	struct TASK *task = task_now();
	char s[30];
	cons_putstr(cons, "\nINT 0D :\n General Protected Exception.\n");
	sprintf(s, "EIP=%08X\n", esp[11]);
	cons_putstr(cons, s);
	return &(task->tss.esp0);
}

int inthandler0c(int *esp)
{
	struct CONSOLE *cons = (struct CONSOLE *)*((int *)0x0fec);
	struct TASK *task = task_now();
	char s[30];
	cons_putstr(cons, "\nINT 0D :\n Stack Exception.\n");
	sprintf(s, "EIP=%08X\n", esp[11]);
	cons_putstr(cons, s);
	return &(task->tss.esp0);
}
