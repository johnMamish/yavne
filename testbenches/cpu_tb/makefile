VERILOG=../../verilog

# Makefile for CPU with testbench
all: cpu_testbench.v $(VERILOG)/cpu_2a03.v $(VERILOG)/control_values.v $(VERILOG)/micro_ops.v $(VERILOG)/control_rom.v
	iverilog -I$(VERILOG) -Wall -o cpu_tb cpu_testbench.v $(VERILOG)/cpu_2a03.v
