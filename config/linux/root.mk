# -----------------------------------------------------------------------------
# ROOT
# -----------------------------------------------------------------------------
ALPINE_VERSION_MAJOR	:= 3
ALPINE_VERSION_MINOR	:= 19
ALPINE_VERSION_PATCH	:= 1
ALPINE_VERSION_DATE	:= 20231111
ALPINE_VERSION		:= $(ALPINE_VERSION_MAJOR).$(ALPINE_VERSION_MINOR)
ALPINE_VERSION_FULL	:= $(ALPINE_VERSION).$(ALPINE_VERSION_PATCH)
ALPINE_BUILD_DIR	:= $(BUILD_LINUX_ROOT_DIR)/alpine-$(ALPINE_VERSION_FULL)
# -----------------------------------------------------------------------------
ALPINE_ROOT_DIR		:= $(ALPINE_BUILD_DIR)/alpine-root
ALPINE_TARGET_URL	:= http://dl-cdn.alpinelinux.org/alpine/v$(ALPINE_VERSION)
ALPINE_EDGE_TARGET_URL	:= http://dl-cdn.alpinelinux.org/alpine/edge
# -----------------------------------------------------------------------------
ALPINE_UBOOT		:= alpine-uboot-$(ALPINE_VERSION_FULL)-armv7.tar.gz
ALPINE_UBOOT_URL	:= $(ALPINE_TARGET_URL)/releases/armv7/$(ALPINE_UBOOT)
ALPINE_UBOOT_FILE	:= $(ALPINE_BUILD_DIR)/$(ALPINE_UBOOT)
ALPINE_UBOOT_DIR	:= $(ALPINE_BUILD_DIR)/alpine-uboot
# -----------------------------------------------------------------------------
ALPINE_APK_TOOLS	:= apk-tools-static-2.14.4-r0.apk
ALPINE_APK_TOOLS_URL	:= $(ALPINE_TARGET_URL)/main/armv7/$(ALPINE_APK_TOOLS)
ALPINE_APK_TOOLS_FILE	:= $(ALPINE_BUILD_DIR)/$(ALPINE_APK_TOOLS)
ALPINE_APK_TOOLS_DIR	:= $(ALPINE_BUILD_DIR)/alpine-tools
# -----------------------------------------------------------------------------
ALPINE_FIRMWARE         := linux-firmware-other-$(ALPINE_VERSION_DATE)-r4.apk
ALPINE_FIRMWARE_FILE	:= $(ALPINE_BUILD_DIR)/$(ALPINE_FIRMWARE)
ALPINE_FIRMWARE_URL     := $(ALPINE_TARGET_URL)/main/armv7/$(ALPINE_FIRMWARE)
# -----------------------------------------------------------------------------
ALPINE_ADDITIONAL_FIRMWARE += linux-firmware-ath9k_htc-$(ALPINE_VERSION_DATE)-r1.apk
ALPINE_ADDITIONAL_FIRMWARE += linux-firmware-brcm-$(ALPINE_VERSION_DATE)-r1.apk
ALPINE_ADDITIONAL_FIRMWARE += linux-firmware-rtlwifi-$(ALPINE_VERSION_DATE)-r1.apk
# -----------------------------------------------------------------------------
ifeq ($(call file_exists, /run/systemd/resolve/stub-resolv.conf), 1)
    RESOLV_SOURCE := /run/systemd/resolve/stub-resolv.conf
else ifeq ($(call file_exists, /etc/resolv.conf), 1)
    RESOLV_SOURCE := /etc/resolv.conf
endif

RESOLV_TARGET := $(ALPINE_ROOT_DIR)/etc/resolv.conf
# -----------------------------------------------------------------------------
ETC_NETWORK_INTERFACES_SOURCE := $(SOURCE_LINUX_DIR)/files/interfaces
ETC_NETWORK_INTERFACES_TARGET := $(ALPINE_ROOT_DIR)/etc/network/interfaces
# -----------------------------------------------------------------------------
QEMU_SOURCE := /usr/bin/qemu-arm-static
QEMU_TARGET := $(ALPINE_ROOT_DIR)$(QEMU_SOURCE)
# -----------------------------------------------------------------------------
ALPINE_BASE += $(ALPINE_ROOT_DIR)/sbin/apk.static
ALPINE_BASE += $(RESOLV_TARGET)
ALPINE_BASE += $(QEMU_TARGET)
# -----------------------------------------------------------------------------
ALPINE_REPOSITORY_MAIN              := $(ALPINE_TARGET_URL)/main
ALPINE_REPOSITORY_COMMUNITY         := $(ALPINE_TARGET_URL)/community
ALPINE_REPOSITORY_EDGE_MAIN         := $(ALPINE_EDGE_TARGET_URL)/main
ALPINE_REPOSITORY_EDGE_COMMUNITY    := $(ALPINE_EDGE_TARGET_URL)/community
ALPINE_REPOSITORY_EDGE_TESTING      := $(ALPINE_EDGE_TARGET_URL)/testing
# -----------------------------------------------------------------------------

ALPINE_SOURCES += $(ALPINE_UBOOT_DIR)
ALPINE_SOURCES += $(ALPINE_APK_TOOLS_DIR)
ALPINE_SOURCES += $(ALPINE_FIRMWARE_DIR)
ALPINE_SOURCES += $(RESOLV_SOURCE)
ALPINE_SOURCES += $(QEMU_SOURCE)

# -----------------------------------------------------------------------------
.PHONY: alpine-sources
# -----------------------------------------------------------------------------
alpine-sources: $(ALPINE_SOURCES)

$(ALPINE_SOURCES):
	$(call shell_info, Fetching $(B)Alpine Linux$(N) sources)
	@mkdir -p $(ALPINE_UBOOT_DIR)
	@mkdir -p $(ALPINE_APK_TOOLS_DIR)
	$(call shell_info, Downloading alpine u-boot)
	@curl -o $(ALPINE_UBOOT_FILE)				    \
	      -L $(ALPINE_UBOOT_URL)
	$(call shell_info, Downloading alpine apk-tools)
	curl -o $(ALPINE_APK_TOOLS_FILE)			    \
	      -L $(ALPINE_APK_TOOLS_URL)
	$(call shell_info, Downloading Linux firmware)
	@curl -o $(ALPINE_FIRMWARE_FILE)			    \
	      -L $(ALPINE_FIRMWARE_URL)
	$(call shell_info, Extracting u-boot)
	@tar -zxf $(ALPINE_UBOOT_FILE)				    \
	     --directory=$(ALPINE_UBOOT_DIR)
	$(call shell_info, Extracting apk-tools)
	@tar -zxf $(ALPINE_APK_TOOLS_FILE)			    \
	    --directory=$(ALPINE_APK_TOOLS_DIR)			    \
	    --warning=no-unknown-keyword
	$(call shell_info, Downloading additional firmware)
	@$(foreach firmware, $(ALPINE_ADDITIONAL_FIRMWARE),	    \
	     curl -o $(ALPINE_BUILD_DIR)/$(firmware)		    \
		  -L $(ALPINE_TARGET_URL)/main/armv7/$(firmware);   \
	)

define chroot # --------------------------------------------------------------
    @export PATH=$PATH:/usr/bin:/sbin:/bin:/usr/sbin &&                     \
    sudo chroot $(ALPINE_ROOT_DIR) /usr/bin/qemu-arm-static /bin/sh -c '$(1)'
endef # ----------------------------------------------------------------------

# -----------------------------------------------------------------------------
.PHONY: alpine-base
# -----------------------------------------------------------------------------

alpine-base: $(ALPINE_BASE)

$(ALPINE_BASE): $(ALPINE_SOURCES)
	$(call shell_info, Creating $(B)root filesystem$(N) (rootfs))
	@mkdir -p $(ALPINE_ROOT_DIR)/bin
	@mkdir -p $(ALPINE_ROOT_DIR)/usr/bin
	@mkdir -p $(ALPINE_ROOT_DIR)/etc/apk
	@mkdir -p $(ALPINE_ROOT_DIR)/etc/network
	@cp -r $(ALPINE_APK_TOOLS_DIR)/sbin $(ALPINE_ROOT_DIR)/
	@cp -r $(QEMU_SOURCE) $(QEMU_TARGET)
	@cp -r $(RESOLV_SOURCE) $(RESOLV_TARGET)
	@cp -r $(ETC_NETWORK_INTERFACES_SOURCE) $(ETC_NETWORK_INTERFACES_TARGET)
	$(call shell_info, Installing $(B)alpine-base$(N) package)
	sudo chroot $(ALPINE_ROOT_DIR) /sbin/apk.static     \
		--repository $(ALPINE_TARGET_URL)/main	    \
		--update-cache				    \
		--allow-untrusted			    \
		--initdb				    \
		add alpine-base

# -----------------------------------------------------------------------------
.PHONY: alpine-modules
# -----------------------------------------------------------------------------

ALPINE_MODULES_DIR := $(ALPINE_ROOT_DIR)/lib/modules/$(KERNEL_VERSION)
ALPINE_MODULES_KERNEL_DIR := $(ALPINE_MODULES_DIR)/kernel

alpine-modules: $(ALPINE_MODULES_KERNEL_DIR)

$(ALPINE_MODULES_KERNEL_DIR): $(ALPINE_BASE) $(KERNEL_MODULES_TAR)
	$(call shell_info, Installing $(B)Kernel modules$(N))
	@sudo mkdir -p $(ALPINE_MODULES_KERNEL_DIR)
	@cd $(ALPINE_MODULES_KERNEL_DIR) && sudo tar -zxf $(KERNEL_MODULES_TAR)
	@sudo cp -r $(KERNEL_SRC_DIR)/modules.builtin		\
		    $(KERNEL_SRC_DIR)/modules.builtin.modinfo	\
		    $(KERNEL_SRC_DIR)/modules.order		\
	    $(ALPINE_MODULES_DIR)/
	@sudo depmod -a -b $(ALPINE_ROOT_DIR) $(KERNEL_VERSION)

# -----------------------------------------------------------------------------
.PHONY: alpine-fw
# TODO: ideally, we'd have to reference all modules here, because the
# ALPINE_FW is actually empty...
# -----------------------------------------------------------------------------

alpine-fw: $(ALPINE_FW)

$(ALPINE_FW): $(ALPINE_MODULES) $(ALPINE_FIRMWARE_FILE) $(ALPINE_ADDITIONAL_FIRMWARE)
	$(call shell_info, Installing $(B)Linux firmware$(N))
	@sudo tar -zxf $(ALPINE_FIRMWARE_FILE)		    \
	    --directory=$(ALPINE_ROOT_DIR)/lib/modules	    \
	    --warning=no-unknown-keyword		    \
	    --strip-components=1			    \
	    --wildcards lib/firmware/ar* lib/firmware/rt*
	$(foreach fw, $(ALPINE_ADDITIONAL_FIRMWARE),	    \
	    sudo tar -zxf $(ALPINE_BUILD_DIR)/$(fw)	    \
	        --directory=$(ALPINE_ROOT_DIR)/lib/modules  \
	        --warning=no-unknown-keyword		    \
	        --strip-components=1;			    \
	)
# -----------------------------------------------------------------------------
.PHONY: alpine-repositories
# -----------------------------------------------------------------------------

CH_ALPINE_REPOSITORIES_FILE := /etc/apk/repositories
ALPINE_REPOSITORIES_FILE := $(ALPINE_ROOT_DIR)$(CH_ALPINE_REPOSITORIES_FILE)

alpine-repositories: $(ALPINE_REPOSITORIES_FILE)

$(ALPINE_REPOSITORIES_FILE): $(ALPINE_BASE)
	$(call shell_info, Setting up Alpine Linux repositories)
	@mkdir -p $(ALPINE_ROOT_DIR)/etc/apk
	$(call chroot, echo "$(ALPINE_REPOSITORY_MAIN)"		\
                          > $(CH_ALPINE_REPOSITORIES_FILE))
	$(call chroot, echo $(ALPINE_REPOSITORY_COMMUNITY)       \
                         >> $(CH_ALPINE_REPOSITORIES_FILE))

# -----------------------------------------------------------------------------

include $(MK_CONFIG_DIR)/linux/alpine-packages.mk

# -----------------------------------------------------------------------------

ALPINE_GCC_BIN	    := $(ALPINE_ROOT_DIR)/usr/bin/gcc
ALPINE_PYTHON3_BIN  := $(ALPINE_ROOT_DIR)/usr/bin/python3
ALPINE_RUSTC_BIN    := $(ALPINE_ROOT_DIR)/usr/bin/rustc
ALPINE_CARGO_BIN    := $(ALPINE_ROOT_DIR)/usr/bin/cargo

# -----------------------------------------------------------------------------
.PHONY: alpine-packages
# -----------------------------------------------------------------------------

alpine-packages: $(ALPINE_REPOSITORIES_FILE)
	$(call shell_info, Installing additional packages)
	$(call chroot,apk update)
	$(call chroot,apk add $(ALPINE_PACKAGES))
	$(call chroot,apk add $(ALPINE_PACKAGES_EDGE_MAIN)	\
		--repository $(ALPINE_REPOSITORY_EDGE_MAIN))
	$(call chroot,apk add $(ALPINE_PACKAGES_EDGE_TESTING)	\
		--repository $(ALPINE_REPOSITORY_EDGE_TESTING))

# -----------------------------------------------------------------------------
.PHONY: alpine-inittab
# -----------------------------------------------------------------------------

ALPINE_INITTAB_SRC := $(SOURCE_LINUX_DIR)/alpine-root/inittab
ALPINE_INITTAB_DST := $(ALPINE_ROOT_DIR)/etc/inittab

alpine-inittab: $(ALPINE_INITTAB_DST)

$(ALPINE_INITTAB_DST): $(ALPINE_INITTAB_SRC) alpine-packages
	$(call shell_info, Registering daemons)
	$(call chroot, rc-update add bootmisc boot)
	$(call chroot, rc-update add hostname boot)
	$(call chroot, rc-update add hwdrivers boot)
	$(call chroot, rc-update add bootmisc boot)
	$(call chroot, rc-update add modules boot)
	$(call chroot, rc-update add swclock boot)
ifeq ($(BOARD_FAMILY), MPSOC_ULTRASCALE+) # ------------
	$(call chroot, rc-update add hwclock boot)
endif # ------------------------------------------------
	$(call chroot, rc-update add sysctl boot)
	$(call chroot, rc-update add syslog boot)
	$(call chroot, rc-update add seedrng boot)
# SHUTDOWN ---------------------------------------------------
	$(call chroot, rc-update add killprocs shutdown)
	$(call chroot, rc-update add mount-ro shutdown)
	$(call chroot, rc-update add savecache shutdown)
# SYSINIT ----------------------------------------------------
	$(call chroot, rc-update add devfs sysinit)
	$(call chroot, rc-update add dmesg sysinit)
	$(call chroot, rc-update add mdev sysinit)
# DEFAULT ----------------------------------------------------
	$(call chroot, rc-update add avahi-daemon default)
	$(call chroot, rc-update add chronyd default)
	$(call chroot, rc-update add dhcpcd default)
	$(call chroot, rc-update add networking default)
	$(call chroot, rc-update add local default)
	$(call chroot, rc-update add dcron default)
	$(call chroot, rc-update add sshd default)
#	$(call chroot, rc-update add alsa default)
	$(call chroot, rc-update add iwd default)
# TODO: fix: run avahi-daemon with the '--no-drop-root' flag, or else it won't start...
	@sudo sed -i "s/avahi-daemon\s-D.*/avahi-daemon -D --no-drop-root/g" \
	      $(ALPINE_ROOT_DIR)/etc/init.d/avahi-daemon
# SND-SEQ LOAD -----------------------------------------------
	$(call chroot, echo snd-seq >> /etc/modules)
	$(call chroot, echo snd-dummy >> /etc/modules)
# INITTAB ----------------------------------------------------
	@sudo cp -r $(ALPINE_INITTAB_SRC) $(ALPINE_INITTAB_DST)

# -----------------------------------------------------------------------------
.PHONY: alpine-home
# -----------------------------------------------------------------------------
alpine-home: alpine-packages
	$(call shell_info, Setting up $(B)users and permissions$(N))
	$(call chroot, sed -i 's/^SAVE_ON_STOP=.*/SAVE_ON_STOP="no"/g' /etc/conf.d/iptables)
	$(call chroot, sed -i 's/^IPFORWARD=.*/IPFORWARD="yes"/g' /etc/conf.d/iptables)
	$(call chroot, sed -i "s/^#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config)
	$(call chroot, echo "root:syfala" | /usr/sbin/chpasswd)
	$(call chroot, setup-hostname syfala)
	$(call chroot, chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo)
# Allow ttyPS0 to login as root
	$(call chroot, echo ttyPS0 >> /etc/securetty)
	$(call shell_info, Adding users to 'audio' group)
	$(call chroot, addgroup root audio)

# -----------------------------------------------------------------------------
.PHONY: alpine-fpgautil
# -----------------------------------------------------------------------------

ALPINE_FPGAUTIL_SRC := $(SOURCE_LINUX_DIR)/files/fpgautil.c
ALPINE_FPGAUTIL_DST := /usr/bin/fpgautil.c
ALPINE_FPGAUTIL_BIN := $(ALPINE_ROOT_DIR)/usr/bin/fpgautil

alpine-fpgautil: $(ALPINE_FPGAUTIL_BIN)

$(ALPINE_FPGAUTIL_BIN): $(ALPINE_FPGAUTIL_SRC)
	$(call shell_info, Compiling $(B)fpgautil$(N) utility)
	@sudo cp -r $(ALPINE_FPGAUTIL_SRC) $(ALPINE_ROOT_DIR)$(ALPINE_FPGAUTIL_DST)
	$(call chroot, gcc -O3 $(ALPINE_FPGAUTIL_DST) -o /usr/bin/fpgautil)
	@rm -rf $(ALPINE_ROOT_DIR)$(ALPINE_FPGAUTIL_DST)

# -----------------------------------------------------------------------------
.PHONY: alpine-fpgabit2bin
# -----------------------------------------------------------------------------

ALPINE_FPGA_BIT2BIN_SRC := $(SOURCE_LINUX_DIR)/files/fpga-bit-to-bin.py
ALPINE_FPGA_BIT2BIN_DST := $(ALPINE_ROOT_DIR)/usr/bin/fpga-bit-to-bin.py

alpine-fpgabit2bin: $(ALPINE_FPGA_BIT2BIN_DST)

$(ALPINE_FPGA_BIT2BIN_DST): $(ALPINE_FPGA_BIT2BIN_SRC)
	@sudo cp -r $(ALPINE_FPGA_BIT2BIN_SRC) $(ALPINE_FPGA_BIT2BIN_DST)

# -----------------------------------------------------------------------------
.PHONY: alpine-syfala-load
# -----------------------------------------------------------------------------

ALPINE_SYFALA_LOAD_SRC_DIR := $(SOURCE_LINUX_DIR)/syfala-load
ALPINE_SYFALA_LOAD_DST_DIR := $(ALPINE_ROOT_DIR)/root
ALPINE_SYFALA_LOAD_BIN := $(ALPINE_ROOT_DIR)/usr/bin/syfala-load

ALPINE_SYFALA_LOAD_SOURCES += $(ALPINE_SYFALA_LOAD_SRC_DIR)/src/main.rs

alpine-syfala-load: $(ALPINE_SYFALA_LOAD_BIN)

$(ALPINE_SYFALA_LOAD_BIN): $(ALPINE_SYFALA_LOAD_SOURCES)
	$(call shell_info, Compiling $(B)syfala-load$(N) utility)
	@sudo cp -rf $(ALPINE_SYFALA_LOAD_SRC_DIR) $(ALPINE_SYFALA_LOAD_DST_DIR)
	$(call chroot, cargo install --path /root/syfala-load --root /usr -j 8)
	@sudo rm -rf $(ALPINE_SYFALA_LOAD_DST_DIR)

# -----------------------------------------------------------------------------
# Linux TARGET compilation
# -----------------------------------------------------------------------------

SOURCE_ARM_LINUX_DIR    := $(SOURCE_ARM_DIR)/linux
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/audio.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/gpio.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/ip.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/memory.cpp
ARM_LINUX_CPP_MODULES   += $(SOURCE_ARM_LINUX_DIR)/spi.cpp

ALPINE_DSP_DIR_CH   := /root/$(DSP_TARGET_NAME)
ALPINE_DSP_DIR      := $(ALPINE_ROOT_DIR)$(ALPINE_DSP_DIR_CH)

ALPINE_DSP_APPLICATION_SOURCES += $(SOURCE_ARM_LINUX_DIR)/Makefile
ALPINE_DSP_APPLICATION_SOURCES += $(ARM_LINUX_CPP_MODULES)

ifeq ($(TARGET_TYPE), faust) # ----------------------------------------------
    ALPINE_DSP_APPLICATION_SOURCES += $(SOURCE_ARM_LINUX_DIR)/arm.cpp
    ALPINE_DSP_APPLICATION_SOURCES += $(SOURCE_ARM_DIR)/faust/control.cpp
else ifeq ($(TARGET_TYPE), cpp) # -------------------------------------------
    ifdef HOST_MAIN_SOURCE
        ALPINE_DSP_APPLICATION_SOURCES += $(HOST_MAIN_SOURCE)
        ALPINE_DSP_APPLICATION_CUSTOM_INCLUDES += $(wildcard $(dir $(HOST_MAIN_SOURCE))*.hpp)
        ALPINE_DSP_APPLICATION_CUSTOM_INCLUDES += $(wildcard $(dir $(HOST_MAIN_SOURCE))*.h)
        NINCLUDES := $(words $(ALPINE_DSP_APPLICATION_CUSTOM_INCLUDES))
    else
        ALPINE_DSP_APPLICATION_SOURCES += $(SOURCE_ARM_LINUX_DIR)/arm_no_faust.cpp
    endif
endif # ----------------------------------------------------------------

ALPINE_DSP_APPLICATION_SOURCES_TARGETS := $(addprefix $(ALPINE_DSP_DIR)/src/,$(notdir $(ALPINE_DSP_APPLICATION_SOURCES)))
ALPINE_DSP_APPLICATION_INCLUDE_DIR := $(ALPINE_DSP_DIR)/src/include

#------------------------------------------------------------------------------
.PHONY: alpine-bitstream
#------------------------------------------------------------------------------

ALPINE_DSP_BITSTREAM := $(ALPINE_DSP_DIR)/bitstream.bin

alpine-bitstream: $(ALPINE_DSP_BITSTREAM)

$(ALPINE_DSP_BITSTREAM): $(BITSTREAM) $(ALPINE_FPGA_BIT2BIN_DST)
	$(call shell_info, Copying DSP $(B)bitstream$(N))
	@sudo mkdir -p $(ALPINE_DSP_DIR)
	@sudo cp $(BITSTREAM) $(ALPINE_DSP_DIR)/system.bit
	$(call chroot, python3 /usr/bin/fpga-bit-to-bin.py	    \
			    -f $(ALPINE_DSP_DIR_CH)/system.bit	    \
			       $(ALPINE_DSP_DIR_CH)/bitstream.bin   \
	)
	@sudo rm -rf $(ALPINE_DSP_DIR)/system.bit

#------------------------------------------------------------------------------
.PHONY: alpine-application-sources
#------------------------------------------------------------------------------

alpine-application-sources: $(ALPINE_DSP_APPLICATION_SOURCES_TARGETS)

$(ALPINE_DSP_APPLICATION_SOURCES_TARGETS): $(ALPINE_DSP_APPLICATION_SOURCES)
	$(call shell_info, Copying DSP application $(B)sources$(N))
	@sudo mkdir -p $(ALPINE_DSP_DIR)/src
	@sudo cp -r $(ALPINE_DSP_APPLICATION_SOURCES)				\
        	    $(ALPINE_DSP_DIR)/src

#------------------------------------------------------------------------------
.PHONY: alpine-application-xsources
#------------------------------------------------------------------------------

ALPINE_DSP_APPLICATION_XSOURCES := $(addprefix $(ALPINE_DSP_DIR)/src/,$(notdir $(XSOURCES)))

alpine-application-xsources: $(ALPINE_DSP_APPLICATION_XSOURCES)

$(ALPINE_DSP_APPLICATION_XSOURCES): $(XSOURCES)
	$(call shell_info, Copying Xilinx-generated sources)
	@sudo mkdir -p $(ALPINE_DSP_DIR)/src
	@sudo cp -r $(XSOURCES) $(ALPINE_DSP_DIR)/src

#------------------------------------------------------------------------------
.PHONY: alpine-application
#------------------------------------------------------------------------------

ALPINE_DSP_APPLICATION := $(ALPINE_DSP_DIR)/application.elf
alpine-application: $(ALPINE_DSP_APPLICATION)

ALPINE_DSP_APPLICATION_DEPENDENCIES += $(ALPINE_DSP_APPLICATION_SOURCES_TARGETS)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(ALPINE_DSP_APPLICATION_XSOURCES)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(BUILD_SYFALA_UTILITIES_H)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(BUILD_SYFALA_ARM_CONFIG_H)
ALPINE_DSP_APPLICATION_DEPENDENCIES += $(BUILD_HOST_INCLUDES)

ifeq ($(TARGET_TYPE), faust)
    ALPINE_DSP_APPLICATION_DEPENDENCIES += $(FAUST_CONTROL_SOURCE)
endif

$(ALPINE_DSP_APPLICATION): $(ALPINE_DSP_APPLICATION_DEPENDENCIES)
	$(call shell_info, Copying/updating include directory)
	@sudo cp -r $(BUILD_DIR)/include $(ALPINE_DSP_DIR)/src
	@sudo cp -r $(INCLUDE_DIR)/syfala/arm/linux $(ALPINE_DSP_APPLICATION_INCLUDE_DIR)/syfala/arm
ifeq ($(shell expr $(NINCLUDES) \> 0), 1)
	@sudo cp  $(ALPINE_DSP_APPLICATION_CUSTOM_INCLUDES) $(ALPINE_DSP_DIR)/src
endif
	$(call shell_info, Compiling DSP control application)
	$(call chroot, make -C $(ALPINE_DSP_DIR_CH)/src clean)
	$(call chroot, make -C $(ALPINE_DSP_DIR_CH)/src -j8)
	@mkdir -p $(BUILD_DIR)/linux
	@cp -r $(ALPINE_DSP_DIR) $(BUILD_DIR)/linux

# -----------------------------------------------------------------------------------
ALPINE_ETHERNET_CLIENT := $(ALPINE_ROOT_DIR)/usr/bin/syfala-ethernet
# -----------------------------------------------------------------------------------

ALPINE_ETHERNET_SOURCE_DIR := $(SOURCE_DIR)/linux/ethernet
ALPINE_ETHERNET_TARGET_DIR := $(ALPINE_ROOT_DIR)/home/ethernet

ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/Cargo.toml
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/Cross.toml
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/client/Cargo.toml
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/client/build.rs
ALPINE_ETHERNET_SOURCES += $(wildcard $(ALPINE_ETHERNET_SOURCE_DIR)/client/src/*.rs)
ALPINE_ETHERNET_SOURCES += $(wildcard $(ALPINE_ETHERNET_SOURCE_DIR)/client/src/axi/*.rs)
ALPINE_ETHERNET_SOURCES += $(ALPINE_ETHERNET_SOURCE_DIR)/shared/Cargo.toml
ALPINE_ETHERNET_SOURCES += $(wildcard $(ALPINE_ETHERNET_SOURCE_DIR)/shared/src/*.rs)

ALPINE_ETHERNET_TARGETS := $(subst $(ALPINE_ETHERNET_SOURCE_DIR),$(ALPINE_ETHERNET_TARGET_DIR),$(ALPINE_ETHERNET_SOURCES)))

ALPINE_ETHERNET_JSON_SOURCE	:= $(BUILD_ETHERNET_HLS_DIR)/eth_audio/eth_audio_data.json
ALPINE_ETHERNET_JSON_TARGET	:= $(ALPINE_DSP_DIR)/eth_audio_data.json
ALPINE_ETHERNET_JSON_TARGET_CH	:= $(ALPINE_DSP_DIR_CH)/eth_audio_data.json

$(ALPINE_ETHERNET_JSON_TARGET): $(ALPINE_DSP_APPLICATION) $(ETHERNET_HLS_OUTPUT) $(ALPINE_ETHERNET_JSON_SOURCE)
	$(call shell_info, Installing Ethernet Audio register map)
	@sudo mkdir -p $(ALPINE_DSP_DIR)
	@sudo cp -r $(ALPINE_ETHERNET_JSON_SOURCE) $(ALPINE_DSP_DIR)/

ALPINE_ETHERNET_DEPENDENCIES += $(ALPINE_ETHERNET_SOURCES)
ALPINE_ETHERNET_DEPENDENCIES += $(ALPINE_ETHERNET_JSON_TARGET)

$(ALPINE_ETHERNET_TARGET_DIR): $(ALPINE_ETHERNET_DEPENDENCIES)
	$(call shell_info, Preparing Ethernet client application sources)
	@sudo cp -Tr $(ALPINE_ETHERNET_SOURCE_DIR) $(ALPINE_ETHERNET_TARGET_DIR)
	@sudo touch $(ALPINE_ETHERNET_TARGET_DIR)

$(ALPINE_ETHERNET_TARGETS): $(ALPINE_ETHERNET_TARGET_DIR)

$(ALPINE_ETHERNET_CLIENT): $(ALPINE_ETHERNET_TARGET_DIR) alpine-packages
	$(call shell_info, Compiling Ethernet client application (this could take a while...))
	$(call chroot,								\
	    export HLS_ETHERNET_DATA_JSON=$(ALPINE_ETHERNET_JSON_TARGET_CH)	\
	    && export CARGO_TARGET_DIR=/home					\
	    && cd /home/ethernet/client						\
	    && cargo --config "net.git-fetch-with-cli = true" build --release	\
	)
	$(call shell_ok, Installing Ethernet client application in /usr/bin/syfala-ethernet)
	@sudo cp -r $(ALPINE_ROOT_DIR)/home/release/client	\
		    $(ALPINE_ETHERNET_CLIENT)

ifeq ($(CONFIG_EXPERIMENTAL_ETHERNET), TRUE)
    LINUX_ROOT_DEPENDENCIES += $(ALPINE_ETHERNET_CLIENT)
endif

# -----------------------------------------------------------------------------

LINUX_ROOT_DEPENDENCIES += alpine-modules alpine-home
LINUX_ROOT_DEPENDENCIES += $(ALPINE_FW)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_REPOSITORIES_FILE)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_INITTAB_DST)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_FPGAUTIL_BIN)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_FPGA_BIT2BIN_DST)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_SYFALA_LOAD_BIN)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_DSP_BITSTREAM)
LINUX_ROOT_DEPENDENCIES += $(ALPINE_DSP_APPLICATION)

# -----------------------------------------------------------------------------
.PHONY: linux-root
# -----------------------------------------------------------------------------
linux-root: $(LINUX_ROOT_DEPENDENCIES)

# -----------------------------------------------------------------------------
.PHONY: linux-dsp
# -----------------------------------------------------------------------------
LINUX_DSP_OUTPUT_DIR := $(BUILD_LINUX_OUTPUT_DIR)/dsp/$(DSP_TARGET_NAME)
LINUX_DSP_OUTPUT_BIN := $(LINUX_DSP_OUTPUT_DIR)/bitstream.bin
LINUX_DSP_OUTPUT_APP := $(LINUX_DSP_OUTPUT_DIR)/application.elf

LINUX_DSP_DEPENDENCIES += $(ALPINE_REPOSITORIES_FILE)
LINUX_DSP_DEPENDENCIES += $(ALPINE_INITTAB_DST)
LINUX_DSP_DEPENDENCIES += $(ALPINE_FPGAUTIL_BIN)
LINUX_DSP_DEPENDENCIES += $(ALPINE_FPGA_BIT2BIN_DST)
LINUX_DSP_DEPENDENCIES += $(ALPINE_SYFALA_LOAD_BIN)
LINUX_DSP_DEPENDENCIES += $(ALPINE_DSP_BITSTREAM)
LINUX_DSP_DEPENDENCIES += $(ALPINE_DSP_APPLICATION)
LINUX_DSP_DEPENDENCIES += $(LINUX_DSP_OUTPUT_BIN)
LINUX_DSP_DEPENDENCIES += $(LINUX_DSP_OUTPUT_APP)

$(LINUX_DSP_OUTPUT_BIN): $(ALPINE_DSP_BITSTREAM)
	$(call shell_info, Copying bitstream output in $(LINUX_DSP_OUTPUT_BIN))
	@mkdir -p $(LINUX_DSP_OUTPUT_DIR)
	@cp -r $(ALPINE_DSP_BITSTREAM) $(LINUX_DSP_OUTPUT_BIN)

$(LINUX_DSP_OUTPUT_APP): $(ALPINE_DSP_APPLICATION)
	$(call shell_info, Copying control application output in $(LINUX_DSP_OUTPUT_APP))
	@mkdir -p $(LINUX_DSP_OUTPUT_DIR)
	@cp -r $(ALPINE_DSP_APPLICATION) $(LINUX_DSP_OUTPUT_APP)

linux-dsp: $(LINUX_DSP_DEPENDENCIES)
