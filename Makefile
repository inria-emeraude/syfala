
SYFALA_VERSION_MAJOR    := 0
SYFALA_VERSION_MINOR    := 9
SYFALA_VERSION_PATCH    := 0
SYFALA_VERSION          := $(SYFALA_VERSION_MAJOR).$(SYFALA_VERSION_MINOR)
SYFALA_VERSION_FULL     := $(SYFALA_VERSION).$(SYFALA_VERSION_PATCH)

# -----------------------------------------------------------------------------
# utilities
# -----------------------------------------------------------------------------

SHELL ?= /bin/sh

define file_exists # -------------------
$(shell [ -f $(1) ] && echo 1 || echo 0)
endef # --------------------------------

define dir_exists # --------------------
$(shell [ -d $(1) ] && echo 1 || echo 0)
endef # --------------------------------

define dev_exists # --------------------
$(shell [ -e $(1) ] && echo 1 || echo 0)
endef # --------------------------------

define set_preprocessor_data #----------
echo '$(1)'
endef # --------------------------------


SH_BOLD         := $(shell tput bold)
SH_STD          := $(shell tput sgr0)
SH_GREEN        := $(shell tput setaf 2)
SH_RED          := $(shell tput setaf 1)
SH_ORANGE       := $(shell tput setaf 11)
B               := $(SH_BOLD)
N               := $(SH_STD)
R               := $(SH_RED)
O               := $(SH_ORANGE)
G               := $(SH_GREEN)

PRINT_OK       := [$(G)  OK  $(N)]
PRINT_INFO     := [$(O) INFO $(N)]
PRINT_ERROR    := [$(R) ERR! $(N)]

define print_ok # ---
$(PRINT_OK)$(1)
endef # -------------

define print_info # --
$(PRINT_INFO)$(1)
endef # --------------

define print_error # --
$(PRINT_ERROR)$(1)
endef # ---------------

define em # ----------
$(B)$1$(N)
endef # --------------

define static_ok #---------------
    $(info $(call print_ok,$(1)))
endef #--------------------------

define static_info # --------------
    $(info $(call print_info,$(1)))
endef #----------------------------

define static_error #---------------
    $(info $(call print_error,$(1)))
endef #-----------------------------

define shell_ok # ------------------
    @echo -e '$(call print_ok,$(1))'
endef # ----------------------------

define shell_info #-------------------
    @echo -e '$(call print_info,$(1))'
endef # ------------------------------

define shell_error # ------------------
    @echo -e '$(call print_error,$(1))'
endef # -------------------------------

ifeq ($(call file_exists, makefile.env), 1) # -----------------------
    include makefile.env
    $(call static_info, Found 'makefile.env' - including definitions)
endif # -------------------------------------------------------------

# -----------------------------------------------------------------------------
# OS-specific
# TODO: other platforms
# -----------------------------------------------------------------------------

# ---------------------------------------------------
ifeq ($(call file_exists, /etc/arch-release), 1)
# ---------------------------------------------------
    OS              := Arch Linux
# ---------------------------------------------------
else ifeq ($(call file_exists, /etc/lsb-release), 1)
# ---------------------------------------------------
    OS              := Ubuntu
    OS_VERSION_FULL := $(shell lsb_release -d)
    OS_VERSION      := $(word 3, $(OS_VERSION_FULL))
    OS_LTS          := $(word 4, $(OS_VERSION_FULL))
# ---------------------------------------------------
else
# ---------------------------------------------------
    OS              := N/A
    OS_VERSION_FULL := N/A
    OS_VERSION      := N/A
    OS_LTS          := N/A
endif

# -----------------------------------------------------------------------------
# SOURCES
# -----------------------------------------------------------------------------

SOURCE_DIR  := $(PWD)/source
INCLUDE_DIR := $(PWD)/include

# -----------------------------------------------------------------------------
# Codec sources:
# - SSM2603     (Zybo internal codec)
# - ADAU1761    (Genesys internal codec)
# - ADAU1777    (External)
# - ADAU1787    (External)
# -----------------------------------------------------------------------------
SOURCE_ARM_CODECS_DIR	    := $(SOURCE_ARM_DIR)/codecs
ARM_CODECS_SOURCE_ADAU1761  := $(SOURCE_ARM_CODECS_DIR)/ADAU1761Reg.cpp
ARM_CODECS_SOURCE_ADAU1777  := $(SOURCE_ARM_CODECS_DIR)/ADAU1777Reg.cpp
ARM_CODECS_SOURCE_ADAU1787  := $(SOURCE_ARM_CODECS_DIR)/ADAU1787Reg.cpp
ARM_CODECS_SOURCE_TEMPLATE  := $(SOURCE_ARM_CODECS_DIR)/template.pp
# -----------------------------------------------------------------------------
SOURCE_ARM_FAUST_DIR        := $(SOURCE_ARM_DIR)/faust
ARM_FAUST_CONTROL_SOURCE    := $(SOURCE_ARM_FAUST_DIR)/control.cpp
# -----------------------------------------------------------------------------
SOURCE_CONSTRAINTS_DIR      := $(SOURCE_DIR)/constraints
SOURCE_CONSTRAINTS_ZYBO	    := $(SOURCE_CONSTRAINTS_DIR)/zybo.xdc
SOURCE_CONSTRAINTS_GENESYS  := $(SOURCE_CONSTRAINTS_DIR)/genesys-zu-3eg.xdc
# -----------------------------------------------------------------------------
SOURCE_LINUX_DIR        := $(SOURCE_DIR)/linux
# -----------------------------------------------------------------------------
SOURCE_REMOTE_DIR       := $(SOURCE_DIR)/remote
# -----------------------------------------------------------------------------
SOURCE_RTL_DIR		:= $(SOURCE_DIR)/rtl
SOURCE_FAUST2VHDL_DIR	:= $(SOURCE_RTL_DIR)/faust2vhdl
SOURCE_HLS_DIR		:= $(SOURCE_RTL_DIR)/hls
SOURCE_I2S_DIR		:= $(SOURCE_RTL_DIR)/i2s
# -----------------------------------------------------------------------------
SOURCE_BD_DIR		:= $(SOURCE_DIR)/bd
BD_STD			:= $(SOURCE_BD_DIR)/standard.tcl
BD_MULTISAMPLE		:= $(SOURCE_BD_DIR)/multisample.tcl
BD_FAUST2VHDL		:= $(SOURCE_BD_DIR)/faust2vhdl.tcl
BD_TDM			:= $(SOURCE_BD_DIR)/tdm.tcl
BD_SIGMA_DELTA		:= $(SOURCE_BD_DIR)/sigma-delta.tcl
# -----------------------------------------------------------------------------
SCRIPTS_DIR             := $(PWD)/scripts
SCRIPT_PREPROCESSOR     ?= $(SCRIPTS_DIR)/preprocessor.tcl
#SCRIPT_HLS              ?= $(SCRIPTS_DIR)/hls.tcl
SCRIPT_PROJECT          ?= $(SCRIPTS_DIR)/project.tcl
#SCRIPT_SYNTH            ?= $(SCRIPTS_DIR)/synthesis.tcl
SCRIPT_HOST             ?= $(SCRIPTS_DIR)/application.tcl
SCRIPT_FLASH_JTAG       ?= $(SCRIPTS_DIR)/jtag.tcl
# -----------------------------------------------------------------------------
BUILD_DIR		:= $(PWD)/build
BUILD_INCLUDE_DIR       := $(BUILD_DIR)/include
BUILD_IP_DIR 		:= $(BUILD_DIR)/syfala_ip
BUILD_PROJECT_DIR 	:= $(BUILD_DIR)/syfala_project
BUILD_HOST_DIR  	:= $(BUILD_DIR)/syfala_application
BUILD_HW_EXPORT_DIR     := $(BUILD_DIR)/hw_export
BUILD_SW_EXPORT_DIR     := $(BUILD_DIR)/sw_export
BUILD_RTL_DIR           := $(BUILD_DIR)/rtl

# -----------------------------------------------------------------------------
.PHONY: all
# -----------------------------------------------------------------------------
all: hw sw

# -----------------------------------------------------------------------------
# Header
# -----------------------------------------------------------------------------

$(call static_info, Running $(B)syfala$(N) toolchain script \
    ($(B)v$(SYFALA_VERSION_FULL)$(N)) on $(B)$(OS)$(N)      \
    ($(OS_VERSION) $(OS_LTS)))

$(call static_info, Running $(B)from$(N): $(PWD))
$(call static_info, $(B)Targets$(N): $(MAKECMDGOALS))

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
# Used by clean & reset, asks confirmation about removing build directories
# -----------------------------------------------------------------------------
define remove_dir_confirm
@read -p "Please $(B)confirm$(N) [y/$(B)N$(N)]: " confirm;                  \
if [ $$confirm = "y" ] || [ $$confirm = "Y" ]; then                         \
     $(2) rm -rf $(1);                                                      \
     echo "$(_print_ok) Removed $(B)$(notdir $(1))$(N) directory";          \
fi
endef

# -----------------------------------------------------------------------------
.PHONY: clean
# -----------------------------------------------------------------------------
clean: tidy
	$(call shell_info, Cleaning up $(B)build/$(N) directory)
	$(call remove_dir_confirm, $(BUILD_DIR))
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
# Removes build-linux/build/boot & build-linux/output/boot directories
# -----------------------------------------------------------------------------
reset-linux-boot:
	$(call shell_info, Removing $(B)build-linux boot$(N) directories)
	$(call remove_dir_confirm, $(BUILD_LINUX_BOOT_DIR)              \
                                   $(BUILD_LINUX_OUTPUT_BOOT_DIR))

# -----------------------------------------------------------------------------
.PHONY: help
# TODO
# -----------------------------------------------------------------------------
help:
	$(call shell_info, HELP ME!)

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
# imports .zip file containing a previously saved syfala build
# ideally, in the future, we should have a more normalized way to do this
# and check for incorrect builds, or version compatibility issues...
# -----------------------------------------------------------------------------
import:
ifeq ($(call file_exists, $(IMPORT_TARGET)), 1)
	$(call shell_info, Importing build: $(B)$(IMPORT_TARGET)$(N))
	@unzip -q $(IMPORT_TARGET) -d $(BUILD_DIR)/
ifeq ($(call file_exists, $(BUILD_DIR)/makefile.env), 1) # -------------
	@cp -r $(BUILD_DIR)/makefile.env $(PWD)
endif # ----------------------------------------------------------------
	$(call shell_ok, Target successfully imported!)
else
	$(call shell_error, $(B)IMPORT_TARGET$(N) does not exist, aborting)
	$(error abort)
endif

# -----------------------------------------------------------------------------
.PHONY: export
# exports the contents of $(BUILD_DIR) to a .zip file in the export/ directory
# parameters: $(EXPORT_TARGET): has to be set by the user
# -----------------------------------------------------------------------------
export:
	$(call shell_info, Exporting build to $(B)$(EXPORT_TARGET).zip$(N))
	@mkdir -p export/
ifeq ($(call file_exists, makefile.env), 1) # -------------
	@cp -r makefile.env $(BUILD_DIR)
endif # ---------------------------------------------------
	@zip -q -r export/$(EXPORT_TARGET).zip build/
	$(call shell_ok, Build successfully exported!)

# -----------------------------------------------------------------------------
ifeq ($(call dir_exists, $(XILINX_ROOT_DIR)), 0)
# checks whether the $(XILINX_ROOT_DIR) env variable has been set by the user
# -----------------------------------------------------------------------------
    $(call static_error, $(B)XILINX_ROOT_DIR$(N) ($(XILINX_ROOT_DIR))       \
                           does not exist...)
    $(call static_error, Please add                                         \
            '$(B)export XILINX_ROOT_DIR$(N)=/your/path/to/Xilinx/root'      \
            to your shell resource file (~/.bashrc, ~/.zshrc etc.)          \
    )
    $(error syfala abort)
else
    $(call static_ok, - $(B)XILINX_ROOT_DIR$(N): $(XILINX_ROOT_DIR))
endif

# -----------------------------------------------------------------------------
XILINX_VERSION      ?= 2022.2
XILINX_SUPPORTED    := 2020.2 2022.2
# checks Xilinx toolchain versions
# -----------------------------------------------------------------------------
ifneq ($(XILINX_VERSION), $(filter $(XILINX_VERSION), $(XILINX_SUPPORTED)))
    $(call static_error, Unsupported XILINX_VERSION $(XILINX_VERSION))
    $(call static_error, Supported versions: $(XILINX_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)XILINX_VERSION$(N): $(XILINX_VERSION))
    export XILINX_VERSION
endif

define xcheck # -------------------------------------------
    $(XILINX_ROOT_DIR)/$(1)/$(XILINX_VERSION)/settings64.sh
endef # ---------------------------------------------------

XCHECK_VIVADO       := $(call xcheck,Vivado)
XCHECK_VITIS_HLS    := $(call xcheck,Vitis_HLS)
XCHECK_VITIS        := $(call xcheck,Vitis)

# -----------------------------------------------------------------------------
ifeq ($(call file_exists, $(XCHECK_VIVADO)), 0)
# -----------------------------------------------------------------------------
    $(call static_error, $(XCHECK_VIVADO) does not exist,                   \
           please check your XILINX_VERSION and/or XILINX_ROOT_DIR variables)
    $(error abort)
else
    $(call static_ok, - $(B)Vivado $(XILINX_VERSION)$(N) installation)
endif

# -----------------------------------------------------------------------------
ifeq ($(call file_exists, $(XCHECK_VITIS_HLS)), 0)
# -----------------------------------------------------------------------------
    $(call static_error, $(XCHECK_VITIS_HLS) does not exist,                \
           please check your XILINX_VERSION and/or XILINX_ROOT_DIR variables)
    $(error abort)
else
    $(call static_ok, - $(B)Vitis_HLS $(XILINX_VERSION)$(N) installation)
endif

# -----------------------------------------------------------------------------
ifeq ($(call file_exists, $(XCHECK_VITIS)), 0)
# -----------------------------------------------------------------------------
    $(call static_error,  $(XCHECK_VITIS) does not exist,                   \
          please check your XILINX_VERSION and/or XILINX_ROOT_DIR variables)
    $(error abort)
else
    $(call static_ok, - $(B)Vitis $(XILINX_VERSION)$(N) installation)
endif

# -----------------------------------------------------------------------------
CONFIG ?= STD
# -----------------------------------------------------------------------------
ifeq ($(CONFIG_EXPERIMENTAL_TDM), TRUE)
# TODO: repair
# -----------------------------------------------------------------------------
    CONFIG       += TDM
    SAMPLE_RATE  := 48000
    SAMPLE_WIDTH := 16
    PREPROCESSOR_HLS := TRUE
    PREPROCESSOR_I2S := FALSE
    BD_TARGET    := $(BD_TDM)
    I2S_SOURCE   := $(SOURCE_I2S_DIR)/i2s_transceiver_tdm.vhd
    $(call static_ok, - $(B)CONFIG_EXPERIMENTAL_TDM$(N) is $(B)ON$(N))
endif

# -----------------------------------------------------------------------------
ifeq ($(CONFIG_EXPERIMENTAL_SIGMA_DELTA), TRUE)
# TODO: repair
# -----------------------------------------------------------------------------
    CONFIG       += SIGMA_DELTA
    SAMPLE_RATE  := 5000000
    SAMPLE_WIDTH := 16
    PREPROCESSOR_HLS := TRUE
    PREPROCESSOR_I2S := TRUE
    BD_TARGET    := $(BD_SIGMA_DELTA)
    RTL_SOURCES  += $(SOURCE_RTL_DIR)/sd_dac_first.vhd
    $(call static_ok, - $(B)CONFIG_EXPERIMENTAL_SIGMA_DELTA$(N) is $(N)ON$(N))
endif

# -----------------------------------------------------------------------------
ifeq ($(CONFIG_EXPERIMENTAL_ETHERNET), TRUE)
# -----------------------------------------------------------------------------
    CONFIG              += ETHERNET
    ETHERNET            := 1
    PREPROCESSOR_HLS    := TRUE
    PREPROCESSOR_I2S    := TRUE
    LINUX               := TRUE
ifeq (TDM, $(filter TDM, $(CONFIG))) # ---------------------------
    BD_TARGET        := $(SOURCE_BD_DIR)/ethernet_tdm.tcl
    I2S_SOURCE       := $(SOURCE_I2S_DIR)/i2s_template_ethernet_tdm.vhd
    CONSTRAINT_FILE  := $(SOURCE_CONSTRAINTS_DIR)/zybo_tdm.xdc
else # -----------------------------------------------------------
    BD_TARGET   := $(SOURCE_BD_DIR)/ethernet.tcl
    I2S_SOURCE  := $(SOURCE_I2S_DIR)/i2s_template_ethernet.vhd
endif # ----------------------------------------------------------
    $(call static_ok, - $(B)CONFIG_EXPERIMENTAL_ETHERNET$(N) is $(B)ON$(N))
endif

# -----------------------------------------------------------------------------
ifeq ($(CONFIG_EXPERIMENTAL_PD), TRUE)
# hvcc support (experimental)
# see: https://github.com/enzienaudio/hvcc
# TODO: parser + implement control
# -----------------------------------------------------------------------------
    TARGET              := cpp
    PREPROCESSOR_HLS    := TRUE
    PREPROCESSOR_I2S    := TRUE
    NCHANNELS_I         := $(call set_preprocessor_data,0)
    NCHANNELS_O         := $(call set_preprocessor_data,2)
    NCONTROLS_F         := $(call set_preprocessor_data,0)
    NCONTROLS_I         := $(call set_preprocessor_data,0)
    NCONTROLS_P         := $(call set_preprocessor_data,0)
    PD_SOURCE_DIR       := $(SOURCE_DIR)/pd
    PD_TARGET           := $(PD_SOURCE_DIR)/phasor-simple
#    PD_TARGET           := $(PD_SOURCE_DIR)/phasor-slider
    HLS_FLAGS_INCLUDE   := "-I$(PD_TARGET) -I$(BUILD_INCLUDE_DIR)"
    HLS_SOURCE_MAIN     := $(PD_TARGET)/fpga.cpp
    HLS_SOURCE_FILES    += $(wildcard $(PD_TARGET)/*.c)
#    HOST_MAIN_SOURCE    :=
    $(call static_ok, CONFIG_EXPERIMENTAL_PD is $(N)ON$(N))
endif

# -----------------------------------------------------------------------------
BOARD               ?= Z20
BOARD_SUPPORTED     := Z10 Z20 GENESYS
# -----------------------------------------------------------------------------
ifneq ($(BOARD), $(filter $(BOARD), $(BOARD_SUPPORTED)))
    $(call static_error, Unsupported $(B)BOARD$(N) model: $(BOARD))
    $(call static_error, Supported boards: $(BOARD_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)BOARD$(N) model ($(BOARD)))
endif

USE_AUDIO_CODEC_INTERNAL ?= TRUE

ifeq ($(BOARD), Z10) # -------------------------------------
    CONSTRAINT_FILE             ?= $(SOURCE_CONSTRAINTS_ZYBO)
    BOARD_ID                    := zybo-z7-10
    BOARD_CPP_ID                := 10
    BOARD_PART                  := xc7z010clg400-1
    BOARD_PART_FULL             := digilentinc.com:zybo-z7-10:part0:1.0
    BOARD_FAMILY                := ZYNQ_7000
    BOARD_ARCH                  := 32-bit
    BOARD_PROC                  := ps7_cortexa9_0
    HLS_CLOCK_PERIOD            := 8.137634
    AUDIO_CODEC_INTERNAL        := SSM2603
    AUDIO_CODEC_EXTERNAL_MAX    := 9
else ifeq ($(BOARD), Z20) # --------------------------------
    CONSTRAINT_FILE             ?= $(SOURCE_CONSTRAINTS_ZYBO)
    BOARD_ID                    := zybo-z7-20
    BOARD_CPP_ID                := 20
    BOARD_PART                  := xc7z020clg400-1
    BOARD_PART_FULL             := digilentinc.com:zybo-z7-20:part0:1.0
    BOARD_FAMILY                := ZYNQ_7000
    BOARD_ARCH                  := 32-bit
    BOARD_PROC                  := ps7_cortexa9_0
    HLS_CLOCK_PERIOD            := 8.137634
    AUDIO_CODEC_INTERNAL        := SSM2603
    AUDIO_CODEC_EXTERNAL_MAX    := 13
else ifeq ($(BOARD), GENESYS) # ---------------------------
    CONSTRAINT_FILE             ?= $(SOURCE_CONSTRAINTS_GENESYS)
    BOARD_ID                    := gzu_3eg
    BOARD_CPP_ID                := 30
    BOARD_PART                  := xczu3eg-sfvc784-1-e
    BOARD_PART_FULL             := digilentinc.com:gzu_3eg:part0:1.0
    BOARD_FAMILY                := MPSOC_ULTRASCALE+
    BOARD_ARCH                  := 64-bit
    BOARD_PROC                  := psu_cortexa53_0
    HLS_CLOCK_PERIOD            := 8.138352
    AUDIO_CODEC_INTERNAL        := ADAU1761
    AUDIO_CODEC_EXTERNAL_MAX    := 16
endif

# -----------------------------------------------------------------------------
MEMORY_TARGET       ?= DDR
MEMORY_SUPPORTED    := DDR STATIC
# -----------------------------------------------------------------------------
ifneq ($(MEMORY_TARGET), $(filter $(MEMORY_TARGET), $(MEMORY_SUPPORTED)))
    $(call static_error, Unsupported $(B)MEMORY$(N) settings: $(MEMORY_TARGET))
    $(call static_error, $(B)Supported settings$(N): $(MEMORY_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)MEMORY$(N) settings: $(MEMORY_TARGET))
endif

ifeq ($(MEMORY_TARGET), DDR) # --------
    DDR := 1
else # --------------------------------
    DDR := 0
endif # -------------------------------

# -----------------------------------------------------------------------------
SAMPLE_RATE ?= 48000
# TODO: sample rate check depending on the audio codec(s) used
# -----------------------------------------------------------------------------
SAMPLE_RATE_SUPPORTED           := 24000 48000 96000 192000 384000 768000
# -----------------------------------------------------------------------------
SSM2603_SAMPLE_RATE_SUPPORTED   := 8000 11025 12000 16000 22050 24000           \
                                   32000 44100 48000 88200 96000
# -----------------------------------------------------------------------------
ADAU1761_SAMPLE_RATE_SUPPORTED  := 7350 8000 11025 12000 14700 16000            \
                                   22050 24000 29400 32000 44100 48000          \
                                   88200 96000
# -----------------------------------------------------------------------------
ADAU1777_SAMPLE_RATE_SUPPORTED  := 96000 192000 768000
# -----------------------------------------------------------------------------
ADAU1787_SAMPLE_RATE_SUPPORTED  := 12000 24000 48000 96000 192000 384000 768000
# -----------------------------------------------------------------------------
MAX98357A_SAMPLE_RATE_SUPPORTED := 8000 48000 96000
# -----------------------------------------------------------------------------
ifneq ($(CONFIG), $(filter $(CONFIG), TDM SIGMA_DELTA))
    ifneq ($(SAMPLE_RATE), $(filter $(SAMPLE_RATE), $(SAMPLE_RATE_SUPPORTED)))
        $(call static_error, Unsupported $(B)SAMPLE_RATE$(N) settings: $(SAMPLE_RATE))
        $(call static_error, $(B)Supported settings$(N): $(SAMPLE_RATE_SUPPORTED))
        $(error Aborting...)
    else
        $(call static_ok, - $(B)SAMPLE_RATE$(N) settings: $(SAMPLE_RATE))
    endif
endif

# -----------------------------------------------------------------------------
SAMPLE_WIDTH            ?= 24
SAMPLE_WIDTH_SUPPORTED  := 16 24 32
# TODO: sample width check depending on the audio codec(s) used
# -----------------------------------------------------------------------------

SSM2603_SAMPLE_WIDTH_SUPPORTED  := 24
ADAU1761_SAMPLE_WIDTH_SUPPORTED := 24
ADAU1777_SAMPLE_WIDTH_SUPPORTED := 24
ADAU1787_SAMPLE_WIDTH_SUPPORTED := 24

# -----------------------------------------------------------------------------
ifneq ($(SAMPLE_WIDTH), $(filter $(SAMPLE_WIDTH), $(SAMPLE_WIDTH_SUPPORTED)))
    $(call static_error, Unsupported $(B)SAMPLE_WIDTH$(N) settings: $(SAMPLE_WIDTH))
    $(call static_error, $(B)Supported settings$(N): $(SAMPLE_WIDTH_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)SAMPLE_WIDTH$(N) settings: $(SAMPLE_WIDTH))
endif

# -----------------------------------------------------------------------------
CONTROLLER_TYPE             ?= PCB1
CONTROLLER_TYPE_SUPPORTED   := DEMO PCB1 PCB2 PCB3 PCB4
# -----------------------------------------------------------------------------
ifneq ($(CONTROLLER_TYPE), $(filter $(CONTROLLER_TYPE), $(CONTROLLER_TYPE_SUPPORTED)))
    $(call static_error, Unsupported $(B)CONTROLLER_TYPE$(N) settings: $(CONTROLLER_TYPE))
    $(call static_error, $(B)Supported settings$(N): $(CONTROLLER_TYPE_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)CONTROLLER_TYPE$(N) settings: $(CONTROLLER_TYPE))
endif

# -----------------------------------------------------------------------------
SSM_VOLUME		?= HEADPHONE
SSM_VOLUME_SUPPORTED    := FULL HEADPHONE DEFAULT
# -----------------------------------------------------------------------------
ifneq ($(SSM_VOLUME), $(filter $(SSM_VOLUME), $(SSM_VOLUME_SUPPORTED)))
    $(call static_error, Unsupported $(B)SSM_VOLUME$(N) settings: $(SSM_VOLUME))
    $(call static_error, $(B)Supported settings$(N): $(SSM_VOLUME_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)SSM_VOLUME$(N) settings: $(SSM_VOLUME))
endif

# -----------------------------------------------------------------------------
SSM_SPEED		?= DEFAULT
SSM_SPEED_SUPPORTED     := FAST DEFAULT
# -----------------------------------------------------------------------------
ifneq ($(SSM_SPEED), $(filter $(SSM_SPEED), $(SSM_SPEED_SUPPORTED)))
    $(call static_error, Unsupported $(B)SSM_SPEED$(N) settings: $(SSM_SPEED))
    $(call static_error, $(B)Supported settings$(N): $(SSM_SPEED_SUPPORTED))
    $(error Aborting...)
else
    $(call static_ok, - $(B)SSM_SPEED$(N) settings: $(SSM_SPEED))
endif

# -----------------------------------------------------------------------------
LINUX               ?= FALSE
# -----------------------------------------------------------------------------

$(call static_info, - $(B)LINUX$(N): $(LINUX))

# -----------------------------------------------------------------------------

CTRL_BLOCK          ?= TRUE
ADAU_EXTERN         ?= 0
ETHERNET            ?= 0
# -----------------------------------------------------------------------------

CTRL_MIDI           ?= 0
CTRL_OSC            ?= 0
CTRL_HTTP           ?= 0

$(call static_info, - $(B)CONTROL_MIDI$(N): $(CTRL_MIDI))
$(call static_info, - $(B)CONTROL_OSC$(N): $(CTRL_OSC))
$(call static_info, - $(B)CONTROL_HTTP$(N): $(CTRL_HTTP))

# -----------------------------------------------------------------------------
#TODO
DEBUG               ?= FALSE
DEBUG_AUDIO_UART    ?= 0
# -----------------------------------------------------------------------------

TARGET              ?= faust

$(call static_info, - $(B)TARGET$(N): $(TARGET))

PREPROCESSOR_HLS    ?= TRUE
PREPROCESSOR_I2S    ?= TRUE

#TODO: verbose & verbose levels

# -----------------------------------------------------------------------------
MULTISAMPLE ?= 0
# -----------------------------------------------------------------------------
ifeq ($(shell expr $(MULTISAMPLE) \> 0), 1)
    $(call static_info, - $(B)MULTISAMPLE$(N) mode (experimental) is $(B)ON$(N))
    $(call static_info, - $(B)FIFO$(N) i/o size: $(MULTISAMPLE) frames)
    BD_TARGET  := $(BD_MULTISAMPLE)
    I2S_SOURCE := $(SOURCE_I2S_DIR)/i2s_template_multisample.vhd
    ifeq ($(TARGET), faust)
        FAUST_HLS_ARCH_FILE = $(SOURCE_HLS_DIR)/faust_dsp_template_multisample.cpp
        I2S_PREPROCESSOR := TRUE
    else
        HLS_SOURCE_MAIN ?= $(SOURCE_HLS_DIR)/template_fir_multisample.cpp
    endif
else
    $(call static_ok, - $(B)ONE_SAMPLE$(N) configuration)
endif

# -----------------------------------------------------------------------------

$(call static_info, - $(B)PREPROCESSOR_HLS$(N): $(PREPROCESSOR_HLS))
$(call static_info, - $(B)PREPROCESSOR_I2S$(N): $(PREPROCESSOR_I2S))

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
FAUST			?= faust
# -----------------------------------------------------------------------------

FAUST_MCD		?= 16
FAUST_DSP_TARGET	?= examples/faust/bypass.dsp
FAUST_DSP_TARGET_NAME   := $(basename $(notdir $(FAUST_DSP_TARGET)))
FAUST_HLS_ARCH_FILE  	?= $(SOURCE_HLS_DIR)/faust_dsp_template.cpp
FAUST_ARM_ARCH_FILE     ?= include/syfala/arm/faust/control.hpp

define parse_data_faust # -----------------------------------------
    cat $(HLS_TARGET_FILE) | grep -oP '(?<=\#define\s$(1)\s)[0-9]+'
endef # -----------------------------------------------------------

define parse_nchannels_cpp # ----------------------------------------
    sed -n '/void\ssyfala/,/)/p' $(HLS_TARGET_FILE) |               \
    grep -oP '$(1)' |                                               \
    wc -l
endef # -------------------------------------------------------------

ifeq ($(TARGET), faust) # -----------------------------------------------------
    ifeq ($(call file_exists, $(FAUST_DSP_TARGET)), 0)
    # Check Faust DSP target file
    # -------------------------------------------------------------------------
          $(call static_error, DSP target                                           \
          ($(FAUST_DSP_TARGET)) does not exist, aborting...)
          $(error abort)
    else
         $(call static_ok, - $(B)FAUST_DSP_TARGET$(N): $(notdir $(FAUST_DSP_TARGET)))
         NCHANNELS_I = $(call parse_data_faust,FAUST_INPUTS)
         NCHANNELS_O = $(call parse_data_faust,FAUST_OUTPUTS)
         NCONTROLS_F = $(call parse_data_faust,FAUST_REAL_CONTROLS)
         NCONTROLS_I = $(call parse_data_faust,FAUST_INT_CONTROLS)
         NCONTROLS_P = $(call parse_data_faust,FAUST_PASSIVES)
    endif
    # -------------------------------------------------------------------------
    ifeq ($(call file_exists, $(FAUST_HLS_ARCH_FILE)), 0)
    # Check Faust HLS architecture file
    # -------------------------------------------------------------------------
          $(call static_error, $(B)FAUST_HLS_ARCH_FILE$(N)                      \
          ($(FAUST_HLS_ARCH_FILE)) does not exist, aborting..)
          $(error abort)
    else
         $(call static_ok, - $(B)FAUST_HLS_ARCH_FILE$(N):                       \
         $(notdir $(FAUST_HLS_ARCH_FILE)))
    endif
    # -------------------------------------------------------------------------
    ifeq ($(call file_exists, $(FAUST_ARM_ARCH_FILE)), 0)
    # Check Faust control/ARM architecture file
    # -------------------------------------------------------------------------
          $(call static_error, $(B)FAUST_ARM_ARCH_FILE$(N)                      \
            ($(FAUST_ARM_ARCH_FILE)) does not exist, aborting..)
          $(error abort)
    else
         $(call static_ok, - $(B)FAUST_ARM_ARCH_FILE$(N):                       \
         $(notdir $(FAUST_ARM_ARCH_FILE)))
    endif
# -----------------------------------------------------------------------------
else ifeq ($(TARGET), cpp)
    # Check CPP HLS source file
# -----------------------------------------------------------------------------
    ifeq ($(call file_exists, $(HLS_SOURCE_MAIN)), 0)
          $(call static_error, $(HLS_SOURCE_MAIN) does not exist, aborting...)
    else
          $(call static_ok, - $(B)HLS_SOURCE_MAIN$(N): $(notdir $(HLS_SOURCE_MAIN)))
          HLS_SOURCE_MAIN   ?= examples/cpp/bypass.cpp
          HLS_FLAGS_INCLUDE ?= "-I$(BUILD_INCLUDE_DIR)"
          NCHANNELS_I ?= $(call parse_nchannels_cpp, sy_ap_int\saudio_in)
          NCHANNELS_O ?= $(call parse_nchannels_cpp, sy_ap_int\*?\saudio_out)
          NCONTROLS_I ?= $(call set_preprocessor_data,0)
          NCONTROLS_F ?= $(call set_preprocessor_data,0)
          NCONTROLS_P ?= $(call set_preprocessor_data,0)
    endif
endif

define check_print_nchannels # ---------------------------------------------------
    $(call shell_ok, Retrieved number of input channels: $(shell $(NCHANNELS_I)))
    $(call shell_ok, Retrieved number of output channels: $(shell $(NCHANNELS_O)))
endef # --------------------------------------------------------------------------

define check_print_ncontrols # ---------------------------------------------------
    $(call shell_ok, Retrieved number of real controls: $(shell $(NCONTROLS_F)))
    $(call shell_ok, Retrieved number of int controls: $(shell $(NCONTROLS_I)))
    $(call shell_ok, Retrieved number of passive controls: $(shell $(NCONTROLS_P)))
endef # --------------------------------------------------------------------------

# -----------------------------------------------------------------------------
.PHONY: hls-target-file
# -----------------------------------------------------------------------------
HLS_TARGET_FILE := $(BUILD_IP_DIR)/syfala_ip.cpp
hls-target-file: $(HLS_TARGET_FILE)

# -----------------------------------------------------------------------------
ifeq ($(TARGET), faust)
# -----------------------------------------------------------------------------

BUILD_FAUST_DSP_TARGET		:= $(BUILD_DIR)/$(FAUST_DSP_TARGET_NAME).dsp
HLS_TARGET_FILE_DEPENDENCIES	+= $(FAUST_HLS_ARCH_FILE)
HLS_TARGET_FILE_DEPENDENCIES	+= $(BUILD_FAUST_DSP_TARGET)
HLS_FLAGS_INCLUDE               := "-I$(BUILD_INCLUDE_DIR)"

# ----------------------------------------------------------------------------
# $(TARGET) = 'faust' only
# Copy faust target into build directory, remove all previous targets
# This allows the toolchain to re-build hw & sw when the
# Faust dsp file target changes
# ----------------------------------------------------------------------------
$(BUILD_FAUST_DSP_TARGET): $(FAUST_DSP_TARGET)
	@mkdir -p $(BUILD_DIR)
	@touch $(FAUST_DSP_TARGET)
	@rm -rf $(wildcard $(BUILD_DIR)/*.dsp)
	@cp -r $(FAUST_DSP_TARGET) $(BUILD_FAUST_DSP_TARGET)

# ----------------------------------------------------------------------------
# Generate the HLS target cpp (syfala_ip.cpp) file from the Faust compiler
# using the 'os2' mode and the selected architecture file.
# If $(TARGET) is 'cpp', $(HLS_SOURCE_MAIN) is only copied into the build dir.
# If $(PREPROCESSOR_HLS) is 'TRUE':
# run the preprocessor.tcl script file, it will set several things:
# - the number of input/output ports (top-level arguments).
# - the number of real/int & passive control arrays passed from/to the ARM
#   through the Axilite protocol.
# ----------------------------------------------------------------------------
$(HLS_TARGET_FILE): $(HLS_TARGET_FILE_DEPENDENCIES)
	$(call shell_info, Generating $(B)HLS$(N) source from   \
                           the $(B)Faust$(N) compiler)
	@mkdir -p $(BUILD_IP_DIR)
	@$(FAUST) $(FAUST_DSP_TARGET)	    \
	    -lang c			    \
	    -light			    \
	    -os2			    \
	    -uim			    \
	    -mcd $(FAUST_MCD)		    \
	    -t 0			    \
	    -a $(FAUST_HLS_ARCH_FILE)	    \
	    -o $(HLS_TARGET_FILE)

# -----------------------------------------------------------------------------
else ifeq ($(TARGET), cpp)
# ------------------------------------------------------------------------------
HLS_TARGET_FILE_DEPENDENCIES += $(HLS_SOURCE_MAIN)

$(HLS_TARGET_FILE): $(HLS_TARGET_FILE_DEPENDENCIES)
	$(call shell_info, Copying file $(notdir $(HLS_SOURCE_MAIN)) \
                           to build/syfala_ip.cpp)
	@mkdir -p $(BUILD_IP_DIR)
	@cp -r $(HLS_SOURCE_MAIN) $(HLS_TARGET_FILE)
endif

# -----------------------------------------------------------------------------
.PHONY: hls-includes
# -----------------------------------------------------------------------------
SYFALA_CONFIG_H		:= $(INCLUDE_DIR)/syfala/config.hpp
SYFALA_UTILITIES_H	:= $(INCLUDE_DIR)/syfala/utilities.hpp
BUILD_SYFALA_CONFIG_H	:= $(BUILD_INCLUDE_DIR)/syfala/config.hpp

HLS_INCLUDES += $(BUILD_SYFALA_CONFIG_H)
HLS_INCLUDES += $(BUILD_INCLUDE_DIR)/syfala/utilities.hpp

hls-includes: $(HLS_INCLUDES)

define set_config_definition # ------------------------------------------------
    $(call shell_info, Setting #define $(B)$(1)$(N) $(2))
    @sed -i 's/^#define\s$(1)\s[0-9]\+/#define $(1) $(2)/g' $(BUILD_SYFALA_CONFIG_H)
endef # -----------------------------------------------------------------------

$(HLS_INCLUDES): $(SYFALA_CONFIG_H)
	$(call shell_info, Preparing $(B)HLS$(N) sources...)
	@mkdir -p $(BUILD_INCLUDE_DIR)/syfala
	@cp -r $(SYFALA_CONFIG_H) $(BUILD_SYFALA_CONFIG_H)
	@cp -r $(SYFALA_UTILITIES_H) $(BUILD_INCLUDE_DIR)/syfala/utilities.hpp
	$(call set_config_definition,SYFALA_BOARD,$(BOARD_CPP_ID))
	$(call set_config_definition,SYFALA_SAMPLE_RATE,$(SAMPLE_RATE))
	$(call set_config_definition,SYFALA_SAMPLE_WIDTH,$(SAMPLE_WIDTH))
	$(call set_config_definition,SYFALA_SSM_VOLUME,$(SSM_VOLUME))
	$(call set_config_definition,SYFALA_SSM_SPEED,$(SSM_SPEED))
	$(call set_config_definition,SYFALA_MEMORY_USE_DDR,$(DDR))
	$(call set_config_definition,SYFALA_ADAU_EXTERN,$(ADAU_EXTERN))
	$(call set_config_definition,SYFALA_DEBUG_AUDIO_UART,$(DEBUG_AUDIO_UART))
	$(call set_config_definition,SYFALA_CONTROL_MIDI,$(CTRL_MIDI))
	$(call set_config_definition,SYFALA_CONTROL_OSC,$(CTRL_OSC))
	$(call set_config_definition,SYFALA_CONTROL_HTTP,$(CTRL_HTTP))
	$(call set_config_definition,SYFALA_BLOCK_NSAMPLES,$(MULTISAMPLE))
ifneq ($(TARGET), faust)
	$(call set_config_definition,SYFALA_FAUST_TARGET,0)
	$(call set_config_definition,SYFALA_CONTROL_BLOCK,0)
endif

# -----------------------------------------------------------------------------
.PHONY: hls
# -----------------------------------------------------------------------------

HLS_OUTPUT  := $(BUILD_IP_DIR)/syfala/impl/vhdl/syfala.vhd

HLS_PATH	    ?= $(XILINX_ROOT_DIR)/Vitis_HLS/$(XILINX_VERSION)
HLS_EXEC	    := $(HLS_PATH)/bin/vitis_hls
HLS_DEPENDENCIES    := $(HLS_INCLUDES) $(HLS_TARGET_FILE)
HLS_REPORT	    := $(BUILD_IP_DIR)/syfala/syn/report/syfala_csynth.rpt
HLS_TOP_LEVEL	    := syfala
ADD_FILES_CMD       += add_files $(HLS_TARGET_FILE)
ADD_FILES_CMD       += -cflags $(HLS_FLAGS_INCLUDE);

ifeq ($(HLS_DIRECTIVES_UNSAFE_MATH_OPTIMIZATIONS), TRUE) # ---------
    HLS_DIRECTIVES += config_compile -unsafe_math_optimizations=true
endif # ------------------------------------------------------------

ifdef HLS_SOURCE_FILES # -----------------------------
    ADD_FILES_CMD  += add_files "$(HLS_SOURCE_FILES)";
endif # ----------------------------------------------

# -----------------------------------------------------------------------------
HLS_COMMAND := cd $(BUILD_DIR);                                                 \
	       open_project -reset $(notdir $(BUILD_IP_DIR));                   \
               $(ADD_FILES_CMD)                                                 \
	       set_top $(HLS_TOP_LEVEL);                                        \
	       open_solution -reset $(HLS_TOP_LEVEL) -flow_target vivado;       \
	       set_part $(BOARD_PART);                                          \
	       create_clock -period $(HLS_CLOCK_PERIOD);                        \
	       $(HLS_DIRECTIVES);						\
	       csynth_design;                                                   \
	       export_design -rtl vhdl -format ip_catalog;                      \
	       exit;
# -----------------------------------------------------------------------------

hls: $(HLS_OUTPUT)

$(HLS_OUTPUT): $(HLS_DEPENDENCIES)
ifeq ($(PREPROCESSOR_HLS), TRUE) # ----------------------------------------------------
	$(call shell_info, Running $(B)preprocessor$(N) on  \
                           $(B)HLS$(N) target file ($(notdir $(HLS_TARGET_FILE))))
	$(call check_print_nchannels)
	$(call check_print_ncontrols)
	@tclsh $(SCRIPT_PREPROCESSOR) --hls		    \
                            $(HLS_TARGET_FILE)		    \
                            $(shell $(NCHANNELS_I))         \
                            $(shell $(NCHANNELS_O))         \
                            $(shell $(NCONTROLS_F))         \
                            $(shell $(NCONTROLS_I))         \
                            $(shell $(NCONTROLS_P))         \
                            $(MULTISAMPLE)
endif # -------------------------------------------------------------------------------
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file $(notdir $(HLS_TARGET_FILE)))
	@echo '$(HLS_COMMAND)' | $(HLS_EXEC) -i
	$(call shell_ok, High-level synthesis done)

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
ifeq ($(CONFIG_EXPERIMENTAL_ETHERNET), TRUE)
# TODO: refactor/clean-up
# -----------------------------------------------------------------------------

ETHERNET_HLS_SOURCE	:= $(SOURCE_HLS_DIR)/ethernet.cpp
BUILD_ETHERNET_HLS_DIR	:= $(BUILD_DIR)/ethernet
ETHERNET_HLS_TARGET	:= $(BUILD_ETHERNET_HLS_DIR)/ethernet.cpp
ETHERNET_HLS_TOP_LEVEL	:= eth_audio
ETHERNET_HLS_OUTPUT	:= $(BUILD_ETHERNET_HLS_DIR)/$(ETHERNET_HLS_TOP_LEVEL)/impl/vhdl/$(ETHERNET_HLS_TOP_LEVEL).vhd

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

$(ETHERNET_HLS_OUTPUT): $(HLS_DEPENDENCIES) $(ETHERNET_HLS_SOURCE)
	@mkdir -p $(BUILD_ETHERNET_HLS_DIR)
	@cp -r $(ETHERNET_HLS_SOURCE) $(ETHERNET_HLS_TARGET)
ifeq ($(PREPROCESSOR_HLS), TRUE) # ----------------------------------------------------
	$(call shell_info, Running $(B)preprocessor$(N) on      \
                           $(B)HLS$(N) target file              \
                           ($(notdir $(ETHERNET_HLS_TARGET))))
	@tclsh $(SCRIPT_PREPROCESSOR) --hls                     \
                            $(ETHERNET_HLS_TARGET)              \
                            $(shell $(NCHANNELS_I))             \
                            $(shell $(NCHANNELS_O))             \
                            0 0 0                               \
                            $(MULTISAMPLE)
endif # -------------------------------------------------------------------------------
	$(call shell_info, Running $(B)Vitis_HLS$(N) on file    \
                           $(notdir $(ETHERNET_HLS_TARGET)))
	@echo '$(ETHERNET_HLS_COMMAND)' | $(HLS_EXEC) -i
	$(call shell_ok, High-level synthesis done)
endif

# -----------------------------------------------------------------------------
ifeq ($(TARGET), faust2vhdl)
# -----------------------------------------------------------------------------

FAUST_VHDL_OUTPUT := $(BUILD_RTL_DIR)/faust.vhd

$(FAUST_VHDL_OUTPUT): $(BUILD_FAUST_DSP_TARGET)
	$(call shell_info, Generating $(B)HLS$(N) source from   \
	                   the $(B)Faust$(N) compiler)
	@mkdir -p $(BUILD_IP_DIR)
	@$(FAUST) $(FAUST_DSP_TARGET)	    \
	    -lang vhdl			    \
	    -o $(FAUST_VHDL_OUTPUT)
endif

# -----------------------------------------------------------------------------
.PHONY: i2s
# -----------------------------------------------------------------------------

I2S_SOURCE ?= $(SOURCE_I2S_DIR)/i2s_template.vhd
I2S_TARGET := $(BUILD_RTL_DIR)/i2s_transceiver.vhd

i2s: $(I2S_TARGET)

ifeq ($(call file_exists, $(I2S_SOURCE)), 1) # -----------------------
      $(call static_ok, - $(B)I2S_SOURCE$(N): $(notdir $(I2S_SOURCE)))
else # ---------------------------------------------------------------
      $(call static_error, - $(B)I2S_SOURCE$(N) file does not exist \
            $(I2S_SOURCE))
      $(error abort)
endif # --------------------------------------------------------------

ifeq ($(PREPROCESSOR_I2S), TRUE) # ----------------------------------
$(I2S_TARGET): $(I2S_SOURCE) $(HLS_OUTPUT)
	@mkdir -p $(BUILD_RTL_DIR)
	$(call shell_info, Running $(B)preprocessor$(N) on          \
	    $(B)I2S$(N) template ($(notdir $(I2S_TARGET))))
	@tclsh $(SCRIPT_PREPROCESSOR) --i2s $(I2S_SOURCE)           \
                                            $(I2S_TARGET)           \
					    $(shell $(NCHANNELS_I)) \
					    $(shell $(NCHANNELS_O)) \
					    $(SAMPLE_WIDTH)         \
					    $(MULTISAMPLE)
else # --------------------------------------------------------------
$(I2S_TARGET): $(I2S_SOURCE) $(HLS_TARGET_FILE)
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
	$(foreach rtl,$(RTL_SOURCES),	\
	    $(call shell_ok, Added $(notdir $(rtl)) to $(B)RTL targets$(N)))

# -----------------------------------------------------------------------------
.PHONY: project
# -----------------------------------------------------------------------------

BUILD_PROJECT_DIR       := $(BUILD_DIR)/syfala_project
PROJECT_DEPENDENCIES	+= $(SCRIPT_PROJECT)
PROJECT_DEPENDENCIES	+= $(BD_TARGET)
PROJECT_DEPENDENCIES	+= $(RTL_TARGETS)
PROJECT_DEPENDENCIES	+= $(I2S_TARGET)

# ------------------------------------------------------------------------
VIVADO_PATH     ?= $(XILINX_ROOT_DIR)/Vivado/$(XILINX_VERSION)
VIVADO_EXEC     := $(VIVADO_PATH)/bin/vivado
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
# ------------------------------------------------------------------------

ifeq ($(TARGET), faust2vhdl) # -------------------
    PROJECT_DEPENDENCIES += $(FAUST_VHDL_OUTPUT)
else # -------------------------------------------
    PROJECT_DEPENDENCIES += $(HLS_OUTPUT)
endif # ------------------------------------------
ifeq (ETHERNET, $(filter ETHERNET, $(CONFIG)))
    PROJECT_DEPENDENCIES += $(ETHERNET_HLS_OUTPUT)
endif # ------------------------------------------

PROJECT_OUTPUT  := $(BUILD_PROJECT_DIR)/syfala_project.gen/sources_1/bd/main/hdl/main_wrapper.vhd
PROJECT_OUTPUT	+= $(BUILD_PROJECT_DIR)/syfala_project.srcs/sources_1/bd/main/main.bd
PROJECT_FILE	:= $(BUILD_PROJECT_DIR)/syfala_project.xpr

project: $(PROJECT_OUTPUT)

$(PROJECT_OUTPUT): $(PROJECT_DEPENDENCIES)
	$(call shell_info, Generating $(B)Vivado project$(N))
	@mkdir -p $(BUILD_PROJECT_DIR)
	$(VIVADO_EXEC) $(VIVADO_CMD_ARGUMENTS) \
                       $(shell $(NCHANNELS_I)) \
                       $(shell $(NCHANNELS_O))
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

SOURCE_ARM_DIR                     := $(SOURCE_DIR)/arm
SOURCE_ARM_BAREMETAL_DIR           := $(SOURCE_ARM_DIR)/baremetal
SOURCE_ARM_BAREMETAL_LINKERS_DIR   := $(SOURCE_ARM_BAREMETAL_DIR)/linkers
SOURCE_ARM_BAREMETAL_MODULES_DIR   := $(SOURCE_ARM_BAREMETAL_DIR)/modules

ARM_BAREMETAL_CPP_MODULES           = $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/audio.cpp
ARM_BAREMETAL_CPP_MODULES          += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/gpio.cpp
ARM_BAREMETAL_CPP_MODULES          += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/ip.cpp
ARM_BAREMETAL_CPP_MODULES          += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/memory.cpp
ARM_BAREMETAL_CPP_MODULES          += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/spi.cpp
ARM_BAREMETAL_CPP_MODULES          += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/uart.cpp

ARM_BAREMETAL_CPP_MAIN_STD         := $(SOURCE_ARM_BAREMETAL_DIR)/arm.cpp
ARM_BAREMETAL_CPP_MAIN_MINIMAL     := $(SOURCE_ARM_BAREMETAL_DIR)/arm_minimal.cpp
ARM_BAREMETAL_CPP_MAIN             ?= $(SOURCE_ARM_BAREMETAL_DIR)/arm.cpp

XSOURCES_DIR        := $(BUILD_IP_DIR)/syfala/impl/ip/drivers/syfala_v1_0/src
XSOURCES	    := $(wildcard $(XSOURCES_DIR)/*.c) $(wildcard $(XSOURCES_DIR)/*.h)

ifeq ($(TARGET), faust) # ---------------------------------------------
    HOST_MAIN_SOURCE    ?= $(ARM_BAREMETAL_CPP_MAIN_STD)
    SCRIPT_HOST_CONFIG  := 0
else # minimal configuration ------------------------------------------
    HOST_MAIN_SOURCE    ?= $(ARM_BAREMETAL_CPP_MAIN_MINIMAL)
    SCRIPT_HOST_CONFIG  := 1
endif # ---------------------------------------------------------------

VITIS_PATH := $(XILINX_ROOT_DIR)/Vitis/$(XILINX_VERSION)
VITIS_EXEC := $(VITIS_PATH)/bin/xsct

VITIS_CMD_ARGUMENTS := $(SCRIPT_HOST_CONFIG)	\
		       $(BOARD)			\
		       $(HOST_MAIN_SOURCE)

# -----------------------------------------------------------------------------
ifeq ($(TARGET), faust)
# -----------------------------------------------------------------------------
.PHONY: faust-control-source
# -----------------------------------------------------------------------------
FAUST_CONTROL_SOURCE  := $(BUILD_INCLUDE_DIR)/syfala/arm/faust/control.hpp

faust-control-source: $(FAUST_CONTROL_SOURCE)

$(FAUST_CONTROL_SOURCE): $(FAUST_ARM_ARCH_FILE) $(BUILD_FAUST_DSP_TARGET)
	$(call shell_info, Generating $(B)Host control sources$(N))
	@mkdir -p build/include/syfala/arm/faust
	$(FAUST) $(FAUST_DSP_TARGET)	\
	    -i				\
	    -lang cpp			\
	    -os2			\
	    -uim			\
	    -mcd $(FAUST_MCD)		\
	    -t 0			\
	    -a $(FAUST_ARM_ARCH_FILE)	\
	    -o $(FAUST_CONTROL_SOURCE)
endif

# -----------------------------------------------------------------------------
.PHONY: host-includes
# -----------------------------------------------------------------------------

HOST_INCLUDES       := $(wildcard include/syfala/arm/*.hpp)
BUILD_HOST_INCLUDES := $(foreach hpp, $(HOST_INCLUDES), $(BUILD_DIR)/$(hpp))

host-includes: $(BUILD_HOST_INCLUDES)

$(BUILD_HOST_INCLUDES): $(HOST_INCLUDES)
	@mkdir -p build/include/syfala/arm
	@cp -r $(HOST_INCLUDES) $(BUILD_DIR)/include/syfala/arm/
	@cp -r include/syfala/arm/codecs $(BUILD_DIR)/include/syfala/arm/

# -----------------------------------------------------------------------------
.PHONY: host-application
# -----------------------------------------------------------------------------

HOST_APPLICATION    := $(BUILD_SW_EXPORT_DIR)/application.elf
HOST_DEPENDENCIES   += $(SCRIPT_HOST)
HOST_DEPENDENCIES   += $(HW_PLATFORM)
HOST_DEPENDENCIES   += $(BUILD_HOST_INCLUDES)
HOST_DEPENDENCIES   += $(HOST_MAIN_SOURCE)

ifeq ($(TARGET), faust) # ----------------------
    HOST_DEPENDENCIES += $(FAUST_CONTROL_SOURCE)
endif # ----------------------------------------

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
.PHONY: gui
# -----------------------------------------------------------------------------

BUILD_GUI_DIR := $(BUILD_DIR)/gui

GUI_APPLICATION := $(BUILD_GUI_DIR)/faust-uart-control
GUI_APPLICATION_ARCH_FILE := $(SOURCE_DIR)/remote/faust-uart-control-arch.cpp
GUI_APPLICATION_SOURCE := $(GUI_APPLICATION).cpp
GUI_APPLICATION_PKGC_FLAGS := $(shell pkg-config --libs --cflags gtk+-2.0 libmicrohttpd)
GUI_APPLICATION_CXX_FLAGS += $(GUI_APPLICATION_PKGC_FLAGS)
GUI_APPLICATION_CXX_FLAGS += -Iinclude
GUI_APPLICATION_CXX_FLAGS += -std=c++17

ifeq ($(CTRL_HTTP), 1) # ---------------------------------
    GUI_APPLICATION_CXX_FLAGS += -lHTTPDFaust -lmicrohttpd
endif
ifeq ($(CTRL_MIDI), 1) # ---------------------------------
    GUI_APPLICATION_CXX_FLAGS += -lasound
endif
ifeq ($(CTRL_OSC), 1) # ----------------------------------
    GUI_APPLICATION_CXX_FLAGS += -llo -lOSCFaust
endif # --------------------------------------------------

gui: $(GUI_APPLICATION)

$(GUI_APPLICATION_SOURCE): $(GUI_APPLICATION_ARCH_FILE)
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
.PHONY: flash
# -----------------------------------------------------------------------------
FLASH_JTAG_TARGET ?= /dev/ttyUSB1

ifeq ($(call dev_exists, $(FLASH_JTAG_TARGET)),1)
flash:
	$(call shell_info, Flashing build with JTAG)
	$(VITIS_EXEC) $(SCRIPT_FLASH_JTAG) $(BOARD) $(XILINX_ROOT)
else
flash:
	$(call shell_error, Could not find device $(FLASH_JTAG_TARGET))
endif

# -----------------------------------------------------------------------------
# LINUX
# -----------------------------------------------------------------------------

BUILD_LINUX_DIR                 := $(PWD)/build-linux
BUILD_LINUX_BUILD_DIR           := $(BUILD_LINUX_DIR)/build
BUILD_LINUX_OUTPUT_DIR          := $(BUILD_LINUX_DIR)/output
BUILD_LINUX_OUTPUT_BOOT_DIR     := $(BUILD_LINUX_OUTPUT_DIR)/boot
BUILD_LINUX_BOOT_DIR            := $(BUILD_LINUX_BUILD_DIR)/boot
BUILD_LINUX_ROOT_DIR		:= $(BUILD_LINUX_BUILD_DIR)/root
BUILD_LINUX_OUTPUT_ROOT_DIR	:= $(BUILD_LINUX_OUTPUT_DIR)/root
XILINX_GITHUB                   := https://github.com/Xilinx

# -----------------------------------------------------------------------------
.PHONY: uboot
# -----------------------------------------------------------------------------
# Cloning and compiling Xilinx' u-boot repository
# https://github.com/Xilinx/u-boot-xlnx
# branch/tag xilinx-v2022.2
# It will generate the First Stage Boot Loader (FSBL), and the
# Secondary Program Loader (SPL) included in the main 'boot.bin' binary
# and the u-boot.img image.
# Outputs:
# - boot.bin
# - spl/u-boot.img

UBOOT_DIR	:= $(BUILD_LINUX_BOOT_DIR)/u-boot-xlnx-xilinx-v2022.2
UBOOT_ZIP	:= $(BUILD_LINUX_BOOT_DIR)/xilinx-uboot-v2022.2.zip
UBOOT_SOURCES	:= $(XILINX_GITHUB)/u-boot-xlnx/archive/refs/tags/xilinx-v2022.2.zip
UBOOT_BIN_SRC	:= $(UBOOT_DIR)/spl/boot.bin
UBOOT_BIN_DST	:= $(BUILD_LINUX_OUTPUT_BOOT_DIR)/boot.bin
UBOOT_DTB_SRC	:= $(UBOOT_DIR)/u-boot.img
UBOOT_DTB_DST	:= $(BUILD_LINUX_OUTPUT_BOOT_DIR)/u-boot.img

ifeq ($(BOARD_FAMILY), ZYNQ_7000) # -----------------------------------------
    UBOOT_CFG_TARGET := "xilinx_zynq_virt_defconfig"
else # ----------------------------------------------------------------------
    $(call static_error, No Linux support for board model $(BOARD), aborting)
    $(error syfala)
endif # ---------------------------------------------------------------------

$(UBOOT_DIR):
	$(call shell_info, Extracting $(B)u-boot$(N) sources)
	@mkdir -p $(BUILD_LINUX_BOOT_DIR)
	@curl -L $(UBOOT_SOURCES) -o $(UBOOT_ZIP)
	@unzip -q $(UBOOT_ZIP) -d $(BUILD_LINUX_BOOT_DIR)
	@rm -rf $(UBOOT_ZIP)

uboot: $(UBOOT_BIN_DST)

$(UBOOT_BIN_DST): $(UBOOT_DIR)
	$(call shell_info, Compiling $(B)u-boot$(N))
	@export ARCH=arm			\
     && export CROSS_COMPILE=arm-none-eabi-	\
     && export DEVICE_TREE=zynq-zybo-z7         \
     && cd $(UBOOT_DIR)                         \
     && make distclean                          \
     && make $(UBOOT_CFG_TARGET)                \
     && make -j8
	@mkdir -p $(BUILD_LINUX_OUTPUT_BOOT_DIR)
	@cp -r $(UBOOT_BIN_SRC) $(UBOOT_BIN_DST)
	@cp -r $(UBOOT_DTB_SRC) $(UBOOT_DTB_DST)

# -----------------------------------------------------------------------------
.PHONY: kernel
# -----------------------------------------------------------------------------

KERNEL_VERSION	    := 5.15.0-xilinx
KERNEL_XTAG         := xilinx-v2022.2
KERNEL_SRC	    := $(XILINX_GITHUB)/linux-xlnx/archive/refs/tags/$(KERNEL_XTAG).zip
KERNEL_ZIP	    := $(BUILD_LINUX_BOOT_DIR)/xilinx-kernel-v2022.2.zip
KERNEL_SRC_DIR	    := $(BUILD_LINUX_BOOT_DIR)/linux-xlnx-xilinx-v2022.2
KERNEL_UIMAGE_SRC   := $(KERNEL_SRC_DIR)/arch/arm/boot/uImage
KERNEL_UIMAGE_DST   := $(BUILD_LINUX_OUTPUT_BOOT_DIR)/uImage
KERNEL_CONFIG_DST   := $(KERNEL_SRC_DIR)/arch/arm/configs

ifeq ($(BOARD_FAMILY), ZYNQ_7000) # ------------------------------------
    KERNEL_CONFIG_SRC   := $(SOURCE_LINUX_DIR)/configs/zybo_z7_defconfig
else # -----------------------------------------------------------------
    $(call static_error, No Linux support for board model $(BOARD), aborting)
    $(error syfala)
endif # ----------------------------------------------------------------

$(KERNEL_SRC_DIR):
	@mkdir -p $(BUILD_LINUX_BOOT_DIR)
	@curl -L $(KERNEL_SRC) -o $(KERNEL_ZIP)
	@unzip -q $(KERNEL_ZIP) -d $(BUILD_LINUX_BOOT_DIR)
	@rm -rf $(KERNEL_ZIP)

kernel: $(KERNEL_UIMAGE_DST)

$(KERNEL_UIMAGE_DST): $(KERNEL_SRC_DIR)
	$(call shell_info, Compiling Linux Kernel $(KERNEL_VERSION))
	@cp -r $(KERNEL_CONFIG_SRC) $(KERNEL_CONFIG_DST)
	@cd $(KERNEL_SRC_DIR)		     \
     && export ARCH=arm			     \
     && export CROSS_COMPILE=arm-none-eabi-  \
     && make zybo_z7_defconfig               \
     && make UIMAGE_LOADADDR=0x8000          \
             CFLAGS=-O2                      \
             uImage                          \
             modules                         \
        -j8
	@cp -r $(KERNEL_UIMAGE_SRC) $(KERNEL_UIMAGE_DST)

# -----------------------------------------------------------------------------
.PHONY: kernel-modules
# -----------------------------------------------------------------------------

KERNEL_MODULES_TAR := $(KERNEL_SRC_DIR)/modules.tar
KERNEL_MODULES_CMD_SH = $(shell cd $(KERNEL_SRC_DIR) && find . -name *.ko)
KERNEL_MODULES_CMD_EV = $(eval KERNEL_MODULES=$(KERNEL_MODULES_CMD_SH))

kernel-modules: $(KERNEL_MODULES_TAR)

$(KERNEL_MODULES_TAR): $(KERNEL_UIMAGE_DST)
	$(call shell_info, Extracting Kernel modules)
	$(KERNEL_MODULES_CMD_EV)
	@cd $(KERNEL_SRC_DIR) &&    \
	    tar -zcf modules.tar $(KERNEL_MODULES) --owner=0 --group=0

# -----------------------------------------------------------------------------
.PHONY: device-tree
# -----------------------------------------------------------------------------

BUILD_DT_DIR := $(BUILD_LINUX_BOOT_DIR)/device-tree
DTS_DIR := $(BUILD_DT_DIR)/dts
DTS_SRC := $(SOURCE_LINUX_DIR)/device-tree/system.dts
DTS_DST := $(DTS_DIR)/system.dts
DTB_SRC := $(BUILD_DTS_DIR)/system.dtb
DTB_DST := $(BUILD_LINUX_OUTPUT_BOOT_DIR)/system.dtb

$(DTS_DST): $(DTS_SRC)
	$(call shell_info, Compiling $(B)device-tree sources$(N) with gcc)
	@mkdir -p $(DTS_DIR)
	@gcc -I $(BUILD_DT_DIR) -E -nostdinc	\
	     -undef -D__DTS__			\
	     -x assembler-with-cpp		\
	     -o $(DTS_DST)			\
	     $(DTS_SRC)

device-tree: $(DTB_DST)

$(DTB_DST): $(DTS_DST)
	$(call shell_info, Compiling $(B)device-tree blob$(N))
	@mkdir -p $(BUILD_LINUX_OUTPUT_BOOT_DIR)
	@dtc -I dts -O dtb			\
	     -o $(DTB_DST)			\
	     $(DTS_DST)

# -----------------------------------------------------------------------------
.PHONY: bootscript
# -----------------------------------------------------------------------------

BOOT_SCRIPT_SRC := $(SOURCE_LINUX_DIR)/boot.cmd
BOOT_SCRIPT_DST := $(BUILD_LINUX_OUTPUT_BOOT_DIR)/boot.scr
UBOOT_MKIMAGE	:= $(UBOOT_DIR)/tools/mkimage

bootscript: $(BOOT_SCRIPT_DST)

$(BOOT_SCRIPT_DST): $(UBOOT_MKIMAGE) $(BOOT_SCRIPT_SRC)
	$(call shell_info, Signing & Exporting $(B)boot script$(N))
	$(UBOOT_MKIMAGE) -c none		\
			 -A arm			\
			 -T script		\
			 -d $(BOOT_SCRIPT_SRC)	\
			 $(BOOT_SCRIPT_DST)

# -----------------------------------------------------------------------------
.PHONY: bootstream
# -----------------------------------------------------------------------------
BOOTSTREAM := $(BUILD_LINUX_OUTPUT_BOOT_DIR)/system.bit

bootstream: $(BOOTSTREAM)

$(BOOTSTREAM): $(BITSTREAM)
	$(call shell_info, Copying bitstream in boot output directory)
	@cp -r $(BITSTREAM) $(BOOTSTREAM)

# -----------------------------------------------------------------------------

.PHONY: linux-boot
linux-boot: uboot kernel device-tree bootscript bootstream

# -----------------------------------------------------------------------------
# ROOT
# -----------------------------------------------------------------------------
ALPINE_VERSION_MAJOR	:= 3
ALPINE_VERSION_MINOR	:= 17
ALPINE_VERSION_PATCH	:= 3
ALPINE_VERSION_DATE	:= 20221214
ALPINE_VERSION		:= $(ALPINE_VERSION_MAJOR).$(ALPINE_VERSION_MINOR)
ALPINE_VERSION_FULL	:= $(ALPINE_VERSION).$(ALPINE_VERSION_PATCH)
ALPINE_BUILD_DIR	:= $(BUILD_LINUX_ROOT_DIR)/alpine-$(ALPINE_VERSION_FULL)
# -----------------------------------------------------------------------------
ALPINE_ROOT_DIR		:= $(ALPINE_BUILD_DIR)/alpine-root
ALPINE_TARGET_URL	:= http://dl-cdn.alpinelinux.org/alpine/v$(ALPINE_VERSION)
ALPINE_EDGE_TARGET_URL	:= http://dl-cdn.alpinelinux.org/alpine/edge
# -----------------------------------------------------------------------------
ALPINE_UBOOT		:= alpine-uboot-$(ALPINE_VERSION_FULL)-armv7.tar.gz
ALPINE_UBOOT_URL	:= $(ALPINE_TARGET_URL)/releases/armv7/$(ALPINE_UBOOT)
ALPINE_UBOOT_FILE	:= $(ALPINE_BUILD_DIR)/$(ALPINE_UBOOT)
ALPINE_UBOOT_DIR	:= $(ALPINE_BUILD_DIR)/alpine-uboot
# -----------------------------------------------------------------------------
ALPINE_APK_TOOLS	:= apk-tools-static-2.12.10-r1.apk
ALPINE_APK_TOOLS_URL	:= $(ALPINE_TARGET_URL)/main/armv7/$(ALPINE_APK_TOOLS)
ALPINE_APK_TOOLS_FILE	:= $(ALPINE_BUILD_DIR)/$(ALPINE_APK_TOOLS)
ALPINE_APK_TOOLS_DIR	:= $(ALPINE_BUILD_DIR)/alpine-tools
# -----------------------------------------------------------------------------
ALPINE_FIRMWARE		:= linux-firmware-other-$(ALPINE_VERSION_DATE)-r1.apk
ALPINE_FIRMWARE_FILE	:= $(ALPINE_BUILD_DIR)/$(ALPINE_FIRMWARE)
ALPINE_FIRMWARE_URL	:= $(ALPINE_TARGET_URL)/main/armv7/$(ALPINE_FIRMWARE)
# -----------------------------------------------------------------------------
ALPINE_ADDITIONAL_FIRMWARE += linux-firmware-ath9k_htc-$(ALPINE_VERSION_DATE)-r1.apk
ALPINE_ADDITIONAL_FIRMWARE += linux-firmware-brcm-$(ALPINE_VERSION_DATE)-r1.apk
ALPINE_ADDITIONAL_FIRMWARE += linux-firmware-rtlwifi-$(ALPINE_VERSION_DATE)-r1.apk
# -----------------------------------------------------------------------------
RESOLV_SOURCE := /run/systemd/resolve/stub-resolv.conf
RESOLV_TARGET := $(ALPINE_ROOT_DIR)/etc/resolv.conf
# -----------------------------------------------------------------------------
QEMU_SOURCE := /usr/bin/qemu-arm-static
QEMU_TARGET := $(ALPINE_ROOT_DIR)$(QEMU_SOURCE)
# -----------------------------------------------------------------------------
ALPINE_BASE += $(ALPINE_ROOT_DIR)/sbin/apk.static
ALPINE_BASE += $(RESOLV_TARGET)
ALPINE_BASE += $(QEMU_TARGET)
# -----------------------------------------------------------------------------
ALPINE_REPOSITORY_MAIN              := $(ALPINE_TARGET_URL)/main
ALPINE_REPOSITORY_COMMUNITY         := $(ALPINE_TARGET_URL)/community
ALPINE_REPOSITORY_EDGE_MAIN         := $(ALPINE_EDGE_TARGET_URL)/main
ALPINE_REPOSITORY_EDGE_COMMUNITY    := $(ALPINE_EDGE_TARGET_URL)/community
ALPINE_REPOSITORY_EDGE_TESTING      := $(ALPINE_EDGE_TARGET_URL)/testing
# -----------------------------------------------------------------------------

ALPINE_SOURCES += $(ALPINE_UBOOT_DIR)
ALPINE_SOURCES += $(ALPINE_APK_TOOLS_DIR)
ALPINE_SOURCES += $(ALPINE_FIRMWARE_DIR)
ALPINE_SOURCES += $(RESOLV_SOURCE)
ALPINE_SOURCES += $(QEMU_SOURCE)

# -----------------------------------------------------------------------------
.PHONY: alpine-sources
# -----------------------------------------------------------------------------
alpine-sources: $(ALPINE_SOURCES)

$(ALPINE_SOURCES):
	$(call shell_info, Fetching $(B)Alpine Linux$(N) sources)
	@mkdir -p $(ALPINE_UBOOT_DIR)
	@mkdir -p $(ALPINE_APK_TOOLS_DIR)
	$(call shell_info, Downloading alpine u-boot)
	@curl -o $(ALPINE_UBOOT_FILE)				    \
	      -L $(ALPINE_UBOOT_URL)
	$(call shell_info, Downloading alpine apk-tools)
	@curl -o $(ALPINE_APK_TOOLS_FILE)			    \
	      -L $(ALPINE_APK_TOOLS_URL)
	$(call shell_info, Downloading Linux firmware)
	@curl -o $(ALPINE_FIRMWARE_FILE)			    \
	      -L $(ALPINE_FIRMWARE_URL)
	$(call shell_info, Extracting u-boot)
	@tar -zxf $(ALPINE_UBOOT_FILE)				    \
	     --directory=$(ALPINE_UBOOT_DIR)
	$(call shell_info, Extracting apk-tools)
	@tar -zxf $(ALPINE_APK_TOOLS_FILE)			    \
	    --directory=$(ALPINE_APK_TOOLS_DIR)			    \
	    --warning=no-unknown-keyword
	$(call shell_info, Downloading additional firmware)
	@$(foreach firmware, $(ALPINE_ADDITIONAL_FIRMWARE),	    \
	     curl -o $(ALPINE_BUILD_DIR)/$(firmware)		    \
		  -L $(ALPINE_TARGET_URL)/main/armv7/$(firmware);   \
	)

define chroot # ------------------------------------
    @sudo chroot $(ALPINE_ROOT_DIR) /bin/sh -c '$(1)'
endef # --------------------------------------------

# -----------------------------------------------------------------------------
.PHONY: alpine-base
# -----------------------------------------------------------------------------

alpine-base: $(ALPINE_BASE)

$(ALPINE_BASE): $(ALPINE_SOURCES)
	$(call shell_info, Creating $(B)root filesystem$(N) (rootfs))
	@mkdir -p $(ALPINE_ROOT_DIR)/bin
	@mkdir -p $(ALPINE_ROOT_DIR)/usr/bin
	@mkdir -p $(ALPINE_ROOT_DIR)/etc/apk
	@cp -r $(ALPINE_APK_TOOLS_DIR)/sbin $(ALPINE_ROOT_DIR)/
	@cp -r $(QEMU_SOURCE) $(QEMU_TARGET)
	@cp -r $(RESOLV_SOURCE) $(RESOLV_TARGET)
	$(call shell_info, Installing $(B)alpine-base$(N) package)
	@sudo chroot $(ALPINE_ROOT_DIR) /sbin/apk.static    \
		--repository $(ALPINE_TARGET_URL)/main	    \
		--update-cache				    \
		--allow-untrusted			    \
		--initdb				    \
		add alpine-base

# -----------------------------------------------------------------------------
.PHONY: alpine-modules
# -----------------------------------------------------------------------------

ALPINE_MODULES_DIR	    := $(ALPINE_ROOT_DIR)/lib/modules/$(KERNEL_VERSION)
ALPINE_MODULES_KERNEL_DIR   := $(ALPINE_MODULES_DIR)/kernel

alpine-modules: $(ALPINE_MODULES_KERNEL_DIR)

$(ALPINE_MODULES_KERNEL_DIR): $(ALPINE_BASE) $(KERNEL_MODULES_TAR)
	$(call shell_info, Installing $(B)Kernel modules$(N))
	@sudo mkdir -p $(ALPINE_MODULES_KERNEL_DIR)
	@cd $(ALPINE_MODULES_KERNEL_DIR) && sudo tar -zxf $(KERNEL_MODULES_TAR)
	@sudo cp -r $(KERNEL_SRC_DIR)/modules.builtin		\
		    $(KERNEL_SRC_DIR)/modules.builtin.modinfo	\
		    $(KERNEL_SRC_DIR)/modules.order		\
	    $(ALPINE_MODULES_DIR)/
	@sudo depmod -a -b $(ALPINE_ROOT_DIR) $(KERNEL_VERSION)

# -----------------------------------------------------------------------------
.PHONY: alpine-fw
# -----------------------------------------------------------------------------

alpine-fw: $(ALPINE_FW)

$(ALPINE_FW): $(ALPINE_MODULES) $(ALPINE_FIRMWARE_FILE) $(ALPINE_ADDITIONAL_FIRMWARE)
	$(call shell_info, Installing $(B)Linux firmware$(N))
	@sudo tar -zxf $(ALPINE_FIRMWARE_FILE)		    \
	    --directory=$(ALPINE_ROOT_DIR)/lib/modules	    \
	    --warning=no-unknown-keyword		    \
	    --strip-components=1			    \
	    --wildcards lib/firmware/ar* lib/firmware/rt*
	$(foreach fw, $(ALPINE_ADDITIONAL_FIRMWARE),	    \
	    sudo tar -zxf $(ALPINE_BUILD_DIR)/$(fw)	    \
	        --directory=$(ALPINE_ROOT_DIR)/lib/modules  \
	        --warning=no-unknown-keyword		    \
	        --strip-components=1;			    \
	)
# -----------------------------------------------------------------------------
.PHONY: alpine-repositories
# -----------------------------------------------------------------------------

CH_ALPINE_REPOSITORIES_FILE := /etc/apk/repositories
ALPINE_REPOSITORIES_FILE    := $(ALPINE_ROOT_DIR)$(CH_ALPINE_REPOSITORIES_FILE)

alpine-repositories: $(ALPINE_REPOSITORIES_FILE)

$(ALPINE_REPOSITORIES_FILE): $(ALPINE_BASE)
	$(call shell_info, Setting up Alpine Linux repositories)
	@mkdir -p $(ALPINE_ROOT_DIR)/etc/apk
	$(call chroot, echo "$(ALPINE_REPOSITORY_MAIN)"	    \
                          > $(CH_ALPINE_REPOSITORIES_FILE))
	$(call chroot,echo $(ALPINE_REPOSITORY_COMMUNITY)   \
                         >> $(CH_ALPINE_REPOSITORIES_FILE))

# -----------------------------------------------------------------------------

ALPINE_PACKAGES += busybox-suid
ALPINE_PACKAGES += sudo
ALPINE_PACKAGES += openssh
ALPINE_PACKAGES += ucspi-tcp6
ALPINE_PACKAGES += iw
ALPINE_PACKAGES += iwd
ALPINE_PACKAGES += dhcpcd
ALPINE_PACKAGES += dnsmasq
ALPINE_PACKAGES += hostapd
ALPINE_PACKAGES += iptables
ALPINE_PACKAGES += avahi-dev
ALPINE_PACKAGES += dbus
ALPINE_PACKAGES += dcron
ALPINE_PACKAGES += chrony
ALPINE_PACKAGES += gpsd
ALPINE_PACKAGES += musl-dev
ALPINE_PACKAGES += libconfig-dev
ALPINE_PACKAGES += alsa-lib-dev
ALPINE_PACKAGES += alsa-utils
ALPINE_PACKAGES += alsaconf
ALPINE_PACKAGES += alsa-ucm-conf
ALPINE_PACKAGES += wget
ALPINE_PACKAGES += vim
ALPINE_PACKAGES += emacs
ALPINE_PACKAGES += bc
ALPINE_PACKAGES += patch
ALPINE_PACKAGES += make
ALPINE_PACKAGES += gcc
ALPINE_PACKAGES += g++
ALPINE_PACKAGES += liblo-dev
ALPINE_PACKAGES += libmicrohttpd-dev
ALPINE_PACKAGES += libc6-compat
ALPINE_PACKAGES += linux-headers
ALPINE_PACKAGES += python3
ALPINE_PACKAGES += i2c-tools
ALPINE_PACKAGES += spi-tools
ALPINE_PACKAGES += autologin
ALPINE_PACKAGES += hwdata-usb
ALPINE_PACKAGES += usbutils
ALPINE_PACKAGES += util-linux
ALPINE_PACKAGES += gzip
ALPINE_PACKAGES += procps-dev
ALPINE_PACKAGES += mingetty
ALPINE_PACKAGES += git
ALPINE_PACKAGES += cargo
ALPINE_PACKAGES += jack-dev

# -----------------------------------------------------------------------------

ALPINE_GCC_BIN	    := $(ALPINE_ROOT_DIR)/usr/bin/gcc
ALPINE_PYTHON3_BIN  := $(ALPINE_ROOT_DIR)/usr/bin/python3
ALPINE_RUSTC_BIN    := $(ALPINE_ROOT_DIR)/usr/bin/rustc
ALPINE_CARGO_BIN    := $(ALPINE_ROOT_DIR)/usr/bin/cargo

# -----------------------------------------------------------------------------
.PHONY: alpine-packages
# -----------------------------------------------------------------------------

alpine-packages: $(ALPINE_REPOSITORIES_FILE)
	$(call shell_info, Installing additional packages)
	$(call chroot,/sbin/apk update)
	$(call chroot,/sbin/apk add $(ALPINE_PACKAGES))
	$(call chroot, /sbin/apk add llvm16			    \
		--repository $(ALPINE_REPOSITORY_EDGE_MAIN))
	$(call chroot, /sbin/apk add llvm16 faust-dev a2jmidid	    \
		--repository $(ALPINE_REPOSITORY_EDGE_TESTING))

# -----------------------------------------------------------------------------
.PHONY: alpine-inittab
# -----------------------------------------------------------------------------

ALPINE_INITTAB_SRC := $(SOURCE_LINUX_DIR)/alpine-root/inittab
ALPINE_INITTAB_DST := $(ALPINE_ROOT_DIR)/etc/inittab

alpine-inittab: $(ALPINE_INITTAB_DST)

$(ALPINE_INITTAB_DST): $(ALPINE_INITTAB_SRC) alpine-packages
	$(call shell_info, Registering daemons)
	$(call chroot, /sbin/rc-update add bootmisc boot)
	$(call chroot, /sbin/rc-update add hostname boot)
	$(call chroot, /sbin/rc-update add hwdrivers boot)
	$(call chroot, /sbin/rc-update add bootmisc boot)
	$(call chroot, /sbin/rc-update add modules boot)
	$(call chroot, /sbin/rc-update add swclock boot)
ifeq ($(BOARD_FAMILY), MPSOC_ULTRASCALE+) # ------------
	$(call chroot, /sbin/rc-update add hwclock boot)
endif # ------------------------------------------------
	$(call chroot, /sbin/rc-update add sysctl boot)
	$(call chroot, /sbin/rc-update add syslog boot)
	$(call chroot, /sbin/rc-update add seedrng boot)
# SHUTDOWN ---------------------------------------------------
	$(call chroot, /sbin/rc-update add killprocs shutdown)
	$(call chroot, /sbin/rc-update add mount-ro shutdown)
	$(call chroot, /sbin/rc-update add savecache shutdown)
# SYSINIT ----------------------------------------------------
	$(call chroot, /sbin/rc-update add devfs sysinit)
	$(call chroot, /sbin/rc-update add dmesg sysinit)
	$(call chroot, /sbin/rc-update add mdev sysinit)
# DEFAULT ----------------------------------------------------
	$(call chroot, /sbin/rc-update add avahi-daemon default)
	$(call chroot, /sbin/rc-update add chronyd default)
	$(call chroot, /sbin/rc-update add dhcpcd default)
	$(call chroot, /sbin/rc-update add local default)
	$(call chroot, /sbin/rc-update add dcron default)
	$(call chroot, /sbin/rc-update add sshd default)
#	$(call chroot, /sbin/rc-update add alsa default)
	$(call chroot, /sbin/rc-update add iwd default)
# TODO: fix: run avahi-daemon with the '--no-drop-root' flag, or else it won't start...
	@sudo sed -i "s/avahi-daemon\s-D.*/avahi-daemon -D --no-drop-root/g" \
	      $(ALPINE_ROOT_DIR)/etc/init.d/avahi-daemon
# INITTAB ----------------------------------------------------
	@sudo cp -r $(ALPINE_INITTAB_SRC) $(ALPINE_INITTAB_DST)
# SND-SEQ LOAD -----------------------------------------------
	$(call chroot, echo snd-seq >> /etc/modules)
	$(call chroot, echo snd-dummy >> /etc/modules)

# -----------------------------------------------------------------------------
.PHONY: alpine-home-syfala
# -----------------------------------------------------------------------------

ALPINE_HOME_SYFALA := $(ALPINE_ROOT_DIR)/home/syfala

ifeq ($(call dir_exists, $(ALPINE_HOME_SYFALA)), 0)
    $(call static_info, Adding $(ALPINE_HOME_SYFALA) to dependencies)
    ALPINE_HOME_SYFALA_CH := $(ALPINE_HOME_SYFALA)
else
    $(call static_info, $(ALPINE_HOME_SYFALA) removed from dependencies)
endif

alpine-home-syfala: $(ALPINE_HOME_SYFALA)

$(ALPINE_HOME_SYFALA): alpine-packages
ifeq ($(call dir_exists, $(ALPINE_HOME_SYFALA)), 0)
	$(call shell_info, Setting up $(B)users and permissions$(N))
	$(call chroot, sed -i 's/^SAVE_ON_STOP=.*/SAVE_ON_STOP="no"/g' /etc/conf.d/iptables)
	$(call chroot, sed -i 's/^IPFORWARD=.*/IPFORWARD="yes"/g' /etc/conf.d/iptables)
	$(call chroot, sed -i "s/^#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config)
	$(call chroot, echo "root:syfala" | /usr/sbin/chpasswd)
	$(call chroot, /sbin/setup-hostname syfala)
	$(call chroot, /usr/sbin/adduser -D -h /home/syfala -s /bin/ash  -g "syfala" syfala)
	$(call chroot, echo "syfala:syfala" | /usr/sbin/chpasswd)
	$(call chroot, echo "syfala ALL=(ALL) ALL" > /etc/sudoers.d/syfala && chmod 0440 /etc/sudoers.d/syfala)
	$(call chroot, chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo)
# Allow ttyPS0 to login as root
	$(call chroot, echo ttyPS0 >> /etc/securetty)
	$(call shell_info, Adding users to 'audio' group)
	$(call chroot, /usr/sbin/addgroup syfala audio)
	$(call chroot, /usr/sbin/addgroup root audio)
endif

# -----------------------------------------------------------------------------
.PHONY: alpine-fpgautil
# -----------------------------------------------------------------------------

ALPINE_FPGAUTIL_SRC := $(SOURCE_LINUX_DIR)/files/fpgautil.c
ALPINE_FPGAUTIL_DST := /usr/bin/fpgautil.c
ALPINE_FPGAUTIL_BIN := $(ALPINE_ROOT_DIR)/usr/bin/fpgautil

alpine-fpgautil: $(ALPINE_FPGAUTIL_BIN)

$(ALPINE_FPGAUTIL_BIN): $(ALPINE_FPGAUTIL_SRC) $(ALPINE_GCC_BIN)
	$(call shell_info, Compiling $(B)fpgautil$(N) utility)
	@sudo cp -r $(ALPINE_FPGAUTIL_SRC) $(ALPINE_ROOT_DIR)$(ALPINE_FPGAUTIL_DST)
	$(call chroot, gcc -O3 $(ALPINE_FPGAUTIL_DST) -o /usr/bin/fpgautil)
	@rm -rf $(ALPINE_ROOT_DIR)$(ALPINE_FPGAUTIL_DST)

# -----------------------------------------------------------------------------
.PHONY: alpine-fpgabit2bin
# -----------------------------------------------------------------------------

ALPINE_FPGA_BIT2BIN_SRC := $(SOURCE_LINUX_DIR)/files/fpga-bit-to-bin.py
ALPINE_FPGA_BIT2BIN_DST := $(ALPINE_ROOT_DIR)/usr/bin/fpga-bit-to-bin.py

alpine-fpgabit2bin: $(ALPINE_FPGA_BIT2BIN_DST)

$(ALPINE_FPGA_BIT2BIN_DST): $(ALPINE_FPGA_BIT2BIN_SRC)
	@sudo cp -r $(ALPINE_FPGA_BIT2BIN_SRC) $(ALPINE_FPGA_BIT2BIN_DST)

# -----------------------------------------------------------------------------
.PHONY: alpine-syfala-load
# -----------------------------------------------------------------------------

ALPINE_SYFALA_LOAD_SRC := $(SOURCE_LINUX_DIR)/files/syfala-load.c
ALPINE_SYFALA_LOAD_DST := /usr/bin/syfala-load.c
ALPINE_SYFALA_LOAD_BIN := $(ALPINE_ROOT_DIR)/usr/bin/syfala-load

alpine-syfala-load: $(ALPINE_SYFALA_LOAD_BIN)

$(ALPINE_SYFALA_LOAD_BIN): $(ALPINE_SYFALA_LOAD_SRC) $(ALPINE_GCC_BIN)
	$(call shell_info, Compiling $(B)syfala-load$(N) utility)
	@sudo cp -r $(ALPINE_SYFALA_LOAD_SRC) $(ALPINE_ROOT_DIR)$(ALPINE_SYFALA_LOAD_DST)
	$(call chroot, gcc -O3 $(ALPINE_SYFALA_LOAD_DST)    \
			    -o /usr/bin/syfala-load	    \
                            -lprocps                        \
        )
	@rm -rf $(ALPINE_ROOT_DIR)$(ALPINE_SYFALA_LOAD_DST)

# -----------------------------------------------------------------------------
# Linux TARGET compilation
# -----------------------------------------------------------------------------

SOURCE_ARM_LINUX_DIR    := $(SOURCE_ARM_DIR)/linux
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/audio.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/gpio.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/ip.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/memory.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/spi.cpp

ALPINE_DSP_DIR_CH := /home/syfala/$(FAUST_DSP_TARGET_NAME)
ALPINE_DSP_DIR := $(ALPINE_ROOT_DIR)$(ALPINE_DSP_DIR_CH)

ALPINE_DSP_APPLICATION_SOURCES += $(SOURCE_ARM_LINUX_DIR)/Makefile

ifeq ($(TARGET), faust) # ----------------------------------------------
    ALPINE_DSP_APPLICATION_SOURCES += $(wildcard $(SOURCE_ARM_LINUX_DIR)/*.cpp)
    ALPINE_DSP_APPLICATION_SOURCES += $(SOURCE_ARM_DIR)/faust/control.cpp
else ifeq ($(TARGET), cpp) # -------------------------------------------
# TODO
endif # ----------------------------------------------------------------

ALPINE_DSP_APPLICATION_SOURCES_TARGETS := $(addprefix $(ALPINE_DSP_DIR)/src/,$(notdir $(ALPINE_DSP_APPLICATION_SOURCES)))
ALPINE_DSP_APPLICATION_INCLUDE_DIR := $(ALPINE_DSP_DIR)/src/include

#------------------------------------------------------------------------------
.PHONY: alpine-bitstream
#------------------------------------------------------------------------------

ALPINE_DSP_BITSTREAM := $(ALPINE_DSP_DIR)/bitstream.bin

alpine-bitstream: $(ALPINE_DSP_BITSTREAM)

$(ALPINE_DSP_BITSTREAM): $(BITSTREAM) $(ALPINE_FPGA_BIT2BIN_DST) $(ALPINE_PYTHON3_BIN)
	$(call shell_info, Copying DSP $(B)bitstream$(N))
	@sudo mkdir -p $(ALPINE_DSP_DIR)
	@sudo cp -r $(BITSTREAM) $(ALPINE_DSP_DIR)/system.bit
	$(call chroot, python3 /usr/bin/fpga-bit-to-bin.py			    \
			    -f /home/syfala/$(FAUST_DSP_TARGET_NAME)/system.bit	    \
			       /home/syfala/$(FAUST_DSP_TARGET_NAME)/bitstream.bin  \
	)
	@sudo rm -rf $(ALPINE_DSP_DIR)/system.bit

#------------------------------------------------------------------------------
.PHONY: alpine-application-sources
#------------------------------------------------------------------------------

alpine-application-sources: $(ALPINE_DSP_APPLICATION_SOURCES_TARGETS)

$(ALPINE_DSP_APPLICATION_SOURCES_TARGETS): $(ALPINE_DSP_APPLICATION_SOURCES)
	$(call shell_info, Copying DSP application $(B)sources$(N))
	@sudo mkdir -p $(ALPINE_DSP_DIR)/src
	@sudo cp -r $(ALPINE_DSP_APPLICATION_SOURCES)				\
        	    $(ALPINE_DSP_DIR)/src

#------------------------------------------------------------------------------
.PHONY: alpine-application-xsources
#------------------------------------------------------------------------------

ALPINE_DSP_APPLICATION_XSOURCES := $(addprefix $(ALPINE_DSP_DIR)/src/,$(notdir $(XSOURCES)))

alpine-application-xsources: $(ALPINE_DSP_APPLICATION_XSOURCES)

$(ALPINE_DSP_APPLICATION_XSOURCES): $(XSOURCES)
	$(call shell_info, Copying Xilinx-generated sources)
	@sudo mkdir -p $(ALPINE_DSP_DIR)/src
	@sudo cp -r $(XSOURCES) $(ALPINE_DSP_DIR)/src

$(ALPINE_DSP_APPLICATION_INCLUDE_DIR): $(BUILD_INCLUDES)			\
				       $(BUILD_HOST_INCLUDES)			\
				       $(FAUST_CONTROL_SOURCE)
	$(call shell_info, Copying include directory)
	@sudo cp -r $(BUILD_DIR)/include $(ALPINE_DSP_APPLICATION_INCLUDE_DIR)
	@sudo cp -r include/syfala/arm/linux $(ALPINE_DSP_APPLICATION_INCLUDE_DIR)/syfala/arm

#------------------------------------------------------------------------------
.PHONY: alpine-application
#------------------------------------------------------------------------------

ALPINE_DSP_APPLICATION := $(ALPINE_DSP_DIR)/application.elf

alpine-application: $(ALPINE_DSP_APPLICATION)

ALPINE_DSP_APPLICATION_DEPENDENCIES += $(ALPINE_DSP_APPLICATION_SOURCES_TARGETS)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(ALPINE_DSP_APPLICATION_XSOURCES)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(ALPINE_DSP_APPLICATION_INCLUDE_DIR)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(ALPINE_HOME_SYFALA_CH)

$(ALPINE_DSP_APPLICATION): $(ALPINE_DSP_APPLICATION_DEPENDENCIES)
	$(call shell_info, Compiling DSP control application)
	$(call chroot, make -C /home/syfala/$(FAUST_DSP_TARGET_NAME)/src -j8)
	@sudo touch $(ALPINE_DSP_APPLICATION)

# -----------------------------------------------------------------------------
ifeq (ETHERNET, $(filter ETHERNET, $(CONFIG)))
# -----------------------------------------------------------------------------

ALPINE_ETHERNET_CLIENT := $(ALPINE_ROOT_DIR)/usr/bin/syfala-ethernet

ALPINE_ETHERNET_SOURCE_DIR := $(SOURCE_DIR)/linux/ethernet
ALPINE_ETHERNET_TARGET_DIR := $(ALPINE_ROOT_DIR)/home/syfala/ethernet

ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/Cargo.toml
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/Cross.toml
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/client/Cargo.toml
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/client/build.rs
ALPINE_ETHERNET_SOURCES += $(wildcard $(ALPINE_ETHERNET_SOURCE_DIR)/client/src/*.rs)
ALPINE_ETHERNET_SOURCES += $(wildcard $(ALPINE_ETHERNET_SOURCE_DIR)/client/src/axi/*.rs)
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/shared/Cargo.toml
ALPINE_ETHERNET_SOURCES += $(wildcard $(ALPINE_ETHERNET_SOURCE_DIR)/shared/src/*.rs)

ALPINE_ETHERNET_TARGETS := $(subst $(ALPINE_ETHERNET_SOURCE_DIR),$(ALPINE_ETHERNET_TARGET_DIR),$(ALPINE_ETHERNET_SOURCES)))

ALPINE_ETHERNET_JSON_SOURCE	:= $(BUILD_ETHERNET_HLS_DIR)/eth_audio/eth_audio_data.json
ALPINE_ETHERNET_JSON_TARGET	:= $(ALPINE_DSP_DIR)/eth_audio_data.json
ALPINE_ETHERNET_JSON_TARGET_CH	:= $(ALPINE_DSP_DIR_CH)/eth_audio_data.json

$(ALPINE_ETHERNET_JSON_TARGET): $(ALPINE_HOME_SYFALA_CH) $(ETHERNET_HLS_OUTPUT) $(ALPINE_ETHERNET_JSON_SOURCE)
	$(call shell_info, Installing Ethernet Audio register map)
	@mkdir -p $(ALPINE_DSP_DIR)
	@sudo cp -r $(ALPINE_ETHERNET_JSON_SOURCE) $(ALPINE_DSP_DIR)/

ALPINE_ETHERNET_DEPENDENCIES += $(ALPINE_ETHERNET_SOURCES)
ALPINE_ETHERNET_DEPENDENCIES += $(ALPINE_HOME_SYFALA_CH)
ALPINE_ETHERNET_DEPENDENCIES += $(ALPINE_ETHERNET_JSON_TARGET)

$(ALPINE_ETHERNET_TARGET_DIR): $(ALPINE_ETHERNET_DEPENDENCIES)
	$(call shell_info, Preparing Ethernet client application sources)
	@sudo cp -Tr $(ALPINE_ETHERNET_SOURCE_DIR) $(ALPINE_ETHERNET_TARGET_DIR)
	@sudo touch $(ALPINE_ETHERNET_TARGET_DIR)

$(ALPINE_ETHERNET_TARGETS): $(ALPINE_ETHERNET_TARGET_DIR)


# HLS_ETHERNET_DATA_JSON_IGNORE=1

$(ALPINE_ETHERNET_CLIENT): $(ALPINE_ETHERNET_TARGET_DIR) $(ALPINE_RUSTC_BIN) $(ALPINE_CARGO_BIN)
	$(call shell_info, Compiling Ethernet client application (this could take a while...))
	$(call chroot,								\
	    export HLS_ETHERNET_DATA_JSON=$(ALPINE_ETHERNET_JSON_TARGET_CH)	\
	    && export CARGO_TARGET_DIR=/home/syfala				\
	    && cd /home/syfala/ethernet/client					\
	    && cargo --config "net.git-fetch-with-cli = true" build --release	\
	)
	$(call shell_ok, Installing Ethernet client application in /usr/bin/syfala-ethernet)
	@sudo cp -r $(ALPINE_ROOT_DIR)/home/syfala/release/client	\
		    $(ALPINE_ETHERNET_CLIENT)

LINUX_ROOT_DEPENDENCIES += $(ALPINE_ETHERNET_CLIENT)
endif

# -----------------------------------------------------------------------------
ifeq ($(SMC23_SYNTH_DEMO), TRUE)
# -----------------------------------------------------------------------------
SMC23_SYNTH_DEMO_EXEC   := $(ALPINE_ROOT_DIR)/usr/bin/smc23
SMC23_SYNTH_DEMO_SOURCE := $(SOURCE_LINUX_DIR)/files/smc23.cpp
SMC23_SYNTH_DEMO_TARGET := $(ALPINE_ROOT_DIR)/home/syfala/smc23.cpp

$(SMC23_SYNTH_DEMO_TARGET): $(SMC23_SYNTH_DEMO_SOURCE) $(ALPINE_HOME_SYFALA_CH)
	$(call shell_info, Copying $(B)smc23.cpp$(N) source)
	@cp -r $(SMC23_SYNTH_DEMO_SOURCE) $(SMC23_SYNTH_DEMO_TARGET)

$(SMC23_SYNTH_DEMO_EXEC): $(SMC23_SYNTH_DEMO_TARGET)
	$(call shell_info, Building $(B)smc23$(N) application)
	@$(call chroot, g++ -O3 /home/syfala/smc23.cpp -o /usr/bin/smc23 -ljack -lpthread)

LINUX_ROOT_DEPENDENCIES += $(SMC23_SYNTH_DEMO_EXEC)
endif

# -----------------------------------------------------------------------------
LINUX_ROOT_DEPENDENCIES += alpine-modules
LINUX_ROOT_DEPENDENCIES += $(ALPINE_FW)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_REPOSITORIES_FILE)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_INITTAB_DST)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_FPGAUTIL_BIN)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_FPGA_BIT2BIN_DST)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_SYFALA_LOAD_BIN)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_DSP_BITSTREAM)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_DSP_APPLICATION)

# -----------------------------------------------------------------------------

$(BUILD_LINUX_OUTPUT_ROOT_DIR): $(LINUX_ROOT_DEPENDENCIES)
	@mkdir -p $(BUILD_LINUX_OUTPUT_ROOT_DIR)
	$(call shell_info, Now copying rootfs to $(BUILD_LINUX_OUTPUT_ROOT_DIR))
	@sudo cp -Tr $(ALPINE_ROOT_DIR) $(BUILD_LINUX_OUTPUT_ROOT_DIR)

# -----------------------------------------------------------------------------
.PHONY: linux-root
# -----------------------------------------------------------------------------
linux-root: $(BUILD_LINUX_OUTPUT_ROOT_DIR)

# -----------------------------------------------------------------------------
.PHONY: linux
# -----------------------------------------------------------------------------
linux: linux-boot linux-root

# -----------------------------------------------------------------------------
.PHONY: scp
# -----------------------------------------------------------------------------
# SCP_TARGET_ADDR: e.g. 192.168.0.2
SCP_TARGET_USER ?= root

scp:
	$(call shell_info, - $(B)Flashing DSP$(N) $(ALPINE_DSP_DIR_CH) with scp)
	$(call shell_info, - $(B)SCP_TARGET_ADDR$(N): $(SCP_TARGET_ADDR))
	$(call shell_info, - $(B)SCP_TARGET_USER$(N): $(SCP_TARGET_USER))
	@scp -r $(ALPINE_DSP_DIR)						\
	$(SCP_TARGET_USER)@$(SCP_TARGET_ADDR):$(ALPINE_DSP_DIR_CH)

# -----------------------------------------------------------------------------
.PHONY: flash-linux-boot
.PHONY: flash-linux-root
.PHONY: flash-linux
.PHONY: flash-linux-dsp

# TODO:check partition formats
# -----------------------------------------------------------------------------

SD_DEVICE   ?= null

$(call static_info, - $(B)SD_DEVICE$(N) = $(SD_DEVICE))

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
        $(call static_info, Unsupported device: $(SD_DEVICE) (contact developer))
        SD_DEVICE_BOOT_PARTITION := null
        SD_DEVICE_ROOT_PARTITION := null
    endif

ifeq ($(call dev_exists, $(SD_DEVICE_BOOT_PARTITION)), 1)
# -----------------------------------------------------------------------------
flash-linux-boot: linux-boot
# -----------------------------------------------------------------------------
	$(call shell_info, Mounting $(SD_DEVICE_BOOT_PARTITION))
	@sudo mount $(SD_DEVICE_BOOT_PARTITION) /mnt
	$(call shell_info, Cleaning up $(SD_DEVICE_BOOT_PARTITION))
	@rm -rf /mnt/*
	$(call shell_info, Copying boot files)
	@cp -r $(BUILD_LINUX_OUTPUT_BOOT_DIR)/* /mnt
	$(call shell_ok, Boot files successfully copied)
	$(call shell_info, Now syncing...)
	@sync
	$(call shell_info, Unmounting $(SD_DEVICE_BOOT_PARTITION))
	@sudo umount /mnt
else
    $(call static_info, Could not find boot partition ($(SD_DEVICE_BOOT_PARTITION)))
    SD_DEVICE_BOOT_PARTITION := null
endif

ifeq ($(call dev_exists, $(SD_DEVICE_ROOT_PARTITION)),1)
# -----------------------------------------------------------------------------
flash-linux-root: linux-root
# -----------------------------------------------------------------------------
	$(call shell_info, Mounting $(SD_DEVICE_ROOT_PARTITION))
	@sudo mount $(SD_DEVICE_ROOT_PARTITION) /mnt
	$(call shell_info, Cleaning up $(SD_DEVICE_ROOT_PARTITION))
	@sudo	rm -rf /mnt/*
	$(call shell_info, Copying root files)
	@sudo cp -r $(BUILD_LINUX_OUTPUT_ROOT_DIR)/* /mnt
	$(call shell_ok, Boot files successfully copied)
	$(call shell_info, Now syncing... (this might take a while))
	@sync
	$(call shell_info, Unmounting $(SD_DEVICE_ROOT_PARTITION))
	@sudo umount /mnt

# -----------------------------------------------------------------------------
flash-linux-dsp: linux-root
# -----------------------------------------------------------------------------
	$(call shell_info, Mounting $(SD_DEVICE_ROOT_PARTITION))
	@sudo mount $(SD_DEVICE_ROOT_PARTITION) /mnt
	$(call shell_info, Copying/overwriting $(notdir $(ALPINE_DSP_DIR)))
	@sudo cp -Tr $(ALPINE_DSP_DIR) /mnt/home/syfala/$(FAUST_DSP_TARGET_NAME)
	$(call shell_ok, Files successfully copied)
	$(call shell_info, Now syncing...)
	@sync
	$(call shell_info, Unmounting $(SD_DEVICE_ROOT_PARTITION))
	@sudo umount /mnt
else
    $(call static_info, Could not find root partition ($(SD_DEVICE_ROOT_PARTITION)))
    SD_DEVICE_ROOT_PARTITION := null
endif

flash-linux: flash-linux-boot flash-linux-root

else # ------------------------------------------------------------------------

flash-linux-boot: linux-boot
	$(call shell_error, Device $(SD_DEVICE) does not exist)

flash-linux-root: linux-root
	$(call shell_error, Device $(SD_DEVICE) does not exist)

flash-linux: flash-linux-boot flash-linux-root
	$(call shell_error, Device $(SD_DEVICE) does not exist)

endif #------------------------------------------------------------------------

ifeq ($(LINUX), TRUE) # -----------
.PHONY: sw
sw: linux
else # ----------------------------
.PHONY: sw
sw: $(HOST_APPLICATION)
endif # ---------------------------

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

#TODO: multisample

define print_reports # ----------------------
    @tools/print_reports.sh		    \
	$(PWD)                              \
	$(SYFALA_VERSION_FULL)		    \
	$(FAUST_DSP_TARGET_NAME)	    \
	$(BOARD)			    \
	$(SAMPLE_RATE)			    \
	$(SAMPLE_WIDTH)			    \
	$(CONTROLLER_TYPE)		    \
	$(SSM_VOLUME)			    \
	$(shell $(NCHANNELS_I))		    \
	$(shell $(NCHANNELS_O))		    \
	$(shell expr $(shell $(faust_mem_count_cmd_r))	    \
		   - $(shell $(faust_mem_count_cmd_w)))	    \
	$(shell $(faust_mem_count_cmd_w))
endef # ------------------------------------

reports:
	$(call print_reports)
