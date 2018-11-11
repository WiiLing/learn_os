extern int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title);
extern void api_boxfillwin(int win, int x0, int y0, int x1, int y1, int col);
extern void api_initmalloc(void);
extern char *api_malloc(int size);
extern void api_point(int win, int x, int y, int col);
extern void api_end(void);

void HariMain(void)
{
	char *buf;
	int win;

	api_initmalloc();
	buf = api_malloc(150 * 100);
	win = api_openwin(buf, 150, 100, -1, "star1");
	api_boxfillwin(win, 6, 26, 143, 93, 0/*黑色*/);
	api_point(win, 75, 59, 3/*黄色*/);
	api_end();
}