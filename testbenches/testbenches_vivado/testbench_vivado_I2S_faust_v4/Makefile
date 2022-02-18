DSP ?= sawtooth.dsp
ORIGIN_DIR=${PWD}

all: bitstream
project: build/faust_v4_project/faust_v4_project.xpr
ip: build/faust_v4_ip/faust_v4/impl/ip/faust_v4_info.xml
bitstream: build/faust_v4_project/faust_v4_project.runs/impl_1/main_wrapper.bit

clean:
	rm -rf build
	rm -rf vivado_*
	rm -rf vivado.*
	rm -rf *~

build/faust_v4_ip/faust_v4.cpp: $(DSP) fpga.cpp
	mkdir -p build/faust_v4_ip
	faust -lang c -light -os -a fpga.cpp -o $@ $(DSP)

build/faust_v4_ip/faust_v4/impl/ip/faust_v4_info.xml: build/faust_v4_ip/faust_v4.cpp  
	cd build && vivado_hls -f ../run_hls_v4.tcl

build/faust_v4_project/faust_v4_project.xpr:  build/faust_v4_ip/faust_v4/impl/ip/faust_v4_info.xml project_v4.tcl
	mkdir -p build
	cd build && vivado -mode batch -source ../project_v4.tcl -tclargs --origin_dir ${ORIGIN_DIR}

build/faust_v4_project/faust_v4_project.runs/impl_1/main_wrapper.bit:  build/faust_v4_project/faust_v4_project.xpr
	cd build && vivado -mode batch -source ../build.tcl
	echo -e "\a"  #produce a beep


program: #build/faust_v4_project/faust_v4_project.runs/impl_1/main_wrapper.bit
	vivado -mode batch -source program.tcl



dummy:
