#include <stdlib.h>
#include "Vvga.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>


void setColor(TESTBENCH<Vvga> * tb, uint8_t red, uint8_t green, uint8_t blue){
    tb->m_core->vga_r =red;
    tb->m_core->vga_g =green;
    tb->m_core->vga_b =blue;
}


int main(int argc, char **argv) {
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
	// Create an instance of our module under test
	TESTBENCH<Vvga> *tb = new TESTBENCH<Vvga>;

	// Tick the clock until we are done
    setColor(tb, 0, 128, 44);
	tb->reset();
    while(tb->m_core->vga_vs != 0) { tb->tick();}
    while(tb->m_core->vga_vs == 0) { tb->tick();}





}

