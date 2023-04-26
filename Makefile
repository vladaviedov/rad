AS=arm-none-eabi-gcc
ASFLAGS=-nostdlib -e start
OBJCOPY=arm-none-eabi-objcopy
PROG=st-flash

DIR=build
ELF=$(DIR)/main.elf
BIN=$(DIR)/main.bin

.PHONY: _build
_build: builddir $(BIN)

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): main.s
	$(AS) -o $@ $< $(ASFLAGS)

.PHONY: builddir
builddir:
	mkdir -p $(DIR)

.PHONY: flash
flash:
	$(PROG) write $(BIN) 0x8000000

.PHONY: clean
clean:
	rm $(ELF) $(BIN)
