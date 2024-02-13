
CONFIG              += SIGMA_DELTA
SIGMA_DELTA         := 1
SAMPLE_RATE         := 5000000
SAMPLE_WIDTH        := 16
PREPROCESSOR_HLS    := TRUE
PREPROCESSOR_I2S    := TRUE
BD_TARGET           := $(BD_SIGMA_DELTA)
#BD_TARGET           := $(SOURCE_BD_DIR)/sigma-delta-hls.tcl
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_first.vhd
RTL_SOURCES	    += $(wildcard $(SOURCE_RTL_DIR)/faust2vhdl/*.vhd)

$(call static_ok, - $(B)CONFIG_EXPERIMENTAL_SIGMA_DELTA$(N) is $(N)ON$(N))

SIGMA_DELTA_HLS_SOURCE	    := $(SOURCE_HLS_DIR)/sigma_delta.cpp
BUILD_SIGMA_DELTA_HLS_DIR   := $(BUILD_DIR)/sigma_delta
SIGMA_DELTA_HLS_TARGET	    := $(BUILD_SIGMA_DELTA_HLS_DIR)/sigma_delta.cpp
SIGMA_DELTA_HLS_TOP_LEVEL   := sigma_delta
SIGMA_DELTA_HLS_OUTPUT	    := $(BUILD_SIGMA_DELTA_HLS_DIR)/$(SIGMA_DELTA_HLS_TOP_LEVEL)/impl/vhdl/$(SIGMA_DELTA_HLS_TOP_LEVEL).vhd
#PROJECT_DEPENDENCIES        += $(SIGMA_DELTA_HLS_OUTPUT)
#HLS_FLAGS_INCLUDE	    := "-I$(BUILD_INCLUDE_DIR)"
SIGMA_DELTA_HLS_INCLUDES    += $(BUILD_SYFALA_CONFIG_H)
SIGMA_DELTA_HLS_INCLUDES    += $(BUILD_SYFALA_UTILITIES_H)
# ---------------------------------------------------------------------------------------
SIGMA_DELTA_HLS_COMMAND := cd $(BUILD_DIR);						\
	       open_project -reset $(notdir $(BUILD_SIGMA_DELTA_HLS_DIR));              \
               add_files $(SIGMA_DELTA_HLS_TARGET) -cflags $(HLS_FLAGS_INCLUDE);	\
	       set_top $(SIGMA_DELTA_HLS_TOP_LEVEL);                                    \
	       open_solution -reset $(SIGMA_DELTA_HLS_TOP_LEVEL) -flow_target vivado;	\
	       set_part $(BOARD_PART);							\
	       create_clock -period $(HLS_CLOCK_PERIOD);				\
	       csynth_design;								\
	       export_design -rtl vhdl -format ip_catalog;				\
	       exit;
# ---------------------------------------------------------------------------------------

$(SIGMA_DELTA_HLS_OUTPUT): $(SIGMA_DELTA_HLS_INCLUDES) $(SIGMA_DELTA_HLS_SOURCE)
	@mkdir -p $(BUILD_SIGMA_DELTA_HLS_DIR)
	@cp -r $(SIGMA_DELTA_HLS_SOURCE) $(SIGMA_DELTA_HLS_TARGET)
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file    \
                           $(notdir $(SIGMA_DELTA_HLS_TARGET)))
	@echo '$(SIGMA_DELTA_HLS_COMMAND)' | $(HLS_EXEC) -i
	$(call shell_ok, High-level synthesis done)
