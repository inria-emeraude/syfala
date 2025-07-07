# -----------------------------------------------------------------------------
FAUST                   ?= faust
# -----------------------------------------------------------------------------
FAUST_VERSION           := $(word 3, $(shell $(FAUST) -v))
FAUST_MCD               ?= 16
FAUST_VEC               ?= 0
FAUST_FPGA_MEM          ?= 10000
FAUST_DSP_TARGET        ?= examples/faust/virtualAnalog.dsp
FAUST_DSP_TARGET_NAME   := $(basename $(notdir $(FAUST_DSP_TARGET)))

I2S_DEPENDENCIES        := $(HLS_OUTPUT)

# -----------------------------------------------------------------------------
ifeq ($(shell expr $(FAUST_VERSION) \<= 2.72.10),1)
# -----------------------------------------------------------------------------
    FAUST_HLS_INTERFACE := old
    FAUST_INTERFACE_NEW := 0
    ifeq (MULTISAMPLE, $(filter MULTISAMPLE, $(CONFIG)))
        FAUST_HLS_ARCH_FILE ?= $(SOURCE_HLS_DIR)/faust/old/faust_dsp_template_multisample.cpp
    else
        FAUST_HLS_ARCH_FILE ?= $(SOURCE_HLS_DIR)/faust/old/faust_dsp_template.cpp
    endif
# -----------------------------------------------------------------------------
else
# -----------------------------------------------------------------------------
    FAUST_HLS_INTERFACE := new
    FAUST_INTERFACE_NEW := 1
    ifeq (MULTISAMPLE, $(filter MULTISAMPLE, $(CONFIG)))
        FAUST_HLS_ARCH_FILE ?= $(SOURCE_HLS_DIR)/faust/faust_dsp_template_multisample.cpp
    else
        FAUST_HLS_ARCH_FILE ?= $(SOURCE_HLS_DIR)/faust/faust_dsp_template.cpp
    endif
endif

FAUST_ARM_ARCH_FILE  ?= include/syfala/arm/faust/control.hpp

$(call static_info, - $(B)FAUST_VERSION$(N) = $(FAUST_VERSION))
$(call static_info, - $(B)FAUST_HLS_INTERFACE$(N): $(FAUST_HLS_INTERFACE))

define parse_data_faust # -----------------------------------------
    cat $(HLS_TARGET_FILE) | grep -oP '(?<=\#define\s$(1)\s)[0-9]+'
endef # -----------------------------------------------------------

 ifeq ($(call file_exists, $(FAUST_DSP_TARGET)), 0)
 # Check Faust DSP target file
 # Fetch number of i/o channels & control values by
 # parsing the respective Faust-generated macros:
 # -------------------------------------------------------------------------
       $(call static_error, DSP target                              \
       ($(FAUST_DSP_TARGET)) does not exist, aborting...)
       $(error abort)
 endif

$(call static_ok, - $(B)FAUST_DSP_TARGET$(N): $(notdir $(FAUST_DSP_TARGET)))

get_nchannels_i     = $(call parse_data_faust,FAUST_INPUTS)
get_nchannels_o     = $(call parse_data_faust,FAUST_OUTPUTS)
get_ncontrols_f     = $(call parse_data_faust,FAUST_REAL_CONTROLS)
get_ncontrols_i     = $(call parse_data_faust,FAUST_INT_CONTROLS)
get_ncontrols_p     = $(call parse_data_faust,FAUST_PASSIVES)
get_mem_f           ?= $(call parse_data_faust,FAUST_FLOAT_ZONE)
get_mem_i           ?= $(call parse_data_faust,FAUST_INT_ZONE)

DSP_TARGET_NAME := $(FAUST_DSP_TARGET_NAME)

 # -------------------------------------------------------------------------
 ifeq ($(call file_exists, $(FAUST_HLS_ARCH_FILE)), 0)
 # Check Faust HLS architecture file
 # -------------------------------------------------------------------------
       $(call static_error, $(B)FAUST_HLS_ARCH_FILE$(N)                     \
       ($(FAUST_HLS_ARCH_FILE)) does not exist, aborting..)
       $(error abort)
 else
      $(call static_ok, - $(B)FAUST_HLS_ARCH_FILE$(N):                      \
      $(notdir $(FAUST_HLS_ARCH_FILE)))
 endif
 # -------------------------------------------------------------------------
 ifeq ($(call file_exists, $(FAUST_ARM_ARCH_FILE)), 0)
 # Check Faust control/ARM architecture file
 # -------------------------------------------------------------------------
       $(call static_error, $(B)FAUST_ARM_ARCH_FILE$(N)                     \
       ($(FAUST_ARM_ARCH_FILE)) does not exist, aborting..)
       $(error abort)
 else
      $(call static_ok, - $(B)FAUST_ARM_ARCH_FILE$(N):                      \
      $(notdir $(FAUST_ARM_ARCH_FILE)))
 endif

BUILD_FAUST_DSP_TARGET          := $(BUILD_DIR)/$(FAUST_DSP_TARGET_NAME).dsp
HLS_TARGET_FILE_DEPENDENCIES	+= $(FAUST_HLS_ARCH_FILE)
HLS_TARGET_FILE_DEPENDENCIES	+= $(BUILD_FAUST_DSP_TARGET)
HOST_MAIN_SOURCE                ?= $(ARM_BAREMETAL_CPP_MAIN_STD)
SCRIPT_HOST_CONFIG              := std

# ----------------------------------------------------------------------------
.PHONY: build-faust-target
# Copy faust target into build directory, remove all previous targets
# This allows the toolchain to re-build hw & sw when the
# Faust dsp file target changes
# ----------------------------------------------------------------------------
build-faust-target: $(BUILD_FAUST_DSP_TARGET)

$(BUILD_FAUST_DSP_TARGET): $(FAUST_DSP_TARGET)
	$(call shell_info, Updating Faust DSP target: $(FAUST_DSP_TARGET))
	@mkdir -p $(BUILD_DIR)
	@touch $(FAUST_DSP_TARGET)
	@rm -rf $(wildcard $(BUILD_DIR)/*.dsp)
	@cp -r $(FAUST_DSP_TARGET) $(BUILD_FAUST_DSP_TARGET)

# ----------------------------------------------------------------------------
# Generate the HLS target cpp (syfala_ip.cpp) file from the Faust compiler
# using the 'os2' mode and the selected architecture file.
# ----------------------------------------------------------------------------

# Common arguments (old/new hls interface):
FAUST_ARGUMENTS_HLS += -lang c
FAUST_ARGUMENTS_HLS += -uim
FAUST_ARGUMENTS_HLS += -mcd $(FAUST_MCD)
FAUST_ARGUMENTS_HLS += -t 0
FAUST_ARGUMENTS_HLS += -a $(FAUST_HLS_ARCH_FILE)
FAUST_ARGUMENTS_HLS += -o $(HLS_TARGET_FILE)
FAUST_ARGUMENTS_HLS += -fpga-mem $(FAUST_FPGA_MEM)

ifeq ($(FAUST_HLS_INTERFACE), new)
	FAUST_ARGUMENTS_HLS += -it
	FAUST_ARGUMENTS_HLS += -ec
	FAUST_ARGUMENTS_HLS += -mem3

    ifeq (MULTISAMPLE, $(filter MULTISAMPLE, $(CONFIG)))
        FAUST_ARGUMENTS_HLS += -vs $(MULTISAMPLE)
        ifeq ($(FAUST_VEC), 1)
            FAUST_ARGUMENTS_HLS += -vec
            FAUST_ARGUMENTS_HLS += -lv 2
            # Otherwise: no extra options
        endif
    else
        FAUST_ARGUMENTS_HLS += -os
    endif
else # 'old' interface with -light and os2
    FAUST_ARGUMENTS_HLS += -light
    FAUST_ARGUMENTS_HLS += -os2
endif

$(call static_info, HLS_ARGUMENTS: $(FAUST_ARGUMENTS_HLS))

$(HLS_TARGET_FILE): $(HLS_TARGET_FILE_DEPENDENCIES)
	$(call shell_info, Generating $(B)HLS$(N) source from   \
                           the $(B)Faust$(N) compiler)
	@mkdir -p $(BUILD_IP_DIR)
	$(FAUST) $(BUILD_FAUST_DSP_TARGET) $(FAUST_ARGUMENTS_HLS)

# -----------------------------------------------------------------------------
.PHONY: faust-control-source
# -----------------------------------------------------------------------------
FAUST_CONTROL_SOURCE	:= $(BUILD_INCLUDE_DIR)/syfala/arm/faust/control.hpp
HOST_DEPENDENCIES	+= $(FAUST_CONTROL_SOURCE)
HOST_DEPENDENCIES	+= $(SOURCE_ARM_FAUST_DIR)/control.cpp

faust-control-source: $(FAUST_CONTROL_SOURCE)

FAUST_ARGUMENTS_CONTROL += -lang cpp
FAUST_ARGUMENTS_CONTROL += -uim
FAUST_ARGUMENTS_CONTROL += -mcd $(FAUST_MCD)
FAUST_ARGUMENTS_CONTROL += -t 0
FAUST_ARGUMENTS_CONTROL += -a $(FAUST_ARM_ARCH_FILE)
FAUST_ARGUMENTS_CONTROL += -o $(FAUST_CONTROL_SOURCE)

ifeq ($(FAUST_HLS_INTERFACE), new)
	FAUST_ARGUMENTS_CONTROL += -ec
	FAUST_ARGUMENTS_CONTROL += -it
	FAUST_ARGUMENTS_CONTROL += -os
	FAUST_ARGUMENTS_CONTROL += -mem2
	FAUST_ARGUMENTS_CONTROL += -fpga-mem $(FAUST_FPGA_MEM)
else
	FAUST_ARGUMENTS_CONTROL += -i
	FAUST_ARGUMENTS_CONTROL += -os2
endif

$(FAUST_CONTROL_SOURCE): $(FAUST_ARM_ARCH_FILE) $(BUILD_FAUST_DSP_TARGET)
	$(call shell_info, Generating $(B)Host control sources$(N))
	@mkdir -p build/include/syfala/arm/faust
	$(FAUST) $(FAUST_DSP_TARGET) $(FAUST_ARGUMENTS_CONTROL)

# -----------------------------------------------------------------------------
.PHONY: gui
# -----------------------------------------------------------------------------

BUILD_GUI_DIR := $(BUILD_DIR)/gui

GUI_APPLICATION := $(BUILD_GUI_DIR)/faust-uart-control
GUI_APPLICATION_ARCH_FILE := $(SOURCE_DIR)/remote/faust-uart-control-arch.cpp
GUI_APPLICATION_SOURCE := $(GUI_APPLICATION).cpp

GUI_APPLICATION_CXX_FLAGS += -I$(BUILD_INCLUDE_DIR)
GUI_APPLICATION_CXX_FLAGS += -std=c++17

ifeq ($(CTRL_HTTP), 1) # ---------------------------------
    GUI_APPLICATION_CXX_FLAGS += -lHTTPDFaust
    GUI_APPLICATION_CXX_FLAGS += $(shell pkg-config --libs --cflags libmicrohttpd)
endif
ifeq ($(CTRL_MIDI), 1) # ---------------------------------
    GUI_APPLICATION_CXX_FLAGS += -lasound
endif
ifeq ($(CTRL_OSC),  1) # ---------------------------------
    GUI_APPLICATION_CXX_FLAGS += -llo -lOSCFaust
endif # --------------------------------------------------

GUI_APPLICATION_CXX_FLAGS += $(shell pkg-config --libs --cflags gtk+-2.0)

SYFALA_ARM_CONFIG_H	    := $(INCLUDE_DIR)/syfala/config_arm.hpp
BUILD_SYFALA_ARM_CONFIG_H   := $(BUILD_INCLUDE_DIR)/syfala/config_arm.hpp

gui: $(GUI_APPLICATION)

$(GUI_APPLICATION_SOURCE): $(GUI_APPLICATION_ARCH_FILE)	    \
			   $(BUILD_SYFALA_ARM_CONFIG_H)
	$(call shell_info, Generating $(B)Faust UART control application$(N))
	@mkdir -p $(BUILD_GUI_DIR)
	$(FAUST) $(FAUST_DSP_TARGET)		    \
		-uim				    \
		-a $(GUI_APPLICATION_ARCH_FILE)	    \
		-o $(GUI_APPLICATION_SOURCE)

$(GUI_APPLICATION): $(GUI_APPLICATION_SOURCE) $(BUILD_INCLUDES)
	$(call shell_info, Compiling $(B)Faust UART control application$(N))
	@c++ -v $(GUI_APPLICATION_SOURCE)	    \
		$(GUI_APPLICATION_CXX_FLAGS)	    \
	     -o $(GUI_APPLICATION)

# -----------------------------------------------------------------------------
.PHONY: start-gui
# -----------------------------------------------------------------------------
start-gui: gui
	$(call shell_info, Starting Faust remote GUI)
	$(GUI_APPLICATION)
