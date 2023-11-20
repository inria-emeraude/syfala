# -----------------------------------------------------------------------------
BOARD               ?= Z10
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
    LINKER_FILE                 ?= $(SOURCE_ARM_BAREMETAL_LINKER_ZYBO)
    BOARD_ID                    := zybo-z7-10
    BOARD_PATH                  := zybo-z7-10
    BOARD_CPP_ID                := 10
    BOARD_PART                  := xc7z010clg400-1
    BOARD_PART_FULL             := digilentinc.com:zybo-z7-10:part0:
    BOARD_PART_REVISION         := A.0
    BOARD_FAMILY                := ZYNQ_7000
    BOARD_ARCH                  := 32-bit
    BOARD_PROC                  := ps7_cortexa9_0
    HLS_CLOCK_PERIOD            := 8.137634
    AUDIO_CODEC_INTERNAL        := SSM2603
    AUDIO_CODEC_EXTERNAL_MAX    := 9
else ifeq ($(BOARD), Z20) # --------------------------------
    CONSTRAINT_FILE             ?= $(SOURCE_CONSTRAINTS_ZYBO)
    LINKER_FILE                 ?= $(SOURCE_ARM_BAREMETAL_LINKER_ZYBO)
    BOARD_ID                    := zybo-z7-20
    BOARD_PATH                  := zybo-z7-20
    BOARD_CPP_ID                := 20
    BOARD_PART                  := xc7z020clg400-1
    BOARD_PART_FULL             := digilentinc.com:zybo-z7-20:part0:
    BOARD_PART_REVISION         := A.0
    BOARD_FAMILY                := ZYNQ_7000
    BOARD_ARCH                  := 32-bit
    BOARD_PROC                  := ps7_cortexa9_0
    HLS_CLOCK_PERIOD            := 8.137634
    AUDIO_CODEC_INTERNAL        := SSM2603
    AUDIO_CODEC_EXTERNAL_MAX    := 13
else ifeq ($(BOARD), GENESYS) # ---------------------------
    CONSTRAINT_FILE             ?= $(SOURCE_CONSTRAINTS_GENESYS)
    LINKER_FILE                 ?= $(SOURCE_ARM_BAREMETAL_LINKER_GENESYS)
    BOARD_ID                    := gzu_3eg
    BOARD_PATH                  := genesys-zu-3eg
    BOARD_CPP_ID                := 30
    BOARD_PART                  := xczu3eg-sfvc784-1-e
    BOARD_PART_FULL             := digilentinc.com:gzu_3eg:part0:
    BOARD_PART_REVISION         := B.0
    BOARD_FAMILY                := MPSOC_ULTRASCALE+
    BOARD_ARCH                  := 64-bit
    BOARD_PROC                  := psu_cortexa53_0
    HLS_CLOCK_PERIOD            := 8.138352
    AUDIO_CODEC_INTERNAL        := ADAU1761
    AUDIO_CODEC_EXTERNAL_MAX    := 16
endif

ifeq ($(XILINX_VERSION), 2020.2) # --------------------------------------------
    BOARD_XPATH := $(VIVADO_PATH)/data/boards/board_files
else ifeq ($(XILINX_VERSION), 2022.2)
    BOARD_XPATH := $(VIVADO_PATH)/data/xhub/boards/XilinxBoardStore/boards/Xilinx
endif # -----------------------------------------------------------------------

BOARD_FILE := $(BOARD_XPATH)/$(BOARD_PATH)/$(BOARD_PART_REVISION)/board.xml
BOARD_VERSION_REGEX := (?<=<file_version>)[0-9]+\.[0-9]+(?=</file_version>)

BOARD_PART_VERSION  := $(shell cat $(BOARD_FILE) | grep -oP '$(BOARD_VERSION_REGEX)')
BOARD_PART_FULL     := $(BOARD_PART_FULL)$(BOARD_PART_VERSION)

$(call static_ok, - $(B)BOARD_PART$(N) = $(BOARD_PART_FULL))
