// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VPALROM__Syms.h"


//======================

void VPALROM::trace (VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback (&VPALROM::traceInit, &VPALROM::traceFull, &VPALROM::traceChg, this);
}
void VPALROM::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    VPALROM* t=(VPALROM*)userthis;
    VPALROM__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) vl_fatal(__FILE__,__LINE__,__FILE__,"Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    vcdp->scopeEscape(' ');
    t->traceInitThis (vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void VPALROM::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    VPALROM* t=(VPALROM*)userthis;
    VPALROM__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    t->traceFullThis (vlSymsp, vcdp, code);
}

//======================


void VPALROM::traceInitThis(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name()); // Setup signal names
    // Body
    {
	vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void VPALROM::traceFullThis(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void VPALROM::traceInitThis__1(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->declBus  (c+1,"pal_in",-1,5,0);
	vcdp->declBus  (c+2,"red",-1,7,0);
	vcdp->declBus  (c+3,"green",-1,7,0);
	vcdp->declBus  (c+4,"blue",-1,7,0);
	vcdp->declBus  (c+1,"v pal_in",-1,5,0);
	vcdp->declBus  (c+2,"v red",-1,7,0);
	vcdp->declBus  (c+3,"v green",-1,7,0);
	vcdp->declBus  (c+4,"v blue",-1,7,0);
    }
}

void VPALROM::traceFullThis__1(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->fullBus  (c+1,(vlTOPp->pal_in),6);
	vcdp->fullBus  (c+2,(vlTOPp->red),8);
	vcdp->fullBus  (c+3,(vlTOPp->green),8);
	vcdp->fullBus  (c+4,(vlTOPp->blue),8);
    }
}
