TOOLCHAIN ?= C:/ST/STM32CubeIDE_1.0.2/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.7-2018-q2-update.win32_1.0.0.201904181610/tools/bin
PREFIX    := $(TOOLCHAIN)/arm-none-eabi-

CC      := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
SIZE    := $(PREFIX)size

TARGET := hello
SRCS   := main.c startup.c
OBJS   := $(SRCS:%.c=build/%.o)

CPUFLAGS := -mcpu=cortex-m4 -mthumb -mfloat-abi=soft
CFLAGS   := $(CPUFLAGS) -Os -g -Wall -ffreestanding -ffunction-sections -fdata-sections
LDFLAGS  := $(CPUFLAGS) -nostdlib -T linker.ld -Wl,--gc-sections -Wl,-Map=build/$(TARGET).map

all: build/$(TARGET).elf build/$(TARGET).bin build/$(TARGET).hex
	$(SIZE) build/$(TARGET).elf

build/%.o: %.c | build
	$(CC) $(CFLAGS) -c $< -o $@

build/$(TARGET).elf: $(OBJS) linker.ld
	$(CC) $(OBJS) $(LDFLAGS) -o $@

build/%.bin: build/%.elf
	$(OBJCOPY) -O binary $< $@

build/%.hex: build/%.elf
	$(OBJCOPY) -O ihex $< $@

OPENOCD     ?= C:/ST/STM32CubeIDE_1.0.2/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.win32_1.0.0.201904181610/tools/bin/openocd.exe
OPENOCD_SCR ?= C:/ST/STM32CubeIDE_1.0.2/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.debug_1.0.2.201907120816/resources/openocd/st_scripts

# Flash, run, and show "Hello World" in this terminal (semihosting). Ctrl+C to stop.
run: all
	"$(OPENOCD)" -s "$(OPENOCD_SCR)" -f interface/stlink.cfg -f target/stm32f4x.cfg \
		-c "program build/$(TARGET).elf verify" -c "init" -c "arm semihosting enable" -c "reset run"

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: all clean run
