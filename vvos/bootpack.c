#include <stdio.h>
#include <string.h>
#include "bootpack.h"

#define KEYCMD_LED 			0xed

void HariMain(void)
{
	struct SHTCTL *shtctl;
	struct SHEET *sht_back, *sht_mouse, *sht_win, *sht_win_b[3], *sht_cons;
	unsigned char *buf_back, buf_mouse[256], *buf_win, *buf_win_b, *buf_cons;
	char s[40];
	int fifobuf[128], keycmd_buf[32];
	struct MOUSE_DEC mdec;
	struct BOOTINFO *binfo = (struct BOOTINFO *)ADR_BOOTINFO;
	unsigned int memtotal;
	struct MEMMAN *memman = (struct MEMMAN *)MEMMAN_ADDR;
	struct FIFO32 fifo, keycmd;
	struct TIMER *timer;
	int cursor_x, cursor_c;
	struct TASK *task_a, *task_b[3], *task_cons;
	int i, mx, my, keyboard, count = 0, key_to = 0, key_shift = 0, key_leds = (binfo->leds >> 4) & 7, keycmd_wait = -1;
	struct CONSOLE *cons;

	static char keytable0[0x80] = {
		0,		0,		'1',	'2',	'3',	'4',	'5',	'6',	'7',	'8',	'9',	'0',	'-',	'^',	0,		0,
		'Q',	'W',	'E',	'R',	'T',	'Y',	'U',	'I',	'O',	'P',	'@',	'[',	0,		0,		'A',	'S',
		'D',	'F',	'G',	'H',	'J',	'K',	'L',	';',	':',	0,		0,		']',	'Z',	'X',	'C',	'V',
		'B',	'N',	'M',	',',	'.',	'/',	0,		'*',	0,		' ',	0,		0,		0,		0,		0,		0,
		0,		0,		0,		0,		0,		0,		0,		'7',	'8',	'9',	'-',	'4',	'5',	'6',	'+',	'1',
		'2',	'3',	'0',	'.',	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,
		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,
		0,		0,		0,		0x5c,	0,		0,		0,		0,		0,		0,		0,		0,		0,		0x5c,	0,		0,
	};
	static char keytable1[0x80] = {
		0,		0,		'!',	0x22,	'#',	'$',	'%',	'&',	0x27,	'(',	')',	'~',	'=',	'~',	0,		0,
		'Q',	'W',	'E',	'R',	'T',	'Y',	'U',	'I',	'O',	'P',	'`',	'{',	0,		0,		'A',	'S',
		'D',	'F',	'G',	'H',	'J',	'K',	'L',	'+',	'*',	0,		0,		'}',	'Z',	'X',	'C',	'V',
		'B',	'N',	'M',	'<',	'>',	'?',	0,		'*',	0,		' ',	0,		0,		0,		0,		0,		0,
		0,		0,		0,		0,		0,		0,		0,		'7',	'8',	'9',	'-',	'4',	'5',	'6',	'+',	'1',
		'2',	'3',	'0',	'.',	0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,
		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,		0,
		0,		0,		0,		'_',	0,		0,		0,		0,		0,		0,		0,		0,		0,		'|',	0,		0,
	};

	/*防止硬件上积累过多数据而产生错误动作之前，尽快开放中断，接收数据*/
	init_gdtidt();
	/*初始化PIC可编程中断控制器*/
	init_pic();
	/*初始化PIT可编程中断定时器*/
	init_pit();
	/*开放CPU中断*/
	io_sti();
	/*初始化键盘和鼠标信息的接收缓存*/
	fifo32_init(&fifo, 128, fifobuf, 0);
	fifo32_init(&keycmd, 32, keycmd_buf, 0);
	/*开始接收键盘信息*/
	init_keyboard(&fifo, 256);
	/*开始接收鼠标信息*/
	enable_mouse(&fifo, 512, &mdec);
	/*开放PIC1和键盘中断(11111000)*/
	io_out8(PIC0_IMR, 0xf8);
	/*开放鼠标中断(11101111)*/
	io_out8(PIC1_IMR, 0xef);

	memtotal = memtest(0x00400000, 0xbfffffff);
	memman_init(memman);
	memman_free(memman, 0x00001000, 0x0009e000);
	memman_free(memman, 0x00400000, memtotal - 0x00400000);

	task_a = task_init(memman);
	fifo.task = task_a;
	task_run(task_a, 1, 0);

	/*初始化调色板*/
	init_palette();
	shtctl = shtctl_init(memman, binfo->vram, binfo->scrnx, binfo->scrny);
	*((int *)0x0fe4) = (int)shtctl;

	/*sht_back*/
	sht_back = sheet_alloc(shtctl);
	buf_back = (unsigned char *)memman_alloc_4k(memman, binfo->scrnx * binfo->scrny);
	sheet_setbuf(sht_back, buf_back, binfo->scrnx, binfo->scrny, -1);
	/*初始化屏幕*/
	init_screen8(buf_back, binfo->scrnx, binfo->scrny);

	/*sht_win_b*/
	// for (i = 0; i < 3; ++i)
	// {
	// 	/* code */
	// 	sht_win_b[i] = sheet_alloc(shtctl);
	// 	buf_win_b = (unsigned char *)memman_alloc_4k(memman, 144 * 52);
	// 	sheet_setbuf(sht_win_b[i], buf_win_b, 144, 52, -1);
	// 	sprintf(s, "task_b%d", i);
	// 	make_window8(buf_win_b, 144, 52, s, 0);
	// 	task_b[i] = task_alloc();
	// 	task_b[i]->tss.esp = memman_alloc_4k(memman, 64 * 1024) + 64 * 1024 - 8;
	// 	task_b[i]->tss.eip = (int)&task_b_main;
	// 	task_b[i]->tss.es = 1 * 8;
	// 	task_b[i]->tss.cs = 2 * 8;
	// 	task_b[i]->tss.ss = 1 * 8;
	// 	task_b[i]->tss.ds = 1 * 8;
	// 	task_b[i]->tss.fs = 1 * 8;
	// 	task_b[i]->tss.gs = 1 * 8;
	// 	*((int *)(task_b[i]->tss.esp + 4)) = (int)sht_win_b[i];
	// 	//task_run(task_b[i], 2, i + 1);
	// }

	/*sht_cons*/
	sht_cons = sheet_alloc(shtctl);
	buf_cons = (unsigned char *)memman_alloc_4k(memman, 256 * 165);
	sheet_setbuf(sht_cons, buf_cons, 256, 165, -1);
	make_window8(buf_cons, 256, 165, "console", 0);
	make_textbox8(sht_cons, 8, 28, 240, 128, COL8_000000);
	task_cons = task_alloc();
	task_cons->tss.esp = memman_alloc_4k(memman, 64 * 1024) + 64 * 1024 - 12;
	task_cons->tss.eip = (int)&console_task;
	task_cons->tss.es = 1 * 8;
	task_cons->tss.cs = 2 * 8;
	task_cons->tss.ss = 1 * 8;
	task_cons->tss.ds = 1 * 8;
	task_cons->tss.fs = 1 * 8;
	task_cons->tss.gs = 1 * 8;
	*((int *)(task_cons->tss.esp + 4)) = (int)sht_cons;
	*((int *)(task_cons->tss.esp + 8)) = memtotal;
	task_run(task_cons, 2, 2);

	/*sht_win*/
	sht_win = sheet_alloc(shtctl);
	buf_win = (unsigned char *)memman_alloc_4k(memman, 160 * 52);
	sheet_setbuf(sht_win, buf_win, 144, 52, -1);
	make_window8(buf_win, 144, 52, "task_a", 1);
	make_textbox8(sht_win, 8, 28, 128, 16, COL8_FFFFFF);
	cursor_x = 8;
	cursor_c = COL8_FFFFFF;
	timer = timer_alloc();
	timer_init(timer, &fifo, 1);
	timer_settime(timer, 50);

	/*sht_mouse*/
	sht_mouse = sheet_alloc(shtctl);
	sheet_setbuf(sht_mouse, buf_mouse, 16, 16, 99);
	/*初始化鼠标光标图标*/
	init_mouse_cursor8(buf_mouse, 99);
	mx = (binfo->scrnx - 16) / 2;
	my = (binfo->scrny - 28 -16) / 2;

	/*显示窗口*/
	sheet_slide(sht_back, 0, 0);
	sheet_slide(sht_cons, 32, 4);
	// sheet_slide(sht_win_b[0], 168, 56);
	// sheet_slide(sht_win_b[1], 8, 116);
	// sheet_slide(sht_win_b[2], 168, 116);
	sheet_slide(sht_mouse, mx, my);
	sheet_slide(sht_win, 64, 56);
	sheet_updown(sht_back, 0);
	sheet_updown(sht_cons, 1);
	// sheet_updown(sht_win_b[0], 1);
	// sheet_updown(sht_win_b[1], 2);
	// sheet_updown(sht_win_b[2], 3);
	sheet_updown(sht_win, 2);
	sheet_updown(sht_mouse, 3);
	/*显示屏幕信息*/
	// sprintf(s, "(%d, %d)", mx, my);
	// putfonts8_asc(buf_back, binfo->scrnx, 0, 0, COL8_FFFFFF, s);
	// sprintf(s, "memory %dMB    free %dKB", memtotal / (1024 * 1024), memman_total(memman) / 1024);
	// putfonts8_asc(buf_back, binfo->scrnx, 0, 32, COL8_FFFFFF, s);
	// sheet_refresh(sht_back, 0, 0, binfo->scrnx, 48);

	fifo32_put(&keycmd, KEYCMD_LED);
	fifo32_put(&keycmd, key_leds);
	/*操作系统循环*/
	for(;;)
	{
		//++count;
		//sprintf(s, "%010d", timerctl.count);
		//boxfill8(buf_win, 160, COL8_C6C6C6, 40, 28, 119, 43);
		//putfonts8_asc(buf_win, 160, 40, 28, COL8_000000, s);
		//sheet_refresh(sht_win, 40, 28, 120, 44);
		//putfonts8_asc_sht(sht_win, 40, 28, COL8_000000, COL8_C6C6C6, s, 10);
		if(fifo32_status(&keycmd) > 0 && keycmd_wait < 0)
		{
			keycmd_wait = fifo32_get(&keycmd);
			wait_KBC_sendready();
			io_out8(PORT_KEYDAT, keycmd_wait);
		}
		/*关闭CPU中断*/
		io_cli();
		/*是否有键盘或鼠标信息*/
		if(fifo32_status(&fifo) == 0)
		{
			task_sleep(task_a);
			/*开放CPU中断*/
			io_sti();
		}
		else
		{
			keyboard = fifo32_get(&fifo);
			io_sti();
			/*处理键盘信息*/
			if(256 <= keyboard && keyboard <= 511)
			{
				// sprintf(s, "%02X", keyboard - 256);
				// putfonts8_asc_sht(sht_back, 0, 16, COL8_FFFFFF, COL8_008484, s, 2);
				if(keyboard < 0x80 + 256)
				{
					if(key_shift == 0)
					{
						s[0] = keytable0[keyboard - 256];
					}
					else
					{
						s[0] = keytable1[keyboard - 256];
					}
				}
				else
				{
					s[0] = 0;
				}
				if('A' <= s[0] && s[0] <= 'Z')
				{
					if(((key_leds & 4) == 0 && key_shift == 0)
						||((key_leds & 4) != 0 && key_shift != 0))
					{
						s[0] += 0x20;
					}

				}
				if(s[0] != 0)
				{
					if(key_to == 0)
					{
						if(cursor_x < 128)
						{
							s[1] = 0;
							putfonts8_asc_sht(sht_win, cursor_x, 28, COL8_000000, COL8_FFFFFF, s, 1);
							cursor_x += 8;
						}
					}
					else
					{
						fifo32_put(&task_cons->fifo, s[0] + 256);
					}
				}
				/*Shift+F1*/
				if(keyboard == 256 + 0x3b && key_shift != 0 && task_cons->tss.ss0 != 0)
				{
					cons = (struct CONSOLE *)*((int *)0x0fec);
					cons_putstr(cons, "\nBreak(key) :\n");
					io_cli();
					task_cons->tss.eax = (int)&(task_cons->tss.esp0);
					task_cons->tss.eip = (int)asm_end_app;
					io_sti();
				}
				/*回车键*/
				if(keyboard == 256 + 0x1c)
				{
					if(key_to != 0)
					{
						fifo32_put(&task_cons->fifo, 10 + 256);
					}
				}
				/*CapsLock*/
				if(keyboard == 256 + 0x3a)
				{
					key_leds ^= 4;
					fifo32_put(&keycmd, KEYCMD_LED);
					fifo32_put(&keycmd, key_leds);
				}
				/*NumLock*/
				if(keyboard == 256 + 0x45)
				{
					key_leds ^= 2;
					fifo32_put(&keycmd, KEYCMD_LED);
					fifo32_put(&keycmd, key_leds);
				}
				/*ScrollLock*/
				if(keyboard == 256 + 0x46)
				{
					key_leds ^= 1;
					fifo32_put(&keycmd, KEYCMD_LED);
					fifo32_put(&keycmd, key_leds);
				}
				/*键盘成功接收out数据*/
				if(keyboard == 256 + 0xfa)
				{
					keycmd_wait = -1;
				}
				/*键盘没成功接收out数据*/
				if(keyboard == 256 + 0xfe)
				{
					wait_KBC_sendready();
					io_out8(PORT_KEYDAT, keycmd_wait);
				}
				/*退格键*/
				if(keyboard == 256 + 0x0e)
				{
					if(key_to == 0)
					{
						if(cursor_x > 8)
						{
							putfonts8_asc_sht(sht_win, cursor_x, 28, COL8_000000, COL8_FFFFFF, " ", 1);
							cursor_x -= 8;
						}
					}
					else
					{
						fifo32_put(&task_cons->fifo, 8 + 256);
					}
				}
				/*Tab键*/
				if(keyboard == 256 + 0x0f)
				{
					if(key_to == 0)
					{
						key_to = 1;
						make_wtitle8(buf_win, sht_win->bxsize, "task_a", 0);
						make_wtitle8(buf_cons, sht_cons->bxsize, "console", 1);
						cursor_c = -1;
						boxfill8(sht_win->buf, sht_win->bxsize, COL8_FFFFFF, cursor_x, 28, cursor_x + 8 - 1, 28 + 16 - 1);
						fifo32_put(&task_cons->fifo, 2);
					}
					else
					{
						key_to = 0;
						make_wtitle8(buf_win, sht_win->bxsize, "task_a", 1);
						make_wtitle8(buf_cons, sht_cons->bxsize, "console", 0);
						cursor_c = COL8_000000;
						fifo32_put(&task_cons->fifo, 3);
					}
					sheet_refresh(sht_win, 0, 0, sht_win->bxsize, 21);
					sheet_refresh(sht_cons, 0, 0, sht_cons->bxsize, 21);
				}
				/*左Shift按下*/
				if(keyboard == 256 + 0x2a)
				{
					key_shift |= 1;
				}
				/*右Shift按下*/
				if(keyboard == 256 + 0x36)
				{
					key_shift |= 2;
				}
				/*左Shift释放*/
				if(keyboard == 256 + 0xaa)
				{
					key_shift &= ~1;
				}
				/*右Shift释放*/
				if(keyboard == 256 + 0xb6)
				{
					key_shift &= ~2;
				}
				if(cursor_c >= 0)
				{
					boxfill8(sht_win->buf, sht_win->bxsize, cursor_c, cursor_x, 28, cursor_x + 8 - 1, 28 + 16 - 1);
				}
				sheet_refresh(sht_win, cursor_x, 28, cursor_x + 8, 28 + 16);
			}
			/*处理鼠标信息*/
			else if(512 <= keyboard && keyboard <= 767)
			{
				if(mouse_decode(&mdec, keyboard - 512) != 0)
				{
					// sprintf(s, "[lcr %4d %4d]", mdec.x, mdec.y);
					// if((mdec.btn & 0x01) != 0)
					// {
					// 	s[1] = 'L';
					// }
					// if((mdec.btn & 0x02) != 0)
					// {
					// 	s[3] = 'R';
					// }
					// if((mdec.btn & 0x04) != 0)
					// {
					// 	s[2] = 'C';
					// }
					// /*输出鼠标变化*/
					// putfonts8_asc_sht(sht_back, 32, 16, COL8_FFFFFF, COL8_008484, s, 15);
					/*鼠标移动*/
					mx += mdec.x;
					my += mdec.y;
					if(mx < 0)
					{
						mx = 0;
					}
					if(my < 0)
					{
						my = 0;
					}
					if(mx > binfo->scrnx - 1)
					{
						mx = binfo->scrnx - 1;
					}
					if(my > binfo->scrny - 1)
					{
						my = binfo->scrny - 1;
					}
					/*输出鼠标坐标*/
					// sprintf(s, "(%3d, %3d)", mx, my);
					// putfonts8_asc_sht(sht_back, 0, 0, COL8_FFFFFF, COL8_008484, s, 10);
					sheet_slide(sht_mouse, mx, my);
					if((mdec.btn & 0x01) != 0)
					{
						sheet_slide(sht_win, mx - 80, my - 8);
					}
				}
			}
			else if(keyboard == 10)
			{
				putfonts8_asc_sht(sht_back, 0, 64, COL8_FFFFFF, COL8_008484, "10[Sec]", 7);
				//sprintf(s, "%010d", count);
				//putfonts8_asc_sht(sht_win, 40, 28, COL8_000000, COL8_C6C6C6, s, 10);
				//farjmp(0, 4 * 8);
			}
			else if(keyboard == 3)
			{
				putfonts8_asc_sht(sht_back, 0, 80, COL8_FFFFFF, COL8_008484, "3[Sec]", 6);
				//count = 0;
			}
			else if(keyboard <= 1)
			{
				if(keyboard != 0)
				{
					timer_init(timer, &fifo, 0);
					if(cursor_c >= 0)
					{
						cursor_c = COL8_000000;
					}
				}
				else
				{
					timer_init(timer, &fifo, 1);
					if(cursor_c >= 0)
					{
						cursor_c = COL8_FFFFFF;
					}
				}
				timer_settime(timer, 50);
				if(cursor_c >= 0)
				{
					boxfill8(sht_win->buf, sht_win->bxsize, cursor_c, cursor_x, 28, cursor_x + 8 - 1, 28 + 16 - 1);
				}
				sheet_refresh(sht_win, cursor_x, 28, cursor_x + 8, 28 + 16);
			}
			//else if(keyboard == 2)
			//{
				//timer_settime(timer_ts, 2);
				//putfonts8_asc_sht(sht_back, 0, 64, COL8_FFFFFF, COL8_008484, "farjmp4", 7);
				//farjmp(0, 4 * 8);
				//putfonts8_asc_sht(sht_back, 0, 64, COL8_FFFFFF, COL8_008484, "backto3", 7);
			//}
		}
	}
}