
FAUST ?= faust
BD_TARGET := $(BD_FAUST2VHDL)

get_nchannels_i := $(call set_preprocessor_data,$(INPUTS))
get_nchannels_o := $(call set_preprocessor_data,$(OUTPUTS))

FAUST_VHDL_OUTPUT       := $(BUILD_RTL_DIR)/faust.vhd
I2S_DEPENDENCIES 		:= $(FAUST_VHDL_OUTPUT)
PROJECT_DEPENDENCIES    += $(FAUST_VHDL_OUTPUT)
HOST_MAIN_SOURCE        ?= $(ARM_BAREMETAL_CPP_MAIN_FAUST2VHDL)
SCRIPT_HOST_CONFIG      :=  faust2vhdl
RTL_SOURCES				+= $(wildcard $(SOURCE_RTL_DIR)/faust2vhdl/*.vhd)

$(FAUST_VHDL_OUTPUT): $(BUILD_FAUST_DSP_TARGET) $(HLS_INCLUDES)
	$(call shell_info, Generating $(B)VHDL$(N) source from   \
	                   the $(B)Faust$(N) compiler)
	@mkdir -p $(BUILD_RTL_DIR)
	$(FAUST) $(FAUST_DSP_TARGET)	\
	    -lang vhdl			    	\
	    -o $(FAUST_VHDL_OUTPUT)

# $(FAUST_VHDL_OUTPUT): $(BUILD_FAUST_DSP_TARGET) $(HLS_INCLUDES)
# 	$(call shell_info, Generating $(B)HLS$(N) source from   \
# 	                   the $(B)Faust$(N) compiler)
# 	@mkdir -p $(BUILD_DIR)/rtl
# 	@cp $(SOURCE_DIR)/rtl/faust2vhdl/faust.vhd	\
# 	    $(FAUST_VHDL_OUTPUT)
