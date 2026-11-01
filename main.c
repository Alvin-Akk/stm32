/* Hello World for STM32F407 Discovery (bare metal, no HAL)
 * UART: USART2 TX on PA2 (needs a USB-serial adapter: adapter RX -> PA2, GND -> GND)
 * LED : PD12 (green) toggles so you can see the program is running
 * Clock: default 16 MHz HSI
 */
#include <stdint.h>

#define REG(addr) (*(volatile uint32_t *)(addr))

#define RCC_AHB1ENR   REG(0x40023830)
#define RCC_APB1ENR   REG(0x40023840)

#define GPIOA_MODER   REG(0x40020000)
#define GPIOA_AFRL    REG(0x40020020)
#define GPIOD_MODER   REG(0x40020C00)
#define GPIOD_ODR     REG(0x40020C14)

#define USART2_SR     REG(0x40004400)
#define USART2_DR     REG(0x40004404)
#define USART2_BRR    REG(0x40004408)
#define USART2_CR1    REG(0x4000440C)

static void uart_init(void)
{
    RCC_AHB1ENR |= (1u << 0);                 /* GPIOA clock */
    RCC_APB1ENR |= (1u << 17);                /* USART2 clock */

    GPIOA_MODER = (GPIOA_MODER & ~(3u << 4)) | (2u << 4);   /* PA2 alternate function */
    GPIOA_AFRL  = (GPIOA_AFRL  & ~(0xFu << 8)) | (7u << 8); /* AF7 = USART2 */

    USART2_BRR = 16000000u / 115200u;         /* 115200 baud @ 16 MHz */
    USART2_CR1 = (1u << 13) | (1u << 3);      /* UE | TE */
}

static void uart_putc(char c)
{
    while (!(USART2_SR & (1u << 7)))          /* wait TXE */
        ;
    USART2_DR = (uint32_t)c;
}

static void uart_puts(const char *s)
{
    while (*s)
        uart_putc(*s++);
    while (!(USART2_SR & (1u << 6)))          /* wait TC */
        ;
}

/* Semihosting: text appears in the OpenOCD console (only when a debugger is attached) */
#define DHCSR REG(0xE000EDF0)

static void semihost_puts(const char *s)
{
    if (!(DHCSR & 1u))                        /* C_DEBUGEN not set: no debugger, skip */
        return;
    register uint32_t op  __asm__("r0") = 0x04;           /* SYS_WRITE0 */
    register const char *p __asm__("r1") = s;
    __asm__ volatile ("bkpt 0xAB" : "+r"(op) : "r"(p) : "memory");
}

static void delay(volatile uint32_t n)
{
    while (n--)
        ;
}

int main(void)
{
    uart_init();

    RCC_AHB1ENR |= (1u << 3);                 /* GPIOD clock */
    GPIOD_MODER = (GPIOD_MODER & ~(3u << 24)) | (1u << 24); /* PD12 output */

    semihost_puts("Hello World!\n");
    uart_puts("Hello World!\r\n");

    while (1)
    {
        GPIOD_ODR ^= (1u << 12);
        delay(1000000);
    }
}
