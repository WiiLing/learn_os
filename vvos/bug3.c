extern void api_putchar(int c);
extern void api_end(void);

void HariMain(void)
{
	for(;;)
	{
		api_putchar('a');
	}
}