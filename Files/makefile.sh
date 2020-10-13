
snake.bin: snake.asm
	nasm hm.asm -f bin -o hm.bin

snake.img: snake.bin
	dd if=/dev/null of=hm.img count=1 bs=512
	dd if=hm.bin of=hm.img conv=notrunc
	touch run

run: hm.img
	qemu-system-x86_64 -fda hm.bin

clean:
	rm *.bin *.img run
