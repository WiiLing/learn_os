extern int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title);
extern void api_initmalloc(void);
extern char *api_malloc(int size);
extern void api_refreshwin(int win, int x0, int y0, int x1, int y1);
extern void api_linewin(int win, int x0, int y0, int x1, int y1, int col);
extern void api_closewin(int win);
extern void api_end(void);

void HariMain(void)
{
	char *buf;
	int win, i;
	api_initmalloc();
	buf = api_malloc(160 * 100);
	win = api_openwin(buf, 160, 100, -1, "lines");
	for(i = 0; i < 8; ++i)
	{
		api_linewin(win + 1, 8, 26, 77, i*9+26, i);
		api_linewin(win + 1, 88, 26, i*9+88, 89, i);
	}
	api_refreshwin(win, 6, 26, 154, 90);
	api_closewin(win);
	api_end();
}