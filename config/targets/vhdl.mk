
BD_TARGET := $(BD_FAUST2VHDL)

get_nchannels_i := $(call set_preprocessor_data,$(INPUTS))
get_nchannels_o := $(call set_preprocessor_data,$(OUTPUTS))
PROJECT_DEPENDENCIES += $(VHDL_TARGET)
SCRIPT_HOST_CONFIG   :=  faust2vhdl
RTL_SOURCES	 += $(VHDL_TARGET)
RTL_SOURCES	 += $(wildcard $(SOURCE_RTL_DIR)/faust2vhdl/*.vhd)
