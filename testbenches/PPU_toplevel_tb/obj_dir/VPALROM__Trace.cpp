// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VPALROM__Syms.h"


//======================

void VPALROM::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    VPALROM* t=(VPALROM*)userthis;
    VPALROM__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
	t->traceChgThis (vlSymsp, vcdp, code);
    }
}

//======================


void VPALROM::traceChgThis(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void VPALROM::traceChgThis__2(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBus  (c+1,(vlTOPp->pal_in),6);
	vcdp->chgBus  (c+2,(vlTOPp->red),8);
	vcdp->chgBus  (c+3,(vlTOPp->green),8);
	vcdp->chgBus  (c+4,(vlTOPp->blue),8);
    }
}
