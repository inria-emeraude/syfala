
# -----------------------------------------------------------------------------
.PHONY: uboot
# Cloning and compiling Xilinx' u-boot repository
# https://github.com/Xilinx/u-boot-xlnx - branch/tag xilinx-v2022.2
# It will generate the First Stage Boot Loader (FSBL), and the
# Secondary Program Loader (SPL) included in the main 'boot.bin' binary
# and the u-boot.img image. Outputs are :
# - boot.bin
# - spl/u-boot.img
# -----------------------------------------------------------------------------

UBOOT_DIR	:= $(BUILD_LINUX_BOOT_DIR)/u-boot-xlnx-xilinx-v$(XILINX_VERSION)
UBOOT_ZIP	:= $(BUILD_LINUX_BOOT_DIR)/xilinx-uboot-v$(XILINX_VERSION).zip
UBOOT_SOURCES	:= $(XILINX_GITHUB)/u-boot-xlnx/archive/refs/tags/xilinx-v$(XILINX_VERSION).zip
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
	@mkdir -p $(BUILD_LINUX_BOOT_DIR)
	$(call shell_info, Downloading $(B)u-boot$(N) sources)
	@curl -L $(UBOOT_SOURCES) -o $(UBOOT_ZIP)
	$(call shell_info, Extracting $(B)u-boot$(N) sources)
	@unzip -q $(UBOOT_ZIP) -d $(BUILD_LINUX_BOOT_DIR)
	@rm -rf $(UBOOT_ZIP)

uboot: $(UBOOT_BIN_DST)

$(UBOOT_BIN_DST): $(UBOOT_DIR)
	$(call shell_info, Compiling $(B)u-boot$(N))
	export ARCH=arm				    \
     && export CROSS_COMPILE=arm-none-eabi-	    \
     && export DEVICE_TREE=zynq-zybo-z7             \
     && cd $(UBOOT_DIR)                             \
     && make distclean                              \
     && make $(UBOOT_CFG_TARGET)                    \
     && make -j8
	@mkdir -p $(BUILD_LINUX_OUTPUT_BOOT_DIR)
	@cp -r $(UBOOT_BIN_SRC) $(UBOOT_BIN_DST)
	@cp -r $(UBOOT_DTB_SRC) $(UBOOT_DTB_DST)

# -----------------------------------------------------------------------------
.PHONY: kernel
# -----------------------------------------------------------------------------

ifeq ($(XILINX_VERSION), 2022.2)
    KERNEL_VERSION := 5.15.0-xilinx
else ifeq ($(XILINX_VERSION), 2023.2)
    KERNEL_VERSION := 6.1.0-xilinx
else ifeq ($(XILINX_VERSION), 2024.1)
    KERNEL_VERSION := 6.6.0-xilinx
else ifeq ($(XILINX_VERSION), 2024.2)
    KERNEL_VERSION := 6.6.0-xilinx
endif

KERNEL_XTAG     := xilinx-v$(XILINX_VERSION)
KERNEL_SRC	    := $(XILINX_GITHUB)/linux-xlnx/archive/refs/tags/$(KERNEL_XTAG).zip
KERNEL_ZIP	    := $(BUILD_LINUX_BOOT_DIR)/xilinx-kernel-v$(XILINX_VERSION).zip
KERNEL_SRC_DIR	    := $(BUILD_LINUX_BOOT_DIR)/linux-xlnx-xilinx-v$(XILINX_VERSION)
KERNEL_UIMAGE_SRC   := $(KERNEL_SRC_DIR)/arch/arm/boot/uImage
KERNEL_UIMAGE_DST   := $(BUILD_LINUX_OUTPUT_BOOT_DIR)/uImage
KERNEL_CONFIG_DST   := $(KERNEL_SRC_DIR)/arch/arm/configs

ifeq ($(BOARD_FAMILY), ZYNQ_7000) # ------------------------------------
    KERNEL_CONFIG_SRC := $(SOURCE_LINUX_DIR)/configs/zybo_z7_defconfig
endif # ----------------------------------------------------------------

$(KERNEL_SRC_DIR):
	@mkdir -p $(BUILD_LINUX_BOOT_DIR)
	$(call shell_info, Downloading $(B)Linux Kernel$(N) sources: $(KERNEL_SRC))
	@curl -L $(KERNEL_SRC) -o $(KERNEL_ZIP)
	$(call shell_info, Extracting $(B)Linux Kernel$(N) sources)
	@unzip -q $(KERNEL_ZIP) -d $(BUILD_LINUX_BOOT_DIR)
	@rm -rf $(KERNEL_ZIP)

kernel: $(KERNEL_UIMAGE_DST)

$(KERNEL_UIMAGE_DST): $(KERNEL_SRC_DIR) $(KERNEL_CONFIG_SRC)
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
	$(KERNEL_MODULES_CMD_EV)
	$(call shell_info, Extracting Kernel modules: $(KERNEL_MODULES))
	@cd $(KERNEL_SRC_DIR) &&    \
	    tar -zcf modules.tar $(KERNEL_MODULES) --owner=0 --group=0

# -----------------------------------------------------------------------------
.PHONY: dts-source
# -----------------------------------------------------------------------------

DEVICE_TREE_BUILD_SCRIPT := $(SOURCE_LINUX_DIR)/device-tree/build_dts.tcl
DEVICE_TREE_SOURCE_DIR := $(SOURCE_LINUX_DIR)/device-tree/source
DEVICE_TREE_SOURCE := $(DEVICE_TREE_SOURCE_DIR)/source.dts

XILINX_DEVICE_TREE_URL := $(XILINX_GITHUB)/device-tree-xlnx/archive/refs/tags/xilinx_v2023.2.zip
XILINX_DEVICE_TREE_DIR := $(BUILD_LINUX_BOOT_DIR)/device-tree-xlnx
XILINX_DEVICE_TREE_ZIP := $(BUILD_LINUX_BOOT_DIR)/device-tree-xlnx.zip

$(XILINX_DEVICE_TREE_DIR):
	@curl -L $(XILINX_DEVICE_TREE_URL)      \
              -o $(XILINX_DEVICE_TREE_ZIP)
	@unzip -q $(XILINX_DEVICE_TREE_ZIP)     \
               -d $(XILINX_DEVICE_TREE_DIR)

dts-source: $(DEVICE_TREE_SOURCE)

$(DEVICE_TREE_SOURCE): $(DEVICE_TREE_BUILD_SCRIPT)  \
                       $(HW_PLATFORM)               \
                       $(XILINX_DEVICE_TREE_DIR)
	@mkdir -p $(DEVICE_TREE_SOURCE_DIR)
	$(VITIS_EXEC) -eval                         \
	    "source $(DEVICE_TREE_BUILD_SCRIPT);    \
	     build_dts $(HW_PLATFORM) $(XILINX_DEVICE_TREE_DIR) $(DEVICE_TREE_SOURCE_DIR)"


# -----------------------------------------------------------------------------
.PHONY: device-tree
# -----------------------------------------------------------------------------

BUILD_DT_DIR := $(BUILD_LINUX_BOOT_DIR)/device-tree
DTS_DIR := $(BUILD_DT_DIR)/dts
DTS_SRC := $(SOURCE_LINUX_DIR)/device-tree/zybo-z7.dts
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
# -----------------------------------------------------------------------------
linux-boot: uboot kernel device-tree bootscript bootstream
