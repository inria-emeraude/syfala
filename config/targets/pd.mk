# -----------------------------------------------------------------------------
# hvcc support (experimental)
# see: https://github.com/enzienaudio/hvcc
# TODO: parser + implement control
# -----------------------------------------------------------------------------
TARGET_TYPE         := cpp
PREPROCESSOR_HLS    := TRUE
PREPROCESSOR_I2S    := TRUE
NCHANNELS_I         := $(call set_preprocessor_data,0)
NCHANNELS_O         := $(call set_preprocessor_data,2)
NCONTROLS_F         := $(call set_preprocessor_data,0)
NCONTROLS_I         := $(call set_preprocessor_data,0)
NCONTROLS_P         := $(call set_preprocessor_data,0)
PD_SOURCE_DIR       := $(SOURCE_DIR)/pd
PD_TARGET           := $(PD_SOURCE_DIR)/phasor-simple
# PD_TARGET           := $(PD_SOURCE_DIR)/phasor-slider
HLS_FLAGS_INCLUDE   := "-I$(PD_TARGET) -I$(BUILD_INCLUDE_DIR)"
HLS_SOURCE_MAIN     := $(PD_TARGET)/fpga.cpp
HLS_SOURCE_FILES    += $(wildcard $(PD_TARGET)/*.c)
# HOST_MAIN_SOURCE    :=
$(call static_ok, CONFIG_EXPERIMENTAL_PD is $(N)ON$(N))

