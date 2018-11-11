extern int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title);
extern void api_putstrwin(int win, int x, int y, int col, int len, char *str);
extern void api_boxfillwin(int win, int x0, int y0, int x1, int y1, int col);
extern void api_initmalloc(void);
extern char *api_malloc(int size);
extern void api_end(void);

void HariMain(void)
{
	char *buf;
	int win;

	api_initmalloc();
	buf = api_malloc(150 * 50);
	win = api_openwin(buf, 150, 50, -1, "hello");
	api_boxfillwin(win, 8, 28, 141, 43, 6/*浅蓝色*/);
	api_putstrwin(win, 28, 28, 0/*黑色*/, 12, "hello, world");
	api_end();
}