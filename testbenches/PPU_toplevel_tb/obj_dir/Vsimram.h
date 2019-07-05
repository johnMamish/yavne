// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _Vsimram_H_
#define _Vsimram_H_

#include "verilated.h"
class Vsimram__Syms;
class VerilatedVcd;

//----------

VL_MODULE(Vsimram) {
  public:
    // CELLS
    // Public to allow access to /*verilator_public*/ items;
    // otherwise the application code can consider these internals.
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clock,0,0);
    VL_IN8(reset,0,0);
    VL_IN8(we,0,0);
    VL_IN8(w_data,7,0);
    VL_OUT8(r_data,7,0);
    //char	__VpadToAlign5[1];
    VL_IN16(w_addr,14,0);
    VL_IN16(r_addr,14,0);
    //char	__VpadToAlign10[2];
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    VL_SIGW(v__DOT__palram,119,0,4);
    VL_SIG8(v__DOT__index,4,0);
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    VL_SIG8(v__DOT____Vlvbound1,7,0);
    VL_SIG8(__Vclklast__TOP__clock,0,0);
    //char	__VpadToAlign38[2];
    VL_SIG(__Vm_traceActivity,31,0);
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vsimram__Syms*	__VlSymsp;		// Symbol table
    
    // PARAMETERS
    // Parameters marked /*verilator public*/ for use by application code
    
    // CONSTRUCTORS
  private:
    Vsimram& operator= (const Vsimram&);	///< Copying not allowed
    Vsimram(const Vsimram&);	///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible WRT DPI scope names.
    Vsimram(const char* name="TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vsimram();
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
    static void _eval_initial_loop(Vsimram__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vsimram__Syms* symsp, bool first);
  private:
    static QData	_change_request(Vsimram__Syms* __restrict vlSymsp);
  public:
    static void	_combo__TOP__2(Vsimram__Syms* __restrict vlSymsp);
    static void	_eval(Vsimram__Syms* __restrict vlSymsp);
    static void	_eval_initial(Vsimram__Syms* __restrict vlSymsp);
    static void	_eval_settle(Vsimram__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__1(Vsimram__Syms* __restrict vlSymsp);
    static void	traceChgThis(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__2(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__3(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis__1(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis__1(Vsimram__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceInit (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceFull (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceChg  (VerilatedVcd* vcdp, void* userthis, uint32_t code);
} VL_ATTR_ALIGNED(128);

#endif  /*guard*/
