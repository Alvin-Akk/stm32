//PD 12 and 13
//HIGH HIGH
//LOW  LOW

#include <stdint.h>

#define RCC_BASE        0x40023800UL
#define RCC_AHB1ENR     (*(volatile uint32_t *)(RCC_BASE + 0x30))

#define GPIOD_BASE      0x40020C00UL
#define GPIOD_MODER     (*(volatile uint32_t *)(GPIOD_BASE + 0x00))
#define GPIOD_ODR       (*(volatile uint32_t *)(GPIOD_BASE + 0x14))

/* ~1 second at 16 MHz HSI (default clock) */
static void delay_1s(void)
{
    volatile uint32_t i = 4000000;
    while (i--) { }
}

int main(void)
{
    /* Enable GPIOD clock */
    RCC_AHB1ENR |= (1 << 3);

    /* PD12 and PD13 as outputs (MODER bits 27:24 = 01 01) */
    GPIOD_MODER &= ~(0xFU << 24);
    GPIOD_MODER |=  (0x5U << 24);

    while (1) {
        GPIOD_ODR ^= (3 << 12);
        delay_1s();
    }
}
