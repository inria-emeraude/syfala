
#require: syfala_ip.tcl BEFORE
#require: onesample/multisample_bd.tcl AFTER

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 1 PORTS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# IIC ports
# -----------------------------------------------------------------------------
set IIC_0       [add_intf_port "xilinx.com:interface:iic_rtl:1.0" IIC_0]
set IIC_1       [add_intf_port "xilinx.com:interface:iic_rtl:1.0" IIC_1]


# -----------------------------------------------------------------------------
# Onboard CODEC ports (SSM for Zybo, ADAU for Genesys...)
# -----------------------------------------------------------------------------
add_port "internal_codec_bclk"   O
add_port "internal_codec_mclk"   O
add_port "internal_codec_sd_rx"  I
add_port "internal_codec_sd_tx"  O
add_port "internal_codec_ws_tx"  O

switch $::rt::board {
Z10 - Z20 {
    add_port "internal_codec_ws_rx"     O
    add_port "internal_codec_out_mute"  O
}
}

# -----------------------------------------------------------------------------
# External CODEC ports
# -----------------------------------------------------------------------------
# we have to round to the superior before the following 'for' loops
# otherwise we don't have the matching number of codec ports
proc round_sup_div2 { x } {
    return [expr $x % 2 ? ($x+1)/2 : $x/2]
}

switch $::rt::board {
    Z10 {
        set ncodecs_max 9
    }
    Z20 {
        set ncodecs_max 13
    }
    GENESYS {
        set ncodecs_max 16
    }
}

set multichannel_i      [expr $::rt::nchannels_i > 2]
set multichannel_o      [expr $::rt::nchannels_o > 2]
set nchannels_div2_i    [round_sup_div2 $::rt::nchannels_i]
set nchannels_div2_o    [round_sup_div2 $::rt::nchannels_o]
set nchannels_div2_max  [round_sup_div2 $::rt::nchannels_max]
set ncodecs_req         $nchannels_div2_max
set ncodecs             [expr min($ncodecs_max, $ncodecs_req)]

print_info "Project has the following settings:"
print_info "Number of input channels: $::rt::nchannels_i"
print_info "Number of output channels: $::rt::nchannels_o"
print_info "Number of codecs required: $ncodecs_req"
print_info "Number of effective codecs: $ncodecs"

foreach_n $ncodecs {{n} {
    add_port "CODEC$n\_sd_rx"     I
    add_port "CODEC$n\_sd_tx"     O
    print_info "Added CODEC$n"
}} {1}; # starting at 'CODEC1'


# -----------------------------------------------------------------------------
# External CODEC ports
# Only one WS, MCLK and BCLK for all
# -----------------------------------------------------------------------------
add_port "external_codec_bclk"   O
add_port "external_codec_mclk"   O
add_port "external_codec_ws"     O

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 2 IP/MODULES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

declare_user_module "i2s_transceiver" $::Syfala::BUILD_SOURCES_DIR/i2s_transceiver.vhd
declare_user_module "mux_2to1" $::Syfala::BUILD_SOURCES_DIR/mux_2to1.vhd


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 3 CONNECTIONS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------


# ---------------------------------------------------
#connect "ports" debug_btn                           \
#        "pins"  syfala/debug
# ---------------------------------------------------
# connect "pins" syfala/ap_done                       \
#         "pins" i2s_transceiver_0/ap_done
# ---------------------------------------------------
connect "pins" syfala/ap_start                      \
        "pins" i2s_transceiver_0/rdy

# -----------------------------------------------------------------------------
# External codecs
# -----------------------------------------------------------------------------

connect "ports" external_codec_mclk "pins" clk_wiz_I2S/clk_24Mhz
connect "ports" external_codec_bclk "pins" i2s_transceiver_0/sclk
connect "ports" external_codec_ws "pins" i2s_transceiver_0/ws

foreach_n [expr min($nchannels_div2_o, $ncodecs_max)] {{n} {
    if {$n == 0} {
        connect "ports" CODEC1_sd_tx                            \
                "pins" i2s_transceiver_0/sd_ch0_ch1_tx          \
                "ports" internal_codec_sd_tx
    } else {
        set n1 [expr $n+1]
        set n2 [expr $n*2]
        set n3 [expr $n2+1]
        connect "ports" CODEC$n1\_sd_tx                         \
                "pins" i2s_transceiver_0/sd_ch$n2\_ch$n3\_tx
    }
}}

foreach_n [expr min($nchannels_div2_i, $ncodecs_max)] {{n} {
    if {$n == 0} {
        print_info "N = 0"
        connect "ports" CODEC1_sd_rx "pins" mux_2to1_0/inA
        connect "ports" internal_codec_sd_rx "pins" mux_2to1_0/inB
        connect "pins" i2s_transceiver_0/sd_ch0_ch1_rx	"pins" mux_2to1_0/outMux
    } else {
        print_info "N = $n"
        set n1 [expr $n+1]
        set n2 [expr $n*2]
        set n3 [expr $n2+1]
        connect "ports" CODEC$n1\_sd_rx "pins" i2s_transceiver_0/sd_ch$n2\_ch$n3\_rx
    }
}}

# -----------------------------------------------------------------------------
# Internal codec
# -----------------------------------------------------------------------------

connect "ports" internal_codec_ws_tx "pins" i2s_transceiver_0/ws
connect "ports" internal_codec_bclk  "pins" i2s_transceiver_0/sclk
connect "ports" internal_codec_mclk  "pins" clk_wiz_I2S/clk_24Mhz

switch $::rt::board {
Z10 - Z20 {
    connect "ports" internal_codec_ws_rx "pins" i2s_transceiver_0/ws
    connect "ports" internal_codec_out_mute "pins" vdd33/dout
}
}

# -----------------------------------------------------------------------------
# Transceiver clk and rst/start
# -----------------------------------------------------------------------------
connect "pins" i2s_transceiver_0/mclk     "pins" $i2s_clk_instance_name/clk_I2S
connect "pins" i2s_transceiver_0/sys_clk  "pins" $system_clock
connect "pins" i2s_transceiver_0/reset_n  "pins" $i2s_clk_instance_name/locked
connect "pins" i2s_transceiver_0/start    "pins" vdd33/dout

# -----------------------------------------------------------------------------
connect "pins" mux_2to1_0/Sel             "pins" sw2/Dout

# -----------------------------------------------------------------------------
# Connections Processing System (PS)
# -----------------------------------------------------------------------------
switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
connect "intf_pins" processing_system7_0/IIC_0          \
        "intf_ports" IIC_0
}
# -----------------------------------------------------------------------------
GENESYS {
connect "intf_pins" zynq_ultra_ps_e_0/IIC_0             \
        "intf_ports" IIC_0
# -------------------------------------------------------
connect "intf_pins" zynq_ultra_ps_e_0/IIC_1             \
        "intf_ports" IIC_1
}
}