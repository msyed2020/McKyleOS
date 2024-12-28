all:
	nasm -f bin ./boot.asm -o ./boot.bin
	dd if=./test.txt >> ./boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin
# 512 bytes of zeroes are being added to ./boot.bin, no direct impact on RAM on line 4