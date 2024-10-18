
CONFIG              += SIGMA_DELTA
SIGMA_DELTA         := 1
SAMPLE_RATE         := 1250000
SAMPLE_WIDTH        := 24
PREPROCESSOR_HLS    := TRUE
PREPROCESSOR_I2S    := TRUE
BD_TARGET           := $(BD_SIGMA_DELTA)
#BD_TARGET           := $(SOURCE_BD_DIR)/sigma-delta-hls.tcl
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_first.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_first_fixed.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_third_fixed.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_second_fixed.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_fifth_fixed.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sd_dac_fourth_fixed.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/clock_divider.vhd
RTL_SOURCES         += $(SOURCE_RTL_DIR)/sawwave.vhd
RTL_SOURCES	    += $(wildcard $(SOURCE_RTL_DIR)/faust2vhdl/*.vhd)

$(call static_ok, - $(B)CONFIG_EXPERIMENTAL_SIGMA_DELTA$(N) is $(N)ON$(N))
