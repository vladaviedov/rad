AS=arm-none-eabi-as
ASFLAGS=-mcpu=cortex-m0 -mthumb -g
LD=arm-none-eabi-ld
LDFLAGS=-T linker.ld -e vtable
OBJCOPY=arm-none-eabi-objcopy

GDB=arm-none-eabi-gdb
FLASH=st-flash
CONN=st-util

DIR=build
OUT=$(DIR)/main.o
ELF=$(DIR)/main.elf
BIN=$(DIR)/main.bin

.PHONY: _build
_build: $(DIR) $(BIN)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): $(OUT)
	$(LD) -o $@ $< $(LDFLAGS)

$(OUT): main.s
	$(AS) -o $@ $< $(ASFLAGS)

$(DIR):
	mkdir -p $(DIR)

.PHONY: flash
flash:
	$(FLASH) write $(BIN) 0x8000000

.PHONY: debug
debug:
	$(CONN) &
	$(GDB) -ex 'target extended-remote localhost:4242' -ex 'load' $(ELF)

.PHONY: clean
clean:
	rm $(OUT) $(ELF) $(BIN)
	rmdir $(DIR)
