#include "bootpack.h"

#define TIMER_FLAGS_ALLOC 	1
#define TIMER_FLAGS_USING 	2

struct TIMERCTL timerctl;

void init_pit(void)
{
	int i;
	struct TIMER *t;
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, 0x9c);
	io_out8(PIT_CNT0, 0x2e);
	timerctl.count = 0;
	for (i = 0; i < MAX_TIMER; ++i)
	{
		timerctl.timer0[i].flags = 0;
	}
	t = timer_alloc();
	t->timeout = 0xffffffff;
	t->flags = TIMER_FLAGS_USING;
	t->next = 0;
	timerctl.t0 = t;
	timerctl.next = 0xffffffff;
	return;
}

struct TIMER *timer_alloc(void)
{
	int i;
	for (i = 0; i < MAX_TIMER; ++i)
	{
		if(timerctl.timer0[i].flags == 0)
		{
			timerctl.timer0[i].flags = TIMER_FLAGS_ALLOC;
			return &timerctl.timer0[i];
		}
	}
	return 0;
}

void timer_free(struct TIMER * timer)
{
	timer->flags = 0;
	return;
}

void timer_init(struct TIMER *timer, struct FIFO32 *fifo, int data)
{
	timer->fifo = fifo;
	timer->data = data;
	return;
}

void timer_settime(struct TIMER *timer, unsigned int timeout)
{
	int eflags;
	struct TIMER *t, *s;
	timer->timeout = timerctl.count + timeout;
	timer->flags = TIMER_FLAGS_USING;
	eflags = io_load_eflags();
	io_cli();
	t = timerctl.t0;
	if(timer->timeout <= t->timeout)
	{
		timer->next = t;
		timerctl.t0 = timer;
		timerctl.next = timer->timeout;
		io_store_eflags(eflags);
		return;
	}
	for (;;)
	{
		s = t;
		t = t->next;
		if(timer->timeout <= t->timeout)
		{
			timer->next = t;
			s->next = timer;
			io_store_eflags(eflags);
			return;
		}
	}
	return;
}

void inthandler20(int *esp)
{
	char ts = 0;
	int i;
	struct TIMER *timer;
	io_out8(PIC0_OCW2, 0x60); 			/*通知PIC"IRQ-00已经受理完毕"*/
	++timerctl.count;
	if(timerctl.next > timerctl.count)
	{
		return;
	}
	timer = timerctl.t0;
	for (;;)
	{
		if(timer->timeout > timerctl.count)
		{
			break;
		}
		timer->flags = TIMER_FLAGS_ALLOC;
		if(timer != task_timer)
		{
			fifo32_put(timer->fifo, timer->data);
		}
		else
		{
			ts = 1;
		}
		timer = timer->next;
	}
	timerctl.t0 = timer;
	timerctl.next = timerctl.t0->timeout;
	if(ts != 0)
	{
		task_switch();
	}
	return;
}