extern int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title);
extern void api_boxfillwin(int win, int x0, int y0, int x1, int y1, int col);
extern void api_initmalloc(void);
extern char *api_malloc(int size);
extern void api_point(int win, int x, int y, int col);
extern void api_refreshwin(int win, int x0, int y0, int x1, int y1);
extern void api_end(void);

extern int rand(void);

void HariMain(void)
{
	char *buf;
	int win, i, x, y;

	api_initmalloc();
	buf = api_malloc(150 * 100);
	win = api_openwin(buf, 150, 100, -1, "stars2");
	api_boxfillwin(win + 1, 6, 26, 143, 93, 0/*黑色*/);
	for (i = 0; i < 50; ++i)
	{
		x = (rand() % 137) + 6;
		y = (rand() % 67) + 26;
		api_point(win + 1, x, y, 3/*黄色*/);
	}
	api_refreshwin(win, 6, 26, 144, 94);
	api_end();
}