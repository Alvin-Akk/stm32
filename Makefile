# Directories
TOOLCHAIN_BIN_DIR = C:/ST/STM32CubeIDE_1.0.2/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.7-2018-q2-update.win32_1.0.0.201904181610/tools/bin
OPENOCD_BIN_DIR   = C:/ST/STM32CubeIDE_1.0.2/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.win32_1.0.0.201904181610/tools/bin
OPENOCD_SCR_DIR   = C:/ST/STM32CubeIDE_1.0.2/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.debug_1.0.2.201907120816/resources/openocd/st_scripts

BUILD_DIR = build
OBJ_DIR   = $(BUILD_DIR)/obj
BIN_DIR   = $(BUILD_DIR)/bin

# Toolchain
PREFIX  = $(TOOLCHAIN_BIN_DIR)/arm-none-eabi-
CC      = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy
SIZE    = $(PREFIX)size
OPENOCD = $(OPENOCD_BIN_DIR)/openocd.exe
RM      = rm

# Files
TARGET  = $(BIN_DIR)/hello
LDSCRIPT = STM32F407VG_FLASH.ld

SOURCES = main.c \
          startup.s

OBJECT_NAMES = $(addsuffix .o,$(basename $(SOURCES)))
OBJECTS      = $(patsubst %,$(OBJ_DIR)/%,$(OBJECT_NAMES))

# Flags
CPUFLAGS = -mcpu=cortex-m4 -mthumb -mfloat-abi=soft
WFLAGS   = -Wall
CFLAGS   = $(CPUFLAGS) $(WFLAGS) -Os -g -ffreestanding -ffunction-sections -fdata-sections
LDFLAGS  = $(CPUFLAGS) -nostdlib -T $(LDSCRIPT) -Wl,--gc-sections -Wl,-Map=$(TARGET).map

# Build
## Linking
$(TARGET).elf: $(OBJECTS) $(LDSCRIPT)
	@mkdir -p $(dir $@)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

## Converting
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

## Compiling
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(CPUFLAGS) -c -o $@ $<

# Phonies
.PHONY: all clean run

all: $(TARGET).elf $(TARGET).bin $(TARGET).hex
	$(SIZE) $(TARGET).elf

clean:
	$(RM) -rf $(BUILD_DIR)

# Flash, run, and show "Hello World" in this terminal (semihosting). Ctrl+C to stop.
run: all
	"$(OPENOCD)" -s "$(OPENOCD_SCR_DIR)" -f interface/stlink.cfg -f target/stm32f4x.cfg \
		-c "program $(TARGET).elf verify" -c "init" -c "arm semihosting enable" -c "reset run"
