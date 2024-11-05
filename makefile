
all: label.bin

lbr: label.lbr

clean:
	rm -f label.lst
	rm -f label.bin
	rm -f label.lbr

label.bin: label.asm include/bios.inc include/kernel.inc
	asm02 -L -b label.asm
	rm -f label.build

label.lbr: label.bin
	rm -f label.lbr
	lbradd label.lbr label.bin

