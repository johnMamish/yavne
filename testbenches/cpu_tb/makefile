# Makefile for CPU with testbench
all: cpu_testbench.v cpu_2a03.v control_values.v micro_ops.v control_rom.v
	iverilog -Wall -Wpedantic -o cpu_tb cpu_testbench.v cpu_2a03.v
