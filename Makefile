all:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin
	dd if=./test.txt >> ./boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin
# 512 bytes of zeroes are being added to ./boot.bin, no direct impact on RAM on line 4

clean:
# Should work when run "make clean"
	rm -rf ./bin/boot.bin