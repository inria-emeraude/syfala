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
SAMPLE_RATE_SUPPORTED           := 24000 48000 48077 78125 96000 156250 192000 312500 384000 625000 5000000 768000 1000000 1250000
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
CONTROLLER_TYPE_SUPPORTED   := DEMO PCB1 PCB2 PCB3 PCB4 TEENSY
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
