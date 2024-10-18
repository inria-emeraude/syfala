# -----------------------------------------------------------------------------
# LINUX
# -----------------------------------------------------------------------------

BUILD_LINUX_BUILD_DIR        := $(BUILD_LINUX_DIR)
BUILD_LINUX_BOOT_DIR         := $(BUILD_LINUX_BUILD_DIR)/boot
BUILD_LINUX_OUTPUT_BOOT_DIR  := $(BUILD_LINUX_BOOT_DIR)/output
BUILD_LINUX_ROOT_DIR         := $(BUILD_LINUX_BUILD_DIR)/root
XILINX_GITHUB                := https://github.com/Xilinx

include $(MK_CONFIG_DIR)/linux/boot.mk
include $(MK_CONFIG_DIR)/linux/root.mk

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

ifeq ($(call dev_exists,$(SD_DEVICE)),1)
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
	$(call shell_ok, Root files successfully copied)
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
	@sudo cp -Tr $(ALPINE_DSP_DIR) /mnt/$(ALPINE_DSP_DIR_CH)
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
