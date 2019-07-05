// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VPALROM_H_
#define _VPALROM_H_

#include "verilated.h"
class VPALROM__Syms;
class VerilatedVcd;

//----------

VL_MODULE(VPALROM) {
  public:
    // CELLS
    // Public to allow access to /*verilator_public*/ items;
    // otherwise the application code can consider these internals.
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(pal_in,5,0);
    VL_OUT8(red,7,0);
    VL_OUT8(green,7,0);
    VL_OUT8(blue,7,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    VL_SIG(__Vm_traceActivity,31,0);
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    //char	__VpadToAlign20[4];
    VPALROM__Syms*	__VlSymsp;		// Symbol table
    
    // PARAMETERS
    // Parameters marked /*verilator public*/ for use by application code
    
    // CONSTRUCTORS
  private:
    VPALROM& operator= (const VPALROM&);	///< Copying not allowed
    VPALROM(const VPALROM&);	///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible WRT DPI scope names.
    VPALROM(const char* name="TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~VPALROM();
    /// Trace signals in the model; called by application code
    void trace (VerilatedVcdC* tfp, int levels, int options=0);
    
    // USER METHODS
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval();
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(VPALROM__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(VPALROM__Syms* symsp, bool first);
  private:
    static QData	_change_request(VPALROM__Syms* __restrict vlSymsp);
  public:
    static void	_combo__TOP__1(VPALROM__Syms* __restrict vlSymsp);
    static void	_eval(VPALROM__Syms* __restrict vlSymsp);
    static void	_eval_initial(VPALROM__Syms* __restrict vlSymsp);
    static void	_eval_settle(VPALROM__Syms* __restrict vlSymsp);
    static void	traceChgThis(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__2(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis__1(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis__1(VPALROM__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceInit (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceFull (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceChg  (VerilatedVcd* vcdp, void* userthis, uint32_t code);
} VL_ATTR_ALIGNED(128);

#endif  /*guard*/
