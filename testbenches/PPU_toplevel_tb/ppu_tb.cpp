#include <stdlib.h>
#include "VPPU2VGA_wrapper.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>









int main(int argc, char **argv) {
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
	// Create an instance of our module under test
	TESTBENCH<Vmmio_vga> *tb = new TESTBENCH<Vmmio_vga>;

	// Tick the clock until we are done

	tb->reset();
    for (int i=0; i < 480 * 640; i++){tb->tick();}






}

