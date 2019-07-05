// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VPALROM.h for the primary calling header

#include "VPALROM.h"           // For This
#include "VPALROM__Syms.h"

//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(VPALROM) {
    VPALROM__Syms* __restrict vlSymsp = __VlSymsp = new VPALROM__Syms(this, name());
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    pal_in = VL_RAND_RESET_I(6);
    red = VL_RAND_RESET_I(8);
    green = VL_RAND_RESET_I(8);
    blue = VL_RAND_RESET_I(8);
    __Vm_traceActivity = VL_RAND_RESET_I(32);
}

void VPALROM::__Vconfigure(VPALROM__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

VPALROM::~VPALROM() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void VPALROM::eval() {
    VPALROM__Syms* __restrict vlSymsp = this->__VlSymsp; // Setup global symbol table
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    VL_DEBUG_IF(VL_PRINTF("\n----TOP Evaluate VPALROM::eval\n"); );
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

void VPALROM::_eval_initial_loop(VPALROM__Syms* __restrict vlSymsp) {
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

VL_INLINE_OPT void VPALROM::_combo__TOP__1(VPALROM__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VPALROM::_combo__TOP__1\n"); );
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->red = (0xffU & ((0U == (IData)(vlTOPp->pal_in))
			     ? 0x60U : ((1U == (IData)(vlTOPp->pal_in))
					 ? 0U : ((2U 
						  == (IData)(vlTOPp->pal_in))
						  ? 0U
						  : 
						 ((3U 
						   == (IData)(vlTOPp->pal_in))
						   ? 0x3cU
						   : 
						  ((4U 
						    == (IData)(vlTOPp->pal_in))
						    ? 0x64U
						    : 
						   ((5U 
						     == (IData)(vlTOPp->pal_in))
						     ? 0x64U
						     : 
						    ((6U 
						      == (IData)(vlTOPp->pal_in))
						      ? 0x64U
						      : 
						     ((7U 
						       == (IData)(vlTOPp->pal_in))
						       ? 0x51U
						       : 
						      ((8U 
							== (IData)(vlTOPp->pal_in))
						        ? 0x24U
						        : 
						       ((9U 
							 == (IData)(vlTOPp->pal_in))
							 ? 0x1cU
							 : 
							((0xaU 
							  == (IData)(vlTOPp->pal_in))
							  ? 0U
							  : 
							 ((0xbU 
							   == (IData)(vlTOPp->pal_in))
							   ? 0U
							   : 
							  ((0xcU 
							    == (IData)(vlTOPp->pal_in))
							    ? 0U
							    : 
							   ((0xdU 
							     == (IData)(vlTOPp->pal_in))
							     ? 0U
							     : 
							    ((0xeU 
							      == (IData)(vlTOPp->pal_in))
							      ? 0x14U
							      : 
							     ((0xfU 
							       == (IData)(vlTOPp->pal_in))
							       ? 0x14U
							       : 
							      ((0x10U 
								== (IData)(vlTOPp->pal_in))
							        ? 0xaeU
							        : 
							       ((0x11U 
								 == (IData)(vlTOPp->pal_in))
								 ? 0x24U
								 : 
								((0x12U 
								  == (IData)(vlTOPp->pal_in))
								  ? 0x34U
								  : 
								 ((0x13U 
								   == (IData)(vlTOPp->pal_in))
								   ? 0x74U
								   : 
								  ((0x14U 
								    == (IData)(vlTOPp->pal_in))
								    ? 0xb4U
								    : 
								   ((0x15U 
								     == (IData)(vlTOPp->pal_in))
								     ? 0xb4U
								     : 
								    ((0x16U 
								      == (IData)(vlTOPp->pal_in))
								      ? 0xb4U
								      : 
								     ((0x17U 
								       == (IData)(vlTOPp->pal_in))
								       ? 0x88U
								       : 
								      ((0x18U 
									== (IData)(vlTOPp->pal_in))
								        ? 0x5cU
								        : 
								       ((0x19U 
									 == (IData)(vlTOPp->pal_in))
									 ? 0x38U
									 : 
									((0x1aU 
									  == (IData)(vlTOPp->pal_in))
									  ? 0U
									  : 
									 ((0x1bU 
									   == (IData)(vlTOPp->pal_in))
									   ? 0U
									   : 
									  ((0x1cU 
									    == (IData)(vlTOPp->pal_in))
									    ? 0U
									    : 
									   ((0x1dU 
									     == (IData)(vlTOPp->pal_in))
									     ? 0x30U
									     : 
									    ((0x1eU 
									      == (IData)(vlTOPp->pal_in))
									      ? 0x14U
									      : 
									     ((0x1fU 
									       == (IData)(vlTOPp->pal_in))
									       ? 0x14U
									       : 
									      ((0x20U 
										== (IData)(vlTOPp->pal_in))
									        ? 0xffU
									        : 
									       ((0x21U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x58U
										 : 
										((0x22U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x84U
										 : 
										((0x23U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb8U
										 : 
										((0x24U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xecU
										 : 
										((0x25U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xf8U
										 : 
										((0x26U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x27U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xdeU
										 : 
										((0x28U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb7U
										 : 
										((0x29U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x7aU
										 : 
										((0x2aU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x3cU
										 : 
										((0x2bU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x34U
										 : 
										((0x2cU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x2cU
										 : 
										((0x2dU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x4cU
										 : 
										((0x2eU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x2fU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x30U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x31U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xc0U
										 : 
										((0x32U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xccU
										 : 
										((0x33U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xe4U
										 : 
										((0x34U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xfcU
										 : 
										((0x35U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x36U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x37U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xf4U
										 : 
										((0x38U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xe4U
										 : 
										((0x39U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xccU
										 : 
										((0x3aU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb4U
										 : 
										((0x3bU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb4U
										 : 
										((0x3cU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb4U
										 : 
										((0x3dU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb6U
										 : 
										((0x3eU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x3fU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 0U)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
    vlTOPp->green = (0xffU & ((0U == (IData)(vlTOPp->pal_in))
			       ? 0x60U : ((1U == (IData)(vlTOPp->pal_in))
					   ? 0x2cU : 
					  ((2U == (IData)(vlTOPp->pal_in))
					    ? 0U : 
					   ((3U == (IData)(vlTOPp->pal_in))
					     ? 0U : 
					    ((4U == (IData)(vlTOPp->pal_in))
					      ? 0U : 
					     ((5U == (IData)(vlTOPp->pal_in))
					       ? 0U
					       : ((6U 
						   == (IData)(vlTOPp->pal_in))
						   ? 0U
						   : 
						  ((7U 
						    == (IData)(vlTOPp->pal_in))
						    ? 0x18U
						    : 
						   ((8U 
						     == (IData)(vlTOPp->pal_in))
						     ? 0x24U
						     : 
						    ((9U 
						      == (IData)(vlTOPp->pal_in))
						      ? 0x34U
						      : 
						     ((0xaU 
						       == (IData)(vlTOPp->pal_in))
						       ? 0x44U
						       : 
						      ((0xbU 
							== (IData)(vlTOPp->pal_in))
						        ? 0x44U
						        : 
						       ((0xcU 
							 == (IData)(vlTOPp->pal_in))
							 ? 0x44U
							 : 
							((0xdU 
							  == (IData)(vlTOPp->pal_in))
							  ? 0U
							  : 
							 ((0xeU 
							   == (IData)(vlTOPp->pal_in))
							   ? 0x14U
							   : 
							  ((0xfU 
							    == (IData)(vlTOPp->pal_in))
							    ? 0x14U
							    : 
							   ((0x10U 
							     == (IData)(vlTOPp->pal_in))
							     ? 0xaeU
							     : 
							    ((0x11U 
							      == (IData)(vlTOPp->pal_in))
							      ? 0x58U
							      : 
							     ((0x12U 
							       == (IData)(vlTOPp->pal_in))
							       ? 0x34U
							       : 
							      ((0x13U 
								== (IData)(vlTOPp->pal_in))
							        ? 0x24U
							        : 
							       ((0x14U 
								 == (IData)(vlTOPp->pal_in))
								 ? 0U
								 : 
								((0x15U 
								  == (IData)(vlTOPp->pal_in))
								  ? 0x18U
								  : 
								 ((0x16U 
								   == (IData)(vlTOPp->pal_in))
								   ? 0x1cU
								   : 
								  ((0x17U 
								    == (IData)(vlTOPp->pal_in))
								    ? 0x3cU
								    : 
								   ((0x18U 
								     == (IData)(vlTOPp->pal_in))
								     ? 0x5cU
								     : 
								    ((0x19U 
								      == (IData)(vlTOPp->pal_in))
								      ? 0x6cU
								      : 
								     ((0x1aU 
								       == (IData)(vlTOPp->pal_in))
								       ? 0x7cU
								       : 
								      ((0x1bU 
									== (IData)(vlTOPp->pal_in))
								        ? 0x7cU
								        : 
								       ((0x1cU 
									 == (IData)(vlTOPp->pal_in))
									 ? 0x7cU
									 : 
									((0x1dU 
									  == (IData)(vlTOPp->pal_in))
									  ? 0x30U
									  : 
									 ((0x1eU 
									   == (IData)(vlTOPp->pal_in))
									   ? 0x14U
									   : 
									  ((0x1fU 
									    == (IData)(vlTOPp->pal_in))
									    ? 0x14U
									    : 
									   ((0x20U 
									     == (IData)(vlTOPp->pal_in))
									     ? 0xffU
									     : 
									    ((0x21U 
									      == (IData)(vlTOPp->pal_in))
									      ? 0xa0U
									      : 
									     ((0x22U 
									       == (IData)(vlTOPp->pal_in))
									       ? 0x84U
									       : 
									      ((0x23U 
										== (IData)(vlTOPp->pal_in))
									        ? 0x74U
									        : 
									       ((0x24U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x64U
										 : 
										((0x25U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x6cU
										 : 
										((0x26U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x74U
										 : 
										((0x27U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x96U
										 : 
										((0x28U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb7U
										 : 
										((0x29U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xc6U
										 : 
										((0x2aU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xd4U
										 : 
										((0x2bU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xc8U
										 : 
										((0x2cU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xbcU
										 : 
										((0x2dU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x4cU
										 : 
										((0x2eU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x2fU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x30U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x31U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xd8U
										 : 
										((0x32U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xccU
										 : 
										((0x33U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xc8U
										 : 
										((0x34U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xc4U
										 : 
										((0x35U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xc8U
										 : 
										((0x36U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xccU
										 : 
										((0x37U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xd8U
										 : 
										((0x38U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xe4U
										 : 
										((0x39U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xecU
										 : 
										((0x3aU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xf4U
										 : 
										((0x3bU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xecU
										 : 
										((0x3cU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xe4U
										 : 
										((0x3dU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb6U
										 : 
										((0x3eU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x3fU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 0U)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
    vlTOPp->blue = (0xffU & ((0U == (IData)(vlTOPp->pal_in))
			      ? 0x60U : ((1U == (IData)(vlTOPp->pal_in))
					  ? 0x70U : 
					 ((2U == (IData)(vlTOPp->pal_in))
					   ? 0x9cU : 
					  ((3U == (IData)(vlTOPp->pal_in))
					    ? 0x80U
					    : ((4U 
						== (IData)(vlTOPp->pal_in))
					        ? 0x64U
					        : (
						   (5U 
						    == (IData)(vlTOPp->pal_in))
						    ? 0x3cU
						    : 
						   ((6U 
						     == (IData)(vlTOPp->pal_in))
						     ? 0U
						     : 
						    ((7U 
						      == (IData)(vlTOPp->pal_in))
						      ? 0U
						      : 
						     ((8U 
						       == (IData)(vlTOPp->pal_in))
						       ? 0U
						       : 
						      ((9U 
							== (IData)(vlTOPp->pal_in))
						        ? 0U
						        : 
						       ((0xaU 
							 == (IData)(vlTOPp->pal_in))
							 ? 0U
							 : 
							((0xbU 
							  == (IData)(vlTOPp->pal_in))
							  ? 0x2cU
							  : 
							 ((0xcU 
							   == (IData)(vlTOPp->pal_in))
							   ? 0x44U
							   : 
							  ((0xdU 
							    == (IData)(vlTOPp->pal_in))
							    ? 0U
							    : 
							   ((0xeU 
							     == (IData)(vlTOPp->pal_in))
							     ? 0x14U
							     : 
							    ((0xfU 
							      == (IData)(vlTOPp->pal_in))
							      ? 0x14U
							      : 
							     ((0x10U 
							       == (IData)(vlTOPp->pal_in))
							       ? 0xaeU
							       : 
							      ((0x11U 
								== (IData)(vlTOPp->pal_in))
							        ? 0xb8U
							        : 
							       ((0x12U 
								 == (IData)(vlTOPp->pal_in))
								 ? 0xf4U
								 : 
								((0x13U 
								  == (IData)(vlTOPp->pal_in))
								  ? 0xd4U
								  : 
								 ((0x14U 
								   == (IData)(vlTOPp->pal_in))
								   ? 0xb4U
								   : 
								  ((0x15U 
								    == (IData)(vlTOPp->pal_in))
								    ? 0x68U
								    : 
								   ((0x16U 
								     == (IData)(vlTOPp->pal_in))
								     ? 0x1cU
								     : 
								    ((0x17U 
								      == (IData)(vlTOPp->pal_in))
								      ? 0x18U
								      : 
								     ((0x18U 
								       == (IData)(vlTOPp->pal_in))
								       ? 0U
								       : 
								      ((0x19U 
									== (IData)(vlTOPp->pal_in))
								        ? 0U
								        : 
								       ((0x1aU 
									 == (IData)(vlTOPp->pal_in))
									 ? 0U
									 : 
									((0x1bU 
									  == (IData)(vlTOPp->pal_in))
									  ? 0x48U
									  : 
									 ((0x1cU 
									   == (IData)(vlTOPp->pal_in))
									   ? 0x7cU
									   : 
									  ((0x1dU 
									    == (IData)(vlTOPp->pal_in))
									    ? 0x30U
									    : 
									   ((0x1eU 
									     == (IData)(vlTOPp->pal_in))
									     ? 0x14U
									     : 
									    ((0x1fU 
									      == (IData)(vlTOPp->pal_in))
									      ? 0x14U
									      : 
									     ((0x20U 
									       == (IData)(vlTOPp->pal_in))
									       ? 0xffU
									       : 
									      ((0x21U 
										== (IData)(vlTOPp->pal_in))
									        ? 0xe8U
									        : 
									       ((0x22U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x23U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x24U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xecU
										 : 
										((0x25U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb0U
										 : 
										((0x26U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x74U
										 : 
										((0x27U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x44U
										 : 
										((0x28U 
										== (IData)(vlTOPp->pal_in))
										 ? 0U
										 : 
										((0x29U 
										== (IData)(vlTOPp->pal_in))
										 ? 0x28U
										 : 
										((0x2aU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x3cU
										 : 
										((0x2bU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x7cU
										 : 
										((0x2cU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xbcU
										 : 
										((0x2dU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x4cU
										 : 
										((0x2eU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x2fU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x30U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x31U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xfcU
										 : 
										((0x32U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x33U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xffU
										 : 
										((0x34U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xfcU
										 : 
										((0x35U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xe4U
										 : 
										((0x36U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xccU
										 : 
										((0x37U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb8U
										 : 
										((0x38U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xa4U
										 : 
										((0x39U 
										== (IData)(vlTOPp->pal_in))
										 ? 0xacU
										 : 
										((0x3aU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb4U
										 : 
										((0x3bU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xccU
										 : 
										((0x3cU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xe4U
										 : 
										((0x3dU 
										== (IData)(vlTOPp->pal_in))
										 ? 0xb6U
										 : 
										((0x3eU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 
										((0x3fU 
										== (IData)(vlTOPp->pal_in))
										 ? 0x14U
										 : 0U)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
}

void VPALROM::_eval(VPALROM__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VPALROM::_eval\n"); );
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

void VPALROM::_eval_initial(VPALROM__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VPALROM::_eval_initial\n"); );
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VPALROM::final() {
    VL_DEBUG_IF(VL_PRINTF("    VPALROM::final\n"); );
    // Variables
    VPALROM__Syms* __restrict vlSymsp = this->__VlSymsp;
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void VPALROM::_eval_settle(VPALROM__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VPALROM::_eval_settle\n"); );
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_combo__TOP__1(vlSymsp);
}

VL_INLINE_OPT QData VPALROM::_change_request(VPALROM__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    VPALROM::_change_request\n"); );
    VPALROM* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}
