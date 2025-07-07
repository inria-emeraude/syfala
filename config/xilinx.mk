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
XILINX_VERSION      ?= 2024.2
XILINX_SUPPORTED    := 2020.2 2022.2 2023.2 2024.1 2024.2
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
HLS_PATH        ?= $(XILINX_ROOT_DIR)/Vitis_HLS/$(XILINX_VERSION)
# -----------------------------------------------------------------------------
VIVADO_PATH     ?= $(XILINX_ROOT_DIR)/Vivado/$(XILINX_VERSION)
# -----------------------------------------------------------------------------
VITIS_PATH      := $(XILINX_ROOT_DIR)/Vitis/$(XILINX_VERSION)

ifeq ($(XILINX_FLATPAK), TRUE)
    define flatrun
        flatpak run --filesystem=$(MK_ROOT_DIR) \
                    --command=$(1) com.github.corna.Vivado
    endef
    VIVADO_EXEC  := $(call flatrun,vivado)
    BOOTGEN_EXEC := $(call flatrun,bootgen)
    HLS_EXEC     := $(call flatrun,vitis_hls)
    VITIS_EXEC   := $(call flatrun,xsct)
else
    VIVADO_EXEC  := $(VIVADO_PATH)/bin/vivado
    BOOTGEN_EXEC := $(VIVADO_PATH)/bin/bootgen
    HLS_EXEC     := $(HLS_PATH)/bin/vitis_hls
    VITIS_EXEC   := $(VITIS_PATH)/bin/xsct
endif
