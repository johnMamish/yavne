// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vsimram__Syms.h"


//======================

void Vsimram::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vsimram* t=(Vsimram*)userthis;
    Vsimram__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
	t->traceChgThis (vlSymsp, vcdp, code);
    }
}

//======================


void Vsimram::traceChgThis(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	if (VL_UNLIKELY((2U & vlTOPp->__Vm_traceActivity))) {
	    vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
	}
	vlTOPp->traceChgThis__3(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vsimram::traceChgThis__2(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgArray(c+1,(vlTOPp->v__DOT__palram),120);
    }
}

void Vsimram::traceChgThis__3(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBit  (c+5,(vlTOPp->clock));
	vcdp->chgBit  (c+6,(vlTOPp->reset));
	vcdp->chgBit  (c+7,(vlTOPp->we));
	vcdp->chgBus  (c+8,(vlTOPp->w_addr),15);
	vcdp->chgBus  (c+9,(vlTOPp->w_data),8);
	vcdp->chgBus  (c+10,(vlTOPp->r_addr),15);
	vcdp->chgBus  (c+11,(vlTOPp->r_data),8);
    }
}
