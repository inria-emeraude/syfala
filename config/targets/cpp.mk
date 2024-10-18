# -----------------------------------------------------------------------------
# Check CPP HLS source file
# parse 'audio_in' & 'audio_out' top-level function arguments in order to
# define how many audio inputs & outputs the DSP IP will have.
# -----------------------------------------------------------------------------

ifeq ($(call file_exists, $(HLS_SOURCE_MAIN)), 0)
      $(call static_error, $(HLS_SOURCE_MAIN) does not exist, aborting...)
      $(error abort)
endif

$(call static_ok, - $(B)HLS_SOURCE_MAIN$(N): $(notdir $(HLS_SOURCE_MAIN)))

define parse_define # ---------------------------------------------
    cat $(HLS_TARGET_FILE) | grep -oP '#define\s+$(1)\s+\K[0-9]+'
endef # -----------------------------------------------------------

HLS_SOURCE_MAIN     ?= examples/cpp/bypass.cpp
HLS_FLAGS_INCLUDE   += -I$(dir $(HLS_SOURCE_MAIN))
get_nchannels_i     ?= $(call parse_define,INPUTS)
get_nchannels_o     ?= $(call parse_define,OUTPUTS)
get_ncontrols_i     ?= echo '0'
get_ncontrols_f     ?= echo '0'
get_ncontrols_p     ?= echo '0'
get_mem_f           ?= echo '0'
get_mem_i           ?= echo '0'

DSP_TARGET_NAME	 := $(basename $(notdir $(HLS_SOURCE_MAIN)))
HLS_TARGET_FILE_DEPENDENCIES += $(HLS_SOURCE_MAIN)
PROJECT_DEPENDENCIES	+= $(HLS_OUTPUT)

ifeq ($(LINUX), FALSE)
    HOST_MAIN_SOURCE ?= $(ARM_BAREMETAL_CPP_MAIN_MINIMAL)
endif

SCRIPT_HOST_CONFIG :=  minimal

$(HLS_TARGET_FILE): $(HLS_TARGET_FILE_DEPENDENCIES)
	$(call shell_info, Copying file $(notdir $(HLS_SOURCE_MAIN)) \
                           to build/syfala_ip.cpp)
	@mkdir -p $(BUILD_IP_DIR)
	@cp -r $(HLS_SOURCE_MAIN) $(HLS_TARGET_FILE)
