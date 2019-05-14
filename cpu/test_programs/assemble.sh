# !/bin/bash

ca65 $1.asm  -o $1.o --cpu 6502
ld65 -C link.cfg $1.o -o $1.bin -Ln $1.lbl
echo "pipeing "$1".bin to ../prog.mem"
hexdump -v -e '16/1 "%02x " "\n"'  $1.bin > ../prog.mem
