
label.bin: label.asm
	asm02 -L -b label.asm
	rm -f label.build

clean:
	rm -f label.lst
	rm -f label.bin

