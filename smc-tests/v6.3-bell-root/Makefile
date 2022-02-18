

mydsp?=bellNNNN
DSP = ../faust/$(mydsp).dsp
ORIGIN_DIR=${PWD}


#SET PETALINUXDIR here:
#PETALINUX_DIR=${ORIGIN_DIR}/../petalinux
PETALINUX_DIR=${ORIGIN_DIR}/../petalinux

#SET ZYBO_IP_ADDRESS here:
#ZYBO_IP_ADDRESS=192.168.1.45

RM := rm -rf


all: bitstream app boot_files

full_petalinux: bitstream app petalinux_build boot
# full compilation:
#    set up PETALINUX_DIR and ZYBO_IP_ADDRESS variable
#    make full
#    make download
#    make connect

#compilation stages 
project: build/faust_v6_project/faust_v6_project.xpr
ip: build/faust_v6_ip/faust_v6/impl/ip/faust_v6_info.xml
bitstream: build/faust_v6_project/faust_v6_project.runs/impl_1/main_wrapper.bit
faust: build/faust_v6_ip/faust_v6.cpp
arm_driver: build/faust_v6_application/generated_src/faust_v6_app.cpp
app: arm_driver build/sw_export/faust_v6_app.elf 
boot_files: build/sw_export/BOOT.bin
petalinux_create:${PETALINUX_DIR}/petalinux_syfala/config.project
petalinux_build:${PETALINUX_DIR}/petalinux_syfala/images/linux/system.bit

clean:
	rm -rf build
	rm -rf vivado_*
	rm -rf vivado.*
	rm -rf vitis_*
	rm -rf *~ *.log .Xil
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) 


build/faust_v6_ip/faust_v6.cpp: $(DSP) fpga.cpp
	@echo "***************** Faust IP generation ***********************"
	@echo "*****************  $(DSP) -> faust_v6.cpp  ******************"
	mkdir -p build/faust_v6_ip
	faust -lang c -light -os2 -a fpga.cpp -uim -mcd 0 -o $@ $(DSP)
	cp configFAUST.h build/faust_v6_ip

build/faust_v6_application/generated_src/faust_v6_app.cpp: $(DSP) arm.cpp
	@echo "********************* $(DSP) -> faust_v6_app.cpp **************"
	rm -rf build/faust_v6_application
	mkdir -p build/faust_v6_application && mkdir -p build/faust_v6_application/generated_src
	faust -i -lang cpp -os2 -mcd 0 -a arm.cpp $(DSP) -o $@
#cp configFAUST.h build/faust_v6_application/generated_src
#cp src/UI/UartReceiverUI.h build/faust_v6_application/generated_src

build/faust_v6_ip/faust_v6/impl/ip/faust_v6_info.xml: build/faust_v6_ip/faust_v6.cpp
	@echo "*********** HLS:  faust_v6 IP generation ************"
	@ echo "Utilisation de Vitis_HLS"
	cd build && vitis_hls -f ../scripts/ip_v6.tcl


build/faust_v6_project/faust_v6_project.xpr: build/faust_v6_ip/faust_v6/impl/ip/faust_v6_info.xml ./scripts/project_v6.tcl
	@echo "****************************************************"
	@echo "******************* PROJECT CREATION ***************"
	mkdir -p build
	cd build && vivado -mode batch -source ../scripts/project_v6.tcl -tclargs --origin_dir ${ORIGIN_DIR}

build/faust_v6_project/faust_v6_project.runs/impl_1/main_wrapper.bit: build/faust_v6_project/faust_v6_project.xpr
	@echo "****************************************************"
	@echo "********************** SYNTHESIS ******************"
	cd build && vivado -mode batch -source ../scripts/build_project_v6.tcl
	@echo "*********** SYNTHESIS DONE ************************"
	@echo "**** main_wapprer.xsa generated in hw_export ******"
	mkdir -p backup && cp build/hw_export/main_wrapper.xsa backup/$(mydsp)_$(shell date +%FT%T).xsa
	@ date

build/sw_export/faust_v6_app.elf: build/hw_export/main_wrapper.xsa build/faust_v6_application/generated_src/faust_v6_app.cpp
	@echo "****************************************************"
	@echo "********** ARM Driver code compilation:**************" 
	xsct ./scripts/application_v6.tcl
	cd build && mkdir -p sw_export && mkdir -p sw_export/src
	cp build/faust_v6_application/faust_v6_app/src/* build/sw_export/src
	cp build/faust_v6_application/faust_v6_app/Debug/faust_v6_app.elf build/sw_export
	@echo "****** faust_v6_app.elf generated in sw_export ***"
	@ echo -e "\a"  #produce a beep



remove_app:
	 rm -rf build/sw_export
	 rm -rf build/faust_v6_application



flash_bitstream: build/faust_v6_project/faust_v6_project.runs/impl_1/main_wrapper.bit
	@echo "************ FLASHING BIT STREAM $(DSP) ******************"
	@echo "[WARNING] This Command is deprecated, are you sure of what you're doing?"
	@echo "[WARNING] Program only Hardware"
	vivado -mode batch -source ./scripts/program_bitstream.tcl
	@ date

standalone_boot: build/sw_export/faust_v6_app.elf
	@echo "************ BOOT IN STANDALONE (JTAG) ******************"
	xsct ./scripts/program_jtag.tcl faust_v6_app.elf
	@ date
	@echo -e "CONTROLS DESCRIPTION:"
	@ grep 'hslider(\|button(' $(DSP) | awk -F 'hslider|button' '{ print $$2 }' | awk -F ')' '{print $$1 ")"}'

binary_dow: build/sw_export/BOOT.bin
	@echo "************ BOOT BOOT.bin with JTAG (not functional)******************"
	xsct ./scripts/program_jtag.tcl build/sw_export/BOOT.bin
	@ date
	@echo -e "CONTROLS DESCRIPTION:"
	@ grep 'hslider(\|button(' $(DSP) | awk -F 'hslider|button' '{ print $$2 }' | awk -F ')' '{print $$1 ")"}'

program_flash: ./build/sw_export/BOOT.bin
	@echo "************ PROGRAM FLASH MEMORY ******************"
	@echo "[WARNING] Please ensure that JP5 is on 'JTAG' position during upload, not 'QSPI'"
	xsct ./scripts/program_flash.tcl
	@echo "[INFO] You can now put JP5 on 'QSPI' position"
	@ date

build/GUI/controlUI.cpp: src/UI/pcUI.cpp $(DSP)
	mkdir -p build/GUI
	faust -a src/UI/pcUI.cpp $(DSP) -o build/GUI/controlUI.cpp

build/GUI/controlUI: build/GUI/controlUI.cpp
	@echo "************ GENERATE GUI for CONTROLLER ******************"
	mkdir -p build/GUI
	c++ -std=c++11 build/GUI/controlUI.cpp src/UI/pcUartInterface.h -Isrc/UI src/UI/serialLib/serialib.cpp -Isrc/UI/serialLib `pkg-config --cflags --libs gtk+-2.0` -o build/GUI/controlUI

controlUI: build/GUI/controlUI
	@echo "************ OPEN GUI ******************"
	@ date
	./build/GUI/controlUI

build/sw_export/BOOT.bin: build/sw_export/faust_v6_app.elf
	@echo "************ GENERATE BOOT.BIN FILE ******************"
	bootgen -image ./scripts/bin_generator.bif -arch zynq -o ./build/sw_export/BOOT.bin -w on
	@ date

rpt: build/faust_v6_ip/faust_v6/syn/report
	cp build/faust_v6_ip/faust_v6/syn/report/faust_v6_csynth.rpt backup/$(mydsp)_$(shell date +%FT%T).rpt
	less build/faust_v6_ip/faust_v6/syn/report/faust_v6_csynth.rpt


################### all PETALINUX below ##############

petalinux_ssh_download: 
ifeq ($(ZYBO_IP_ADDRESS),)
	@echo ERROR: ZYBO_IP_ADDRESS undefined
else
	scp build/sw_export/faust_v6_app.elf root@$(ZYBO_IP_ADDRESS):
endif

petalinux_ssh_connect:
ifeq ($(ZYBO_IP_ADDRESS),)
	@echo ERROR: ZYBO_IP_ADDRESS undefined
else
	ssh root@${ZYBO_IP_ADDRESS}
endif

${PETALINUX_DIR}/petalinux_syfala/config.project:
ifeq ($(PETALINUX_DIR),)
	@ echo ERROR: PETALINUX_DIR undefined
else
	@echo "****************************************************"
	@echo "****** CREATING PETALINUX  ******************"
	@echo "** in: ${PETALINUX_DIR}   ***"
	cd ${PETALINUX_DIR} \
	&& petalinux-create -t project -s ${PETALINUX_DIR}/src/syfalaBSP.bsp

endif

remove_petalinux:
	rm -r ${PETALINUX_DIR}/petalinux_syfala

${PETALINUX_DIR}/petalinux_syfala/images/linux/system.bit: build/hw_export/main_wrapper.xsa
ifeq ($(PETALINUX_DIR),)
	@ echo ERROR: PETALINUX_DIR undefined
else
	@echo "*********************************************"
	@echo "****** BUILDING PETALINUX  ******************"
	@echo "** in: ${PETALINUX_DIR}   ***"
	cp build/hw_export/main_wrapper.xsa ${PETALINUX_DIR}/src/main_wrapper.xsa
	cd ${PETALINUX_DIR}/petalinux_syfala \
	&& petalinux-config --get-hw-description ${PETALINUX_DIR}/src/ --silentconfig \
	&& petalinux-config -c kernel --silentconfig \
	&& petalinux-config -c rootfs  --silentconfig
	cp src/system-user.dtsi ${PETALINUX_DIR}/petalinux_syfala/project-spec/meta-user/recipes-bsp/device-tree/files/
	cd ${PETALINUX_DIR}/petalinux_syfala && petalinux-build
	@echo "****** PETALINUX BUILD FINISHED ***************"

endif

petalinux_boot:
ifeq ($(PETALINUX_DIR),)
	@ echo ERROR: PETALINUX_DIR undefined
else
	cd ${PETALINUX_DIR}/petalinux_syfala; petalinux-boot --jtag --fpga --kernel
endif

petalinux_sd:
ifeq ($(PETALINUX_DIR),)
	@ echo ERROR: PETALINUX_DIR undefined
else
	@echo "*********************************************"
	@echo "****** BUILDING SD CARD FILES  **************"
	cd build && mkdir -p sd_card
	cp ${PETALINUX_DIR}/petalinux_syfala/images/linux/boot.scr build/sd_card/
	cp ${PETALINUX_DIR}/petalinux_syfala/images/linux/image.ub build/sd_card/
	cp ${PETALINUX_DIR}/petalinux_syfala/images/linux/rootfs.cpio.gz build/sd_card/   
	cp build/sw_export/faust_v6_app.elf build/sd_card/ 
	cd ${PETALINUX_DIR}/petalinux_syfala \
	&& petalinux-package --boot --force --fsbl ${PETALINUX_DIR}/petalinux_syfala/images/linux/zynq_fsbl.elf --fpga ${PETALINUX_DIR}/petalinux_syfala/project-spec/hw-description/main_wrapper.bit --u-boot
	cp ${PETALINUX_DIR}/petalinux_syfala/images/linux/BOOT.BIN build/sd_card/   

endif	

dummy:


.PHONY: all clean dependents


