
# -----------------------------------------------------------------------------

SYFALA_VERSION_MAJOR    := 0
SYFALA_VERSION_MINOR    := 8
SYFALA_VERSION_PATCH    := 0
SYFALA_VERSION          := $(SYFALA_VERSION_MAJOR).$(SYFALA_VERSION_MINOR)
SYFALA_VERSION_FULL     := $(SYFALA_VERSION).$(SYFALA_VERSION_PATCH)
SYFALA_COMMIT_HASH      := $(shell git rev-parse HEAD)

# -----------------------------------------------------------------------------
# Includes
# -----------------------------------------------------------------------------

# Makefile absolute path, if make gets called from another directory
MK_ROOT_DIR     := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MK_CONFIG_DIR   := $(MK_ROOT_DIR)/config
MK_ENV          := $(MK_ROOT_DIR)/makefile.env

# -----------------------------------------------------------------------------
# Include Makefile submodules
# -----------------------------------------------------------------------------

# Utilities:
include $(MK_CONFIG_DIR)/utilities.mk

ifeq ($(call file_exists, $(MK_ENV)), 1)
    include $(MK_ENV)
    $(call static_info, Found '$(B)makefile.env$(N)' - including definitions)
endif

$(call static_info, Running $(B)syfala$(N) toolchain    \
    ($(B)v$(SYFALA_VERSION_FULL)$(N)) on $(B)$(OS)$(N)  \
    ($(OS_VERSION) $(OS_LTS)))

$(call static_info, Commit #$(SYFALA_COMMIT_HASH))
$(call static_info, Running $(B)from$(N): $(PWD))
$(call static_info, $(B)Make targets$(N): $(MAKECMDGOALS))

# Sources:
include $(MK_CONFIG_DIR)/sources.mk

# Xilinx-related
include $(MK_CONFIG_DIR)/xilinx.mk

include $(MK_CONFIG_DIR)/boards.mk
include $(MK_CONFIG_DIR)/runtime-parameters.mk

# -----------------------------------------------------------------------------
SD_DEVICE       ?= null
# -----------------------------------------------------------------------------
$(call static_info, - $(B)SD_DEVICE$(N) = $(SD_DEVICE))

# TODO:check partition formats
ifeq ($(call dev_exists,$(SD_DEVICE)),1)
    ifeq ($(SD_DEVICE), /dev/mmcblk0)
        $(call static_info, Found device: $(SD_DEVICE))
        SD_DEVICE_BOOT_PARTITION := /dev/mmcblk0p1
        SD_DEVICE_ROOT_PARTITION := /dev/mmcblk0p2
    else ifeq ($(SD_DEVICE), /dev/sda)
        $(call static_info, Found device: $(SD_DEVICE))
        SD_DEVICE_BOOT_PARTITION := /dev/sda1
        SD_DEVICE_ROOT_PARTITION := /dev/sda2
    else
        $(call static_info, Unsupported device: $(SD_DEVICE) (blame developer))
        SD_DEVICE_BOOT_PARTITION := null
        SD_DEVICE_ROOT_PARTITION := null
    endif
endif

# -----------------------------------------------------------------------------
.PHONY: all
# -----------------------------------------------------------------------------
all: hw sw

# -----------------------------------------------------------------------------
# Linux
# -----------------------------------------------------------------------------

ifeq (linux, $(filter linux, $(MAKECMDGOALS)))
    LINUX := TRUE
else
    LINUX := FALSE
endif

# -----------------------------------------------------------------------------

HLS_FLAGS_INCLUDE = -I$(BUILD_INCLUDE_DIR)

# -----------------------------------------------------------------------------
# Including designs
# -----------------------------------------------------------------------------

ifeq ($(shell expr $(MULTISAMPLE) \> 0), 1) #--------------
    include $(MK_CONFIG_DIR)/designs/multisample.mk
else # ----------------------------------------------------
    $(call static_ok, - $(B)ONE_SAMPLE$(N) configuration)
endif # ---------------------------------------------------

ifeq ($(CONFIG_EXPERIMENTAL_TDM), TRUE) # -----------------
    include $(MK_CONFIG_DIR)/designs/tdm.mk
endif # ---------------------------------------------------

ifeq ($(CONFIG_EXPERIMENTAL_ETHERNET), TRUE) # ------------
    include $(MK_CONFIG_DIR)/designs/ethernet-audio.mk
else # ----------------------------------------------------
    ETHERNET := 0
endif # ---------------------------------------------------

ifeq ($(CONFIG_EXPERIMENTAL_SIGMA_DELTA), TRUE) # ---------
    include $(MK_CONFIG_DIR)/designs/sigma-delta.mk
else # ----------------------------------------------------
    SIGMA_DELTA := 0
endif # ---------------------------------------------------

MULTISAMPLE ?= 0

ARM_BENCHMARK   ?= 0
CTRL_MIDI       ?= 0
CTRL_OSC        ?= 0
CTRL_HTTP       ?= 0

$(call static_info, - $(B)CONTROL_MIDI$(N): $(CTRL_MIDI))
$(call static_info, - $(B)CONTROL_OSC$(N) : $(CTRL_OSC))
$(call static_info, - $(B)CONTROL_HTTP$(N): $(CTRL_HTTP))

# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------

TARGET_TYPE         ?= faust
$(call static_info, - $(B)TARGET_TYPE$(N): $(TARGET_TYPE))

PREPROCESSOR_HLS    ?= TRUE
PREPROCESSOR_I2S    ?= TRUE
$(call static_info, - $(B)PREPROCESSOR_HLS$(N): $(PREPROCESSOR_HLS))
$(call static_info, - $(B)PREPROCESSOR_I2S$(N): $(PREPROCESSOR_I2S))
$(call static_info, - $(B)LINUX$(N): $(LINUX))

DEBUG                   ?= FALSE
VERBOSE                 ?= 0
DEBUG_AUDIO             ?= 0
ADAU_EXTERN             ?= 0
ADAU_MOTHERBOARD        ?= 0
HLS_CSIM_NUM_ITER       ?= 1
CONFIG_EXPERIMENTAL_ETHERNET_NO_OUTPUT ?= 0

# Note: the following rule has to be shared with the different target submodules
# (faust, cpp, etc.)

define set_arm_config_definition # ----------------------------------------------------
    $(call shell_info, Setting #define $(B)$(1)$(N) $(2))
    @sed -i 's/^#define\s$(1)\s[^ ]\+/#define $(1) $(2)/g' $(BUILD_SYFALA_ARM_CONFIG_H)
endef # -------------------------------------------------------------------------------

$(BUILD_SYFALA_ARM_CONFIG_H): $(SYFALA_ARM_CONFIG_H)
	@mkdir -p $(BUILD_INCLUDE_DIR)/syfala
	@cp -r $(SYFALA_ARM_CONFIG_H) $(BUILD_SYFALA_ARM_CONFIG_H)
	$(call shell_info, Setting $(B)compile-time definitions$(N) in $(BUILD_SYFALA_ARM_CONFIG_H))
	$(call set_arm_config_definition,SYFALA_SSM_VOLUME,$(SSM_VOLUME))
	$(call set_arm_config_definition,SYFALA_SSM_SPEED,$(SSM_SPEED))
	$(call set_arm_config_definition,SYFALA_ADAU_EXTERN,$(ADAU_EXTERN))
	$(call set_arm_config_definition,SYFALA_ADAU_MOTHERBOARD,$(ADAU_MOTHERBOARD))
	$(call set_arm_config_definition,SYFALA_ARM_BENCHMARK,$(ARM_BENCHMARK))
	$(call set_arm_config_definition,SYFALA_CONTROLLER_TYPE,$(CONTROLLER_TYPE))
	$(call set_arm_config_definition,SYFALA_CONTROL_MIDI,$(CTRL_MIDI))
	$(call set_arm_config_definition,SYFALA_CONTROL_OSC,$(CTRL_OSC))
	$(call set_arm_config_definition,SYFALA_CONTROL_HTTP,$(CTRL_HTTP))
	$(call set_arm_config_definition,SYFALA_VERBOSE,$(VERBOSE))
ifneq ($(TARGET_TYPE), faust)
	$(call set_arm_config_definition,SYFALA_FAUST_TARGET,0)
endif

ifeq ($(TARGET_TYPE), faust) # ----------------------------
    include $(MK_CONFIG_DIR)/targets/faust.mk
endif # ---------------------------------------------------

ifeq ($(TARGET_TYPE), cpp) # ------------------------------
    include $(MK_CONFIG_DIR)/targets/cpp.mk
endif # ---------------------------------------------------

ifeq ($(TARGET_TYPE), faust2vhdl) # -----------------------
    include $(MK_CONFIG_DIR)/targets/faust2vhdl.mk
endif # ---------------------------------------------------

ifeq ($(CONFIG_EXPERIMENTAL_PD), TRUE) # ------------------
    include $(MK_CONFIG_DIR)/targets/pd.mk
endif # ---------------------------------------------------

# -----------------------------------------------------------------------------
# Parameters
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
BD_TARGET ?= $(BD_STD)
# Block design target file, used to generate the full Vivado project
# -----------------------------------------------------------------------------
ifeq ($(call file_exists, $(BD_TARGET)), 0)
      $(call static_error, $(BD_TARGET) does not exist, aborting...)
else
      $(call static_ok, - $(B)BD_TARGET$(N): $(notdir $(BD_TARGET)))
endif

# -----------------------------------------------------------------------------
.PHONY: install
# Installs syfala.tcl in /usr/bin/syfala
# After that, users can simply call 'syfala <command>' instead
# of './syfala.tcl'
# -----------------------------------------------------------------------------
PREFIX ?= /usr

install:
	$(call shell_info, Installing symlink in $(PREFIX)/bin/syfala)
	@sudo ln -fs $(PWD)/syfala.tcl $(PREFIX)/bin/syfala
	$(call shell_info, You can now use the command 'syfala --help' to	\
			   check if\n \t script has been properly installed)

# -----------------------------------------------------------------------------
.PHONY: status
# -----------------------------------------------------------------------------
status:
	@exit

# -----------------------------------------------------------------------------
.PHONY: tidy
# Cleans up Xilinx temporary files & logs in repository's root
# -----------------------------------------------------------------------------
tidy:
	@rm -rf vivado_*
	@rm -rf vivado.*
	@rm -rf Vitis_HLS
	@rm -rf *.Xil

# -----------------------------------------------------------------------------
.PHONY: clean
# -----------------------------------------------------------------------------
clean: tidy
	$(call remove_dir_confirm, $(BUILD_DIR))
	$(call shell_info, Cleaning up $(B)build/$(N) directory)
	@rm -rf *.log

# -----------------------------------------------------------------------------
.PHONY: reset
# Removes syfala 'build' directory and all of its contents
# -----------------------------------------------------------------------------
reset: clean
	$(call shell_info, Resetting $(B)makefile.env$(N) & $(B)syfala_log.txt$(N))
	@rm -rf makefile.env
	@rm -rf syfala_log.txt

# -----------------------------------------------------------------------------
.PHONY: reset-linux
# Removes syfala 'build' AND 'build-linux' directories
# -----------------------------------------------------------------------------
reset-linux:
	$(call shell_info, Removing $(B)build-linux$(N) directory)
	$(call remove_dir_confirm, $(BUILD_LINUX_DIR), sudo)

# -----------------------------------------------------------------------------
.PHONY: reset-linux-root
# TODO: this should be in the linux submodule
# Removes build-linux/build/root & build-linux/output/root directories
# -----------------------------------------------------------------------------
reset-linux-root:
	$(call shell_info, Removing $(B)build-linux root$(N) directories)
	$(call remove_dir_confirm, $(BUILD_LINUX_ROOT_DIR)              \
                                   $(BUILD_LINUX_OUTPUT_ROOT_DIR),      \
                                   sudo                                 \
        )

# -----------------------------------------------------------------------------
.PHONY: reset-linux-boot
# TODO: this should be in the linux submodule
# Removes build-linux/build/boot & build-linux/output/boot directories
# -----------------------------------------------------------------------------
reset-linux-boot:
	$(call shell_info, Removing $(B)build-linux boot$(N) directories)
	$(call remove_dir_confirm, $(BUILD_LINUX_BOOT_DIR)              \
                                   $(BUILD_LINUX_OUTPUT_BOOT_DIR))

# -----------------------------------------------------------------------------
.PHONY: help
# -----------------------------------------------------------------------------
help:
	@cat doc/help.txt

# -----------------------------------------------------------------------------
.PHONY: version
# -----------------------------------------------------------------------------
version:
	$(call shell_info, Running syfala toolchain script                  \
	    (v$(SYFALA_VERSION_FULL)) on $(OS_VERSION) $(OS_LTS))

# -----------------------------------------------------------------------------
.PHONY: log
# -----------------------------------------------------------------------------
log:
	@cat syfala_log.txt

# -----------------------------------------------------------------------------
.PHONY: import
# Imports .zip file containing a previously saved syfala build
# ideally, in the future, we should have a more normalized way to do this
# and check for incorrect builds, or version compatibility issues...
# -----------------------------------------------------------------------------
import:
ifeq ($(call file_exists, $(IMPORT_TARGET)), 1)
	$(call remove_dir_confirm, $(BUILD_DIR))
	$(call shell_info, Importing build: $(B)$(IMPORT_TARGET)$(N))
	@unzip -q $(IMPORT_TARGET) -d $(MK_ROOT_DIR)
	$(call shell_info, Overwriting 'makefile.env')
	@cp -r $(BUILD_DIR)/makefile.env $(MK_ROOT_DIR)
	$(call shell_ok, Target successfully imported!)
else
	$(call shell_error, $(B)IMPORT_TARGET$(N) does not exist, aborting)
	$(error abort)
endif

# -----------------------------------------------------------------------------
.PHONY: export
# Exports the contents of $(BUILD_DIR) to a .zip file in the export/ directory
# parameters: $(EXPORT_TARGET): has to be set by the user
# -----------------------------------------------------------------------------
export:
	$(call shell_info, Exporting build to $(B)export/$(EXPORT_TARGET).zip$(N))
	@mkdir -p export/
ifeq ($(call file_exists, makefile.env), 1) # --------
	@cp -r makefile.env $(BUILD_DIR)
endif # ----------------------------------------------
	@zip -q -r export/$(EXPORT_TARGET).zip build/
	$(call shell_ok, Build successfully exported!)

# -----------------------------------------------------------------------------
.PHONY: hls-target-file
# Rules to generate the HLS target files
# (build/syfala_ip/syfala_ip.cpp & build/syfala_ip/syfala_ip_preprocessed.cpp)
# -----------------------------------------------------------------------------
hls-target-file: $(HLS_TARGET_FILE)

ifeq ($(PREPROCESSOR_HLS), TRUE)
# Run the preprocessor.tcl script file on the HLS target file, it will set
# several things:
# - the number of input/output ports (top-level arguments).
# - the number of real/int & passive control arrays passed from/to the ARM
#   through the AXI Lite protocol.

HLS_TARGET_FILE_PREPROCESSED := $(BUILD_IP_DIR)/syfala_ip_preprocessed.cpp
HLS_DEPENDENCIES += $(HLS_TARGET_FILE_PREPROCESSED)
ADD_FILES_CMD    += add_files $(HLS_TARGET_FILE_PREPROCESSED)

$(HLS_TARGET_FILE_PREPROCESSED): $(HLS_TARGET_FILE)
	@cp -r $(HLS_TARGET_FILE) $(HLS_TARGET_FILE_PREPROCESSED)
	$(call shell_info, Running $(B)preprocessor$(N) on  \
		       $(B)HLS$(N) target file ($(notdir $(HLS_TARGET_FILE_PREPROCESSED))))
	$(call check_print_nchannels)
	$(call check_print_ncontrols)
	@tclsh $(SCRIPT_PREPROCESSOR) --hls		\
			$(HLS_TARGET_FILE_PREPROCESSED)	\
			$(shell $(get_nchannels_i))	\
			$(shell $(get_nchannels_o))	\
			$(shell $(get_ncontrols_f))	\
			$(shell $(get_ncontrols_i))	\
			$(shell $(get_ncontrols_p))	\
			$(shell $(get_mem_i))		\
			$(shell $(get_mem_f))		\
			$(MULTISAMPLE)			\
			0
else # ------------------------------------------------
    HLS_DEPENDENCIES += $(HLS_TARGET_FILE)
    ADD_FILES_CMD   += add_files $(HLS_TARGET_FILE)
endif #------------------------------------------------

# -----------------------------------------------------------------------------
.PHONY: hls-includes
# Prepare cpp include files for the main HLS source:
# - config_common.hpp, containing all runtime parameters defined as macros,
#   which will be overwritten using 'sed'.
# - utilities.hpp, an additional set of runtime definitions and compile-time
#   expressions.
# -----------------------------------------------------------------------------

HLS_INCLUDES        += $(BUILD_SYFALA_CONFIG_H)
HLS_INCLUDES        += $(BUILD_SYFALA_UTILITIES_H)
HLS_DEPENDENCIES    += $(HLS_INCLUDES)

hls-includes: $(HLS_INCLUDES)

define set_config_definition # ------------------------------------------------
    $(call shell_info, Setting #define $(B)$(1)$(N) $(2))
    @sed -i 's/^#define\s$(1)\s[^ ]\+/#define $(1) $(2)/g' $(BUILD_SYFALA_CONFIG_H)
endef # -----------------------------------------------------------------------

$(HLS_INCLUDES): $(SYFALA_CONFIG_H) $(SYFALA_UTILITIES_H)
	$(call shell_info, Preparing $(B)HLS$(N) sources...)
	@mkdir -p $(BUILD_INCLUDE_DIR)/syfala
	@cp -r $(SYFALA_CONFIG_H) $(BUILD_SYFALA_CONFIG_H)
	@cp -r $(SYFALA_UTILITIES_H) $(BUILD_SYFALA_UTILITIES_H)
	$(call shell_info, Setting $(B)compile-time definitions$(N) in $(BUILD_SYFALA_CONFIG_H))
	$(call set_config_definition,SYFALA_BOARD,$(BOARD_CPP_ID))
	$(call set_config_definition,SYFALA_SAMPLE_RATE,$(SAMPLE_RATE))
	$(call set_config_definition,SYFALA_SAMPLE_WIDTH,$(SAMPLE_WIDTH))
	$(call set_config_definition,SYFALA_MEMORY_USE_DDR,$(DDR))
	$(call set_config_definition,SYFALA_BLOCK_NSAMPLES,$(MULTISAMPLE))
	$(call set_config_definition,SYFALA_CSIM_NUM_ITER,$(HLS_CSIM_NUM_ITER))
	$(call set_config_definition,SYFALA_DEBUG_AUDIO,$(DEBUG_AUDIO))
	$(call set_config_definition,SYFALA_ETHERNET_NO_OUTPUT,$(CONFIG_EXPERIMENTAL_ETHERNET_NO_OUTPUT))

ifneq ($(TARGET_TYPE), faust)
	$(call set_config_definition,SYFALA_CONTROL_BLOCK,0)
endif

# -----------------------------------------------------------------------------
.PHONY: hls
# Synthesizes the Syfala DSP IP using Vitis HLS
# -----------------------------------------------------------------------------
HLS_OUTPUT      := $(BUILD_IP_DIR)/syfala/impl/vhdl/syfala.vhd
HLS_REPORT      := $(BUILD_IP_DIR)/syfala/syn/report/syfala_csynth.rpt
HLS_TOP_LEVEL   := syfala
ADD_FILES_CMD   += -cflags "$(HLS_FLAGS_INCLUDE)";

ifeq ($(HLS_DIRECTIVES_UNSAFE_MATH_OPTIMIZATIONS), TRUE) # ---------
    HLS_DIRECTIVES += config_compile -unsafe_math_optimizations=true
    #; config_array_partition -complete_threshold=1
endif # ------------------------------------------------------------

ifeq ($(HLS_ROUTING_AND_PLACEMENT), TRUE) # ---------
    HLS_FLOW += -flow impl
endif # ------------------------------------------------------------

ifdef HLS_SOURCE_FILES # -----------------------------
    ADD_FILES_CMD  += add_files "$(HLS_SOURCE_FILES)";
endif # ----------------------------------------------

hls: $(HLS_OUTPUT)

# -------------------------------------------------------------------------------
HLS_COMMAND := cd $(BUILD_DIR);                                                 \
	       open_project -reset $(notdir $(BUILD_IP_DIR));                   \
               $(ADD_FILES_CMD)                                                 \
	       set_top $(HLS_TOP_LEVEL);                                        \
	       open_solution -reset $(HLS_TOP_LEVEL) -flow_target vivado;       \
	       set_part $(BOARD_PART);                                          \
	       create_clock -period $(HLS_CLOCK_PERIOD);                        \
	       $(HLS_DIRECTIVES);                                               \
	       config_export $(HLS_FLOW) -format ip_catalog -rtl vhdl;          \
	       if [catch csynth_design] {exit 2};				\
	       export_design;                                                   \
	       exit;
# -------------------------------------------------------------------------------

$(HLS_OUTPUT): $(HLS_DEPENDENCIES)
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file $(notdir $(HLS_TARGET_FILE)))
	@echo '$(HLS_COMMAND)' | $(HLS_EXEC) -i
	$(call shell_ok, High-level synthesis done)

# -----------------------------------------------------------------------------
.PHONY: hls-csim-target
# Generates the C-Simulation .cpp file (scripted by preprocessor if needed)
# Output in build/csim/csim_main.cpp
# -----------------------------------------------------------------------------

BUILD_CSIM_DIR  := $(BUILD_DIR)/csim
HLS_CSIM_TARGET := $(BUILD_CSIM_DIR)/csim_main.cpp

hls-csim-target: $(HLS_CSIM_TARGET)

# TODO: check HLS_CSIM_SOURCE

$(HLS_CSIM_TARGET): $(HLS_CSIM_SOURCE) $(HLS_TARGET_FILE_PREPROCESSED)
	$(call shell_info, Running $(B)preprocessor$(N) on \
			   $(B)CSIM$(N) target file ($(notdir $(HLS_CSIM_TARGET))))
	@mkdir -p $(BUILD_CSIM_DIR)
	@cp -r $(HLS_CSIM_SOURCE) $(HLS_CSIM_TARGET)
	@tclsh $(SCRIPT_PREPROCESSOR) --hls	    \
	    	       $(HLS_CSIM_TARGET)	    \
	    	       $(shell $(get_nchannels_i))  \
	    	       $(shell $(get_nchannels_o))  \
	    	       $(shell $(get_ncontrols_f))  \
	    	       $(shell $(get_ncontrols_i))  \
	    	       $(shell $(get_ncontrols_p))  \
		       $(shell $(get_mem_i))	    \
		       $(shell $(get_mem_f))	    \
	    	       $(MULTISAMPLE)               \
                       0

# -----------------------------------------------------------------------------
.PHONY: hls-csim
# Rule to build and run the C-Simulation using Vitis HLS
# -----------------------------------------------------------------------------

HLS_CSIM_RUN	:= $(BUILD_CSIM_DIR)/syfala_csim/csim/build/run_sim.tcl
HLS_CSIM_REPORT := $(BUILD_CSIM_DIR)/syfala_csim/csim/report/syfala_csim.log

HLS_CSIM_OUTPUTS_DIR := $(MK_ROOT_DIR)/reports/$(DSP_TARGET_NAME)

hls-csim: $(HLS_CSIM_RUN)

CSIM_FILES += add_files $(BUILD_SYFALA_CONFIG_H);
CSIM_FILES += add_files $(BUILD_INCLUDE_DIR)/syfala/utilities.hpp
CSIM_FILES += -cflags "-I$(BUILD_INCLUDE_DIR) -D__CSIM__";

CSIM_FILES += add_files $(HLS_TARGET_FILE_PREPROCESSED)
CSIM_FILES += -cflags "-I$(BUILD_INCLUDE_DIR) -I$(dir $(HLS_SOURCE_MAIN)) -D__CSIM__"

CSIM_TB += add_files -tb $(HLS_CSIM_TARGET)
CSIM_TB += -cflags "-I$(BUILD_INCLUDE_DIR) -I$(BUILD_IP_DIR) -D__CSIM__"

CSIM_ARGV += $(HLS_CSIM_INPUTS_DIR)
CSIM_ARGV += $(HLS_CSIM_OUTPUTS_DIR)

# -------------------------------------------------------------------------------
CSIM_COMMAND := cd $(BUILD_DIR);						\
	       open_project -reset $(notdir $(BUILD_CSIM_DIR));                 \
               $(CSIM_FILES);							\
	       set_top $(HLS_TOP_LEVEL);                                        \
	       $(CSIM_TB);							\
	       open_solution -reset syfala_csim -flow_target vivado;		\
	       set_part $(BOARD_PART);                                          \
	       create_clock -period $(HLS_CLOCK_PERIOD);                        \
	       csim_design -argv "$(CSIM_ARGV)";				\
	       exit;
# -------------------------------------------------------------------------------

$(HLS_CSIM_RUN): $(HLS_CSIM_TARGET) $(HLS_INCLUDES)
	@mkdir -p $(HLS_CSIM_OUTPUTS_DIR)
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file $(notdir $(HLS_CSIM_TARGET)))
	@echo '$(CSIM_COMMAND)' | $(HLS_EXEC) -i

# -----------------------------------------------------------------------------
.PHONY: open-project-hls
# -----------------------------------------------------------------------------
open-project-hls: $(HLS_OUTPUT)
	$(call shell_info, Opening Vitis HLS project)
	$(HLS_EXEC) -p $(BUILD_IP_DIR)

# -----------------------------------------------------------------------------
.PHONY: report-hls
# -----------------------------------------------------------------------------
report-hls: $(HLS_OUTPUT)
	@less $(HLS_REPORT)

# -----------------------------------------------------------------------------
.PHONY: i2s
# -----------------------------------------------------------------------------

I2S_SOURCE ?= $(SOURCE_I2S_DIR)/i2s_template.vhd
I2S_TARGET := $(BUILD_RTL_DIR)/i2s_transceiver.vhd

ifeq ($(TARGET_TYPE), faust2vhdl) # -------------
    I2S_DEPENDENCIES := $(FAUST_VHDL_OUTPUT)
else # -------------------------------------
    I2S_DEPENDENCIES := $(HLS_OUTPUT)
endif #-------------------------------------

i2s: $(I2S_TARGET)

ifeq ($(call file_exists, $(I2S_SOURCE)), 1) # -----------------------
      $(call static_ok, - $(B)I2S_SOURCE$(N): $(notdir $(I2S_SOURCE)))
else # ---------------------------------------------------------------
      $(call static_error, - $(B)I2S_SOURCE$(N) file does not exist \
            $(I2S_SOURCE))
      $(error abort)
endif # --------------------------------------------------------------

ifeq ($(PREPROCESSOR_I2S), TRUE) # ----------------------------------
$(I2S_TARGET): $(I2S_SOURCE) $(I2S_DEPENDENCIES)
	@mkdir -p $(BUILD_RTL_DIR)
	$(call shell_info, Running $(B)preprocessor$(N) on          \
	    $(B)I2S$(N) template ($(notdir $(I2S_TARGET))))
	@tclsh $(SCRIPT_PREPROCESSOR) --i2s $(I2S_SOURCE)           \
                                            $(I2S_TARGET)           \
					    $(shell $(get_nchannels_i)) \
					    $(shell $(get_nchannels_o)) \
					    $(SAMPLE_WIDTH)         \
					    $(SAMPLE_RATE)          \
					    $(MULTISAMPLE)
else # --------------------------------------------------------------
$(I2S_TARGET): $(I2S_SOURCE) $(I2S_DEPENDENCIES)
	@mkdir -p $(BUILD_RTL_DIR)
	@cp -r $(I2S_SOURCE) $(I2S_TARGET)
	$(call shell_ok, Added $(notdir $(I2S_SOURCE)) to $(B)RTL targets$(N))
endif # -------------------------------------------------------------

# -----------------------------------------------------------------------------
.PHONY: rtl-targets
# -----------------------------------------------------------------------------

RTL_SOURCES  += $(SOURCE_RTL_DIR)/mux_2to1.vhd
RTL_TARGETS  += $(addprefix $(BUILD_RTL_DIR)/,$(notdir $(RTL_SOURCES)))

rtl-targets: $(RTL_TARGETS)

$(RTL_TARGETS): $(RTL_SOURCES)
	$(call shell_info, Preparing $(B)RTL sources$(N))
	@mkdir -p $(BUILD_RTL_DIR)
	@cp -r $(RTL_SOURCES) $(BUILD_RTL_DIR)/
	$(foreach rtl,$(RTL_SOURCES),						\
	    $(call shell_ok, Added $(notdir $(rtl)) to $(B)RTL targets$(N))	\
	)

# -----------------------------------------------------------------------------
.PHONY: project
# -----------------------------------------------------------------------------

BUILD_PROJECT_DIR       := $(BUILD_DIR)/syfala_project
PROJECT_DEPENDENCIES	+= $(SCRIPT_PROJECT)
PROJECT_DEPENDENCIES	+= $(BD_TARGET)
PROJECT_DEPENDENCIES	+= $(RTL_TARGETS)
PROJECT_DEPENDENCIES	+= $(I2S_TARGET)
PROJECT_DEPENDENCIES	+= $(CONSTRAINT_FILE)

# ------------------------------------------------------------------------
VIVADO_CMD_ARGUMENTS	+= -mode batch -notrace -source $(SCRIPT_PROJECT)
VIVADO_CMD_ARGUMENTS	+= -tclargs
VIVADO_CMD_ARGUMENTS	+= $(BOARD)
VIVADO_CMD_ARGUMENTS	+= $(BOARD_PART)
VIVADO_CMD_ARGUMENTS	+= $(BOARD_PART_FULL)
VIVADO_CMD_ARGUMENTS	+= $(BOARD_ID)
VIVADO_CMD_ARGUMENTS	+= $(CONSTRAINT_FILE)
VIVADO_CMD_ARGUMENTS	+= $(MULTISAMPLE)
VIVADO_CMD_ARGUMENTS	+= $(SAMPLE_RATE)
VIVADO_CMD_ARGUMENTS	+= $(SAMPLE_WIDTH)
VIVADO_CMD_ARGUMENTS	+= $(BD_TARGET)
VIVADO_CMD_ARGUMENTS	+= $(ETHERNET)
VIVADO_CMD_ARGUMENTS	+= $(CONFIG_EXPERIMENTAL_ETHERNET_NO_OUTPUT)
VIVADO_CMD_ARGUMENTS	+= $(SIGMA_DELTA)
# ------------------------------------------------------------------------

PROJECT_OUTPUT  := $(BUILD_PROJECT_DIR)/syfala_project.gen/sources_1/bd/main/hdl/main_wrapper.vhd
PROJECT_OUTPUT	+= $(BUILD_PROJECT_DIR)/syfala_project.srcs/sources_1/bd/main/main.bd
PROJECT_FILE	:= $(BUILD_PROJECT_DIR)/syfala_project.xpr

project: $(PROJECT_OUTPUT)

$(PROJECT_OUTPUT): $(PROJECT_DEPENDENCIES)
	$(call shell_info, Generating $(B)Vivado project$(N))
	@mkdir -p $(BUILD_PROJECT_DIR)
	$(VIVADO_EXEC) $(VIVADO_CMD_ARGUMENTS)	    \
                       $(shell $(get_nchannels_i))  \
                       $(shell $(get_nchannels_o))
	$(call shell_ok, $(B)Vivado project$(N) succesfully generated)

# -----------------------------------------------------------------------------
.PHONY: open-project
# -----------------------------------------------------------------------------
open-project: $(PROJECT_OUTPUT)
	$(call shell_info, Opening Vivado project)
	$(VIVADO_EXEC) $(PROJECT_FILE)

# -----------------------------------------------------------------------------
.PHONY: synth
# -----------------------------------------------------------------------------
SYNTH_OUTPUT := $(BUILD_PROJECT_DIR)/syfala_project.runs/synth_1/__synthesis_is_complete__

SYNTH_COMMAND = open_project $(PROJECT_FILE);   \
                reset_run synth_1;              \
                launch_runs synth_1;            \
                wait_on_run synth_1;

synth: $(SYNTH_OUTPUT)

$(SYNTH_OUTPUT): $(PROJECT_OUTPUT)
	$(call shell_info, Running $(B)project synthesis$(N) with Vivado)
	echo "$(SYNTH_COMMAND)" | $(VIVADO_EXEC) -mode tcl
	$(call shell_ok, Project synthesis succesfully completed)

# -----------------------------------------------------------------------------
.PHONY: impl
.PHONY: bitstream
# -----------------------------------------------------------------------------

IMPL_OUTPUT  := $(BUILD_PROJECT_DIR)/syfala_project.runs/impl_1/main_wrapper.bit
BITSTREAM    := $(IMPL_OUTPUT)

IMPL_COMMAND := open_project $(PROJECT_FILE);                   \
                reset_run impl_1;                               \
                launch_runs -to_step write_bitstream impl_1;    \
                wait_on_run impl_1;

impl: $(IMPL_OUTPUT)
bitstream: $(BITSTREAM)

$(IMPL_OUTPUT): $(SYNTH_OUTPUT)
	$(call shell_info, Running $(B)project implementation$(N) with Vivado)
	@echo "$(IMPL_COMMAND)" | $(VIVADO_EXEC) -mode tcl
	@mkdir -p $(BUILD_DIR)/hw_export
	@cp $(IMPL_OUTPUT) $(BUILD_DIR)/hw_export
	$(call shell_ok, Project implementation succesfully completed)

# -----------------------------------------------------------------------------
.PHONY: hw
# -----------------------------------------------------------------------------
HW_PLATFORM  := $(BUILD_DIR)/hw_export/main_wrapper.xsa

HW_COMMAND := open_project $(PROJECT_FILE);     \
              write_hw_platform                 \
                -fixed                          \
                -include_bit                    \
                -force                          \
                -file $(HW_PLATFORM)

hw: $(HW_PLATFORM)

$(HW_PLATFORM): $(IMPL_OUTPUT)
	$(call shell_info, Exporting $(B)hardware platform$(N))
	@mkdir -p $(BUILD_DIR)/hw_export
	@echo "$(HW_COMMAND)" | $(VIVADO_EXEC) -mode tcl
	$(call shell_ok, $(B)Hardware platform$(N) exported in build/hw_export)

# -----------------------------------------------------------------------------
#  Host application
# -----------------------------------------------------------------------------

XSOURCES_DIR	:= $(BUILD_IP_DIR)/syfala/impl/ip/drivers/syfala_v1_0/src
XSOURCES	+= $(XSOURCES_DIR)/xsyfala.c
XSOURCES	+= $(XSOURCES_DIR)/xsyfala.h
XSOURCES	+= $(XSOURCES_DIR)/xsyfala_hw.h
XSOURCES	+= $(XSOURCES_DIR)/xsyfala_linux.c
XSOURCES	+= $(XSOURCES_DIR)/xsyfala_sinit.c

VITIS_CMD_ARGUMENTS := $(SCRIPT_HOST_CONFIG)	\
		       $(BOARD)			\
		       $(HOST_MAIN_SOURCE)

# -----------------------------------------------------------------------------
.PHONY: host-includes
# -----------------------------------------------------------------------------

HOST_INCLUDES           += $(wildcard $(INCLUDE_DIR)/syfala/arm/*.hpp)
HOST_INCLUDES_CODECS    += $(wildcard $(INCLUDE_DIR)/syfala/arm/codecs/*.hpp)
HOST_INCLUDES_CODECS    += $(wildcard $(INCLUDE_DIR)/syfala/arm/codecs/*.h)

BUILD_HOST_INCLUDES += $(foreach hpp,$(HOST_INCLUDES),                              \
                       $(BUILD_INCLUDE_DIR)/syfala/arm/$(notdir $(hpp)))

BUILD_HOST_INCLUDES += $(foreach hpp,$(HOST_INCLUDES_CODECS),                       \
                       $(BUILD_INCLUDE_DIR)/syfala/arm/codecs/$(notdir $(hpp)))

host-includes: $(BUILD_HOST_INCLUDES)

$(BUILD_HOST_INCLUDES): $(HOST_INCLUDES)		\
			$(HOST_INCLUDES_CODECS)		\
			$(BUILD_SYFALA_ARM_CONFIG_H)	\
			$(BUILD_SYFALA_UTILITIES_H)
	$(call shell_info, Copying host include directories)
	@mkdir -p $(BUILD_INCLUDE_DIR)/syfala/arm
	@cp -r $(HOST_INCLUDES) $(BUILD_INCLUDE_DIR)/syfala/arm/
	@cp -r $(INCLUDE_DIR)/syfala/arm/codecs $(BUILD_INCLUDE_DIR)/syfala/arm/

# -----------------------------------------------------------------------------
.PHONY: host-application
# -----------------------------------------------------------------------------

HOST_APPLICATION    := $(BUILD_SW_EXPORT_DIR)/application.elf

HOST_DEPENDENCIES   += $(SCRIPT_HOST)
HOST_DEPENDENCIES   += $(HW_PLATFORM)
HOST_DEPENDENCIES   += $(BUILD_HOST_INCLUDES)
HOST_DEPENDENCIES   += $(HOST_MAIN_SOURCE)
HOST_DEPENDENCIES   += $(ARM_BAREMETAL_CPP_MODULES)
HOST_DEPENDENCIES   += $(LINKER_FILE)
HOST_DEPENDENCIES   += $(SOURCE_ARM_CODECS)

host-application: $(HOST_APPLICATION)

$(HOST_APPLICATION): $(HOST_DEPENDENCIES)
	$(call shell_info, Building $(B)Host Control Application$(N))
	@rm -rf $(BUILD_HOST_DIR)
	@mkdir -p $(BUILD_HOST_DIR)
	@mkdir -p $(BUILD_SW_EXPORT_DIR)
	$(VITIS_EXEC) $(SCRIPT_HOST) $(VITIS_CMD_ARGUMENTS)
	@cp -r $(BUILD_HOST_DIR)/application/Debug/application.elf $(HOST_APPLICATION)
	$(call shell_ok, $(B)Host Control Application$(N) succesfully built)

# -----------------------------------------------------------------------------
ifeq ($(LINUX), FALSE)
# -----------------------------------------------------------------------------
BAREMETAL_BOOT_BIN := $(BUILD_DIR)/sw_export/boot.bin
# -----------------------------------------------------------------------------
.PHONY: boot
# -----------------------------------------------------------------------------
boot: $(BAREMETAL_BOOT_BIN)

$(BAREMETAL_BOOT_BIN): $(HOST_APPLICATION)
	@mkdir -p $(BUILD_DIR)/sw_export
	$(BOOTGEN_EXEC) -image $(SCRIPT_BIN_GENERATOR)	\
			-arch zynq			\
			-o $(BAREMETAL_BOOT_BIN)	\
			-w on
endif

# -----------------------------------------------------------------------------
.PHONY: flash-boot
# -----------------------------------------------------------------------------
ifeq ($(call dev_exists, $(SD_DEVICE_BOOT_PARTITION)), 1)
flash-boot: $(BAREMETAL_BOOT_BIN)
	$(call shell_info, Mounting $(SD_DEVICE_BOOT_PARTITION))
	@sudo mount $(SD_DEVICE_BOOT_PARTITION) /mnt
	$(call shell_info, Cleaning up $(SD_DEVICE_BOOT_PARTITION))
	@rm -rf /mnt/*
	$(call shell_info, Copying boot files)
	@cp -r $(BAREMETAL_BOOT_BIN) /mnt
	$(call shell_ok, Boot binary successfully copied)
	$(call shell_info, Now syncing...)
	@sync
	$(call shell_info, Unmounting $(SD_DEVICE_BOOT_PARTITION))
	@sudo umount /mnt
else
    $(call static_info, Could not find boot partition ($(SD_DEVICE_BOOT_PARTITION)))
    SD_DEVICE_BOOT_PARTITION := null
endif

# -----------------------------------------------------------------------------
.PHONY: flash
# -----------------------------------------------------------------------------
FLASH_JTAG_TARGET ?= /dev/ttyUSB1

ifeq ($(call dev_exists, $(FLASH_JTAG_TARGET)),1)
flash: sw
	$(call shell_info, Flashing build with JTAG)
	$(VITIS_EXEC) $(SCRIPT_FLASH_JTAG) $(BOARD) $(VITIS_PATH)
else
flash: sw
	$(call shell_error, Could not find device $(FLASH_JTAG_TARGET))
endif

# -----------------------------------------------------------------------------
ifeq ($(LINUX), TRUE)
# -----------------------------------------------------------------------------
include $(MK_CONFIG_DIR)/linux/linux.mk

# -----------------------------------------------------------------------------
.PHONY: sw
# -----------------------------------------------------------------------------
sw: linux

else
# -----------------------------------------------------------------------------
.PHONY: sw
# -----------------------------------------------------------------------------
sw: $(HOST_APPLICATION)

endif

# -----------------------------------------------------------------------------
.PHONY: sources
# -----------------------------------------------------------------------------
sources: $(BUILD_HOST_INCLUDES)     \
         $(FAUST_CONTROL_SOURCE)    \
         $(HLS_INCLUDES)            \
         $(HLS_TARGET_FILE)

# -----------------------------------------------------------------------------
.PHONY: reports
# -----------------------------------------------------------------------------

define faust_mem_count_cmd # ----------------------------------------
sed -n '/void\scomputemydsp/,/}/p' $(HLS_TARGET_FILE)               \
 | grep -o '$(1)'                                                   \
 | wc -l
endef # -------------------------------------------------------------

faust_mem_count_cmd_r := $(call faust_mem_count_cmd,[if]Zone\[)
faust_mem_count_cmd_w := $(call faust_mem_count_cmd,[if]Zone\[.*\]\s=)

ifeq ($(MULTISAMPLE), 0)
    REPORTS_NSAMPLES := 1
else
    REPORTS_NSAMPLES := $(MULTISAMPLE)
endif

define print_reports # ----------------------
    @tools/print_reports.sh		    \
	$(PWD)                              \
	$(SYFALA_VERSION_FULL)		    \
	$(DSP_TARGET_NAME)		    \
	$(BOARD)			    \
	$(SAMPLE_RATE)			    \
	$(SAMPLE_WIDTH)			    \
	$(CONTROLLER_TYPE)		    \
	$(SSM_VOLUME)			    \
	$(shell $(get_nchannels_i))	    \
	$(shell $(get_nchannels_o))	    \
	$(shell expr $(shell $(faust_mem_count_cmd_r))	    \
		   - $(shell $(faust_mem_count_cmd_w)))	    \
	$(shell $(faust_mem_count_cmd_w))		    \
	$(REPORTS_NSAMPLES)
endef # ------------------------------------

reports:
	$(call print_reports)
