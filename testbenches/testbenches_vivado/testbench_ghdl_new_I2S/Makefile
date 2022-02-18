# vhdl files
TESTBENCH = test_bench_i2s
TESTBENCHDIR = ./
VHDLEX = .vhd
TESTBENCH_SRC=$(TESTBENCHDIR)$(TESTBENCH)$(VHDLEX)

FILES =   i2s_tranciever.vhd   $(TESTBENCH_SRC)
COMPONENTS = i2s_tranciever
 
#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = -fsynopsys #-ieee=synopsys --warn-no-vital-generic
 
SIMDIR = sim
# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=10us
 
WAVEFORM_VIEWER = gtkwave
 
all: $(SIMDIR) analyze compile  link

sim:
	mkdir -p sim

analyze:
	$(GHDL_CMD) -a  $(GHDL_FLAGS) --workdir=sim --work=work $(FILES)

compile : analyze
	mkdir -p sim
	$(GHDL_CMD) -e $(GHDL_FLAGS) --workdir=sim --work=work  $(TESTBENCH) 

link: compile
	$(GHDL_CMD) -r  $(GHDL_FLAGS) --workdir=sim --work=work $(TESTBENCH) --vcd=$(SIMDIR)/$(TESTBENCH).vcd --stop-time=200us


view :
	$(WAVEFORM_VIEWER) $(SIMDIR)/$(TESTBENCH).vcd                           
 
clean :
	$(GHDL_CMD) --clean --workdir=sim

distclean: clean
	 \rm -rf *~ $(SIMDIR)/* $(SIMDIR)/work-obj93.cf src/*.o src/*~ src/work-obj93.cf testbench/*~ 

