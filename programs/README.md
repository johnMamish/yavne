Assembly programs in this folder can be turned into ascii hex files readable by verilog's $readmemh
using ./assemble.sh <progname.asm> <linkerfile.cfg>.  The output file, prog.mem, can then be copied
to the volder where the verilog testbench resides to run the testbench with that program.

Depending on the memory map of the stuff surrounding the cpu in the testbench, different linkers
might be preferable.