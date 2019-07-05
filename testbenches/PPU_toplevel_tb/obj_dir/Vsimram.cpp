// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsimram.h for the primary calling header

#include "Vsimram.h"           // For This
#include "Vsimram__Syms.h"

//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vsimram) {
    Vsimram__Syms* __restrict vlSymsp = __VlSymsp = new Vsimram__Syms(this, name());
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    clock = VL_RAND_RESET_I(1);
    reset = VL_RAND_RESET_I(1);
    we = VL_RAND_RESET_I(1);
    w_addr = VL_RAND_RESET_I(15);
    w_data = VL_RAND_RESET_I(8);
    r_addr = VL_RAND_RESET_I(15);
    r_data = VL_RAND_RESET_I(8);
    VL_RAND_RESET_W(120,v__DOT__palram);
    v__DOT__index = VL_RAND_RESET_I(5);
    v__DOT____Vlvbound1 = VL_RAND_RESET_I(8);
    __Vclklast__TOP__clock = VL_RAND_RESET_I(1);
    __Vm_traceActivity = VL_RAND_RESET_I(32);
}

void Vsimram::__Vconfigure(Vsimram__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vsimram::~Vsimram() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void Vsimram::eval() {
    Vsimram__Syms* __restrict vlSymsp = this->__VlSymsp; // Setup global symbol table
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    VL_DEBUG_IF(VL_PRINTF("\n----TOP Evaluate Vsimram::eval\n"); );
    int __VclockLoop = 0;
    QData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	VL_DEBUG_IF(VL_PRINTF(" Clock loop\n"););
	vlSymsp->__Vm_activity = true;
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't converge");
    }
}

void Vsimram::_eval_initial_loop(Vsimram__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    int __VclockLoop = 0;
    QData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	_eval_settle(vlSymsp);
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't DC converge");
    }
}

//--------------------
// Internal Methods

VL_INLINE_OPT void Vsimram::_sequent__TOP__1(Vsimram__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::_sequent__TOP__1\n"); );
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    //char	__VpadToAlign4[4];
    VL_SIGW(__Vdly__v__DOT__palram,119,0,4);
    //char	__VpadToAlign23[1];
    // Body
    __Vdly__v__DOT__palram[0U] = vlTOPp->v__DOT__palram[0U];
    __Vdly__v__DOT__palram[1U] = vlTOPp->v__DOT__palram[1U];
    __Vdly__v__DOT__palram[2U] = vlTOPp->v__DOT__palram[2U];
    __Vdly__v__DOT__palram[3U] = vlTOPp->v__DOT__palram[3U];
    // ALWAYS at /home/james/yavne/verilog/simram.v:21
    if (vlTOPp->reset) {
	__Vdly__v__DOT__palram[0U] = 0U;
	__Vdly__v__DOT__palram[1U] = 0U;
	__Vdly__v__DOT__palram[2U] = 0U;
	__Vdly__v__DOT__palram[3U] = 0U;
    } else {
	vlTOPp->v__DOT____Vlvbound1 = (0xffU & ((IData)(vlTOPp->we)
						 ? (IData)(vlTOPp->w_data)
						 : 
						((0x77U 
						  >= 
						  (0x7fU 
						   & ((IData)(vlTOPp->v__DOT__index) 
						      << 3U)))
						  ? 
						 (((0U 
						    == 
						    (0x1fU 
						     & ((IData)(vlTOPp->v__DOT__index) 
							<< 3U)))
						    ? 0U
						    : 
						   (vlTOPp->v__DOT__palram[
						    ((IData)(1U) 
						     + 
						     (3U 
						      & ((IData)(vlTOPp->v__DOT__index) 
							 >> 2U)))] 
						    << 
						    ((IData)(0x20U) 
						     - 
						     (0x1fU 
						      & ((IData)(vlTOPp->v__DOT__index) 
							 << 3U))))) 
						  | (vlTOPp->v__DOT__palram[
						     (3U 
						      & ((IData)(vlTOPp->v__DOT__index) 
							 >> 2U))] 
						     >> 
						     (0x1fU 
						      & ((IData)(vlTOPp->v__DOT__index) 
							 << 3U))))
						  : 0U)));
	if ((0x77U >= (0x7fU & ((IData)(vlTOPp->v__DOT__index) 
				<< 3U)))) {
	    VL_ASSIGNSEL_WIII(8,(0x7fU & ((IData)(vlTOPp->v__DOT__index) 
					  << 3U)), __Vdly__v__DOT__palram, vlTOPp->v__DOT____Vlvbound1);
	}
    }
    vlTOPp->v__DOT__palram[0U] = __Vdly__v__DOT__palram[0U];
    vlTOPp->v__DOT__palram[1U] = __Vdly__v__DOT__palram[1U];
    vlTOPp->v__DOT__palram[2U] = __Vdly__v__DOT__palram[2U];
    vlTOPp->v__DOT__palram[3U] = __Vdly__v__DOT__palram[3U];
}

VL_INLINE_OPT void Vsimram::_combo__TOP__2(Vsimram__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::_combo__TOP__2\n"); );
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->r_data = (0xffU & ((0x77U >= (0x7fU & ((IData)(vlTOPp->r_addr) 
						   << 3U)))
			        ? (((0U == (0x1fU & 
					    ((IData)(vlTOPp->r_addr) 
					     << 3U)))
				     ? 0U : (vlTOPp->v__DOT__palram[
					     ((IData)(1U) 
					      + (3U 
						 & ((IData)(vlTOPp->r_addr) 
						    >> 2U)))] 
					     << ((IData)(0x20U) 
						 - 
						 (0x1fU 
						  & ((IData)(vlTOPp->r_addr) 
						     << 3U))))) 
				   | (vlTOPp->v__DOT__palram[
				      (3U & ((IData)(vlTOPp->r_addr) 
					     >> 2U))] 
				      >> (0x1fU & ((IData)(vlTOPp->r_addr) 
						   << 3U))))
			        : 0U));
}

void Vsimram::_eval(Vsimram__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::_eval\n"); );
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clock) & (~ (IData)(vlTOPp->__Vclklast__TOP__clock)))) {
	vlTOPp->_sequent__TOP__1(vlSymsp);
	vlTOPp->__Vm_traceActivity = (2U | vlTOPp->__Vm_traceActivity);
    }
    vlTOPp->_combo__TOP__2(vlSymsp);
    // Final
    vlTOPp->__Vclklast__TOP__clock = vlTOPp->clock;
}

void Vsimram::_eval_initial(Vsimram__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::_eval_initial\n"); );
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vsimram::final() {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::final\n"); );
    // Variables
    Vsimram__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vsimram::_eval_settle(Vsimram__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::_eval_settle\n"); );
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__2(vlSymsp);
}

VL_INLINE_OPT QData Vsimram::_change_request(Vsimram__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vsimram::_change_request\n"); );
    Vsimram* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}
