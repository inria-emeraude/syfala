# Change this macro to change VHDL Simulation
TARGET = I2S-emul-faust
#TARGET = I2S
#TARGET = emul-faust

ifeq ($(TARGET),I2S-emul-faust)
	TESTBENCH = test_bench_I2S_emul_faust
	FILES =   emul_faust.vhd   i2s_transceiver.vhd $(TESTBENCH_SRC)
endif
ifeq ($(TARGET),I2S)
	TESTBENCH = test_bench_I2S
	FILES =      i2s_transceiver.vhd $(TESTBENCH_SRC)
endif
ifeq ($(TARGET),emul-faust)
	TESTBENCH = test_bench_emul_faust
	FILES =      emul_faust.vhd $(TESTBENCH_SRC)
endif

TESTBENCHDIR = ./
VHDLEX = .vhd
TESTBENCH_SRC=$(TESTBENCHDIR)$(TESTBENCH)$(VHDLEX)


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
	$(GHDL_CMD) -r  $(GHDL_FLAGS) --workdir=sim --work=work $(TESTBENCH) --vcd=$(SIMDIR)/$(TESTBENCH).vcd --stop-time=1ms


view :
	$(WAVEFORM_VIEWER) $(SIMDIR)/$(TESTBENCH).vcd                           
 
clean :
	$(GHDL_CMD) --clean --workdir=sim

distclean: clean
	 \rm -rf *~ $(SIMDIR)/* $(SIMDIR)/work-obj93.cf src/*.o src/*~ src/work-obj93.cf testbench/*~ 

