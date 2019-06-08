Directories:
  - Verilog
    contains the verilog code that implements the components of this project: the CPU,
    the PPU, memory interfaces, and video interfaces.

  - synth
    Each subfolder of synth is a Quartus project. These projects should primarily use the code from
    the verilog folder.

  - testbench
    Contains testbenches for testing components in the verilog folder.

  - programs
    Contains C and assembly sources for programs which can be run on the system.