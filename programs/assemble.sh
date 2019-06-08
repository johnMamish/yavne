# !/bin/bash

if [ "$#" -ne 2 ] || [ "$1" == "--help" ]; then
    echo "Illegal number of parameters"
    echo "Usage: ./assemble.sh <prog.asm> <linker.cfg>"
    echo "outputs the assembled program to ./prog.mem in ascii hex format, "
    echo "which is compatiable with verilog \$readmemh()."
    exit 1
fi


base="${1%.*}"

echo "assembling " $1
ca65 $1 -o $base.o --cpu 6502
if [ $? -ne 0 ]
then
    echo "failed"
    exit $?
fi

echo "linking " $base.o " with linker file " $2
ld65 -C $2 $base.o -o $base.bin -Ln $base.lbl -v
if [ $? -ne 0 ]
then
    echo "failed"
    exit $?
fi

echo "piping "$base".bin to ./prog.mem"
hexdump -v -e '16/1 "%02x " "\n"'  $base.bin > ./prog.mem
if [ $? -ne 0 ]
then
    echo "failed"
    exit $?
fi
