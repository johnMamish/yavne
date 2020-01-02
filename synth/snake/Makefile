######################################################################
#
# DESCRIPTION: Verilator Example: Small Makefile
#
# This calls the object directory makefile.  That allows the objects to
# be placed in the "current directory" which simplifies the Makefile.
#
# Copyright 2003-2018 by Wilson Snyder. This program is free software; you can
# redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.
#
######################################################################
# Check for sanity to avoid later confusion


SOURCE_DIR := $(HOME)/yavne/verilog

ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif


TB := snake_tb.cpp
SRC := PPU.v PALROM.v simram.v se.v PPU2VGA_wrapper.v
TOP := toplevel


######################################################################

# This is intended to be a minimal example.  Before copying this to start a
# real project, it is better to start with a more complete example,
# e.g. examples/tracing_c.

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package inatall, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

VFLAGS =  --MMD -O3 --trace --cc
PREFIX = verilated_snake

default:

	@echo "-- VERILATE ----------------"
	$(VERILATOR) $(VFLAGS) --exe -I$(SOURCE_DIR) $(TOP).v --prefix $(PREFIX) --top-module ricoh_2a03_synth $(TB) 
	@echo "-- COMPILE -----------------"
	$(MAKE) -j 4 -C obj_dir -f $(PREFIX).mk
	
######################################################################

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf obj_dir *.log *.dmp *.vpd core
