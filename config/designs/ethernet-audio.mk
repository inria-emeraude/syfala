
CONFIG              += ETHERNET
ETHERNET            := 1
PREPROCESSOR_HLS    := TRUE
PREPROCESSOR_I2S    := TRUE
LINUX               := TRUE

ifeq (TDM, $(filter TDM, $(CONFIG))) # --------------------------------
    BD_TARGET        := $(SOURCE_BD_DIR)/ethernet_tdm.tcl
    I2S_SOURCE       := $(SOURCE_I2S_DIR)/i2s_template_ethernet_tdm.vhd
    CONSTRAINT_FILE  := $(SOURCE_CONSTRAINTS_DIR)/zybo_tdm.xdc
else # ----------------------------------------------------------------
    BD_TARGET   := $(SOURCE_BD_DIR)/ethernet.tcl
    I2S_SOURCE  := $(SOURCE_I2S_DIR)/i2s_template_ethernet.vhd
endif # ---------------------------------------------------------------

$(call static_ok, - $(B)CONFIG_EXPERIMENTAL_ETHERNET$(N) is $(B)ON$(N))

HLS_FLAGS_INCLUDE	+= "-I$(BUILD_INCLUDE_DIR)"
ETHERNET_HLS_INCLUDES    += $(BUILD_SYFALA_CONFIG_H)
ETHERNET_HLS_INCLUDES    += $(BUILD_SYFALA_UTILITIES_H)
ETHERNET_HLS_SOURCE	:= $(SOURCE_HLS_DIR)/ethernet.cpp
BUILD_ETHERNET_HLS_DIR	:= $(BUILD_DIR)/ethernet
ETHERNET_HLS_TARGET	:= $(BUILD_ETHERNET_HLS_DIR)/ethernet.cpp
ETHERNET_HLS_TOP_LEVEL	:= eth_audio
ETHERNET_HLS_OUTPUT	:= $(BUILD_ETHERNET_HLS_DIR)/$(ETHERNET_HLS_TOP_LEVEL)/impl/vhdl/$(ETHERNET_HLS_TOP_LEVEL).vhd
PROJECT_DEPENDENCIES    += $(ETHERNET_HLS_OUTPUT)
#ALPINE_PACKAGES         += cargo
ALPINE_PACKAGES		+= jack-dev

# -----------------------------------------------------------------------------------
ETHERNET_HLS_COMMAND := cd $(BUILD_DIR);					    \
	       open_project -reset $(notdir $(BUILD_ETHERNET_HLS_DIR));             \
               add_files $(ETHERNET_HLS_TARGET) -cflags $(HLS_FLAGS_INCLUDE);	    \
	       set_top $(ETHERNET_HLS_TOP_LEVEL);                                   \
	       open_solution -reset $(ETHERNET_HLS_TOP_LEVEL) -flow_target vivado;  \
	       set_part $(BOARD_PART);						    \
	       create_clock -period $(HLS_CLOCK_PERIOD);			    \
	       csynth_design;							    \
	       export_design -rtl vhdl -format ip_catalog;			    \
	       exit;
# -----------------------------------------------------------------------------------

$(ETHERNET_HLS_OUTPUT): $(ETHERNET_HLS_INCLUDES) $(ETHERNET_HLS_SOURCE) $(HLS_TARGET_FILE)
	@mkdir -p $(BUILD_ETHERNET_HLS_DIR)
	@cp -r $(ETHERNET_HLS_SOURCE) $(ETHERNET_HLS_TARGET)
	$(call shell_info, Running $(B)preprocessor$(N) on      \
                           $(B)HLS$(N) target file              \
                           ($(notdir $(ETHERNET_HLS_TARGET))))
	@tclsh $(SCRIPT_PREPROCESSOR) --hls                     \
                            $(ETHERNET_HLS_TARGET)              \
                            $(shell $(get_nchannels_i))         \
                            $(shell $(get_nchannels_o))         \
                            0 0 0                               \
                            $(MULTISAMPLE)
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file    \
                           $(notdir $(ETHERNET_HLS_TARGET)))
	@echo '$(ETHERNET_HLS_COMMAND)' | $(HLS_EXEC) -i
	$(call shell_ok, High-level synthesis done)
