
# -----------------------------------------------------------------------------
# Directory tree
# -----------------------------------------------------------------------------

SOURCE_DIR          := $(MK_ROOT_DIR)/source
INCLUDE_DIR         := $(MK_ROOT_DIR)/include
SCRIPTS_DIR         := $(MK_ROOT_DIR)/scripts
EXAMPLES_DIR        := $(MK_ROOT_DIR)/examples
DOC_DIR             := $(MK_ROOT_DIR)/doc
TESTS_DIR           := $(MK_ROOT_DIR)/tests
TOOLS_DIR           := $(MK_ROOT_DIR)/tools
BUILD_DIR           := $(MK_ROOT_DIR)/build
BUILD_LINUX_DIR     := $(MK_ROOT_DIR)/build-linux

# -----------------------------------------------------------------------------
# Sources
# -----------------------------------------------------------------------------
SOURCE_ARM_DIR          := $(SOURCE_DIR)/arm
SOURCE_BD_DIR           := $(SOURCE_DIR)/bd
SOURCE_RTL_DIR          := $(SOURCE_DIR)/rtl
SOURCE_LINUX_DIR        := $(SOURCE_DIR)/linux
SOURCE_REMOTE_DIR       := $(SOURCE_DIR)/remote
SOURCE_ARM_FAUST_DIR    := $(SOURCE_ARM_DIR)/faust

ARM_FAUST_CONTROL_SOURCE    := $(SOURCE_ARM_FAUST_DIR)/control.cpp

SOURCE_FAUST2VHDL_DIR	:= $(SOURCE_RTL_DIR)/faust2vhdl
SOURCE_HLS_DIR		:= $(SOURCE_RTL_DIR)/hls
SOURCE_I2S_DIR		:= $(SOURCE_RTL_DIR)/i2s

# -----------------------------------------------------------------------------
# Codec sources:
# - SSM2603     (Zybo internal codec)
# - ADAU1761    (Genesys internal codec)
# - ADAU1777    (External)
# - ADAU1787    (External)
# -----------------------------------------------------------------------------
SOURCE_ARM_CODECS_DIR               := $(SOURCE_ARM_DIR)/codecs
ARM_CODECS_SOURCE_ADAU1761          := $(SOURCE_ARM_CODECS_DIR)/ADAU1761Reg.cpp
ARM_CODECS_SOURCE_ADAU1777          := $(SOURCE_ARM_CODECS_DIR)/ADAU1777Reg.cpp
ARM_CODECS_SOURCE_ADAU1787          := $(SOURCE_ARM_CODECS_DIR)/ADAU1787Reg.cpp
ARM_CODECS_SOURCE_TEMPLATE          := $(SOURCE_ARM_CODECS_DIR)/template.pp

SOURCE_ARM_CODECS		    := $(wildcard $(SOURCE_ARM_CODECS)/*.cpp)

SOURCE_ARM_BAREMETAL_DIR	    := $(SOURCE_ARM_DIR)/baremetal

SOURCE_ARM_BAREMETAL_LINKERS_DIR    := $(SOURCE_ARM_DIR)/baremetal/linkers
SOURCE_ARM_BAREMETAL_LINKER_ZYBO    := $(SOURCE_ARM_BAREMETAL_LINKERS_DIR)/zybo/lscript.ld
SOURCE_ARM_BAREMETAL_LINKER_GENESYS := $(SOURCE_ARM_BAREMETAL_LINKERS_DIR)/genesys/lscript.ld

SOURCE_ARM_BAREMETAL_MODULES_DIR    := $(SOURCE_ARM_BAREMETAL_DIR)/modules
ARM_BAREMETAL_CPP_MODULES	     = $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/audio.cpp
ARM_BAREMETAL_CPP_MODULES	    += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/gpio.cpp
ARM_BAREMETAL_CPP_MODULES	    += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/ip.cpp
ARM_BAREMETAL_CPP_MODULES	    += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/memory.cpp
ARM_BAREMETAL_CPP_MODULES	    += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/spi.cpp
ARM_BAREMETAL_CPP_MODULES	    += $(SOURCE_ARM_BAREMETAL_MODULES_DIR)/uart.cpp

ARM_BAREMETAL_CPP_MAIN_STD          := $(SOURCE_ARM_BAREMETAL_DIR)/arm.cpp
ARM_BAREMETAL_CPP_MAIN_MINIMAL      := $(SOURCE_ARM_BAREMETAL_DIR)/arm_minimal.cpp
ARM_BAREMETAL_CPP_MAIN_FAUST2VHDL   := $(SOURCE_ARM_BAREMETAL_DIR)/arm_faust2vhdl.cpp
ARM_BAREMETAL_CPP_MAIN              ?= $(ARM_BAREMETAL_CPP_MAIN_STD)

# -----------------------------------------------------------------------------
# Constraint files
# -----------------------------------------------------------------------------
SOURCE_CONSTRAINTS_DIR      := $(SOURCE_DIR)/constraints
SOURCE_CONSTRAINTS_ZYBO	    := $(SOURCE_CONSTRAINTS_DIR)/zybo.xdc
SOURCE_CONSTRAINTS_GENESYS  := $(SOURCE_CONSTRAINTS_DIR)/genesys-zu-3eg.xdc

# -----------------------------------------------------------------------------
# Scripts
# -----------------------------------------------------------------------------
SCRIPT_PREPROCESSOR     ?= $(SCRIPTS_DIR)/preprocessor.tcl
#SCRIPT_HLS              ?= $(SCRIPTS_DIR)/hls.tcl
SCRIPT_PROJECT          ?= $(SCRIPTS_DIR)/project.tcl
#SCRIPT_SYNTH            ?= $(SCRIPTS_DIR)/synthesis.tcl
SCRIPT_HOST             ?= $(SCRIPTS_DIR)/application.tcl
SCRIPT_FLASH_JTAG       ?= $(SCRIPTS_DIR)/jtag.tcl
SCRIPT_BIN_GENERATOR    ?= $(SCRIPTS_DIR)/bin_generator.bif

# -----------------------------------------------------------------------------
# Block designs
# -----------------------------------------------------------------------------
BD_STD			:= $(SOURCE_BD_DIR)/standard.tcl
BD_MULTISAMPLE		:= $(SOURCE_BD_DIR)/multisample.tcl
BD_FAUST2VHDL		:= $(SOURCE_BD_DIR)/faust2vhdl.tcl
BD_TDM			:= $(SOURCE_BD_DIR)/tdm.tcl
BD_TDM_MULTISAMPLE      := $(SOURCE_BD_DIR)/tdm_multisample.tcl
BD_SIGMA_DELTA		:= $(SOURCE_BD_DIR)/sigma-delta-new-2.tcl

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------
BUILD_INCLUDE_DIR       := $(BUILD_DIR)/include
BUILD_IP_DIR 		:= $(BUILD_DIR)/syfala_ip
BUILD_PROJECT_DIR 	:= $(BUILD_DIR)/syfala_project
BUILD_HOST_DIR  	:= $(BUILD_DIR)/syfala_application
BUILD_HW_EXPORT_DIR     := $(BUILD_DIR)/hw_export
BUILD_SW_EXPORT_DIR     := $(BUILD_DIR)/sw_export
BUILD_RTL_DIR           := $(BUILD_DIR)/rtl

SYFALA_CONFIG_H             := $(INCLUDE_DIR)/syfala/config_common.hpp
SYFALA_ARM_CONFIG_H	    := $(INCLUDE_DIR)/syfala/config_arm.hpp
SYFALA_UTILITIES_H          := $(INCLUDE_DIR)/syfala/utilities.hpp

BUILD_SYFALA_CONFIG_H       := $(BUILD_INCLUDE_DIR)/syfala/config_common.hpp
BUILD_SYFALA_ARM_CONFIG_H   := $(BUILD_INCLUDE_DIR)/syfala/config_arm.hpp
BUILD_SYFALA_UTILITIES_H    := $(BUILD_INCLUDE_DIR)/syfala/utilities.hpp

HLS_TARGET_FILE := $(BUILD_IP_DIR)/syfala_ip.cpp
