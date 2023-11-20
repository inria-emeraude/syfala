# -----------------------------------------------------------------------------
# utilities
# -----------------------------------------------------------------------------

SHELL ?= /bin/sh

define file_exists # -------------------
$(shell [ -f $(1) ] && echo 1 || echo 0)
endef # --------------------------------

define dir_exists # --------------------
$(shell [ -d $(1) ] && echo 1 || echo 0)
endef # --------------------------------

define dev_exists # --------------------
$(shell [ -e $(1) ] && echo 1 || echo 0)
endef # --------------------------------

define set_preprocessor_data #----------
echo '$(1)'
endef # --------------------------------


SH_BOLD         := $(shell tput bold)
SH_STD          := $(shell tput sgr0)
SH_GREEN        := $(shell tput setaf 2)
SH_RED          := $(shell tput setaf 1)
SH_ORANGE       := $(shell tput setaf 11)

B               := $(SH_BOLD)
N               := $(SH_STD)
R               := $(SH_RED)
O               := $(SH_ORANGE)
G               := $(SH_GREEN)

PRINT_OK       := [$(G)  OK  $(N)]
PRINT_INFO     := [$(O) INFO $(N)]
PRINT_ERROR    := [$(R) ERR! $(N)]

define print_ok # ----------------
$(PRINT_OK)$(1)
endef # --------------------------

define print_info # --------------
$(PRINT_INFO)$(1)
endef # --------------------------

define print_error # -------------
$(PRINT_ERROR)$(1)
endef # --------------------------

define em # ----------------------
$(B)$1$(N)
endef # --------------------------

define static_ok #-------------------------------
    $(info $(call print_ok,$(1)))
endef #------------------------------------------

define static_info # ----------------------------
    $(info $(call print_info,$(1)))
endef #------------------------------------------

define static_error #----------------------------
    $(info $(call print_error,$(1)))
endef #------------------------------------------

define shell_ok # -------------------------------
    @echo -e '$(call print_ok,$(1))'
endef # -----------------------------------------

define shell_info #------------------------------
    @echo -e '$(call print_info,$(1))'
endef # -----------------------------------------

define shell_error # ----------------------------
    @echo -e '$(call print_error,$(1))'
endef # -----------------------------------------

# -----------------------------------------------------------------------------
# OS-specific
# TODO: other platforms
# -----------------------------------------------------------------------------

# ---------------------------------------------------
ifeq ($(call file_exists, /etc/arch-release), 1)
# ---------------------------------------------------
    OS              := Arch Linux
# ---------------------------------------------------
else ifeq ($(call file_exists, /etc/lsb-release), 1)
# ---------------------------------------------------
    OS              := Ubuntu
    OS_VERSION_FULL := $(shell lsb_release -d)
    OS_VERSION      := $(word 3, $(OS_VERSION_FULL))
    OS_LTS          := $(word 4, $(OS_VERSION_FULL))
# ---------------------------------------------------
else
# ---------------------------------------------------
    OS              := N/A
    OS_VERSION_FULL := N/A
    OS_VERSION      := N/A
    OS_LTS          := N/A
endif

# -----------------------------------------------------------------------------
# Used by clean & reset, asks confirmation about removing build directories
# -----------------------------------------------------------------------------
define remove_dir_confirm
@read -p "Please $(B)confirm$(N) [y/$(B)N$(N)]: " confirm;                  \
if [ $$confirm = "y" ] || [ $$confirm = "Y" ]; then                         \
     $(2) rm -rf $(1);                                                      \
     echo "$(_print_ok) Removed $(B)$(notdir $(1))$(N) directory";          \
fi
endef

define check_print_nchannels # ---------------------------------------------------
    $(call shell_ok, Retrieved number of input channels: $(shell $(get_nchannels_i)))
    $(call shell_ok, Retrieved number of output channels: $(shell $(get_nchannels_o)))
endef # --------------------------------------------------------------------------

define check_print_ncontrols # ---------------------------------------------------
    $(call shell_ok, Retrieved number of real controls: $(shell $(get_ncontrols_f)))
    $(call shell_ok, Retrieved number of int controls: $(shell $(get_ncontrols_i)))
    $(call shell_ok, Retrieved number of passive controls: $(shell $(get_ncontrols_p)))
endef # --------------------------------------------------------------------------

