
mydsp?=virtualAnalog
DSP = ../faust/$(mydsp).dsp
ORIGIN_DIR=${PWD}

RM := rm -rf


all: bitstream app boot_files


#compilation stages 
project: build/faust_v6_project/faust_v6_project.xpr
ip: build/faust_v6_ip/faust_v6/impl/ip/faust_v6_info.xml
bitstream: build/faust_v6_project/faust_v6_project.runs/impl_1/main_wrapper.bit
faust: build/faust_v6_ip/faust_v6.cpp
arm_driver: build/faust_v6_application/generated_src/faust_v6_app.cpp
app: arm_driver build/sw_export/faust_v6_app.elf 
boot_files: build/sw_export/BOOT.bin

clean:
	rm -rf build
	rm -rf vivado_*
	rm -rf vivado.*
	rm -rf vitis_*
	rm -rf *~ *.log .Xil
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) 


# build DSP C++ file intended to build IP 
build/faust_v6_ip/faust_v6.cpp: $(DSP) fpga.cpp
	@echo "***************** Faust IP generation ***********************"
	@echo "*****************  $(DSP) -> faust_v6.cpp  ******************"
	mkdir -p build/faust_v6_ip
	faust -lang c -light -os2 -a fpga.cpp -uim -mcd 0 -o $@ $(DSP)
	cp configFAUST.h build/faust_v6_ip

# build ARM control application C++ file 
build/faust_v6_application/generated_src/faust_v6_app.cpp: $(DSP) arm.cpp
	@echo "********************* $(DSP) -> faust_v6_app.cpp **************"
	rm -rf build/faust_v6_application
	mkdir -p build/faust_v6_application && mkdir -p build/faust_v6_application/generated_src
	faust -i -lang cpp -os2 -mcd 0 -uim -a arm.cpp $(DSP) -o $@

# running hls on DSP C++ file: building Faust IP
build/faust_v6_ip/faust_v6/impl/ip/faust_v6_info.xml: build/faust_v6_ip/faust_v6.cpp
	@echo "*********** HLS:  faust_v6 IP generation ************"
	@ echo "Utilisation de Vitis_HLS"
	cd build && vitis_hls -f ../scripts/ip_v6.tcl


#building vivado project Faust_v6_project.xpr
build/faust_v6_project/faust_v6_project.xpr: build/faust_v6_ip/faust_v6/impl/ip/faust_v6_info.xml ./scripts/project_v6.tcl
	@echo "****************************************************"
	@echo "******************* PROJECT CREATION ***************"
	mkdir -p build
	cd build && vivado -mode batch -source ../scripts/project_v6.tcl -tclargs --origin_dir ${ORIGIN_DIR}

#running vivado project Faust_v6_project.xpr producing bitstream
build/faust_v6_project/faust_v6_project.runs/impl_1/main_wrapper.bit: build/faust_v6_project/faust_v6_project.xpr
	@echo "****************************************************"
	@echo "********************** SYNTHESIS ******************"
	cd build && vivado -mode batch -source ../scripts/build_project_v6.tcl
	@echo "*********** SYNTHESIS DONE ************************"
	@echo "**** main_wapprer.xsa generated in hw_export ******"
	mkdir -p backup && cp build/hw_export/main_wrapper.xsa backup/$(mydsp)_$(shell date +%FT%T).xsa
	@ date

#Compiling control application C++ program  
build/sw_export/faust_v6_app.elf: build/hw_export/main_wrapper.xsa build/faust_v6_application/generated_src/faust_v6_app.cpp
	@echo "****************************************************"
	@echo "********** ARM Driver code compilation:**************" 
	xsct ./scripts/application_v6.tcl
	cd build && mkdir -p sw_export && mkdir -p sw_export/src
	cp build/faust_v6_application/faust_v6_app/src/* build/sw_export/src
	cp build/faust_v6_application/faust_v6_app/Debug/faust_v6_app.elf build/sw_export
	@echo "****** faust_v6_app.elf generated in sw_export ***"
	@ echo -e "\a"  #produce a beep



#needed if you want to recompile the application
remove_app:
	 rm -rf build/sw_export
	 rm -rf build/faust_v6_application
	 rm -rf build/GUI


#flash bitstream, download ARM application and boot
boot: build/sw_export/faust_v6_app.elf
	@echo "************ BOOT IN STANDALONE (JTAG) ******************"
	xsct ./scripts/program_jtag.tcl faust_v6_app.elf
	@ date
	@echo -e "CONTROLS DESCRIPTION:"
	@ grep 'hslider(\|button(' $(DSP) | awk -F 'hslider|button' '{ print $$2 }' | awk -F ')' '{print $$1 ")"}'

#boot from BOOT.bin
binary_dow: build/sw_export/BOOT.bin
	@echo "************ BOOT BOOT.bin with JTAG (not functional)******************"
	xsct ./scripts/program_jtag.tcl build/sw_export/BOOT.bin
	@ date
	@echo -e "CONTROLS DESCRIPTION:"
	@ grep 'hslider(\|button(' $(DSP) | awk -F 'hslider|button' '{ print $$2 }' | awk -F ')' '{print $$1 ")"}'

#??
program_flash: ./build/sw_export/BOOT.bin
	@echo "************ PROGRAM FLASH MEMORY ******************"
	@echo "[WARNING] Please ensure that JP5 is on 'JTAG' position during upload, not 'QSPI'"
	xsct ./scripts/program_flash.tcl
	@echo "[INFO] You can now put JP5 on 'QSPI' position"
	@ date

#build GUI controlUI running on host computer
build/GUI/controlUI.cpp: src/UI/pcUI.cpp $(DSP)
	mkdir -p build/GUI
	faust -a src/UI/pcUI.cpp $(DSP) -o build/GUI/controlUI.cpp

#compile GUI controlUI running on host computer
build/GUI/controlUI: build/GUI/controlUI.cpp
	@echo "************ GENERATE GUI for CONTROLLER ******************"
	mkdir -p build/GUI
	c++ -std=c++11 build/GUI/controlUI.cpp src/UI/pcUartInterface.h -Isrc/UI `pkg-config --cflags --libs gtk+-2.0` -o build/GUI/controlUI

#run GUI controlUI running on host computer
controlUI: build/GUI/controlUI
	@echo "************ OPEN GUI ******************"
	@ date
	./build/GUI/controlUI

#generates BOOT.bin image
build/sw_export/BOOT.bin: build/sw_export/faust_v6_app.elf
	@echo "************ GENERATE BOOT.BIN FILE ******************"
	bootgen -image ./scripts/bin_generator.bif -arch zynq -o ./build/sw_export/BOOT.bin -w on
	@ date

#show vitis_hls report after HLS
rpt: build/faust_v6_ip/faust_v6/syn/report
	cp build/faust_v6_ip/faust_v6/syn/report/faust_v6_csynth.rpt backup/$(mydsp)_$(shell date +%FT%T).rpt
	less build/faust_v6_ip/faust_v6/syn/report/faust_v6_csynth.rpt



dummy:


.PHONY: all clean dependents


