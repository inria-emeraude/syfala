
$(call static_info, - $(B)MULTISAMPLE$(N) mode (experimental) is $(B)ON$(N))
$(call static_info, - $(B)FIFO$(N) i/o size: $(MULTISAMPLE) frames)

BD_TARGET  := $(BD_MULTISAMPLE)
I2S_SOURCE := $(SOURCE_I2S_DIR)/i2s_template_multisample.vhd
ifeq ($(TARGET_TYPE), faust)
    FAUST_HLS_ARCH_FILE = $(SOURCE_HLS_DIR)/faust_dsp_template_multisample.cpp
    I2S_PREPROCESSOR := TRUE
else ifeq ($(TARGET_TYPE), cpp)
    HLS_SOURCE_MAIN ?= $(SOURCE_HLS_DIR)/template_fir_multisample.cpp
endif
