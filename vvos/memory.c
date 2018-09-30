#include "bootpack.h"

unsigned int memtest(unsigned int start, unsigned int end)
{
	char flg486 = 0;
	unsigned int eflg, cr0, i;
	/*确认CPU是386还是486以上的*/
	eflg = io_load_eflags();
	eflg |= EFLAGS_AC_BIT; 		/*AC=1*/
	io_store_eflags(eflg);
	eflg = io_load_eflags();
	/*如果是386，即使设定AC=1，AC的值还会自动回到0*/
	if((eflg & EFLAGS_AC_BIT) != 0)
	{
		flg486 = 1;
	}
	eflg &= ~EFLAGS_AC_BIT; 		/*AC=0*/
	io_store_eflags(eflg);

	if(flg486 != 0)
	{
		cr0 = load_cr0();
		cr0 |= CR0_CACHE_DISABLE;
		store_cr0(cr0);
	}

	i = memtest_sub(start, end);

	if(flg486 != 0)
	{
		cr0 = load_cr0();
		cr0 &= ~CR0_CACHE_DISABLE;
		store_cr0(cr0);
	}

	return i;
}

void memman_init(struct MEMMAN *man)
{
	man->frees = 0;
	man->maxfrees = 0;
	man->lostsize = 0;
	man->losts = 0;
	return;
}

unsigned int memman_total(struct MEMMAN *man)
{
	unsigned int i, t = 0;
	for (i = 0; i < man->frees; ++i)
	{
		t += man->free[i].size;
	}
	return t;
}

unsigned int memman_alloc(struct MEMMAN *man, unsigned int size)
{
	unsigned int i, a;
	for (i = 0; i < man->frees; ++i)
	{
		if(man->free[i].size >= size)
		{
			a = man->free[i].addr;
			man->free[i].addr += size;
			man->free[i].size -= size;
			if(man->free[i].size == 0)
			{
				--man->frees;
				for (; i < man->frees; ++i)
				{
					man->free[i].addr = man->free[i+1].addr;
					man->free[i].size = man->free[i+1].size;
				}
			}
			return a;
		}
	}
	return 0;
}

int memman_free(struct MEMMAN *man, unsigned int addr, unsigned int size)
{
	int i, j;
	for (i = 0; i < man->frees; ++i)
	{
		if(man->free[i].addr > addr)
		{
			break;
		}
	}
	if(i > 0)
	{
		if(man->free[i-1].addr + man->free[i-1].size == addr)
		{
			man->free[i-1].size += size;
			if(addr + size == man->free[i].addr)
			{
				man->free[i-1].size += size;
				--man->frees;
				for (j = i; j < man->frees; ++j)
				{
					man->free[j].addr = man->free[j+1].addr;
					man->free[j].size = man->free[j+1].size;
				}
			}
			return 0;
		}
	}
	if(i < man->frees)
	{
		if(addr + size == man->free[i].addr)
		{
			man->free[i].addr = addr;
			man->free[i].size += size;
		}
		return 0;
	}
	if(man->frees < MEMMAN_FREES)
	{
		for (j = man->frees; j > i; --j)
		{
			man->free[j].addr = man->free[j-1].addr;
			man->free[j].size = man->free[j-1].size;
		}
		++man->frees;
		if(man->maxfrees > man->frees)
		{
			man->maxfrees = man->frees;
		}
		man->free[i].addr = addr;
		man->free[i].size = size;
		return 0;
	}
	++man->losts;
	man->lostsize += size;
	return -1;
}

unsigned int memman_alloc_4k(struct MEMMAN *man, unsigned int size)
{
	unsigned int a;
	size = (size + 0xfff) & 0xfffff000;
	a = memman_alloc(man, size);
	return a;
}

int memman_free_4k(struct MEMMAN *man, unsigned int addr, unsigned int size)
{
	int i;
	size = (size + 0xfff) & 0xfffff000;
	i = memman_free(man, addr, size);
	return i;
}