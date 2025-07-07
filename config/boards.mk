# -----------------------------------------------------------------------------
BOARD               ?= Z10
BOARD_SUPPORTED     := Z10 Z20 Z35 Z100 GENESYS ZU19EG ZU15EG
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
    RESOURCE_DSP_AVAILABLE      := 80
    RESOURCE_FF_AVAILABLE       := 35200
    RESOURCE_LUT_AVAILABLE      := 17600
    RESOURCE_BRAM_AVAILABLE     := 120
    RESOURCE_URAM_AVAILABLE     := 0
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
    RESOURCE_DSP_AVAILABLE      := 220
    RESOURCE_FF_AVAILABLE       := 106400
    RESOURCE_LUT_AVAILABLE      := 53200
    RESOURCE_BRAM_AVAILABLE     := 280
    RESOURCE_URAM_AVAILABLE     := 0
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
    RESOURCE_DSP_AVAILABLE      := 320
    RESOURCE_FF_AVAILABLE       := 141120
    RESOURCE_LUT_AVAILABLE      := 70560
    RESOURCE_BRAM_AVAILABLE     := 432
    RESOURCE_URAM_AVAILABLE     := 0
else ifeq ($(BOARD), ZU19EG) # ---------------------------
    CONSTRAINT_FILE             ?= 0
    LINKER_FILE                 ?= 0
    BOARD_ID                    := 0
    BOARD_PATH                  := 0
    BOARD_CPP_ID                := 40
    BOARD_PART                  := xczu19eg-ffvc1760-1-e
    BOARD_PART_FULL             := 0
    BOARD_PART_REVISION         := 0
    BOARD_FAMILY                := MPSOC_ULTRASCALE+
    BOARD_ARCH                  := 0
    BOARD_PROC                  := 0
    HLS_CLOCK_PERIOD            := 8.138352
    AUDIO_CODEC_INTERNAL        := 0
    AUDIO_CODEC_EXTERNAL_MAX    := 0
    RESOURCE_DSP_AVAILABLE      := 1968
    RESOURCE_FF_AVAILABLE       := 1045440
    RESOURCE_LUT_AVAILABLE      := 522720
    RESOURCE_BRAM_AVAILABLE     := 1968
    RESOURCE_URAM_AVAILABLE     := 128
else ifeq ($(BOARD), ZU15EG) # ---------------------------
    CONSTRAINT_FILE             ?= 0
    LINKER_FILE                 ?= 0
    BOARD_ID                    := 0
    BOARD_PATH                  := 0
    BOARD_CPP_ID                := 50
    BOARD_PART                  := xczu15eg-ffvb1156-1-e
    BOARD_PART_FULL             := 0
    BOARD_PART_REVISION         := 0
    BOARD_FAMILY                := MPSOC_ULTRASCALE+
    BOARD_ARCH                  := 0
    BOARD_PROC                  := 0
    HLS_CLOCK_PERIOD            := 8.138352
    AUDIO_CODEC_INTERNAL        := 0
    AUDIO_CODEC_EXTERNAL_MAX    := 0
    RESOURCE_DSP_AVAILABLE      := 3528
    RESOURCE_FF_AVAILABLE       := 682560
    RESOURCE_LUT_AVAILABLE      := 341280
    RESOURCE_BRAM_AVAILABLE     := 1488
    RESOURCE_URAM_AVAILABLE     := 112
else ifeq ($(BOARD), Z35) # --------------------------------
    CONSTRAINT_FILE             ?= 0
    LINKER_FILE                 ?= 0
    BOARD_ID                    := 0
    BOARD_PATH                  := 0
    BOARD_CPP_ID                := 60
    BOARD_PART                  := xc7z035ffg676-1
    BOARD_PART_FULL             := 0
    BOARD_PART_REVISION         := 0
    BOARD_FAMILY                := ZYNQ_7000
    BOARD_ARCH                  := 0
    BOARD_PROC                  := 0
    HLS_CLOCK_PERIOD            := 8.137634
    AUDIO_CODEC_INTERNAL        := 0
    AUDIO_CODEC_EXTERNAL_MAX    := 0
    RESOURCE_DSP_AVAILABLE      := 900
    RESOURCE_FF_AVAILABLE       := 343800
    RESOURCE_LUT_AVAILABLE      := 171900
    RESOURCE_BRAM_AVAILABLE     := 1000
    RESOURCE_URAM_AVAILABLE     := 0
else ifeq ($(BOARD), Z100) # --------------------------------
    CONSTRAINT_FILE             ?= 0
    LINKER_FILE                 ?= 0
    BOARD_ID                    := 0
    BOARD_PATH                  := 0
    BOARD_CPP_ID                := 70
    BOARD_PART                  := xc7z100ffg900-1
    BOARD_PART_FULL             := 0
    BOARD_PART_REVISION         := 0
    BOARD_FAMILY                := ZYNQ_7000
    BOARD_ARCH                  := 0
    BOARD_PROC                  := 0
    HLS_CLOCK_PERIOD            := 8.137634
    AUDIO_CODEC_INTERNAL        := 0
    AUDIO_CODEC_EXTERNAL_MAX    := 0
    RESOURCE_DSP_AVAILABLE      := 2020
    RESOURCE_FF_AVAILABLE       := 554800
    RESOURCE_LUT_AVAILABLE      := 277400
    RESOURCE_BRAM_AVAILABLE     := 1510
    RESOURCE_URAM_AVAILABLE     := 0
endif

XPATH_BOARDSTORE := $(VIVADO_PATH)/data/xhub/boards/XilinxBoardStore/boards/Xilinx

ifeq ($(XILINX_VERSION), 2020.2) # ----------------------
    BOARD_XPATH := $(VIVADO_PATH)/data/boards/board_files
else ifeq ($(XILINX_VERSION), 2022.2)
    BOARD_XPATH := $(XPATH_BOARDSTORE)
else ifeq ($(XILINX_VERSION), 2023.2)
    BOARD_XPATH := $(XPATH_BOARDSTORE)
else ifeq ($(XILINX_VERSION), 2024.1)
    BOARD_XPATH := $(XPATH_BOARDSTORE)
else ifeq ($(XILINX_VERSION), 2024.2)
    BOARD_XPATH := $(XPATH_BOARDSTORE)
else
    $(call static_error, Please update file config/boards.mk with new Xilinx version)
endif # -------------------------------------------------

BOARD_FILE := $(BOARD_XPATH)/$(BOARD_PATH)/$(BOARD_PART_REVISION)/board.xml
BOARD_VERSION_REGEX := (?<=<file_version>)[0-9]+\.[0-9]+(?=</file_version>)

BOARD_PART_VERSION  := $(shell cat $(BOARD_FILE) | grep -oP '$(BOARD_VERSION_REGEX)')
BOARD_PART_FULL     := $(BOARD_PART_FULL)$(BOARD_PART_VERSION)

$(call static_ok, - $(B)BOARD_PART$(N) = $(BOARD_PART_FULL))
