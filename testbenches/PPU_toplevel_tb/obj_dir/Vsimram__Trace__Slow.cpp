// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vsimram__Syms.h"


//======================

void Vsimram::trace (VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback (&Vsimram::traceInit, &Vsimram::traceFull, &Vsimram::traceChg, this);
}
void Vsimram::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    Vsimram* t=(Vsimram*)userthis;
    Vsimram__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) vl_fatal(__FILE__,__LINE__,__FILE__,"Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    vcdp->scopeEscape(' ');
    t->traceInitThis (vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void Vsimram::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vsimram* t=(Vsimram*)userthis;
    Vsimram__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    t->traceFullThis (vlSymsp, vcdp, code);
}

//======================


void Vsimram::traceInitThis(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name()); // Setup signal names
    // Body
    {
	vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void Vsimram::traceFullThis(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vsimram::traceInitThis__1(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->declBit  (c+5,"clock",-1);
	vcdp->declBit  (c+6,"reset",-1);
	vcdp->declBit  (c+7,"we",-1);
	vcdp->declBus  (c+8,"w_addr",-1,14,0);
	vcdp->declBus  (c+9,"w_data",-1,7,0);
	vcdp->declBus  (c+10,"r_addr",-1,14,0);
	vcdp->declBus  (c+11,"r_data",-1,7,0);
	vcdp->declBit  (c+5,"v clock",-1);
	vcdp->declBit  (c+6,"v reset",-1);
	vcdp->declBit  (c+7,"v we",-1);
	vcdp->declBus  (c+8,"v w_addr",-1,14,0);
	vcdp->declBus  (c+9,"v w_data",-1,7,0);
	vcdp->declBus  (c+10,"v r_addr",-1,14,0);
	vcdp->declBus  (c+11,"v r_data",-1,7,0);
	vcdp->declArray(c+1,"v palram",-1,119,0);
	vcdp->declBus  (c+12,"v index",-1,4,0);
    }
}

void Vsimram::traceFullThis__1(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->fullArray(c+1,(vlTOPp->v__DOT__palram),120);
	vcdp->fullBit  (c+5,(vlTOPp->clock));
	vcdp->fullBit  (c+6,(vlTOPp->reset));
	vcdp->fullBit  (c+7,(vlTOPp->we));
	vcdp->fullBus  (c+8,(vlTOPp->w_addr),15);
	vcdp->fullBus  (c+9,(vlTOPp->w_data),8);
	vcdp->fullBus  (c+10,(vlTOPp->r_addr),15);
	vcdp->fullBus  (c+11,(vlTOPp->r_data),8);
	vcdp->fullBus  (c+12,(vlTOPp->v__DOT__index),5);
    }
}
