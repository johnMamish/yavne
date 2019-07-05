#include <verilated_vcd_c.h>
#include "verilated.h"



template<typename MODULE>	struct TESTBENCH {
	unsigned long	m_tickcount;
	MODULE	*m_core;
    VerilatedVcdC * m_trace; 


	TESTBENCH(void) {
        Verilated::traceEverOn(true);
		m_core = new MODULE;
		m_tickcount = 0l;
        m_trace = new VerilatedVcdC;
        m_core->trace(m_trace,99);
        m_trace->open("trace.vcd"); 
    
	}

	virtual ~TESTBENCH(void) {
		delete m_core;
		m_core = NULL;
	}

	virtual void	reset(void) {
		m_core->reset = 1;
		// Make sure any inheritance gets applied
		this->tick();
		m_core->reset = 0;
	}

	virtual void	tick(void) {
		// Increment our own internal time reference
		m_tickcount++;

		// Make sure any combinatorial logic depending upon
		// inputs that may have changed before we called tick()
		// has settled before the rising edge of the clock.
		m_core->clock = 0;
        m_core->CLOCK_50 = 0;
		m_core->eval();
        m_trace->dump(10*m_tickcount-2);



		// Toggle the clock

		// Rising edge
		m_core->clock = 1;
        m_core->CLOCK_50 = 1;
		m_core->eval();
        m_trace->dump(10*m_tickcount);
		
        // Falling edge
		m_core->clock = 0;
        m_core->CLOCK_50 = 0;
		m_core->eval();
        m_trace->dump(10*m_tickcount+5);
        m_trace->flush();

	}


	virtual bool	done(void) { return (Verilated::gotFinish()); }
};

