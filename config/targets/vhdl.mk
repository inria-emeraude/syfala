
BD_TARGET := $(BD_FAUST2VHDL)

get_nchannels_i := $(call set_preprocessor_data,$(INPUTS))
get_nchannels_o := $(call set_preprocessor_data,$(OUTPUTS))

PROJECT_DEPENDENCIES += $(VHDL_TARGET)
PROJECT_DEPENDENCIES += $(HLS_INCLUDES)

SCRIPT_HOST_CONFIG  :=  faust2vhdl
HOST_MAIN_SOURCE ?= $(ARM_BAREMETAL_CPP_MAIN_FAUST2VHDL)
RTL_SOURCES	 += $(VHDL_TARGET)
RTL_SOURCES	 += $(wildcard $(SOURCE_RTL_DIR)/faust2vhdl/*.vhd)
