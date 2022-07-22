nasm -f bin get_input.asm -o get_input.img
qemu-system-x86_64 -drive file=get_input.img,format=raw,index=0,media=disk