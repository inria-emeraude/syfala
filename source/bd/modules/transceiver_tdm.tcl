#require: syfala_ip.tcl

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 1 PORTS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# IIC ports
# -----------------------------------------------------------------------------
set IIC_0 [add_intf_port "xilinx.com:interface:iic_rtl:1.0" IIC_0]


# -----------------------------------------------------------------------------
# Onboard CODEC ports (SSM for Zybo, ADAU for Genesys...)
# -----------------------------------------------------------------------------
add_port "internal_codec_bclk"   O
add_port "internal_codec_mclk"   O
add_port "internal_codec_sd_rx"  I
#add_port "internal_codec_sd_tx"  O
add_port "internal_codec_ws_tx"  O

switch $::rt::board {
Z10 - Z20 {
    add_port "internal_codec_ws_rx"     O
    add_port "internal_codec_out_mute"  O
}
}

# -----------------------------------------------------------------------------
# TDM8 ports
# -----------------------------------------------------------------------------
# Code is simplier than with ADAU because we only have outputs
# we round to superior 8 to match TDM8 protocol
proc round_sup_div8 {x} {
    return [expr ($x+(8-($x%8)))/8]
}

switch $::rt::board {
    Z10 {
        set ntdm_channels_max 4
    }
    Z20 {
        set ntdm_channels_max 4
    }
    GENESYS {
        set ntdm_channels_max 4
    }
}

set ntdm_channels_req [round_sup_div8 $::rt::nchannels_o]
set ntdm_channels     [expr min($ntdm_channels_max, $ntdm_channels_req)]

print_info "Project has the following settings:"
print_info "Number of input channels (limited to 2): $::rt::nchannels_i"
print_info "Number of output channels: $::rt::nchannels_o"
print_info "Number of TDM8 channels required: $ntdm_channels_req"
print_info "Number of effective TDM8 channels: $ntdm_channels"

foreach_n $ntdm_channels {{n} {
    add_port "port_sd_tx_$n" O
    print_info "Added TDM8 channel $n"
}}

# -----------------------------------------------------------------------------
# External CODEC ports
# Only one WS and BCLK for all
# -----------------------------------------------------------------------------
add_port "port_tdm_ws"    O
add_port "port_tdm_sclk"  O

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 2 IP/MODULES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

#TODO: change the name for i2s_transceiver_tdm.vhd
declare_user_module "i2s_transceiver" $::Syfala::BUILD_SOURCES_DIR/i2s_transceiver.vhd

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 3 CONNECTIONS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Transceiver <-> IP Faust
# ---------------------------------------------------------------

# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/rdy                            \
        "pins" syfala/ap_start
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# External codecs
# ---------------------------------------------------------------

foreach_n $ntdm_channels {{n} {
# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/tdm_tx_$n                      \
        "ports" port_sd_tx_$n
# ---------------------------------------------------------------
}}

# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/tdm_sclk                       \
        "ports" port_tdm_sclk
# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/tdm_ws                         \
        "ports" port_tdm_ws
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# Internal codec
# ---------------------------------------------------------------

# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/ssm_ws                         \
        "ports" internal_codec_ws_tx
# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/ssm_sclk                       \
        "ports" internal_codec_bclk
# ---------------------------------------------------------------
connect "pins" clk_wiz_I2S/clk_24Mhz                            \
        "ports" internal_codec_mclk
# ---------------------------------------------------------------
connect "pins" i2s_transceiver_0/ssm_sd_ch0_ch1_rx              \
        "ports" internal_codec_sd_rx
# ---------------------------------------------------------------

switch $::rt::board {
Z10 - Z20 {
# ---------------------------------------------------------------
    connect "pins" i2s_transceiver_0/ssm_ws                     \
            "ports" internal_codec_ws_rx
# ---------------------------------------------------------------
    connect "ports" internal_codec_out_mute                     \
            "pins" vdd33/dout
# ---------------------------------------------------------------
}
}

# ---------------------------------------------------------------
# Transceiver clk and rst/start
# ---------------------------------------------------------------
connect "pins" $i2s_clk_instance_name/clk_I2S                   \
        "pins" i2s_transceiver_0/mclk
# ---------------------------------------------------------------
connect "pins" $system_clock                                    \
        "pins" i2s_transceiver_0/sys_clk
# ---------------------------------------------------------------
connect "pins" $i2s_clk_instance_name/locked                    \
        "pins" i2s_transceiver_0/reset_n
# ---------------------------------------------------------------
connect "pins" vdd33/dout                                       \
        "pins" i2s_transceiver_0/start
# ---------------------------------------------------------------

# ---------------------------------------------------------------
# Connections Processing System (PS)
# ---------------------------------------------------------------
switch $::rt::board {
# ---------------------------------------------------------------
Z10 - Z20 {
# ---------------------------------------------------------------
connect "intf_pins" processing_system7_0/IIC_0                  \
        "intf_ports" IIC_0
# ---------------------------------------------------------------
}
# ---------------------------------------------------------------
GENESYS {
# ---------------------------------------------------------------
connect "intf_pins" zynq_ultra_ps_e_0/IIC_0                     \
        "intf_ports" IIC_0
# ---------------------------------------------------------------
}
}
