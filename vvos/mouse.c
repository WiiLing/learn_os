#include "bootpack.h"

static int mouse_rate = 2;
struct FIFO32 *mousefifo;
int mousedata0;

/*来自鼠标的中断*/
void inthandler2c(int *esp)
{
	int data;

	io_out8(PIC1_OCW2, 0x64); 			/*通知PIC"IRQ-12已经受理完毕"*/
	io_out8(PIC0_OCW2, 0x62); 			/*通知PIC"IRQ-02已经受理完毕"*/
	data = io_in8(PORT_KEYDAT);

	fifo32_put(mousefifo, data + mousedata0);
	return;
}

int mouse_decode(struct MOUSE_DEC *mdec, unsigned char data)
{
	if(mdec->phase == 0)
	{
		if(data == 0xfa)
		{
			mdec->phase = 1;
		}
		return 0;
	}
	else if(mdec->phase == 1)
	{
		if((data & 0xc8) == 0x08)
		{
			mdec->buf[0] = data;
			mdec->phase = 2;
		}
		return 0;
	}
	else if(mdec->phase == 2)
	{
		mdec->buf[1] = data;
		mdec->phase = 3;
		return 0;
	}
	else if(mdec->phase == 3)
	{
		mdec->buf[2] = data;
		mdec->phase = 1;

		mdec->btn = mdec->buf[0] & 0x07;
		mdec->x = mdec->buf[1];
		mdec->y = mdec->buf[2];
		/*-x方向移动*/
		if((mdec->buf[0] & 0x10) != 0)
		{
			mdec->x |= 0xffffff00;
		}
		/*-y方向移动*/
		if((mdec->buf[0] & 0x20) != 0)
		{
			mdec->y |= 0xffffff00;
		}
		/*屏幕和鼠标方向相反，所以取反*/
		mdec->y = -mdec->y;
		/*倍率变化*/
		mdec->x /= mouse_rate;
		mdec->y /= mouse_rate;
		return 1;
	}
	return -1;
}

void enable_mouse(struct FIFO32 *fifo, int data0, struct MOUSE_DEC *mdec)
{
	mousefifo = fifo;
	mousedata0 = data0;
	wait_KBC_sendready();
	io_out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
	wait_KBC_sendready();
	io_out8(PORT_KEYDAT, MOUSECMD_ENABLE); 				/*顺利的话，键盘控制器会返回ACK(0xfa)*/
	mdec->phase = 0;
	return;
}