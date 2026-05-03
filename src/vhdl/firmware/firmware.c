

#include <stdint.h>
#include <stdbool.h>

#define reg_uart_clkdiv (*(volatile uint32_t*)0x03000004)
#define reg_uart_data (*(volatile uint32_t*)0x03000008)
#define reg_leds (*(volatile uint32_t*)0x04000000)

void putchar(char c)
{
	if (c == '\n')
		putchar('\r');
	reg_uart_data = c;
}

void print(const char *p)
{
    for (unsigned i = 0; i < 128 && p[i] != '\0'; i++)
        putchar(p[i]);
}

void main()
{
	reg_uart_clkdiv = 520;

	print("Booting..");
}
