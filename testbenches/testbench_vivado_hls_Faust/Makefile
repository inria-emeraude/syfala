DSP ?= sawtooth.dsp
CFLAGS=-I /home/trisset/technical/vivadoHLS/Vivado/Vivado/2019.1/include/

all: csim_test test

test: csim_test
	./csim_test
	diff debug-440.000000 debug-faust.txt

csim_test: faust_v4.o testbench_faust_v4.o
	g++ faust_v4.o testbench_faust_v4.o -o csim_test

%.o: %.cpp
	g++ ${CFLAGS} -c -o $@ $<

faust_v4.cpp: $(DSP) fpga.cpp
	faust -lang c -light -os -a fpga.cpp -o $@ $(DSP)

clean:
	\rm -rf *.o *~ csim_test debug-faust.txt
