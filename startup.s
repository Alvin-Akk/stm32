.syntax unified
.cpu cortex-m4
.thumb

/* Vector table */
.section .isr_vector, "a", %progbits
    .word _estack
    .word Reset_Handler

/* Reset handler */
.section .text
.global Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
    /* Copy .data from flash to RAM */
    ldr r0, =_sdata
    ldr r1, =_edata
    ldr r2, =_sidata
copy_data:
    cmp r0, r1
    bge zero_bss
    ldr r3, [r2], #4
    str r3, [r0], #4
    b copy_data

    /* Zero .bss */
zero_bss:
    ldr r0, =_sbss
    ldr r1, =_ebss
    mov r2, #0
clear_bss:
    cmp r0, r1
    bge call_main
    str r2, [r0], #4
    b clear_bss

call_main:
    bl main
    b .
