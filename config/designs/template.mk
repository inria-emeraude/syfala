
DESIGN := transceiver

# Files to be included during HLS:
$(DESIGN)_HLS_INCLUDES  += $(BUILD_SYFALA_CONFIG_H)
$(DESIGN)_HLS_INCLUDES  += $(BUILD_SYFALA_UTILITIES_H)
$(DESIGN)_HLS_SOURCE    := $(SOURCE_HLS_DIR)/$(DESIGN).cpp

# HLS project directory:
BUILD_$(DESIGN)_HLS_DIR	:= $(BUILD_DIR)/$(DESIGN)
$(DESIGN)_HLS_TARGET	:= $(BUILD_ETHERNET_HLS_DIR)/$(DESIGN).cpp
$(DESIGN)_HLS_OUTPUT	:= $(BUILD_$(DESIGN)_HLS_DIR)/$(DESIGN)/impl/vhdl/$(DESIGN).vhd

# Add HLS output to Vivado project dependencies
PROJECT_DEPENDENCIES += $($(DESIGN)_HLS_OUTPUT)

# -----------------------------------------------------------------------------------
$(DESIGN)_HLS_COMMAND := cd $(BUILD_DIR);					    \
	       open_project -reset $(DESIGN));                                      \
               add_files $($(DESIGN)_HLS_TARGET) -cflags "$(HLS_FLAGS_INCLUDE)";    \
	       set_top $(DESIGN);                                                   \
	       open_solution -reset $(DESIGN) -flow_target vivado;		    \
	       set_part $(BOARD_PART);						    \
	       create_clock -period $(HLS_CLOCK_PERIOD);			    \
	       csynth_design;							    \
	       export_design -rtl vhdl -format ip_catalog;			    \
	       exit;
# -----------------------------------------------------------------------------------

$($(DESIGN)_HLS_OUTPUT): $($(DESIGN)_HLS_INCLUDES) $($(DESIGN)_HLS_SOURCE)
	@mkdir -p $(BUILD_$(DESIGN)_HLS_DIR)
	@cp -r $($(DESIGN)_HLS_SOURCE) $($(DESIGN)_HLS_TARGET)
	$(call shell_info, Running $(B)preprocessor$(N) on	\
                           $(B)HLS$(N) target file		\
                           ($(notdir $($(DESIGN)_HLS_TARGET))))
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file    \
                           $(notdir $($(DESIGN)_HLS_TARGET)))
	@echo '$($(DESIGN)_HLS_COMMAND)' | $(HLS_EXEC) -i
	$(call shell_ok, High-level synthesis done)

$(call static_ok, - $(B)CONFIG_EXPERIMENTAL_$(DESIGN)$(N) is $(B)ON$(N))
