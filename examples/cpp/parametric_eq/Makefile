PROJECT_NAME = parametric_eq
BOARD = Z20
VITIS_VERSION = 2022.2

# change to the directory where syfala is
SYFALA_DIR = /home/syfala/syfala
WORKING_DIR = $(SYFALA_DIR)/examples/cpp/$(PROJECT_NAME)

# compiles the example with the arm target for osc integration
main: 
	syfala $(PROJECT_NAME)_hls.cpp --board $(BOARD) --arm-target $(PROJECT_NAME)_arm.cpp --linux --xversion $(VITIS_VERSION)
	# sudo cp -r $(SYFALA_DIR)/build-linux/output/root/home/syfala/$(PROJECT_NAME)_hls $(WORKING_DIR)/../builds/$(PROJECT_NAME)_hls

# only compiles the HLS
hls: 
	syfala $(PROJECT_NAME)_hls.cpp --hls --umo --board $(BOARD) --xversion $(VITIS_VERSION)

hls-accurate: 
	syfala $(PROJECT_NAME)_hls.cpp --hls --umo --accurate-use --board $(BOARD) --xversion $(VITIS_VERSION)

# after compilation, mounts the result on the embedded linux (via scp so an ethernet connection is needed)
mount:
	scp -r $(SYFALA_DIR)/build-linux/output/root/home/syfala/$(PROJECT_NAME)_hls root@192.168.0.2:/home/syfala/

# compiles the HLS and runs csim to test the algorithm
csim:
	cd $(SYFALA_DIR)
	syfala $(WORKING_DIR)/$(PROJECT_NAME)_hls.cpp --board $(BOARD) --csim $(WORKING_DIR)/$(PROJECT_NAME)_csim.cpp \
		--csim-inputs $(SYFALA_DIR)/tests/stimuli --csim-iter 48000 --xversion $(VITIS_VERSION)
	cp -r $(SYFALA_DIR)/reports/$(PROJECT_NAME)_hls/ $(WORKING_DIR)/outputs
	cd $(WORKING_DIR)