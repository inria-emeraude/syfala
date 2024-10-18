# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 1 PORTS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 2 IP/MODULES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
set eth_audio_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:eth_audio:1.0 eth_audio_0 ]

# We also add a new master/slave port on axi_periph_interconn (M03)
# & axi_mem_interconn (SO1)
set_property -dict [list            \
    CONFIG.NUM_MI {4}               \
] $axi_periph_interconn

set_property -dict [list            \
    CONFIG.NUM_MI {1}               \
    CONFIG.NUM_SI {2}               \
] $axi_mem_interconn

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 3 CONNECTIONS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

if {$::rt::nchannels_i == 1} {
# ---------------------------------------------------
connect "pins" eth_audio_0/audio_out                \
        "pins" i2s_transceiver_0/from_eth_ch0
# ---------------------------------------------------
connect "pins" eth_audio_0/audio_out_ap_vld         \
        "pins" i2s_transceiver_0/from_eth_ch0_ap_vld
} else {
# ---------------------------------------------------
foreach_n $::rt::nchannels_i {{n} {
# ---------------------------------------------------
# 1. From eth_audio to i2s
connect "pins" eth_audio_0/audio_out_$n             \
        "pins" i2s_transceiver_0/from_eth_ch$n
# ---------------------------------------------------
connect "pins" eth_audio_0/audio_out_$n\_ap_vld      \
        "pins" i2s_transceiver_0/from_eth_ch$n\_ap_vld
}}
}

if {!$::rt::ethernet_no_output} {
# ---------------------------------------------------
if {$::rt::nchannels_o == 1} {
    # ---------------------------------------------------
    connect "pins" i2s_transceiver_0/to_eth_ch0         \
            "pins" eth_audio_0/audio_in
    # ---------------------------------------------------
} else {
    foreach_n $::rt::nchannels_o {{n} {
    # ---------------------------------------------------
    # 4 from i2s to eth_audio
    connect "pins" i2s_transceiver_0/to_eth_ch$n        \
            "pins" eth_audio_0/audio_in_$n
    # ---------------------------------------------------
    }}
}
}
# ---------------------------------------------------
connect "pins" $system_clock                        \
        "pins" axi_periph_interconn/M03_ACLK
# ---------------------------------------------------
connect "pins" $system_clock                        \
        "pins" axi_mem_interconn/S01_ACLK
# ---------------------------------------------------
connect "pins" $system_clock                        \
        "pins" eth_audio_0/ap_clk
# ---------------------------------------------------
connect "pins" rst_global/peripheral_aresetn        \
        "pins" eth_audio_0/ap_rst_n
# ---------------------------------------------------
connect "pins" i2s_transceiver_0/eth_rdy            \
        "pins" eth_audio_0/ap_start
# ---------------------------------------------------
connect "intf_pins" eth_audio_0/m_axi_ram           \
        "intf_pins" axi_mem_interconn/S01_AXI
# ---------------------------------------------------
connect "intf_pins" eth_audio_0/s_axi_control       \
        "intf_pins" axi_periph_interconn/M03_AXI
# ---------------------------------------------------
connect "pins" rst_global/peripheral_aresetn        \
        "pins" axi_mem_interconn/S01_ARESETN
# ---------------------------------------------------
connect "pins" rst_global/peripheral_aresetn        \
        "pins" axi_periph_interconn/M03_ARESETN
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 4 ADDRESSES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
    assign_bd_address -offset "0x00000000" -range "0x40000000"                              \
                      -target_address_space                                                 \
                        [get_bd_addr_spaces eth_audio_0/Data_m_axi_ram]                     \
                        [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM]    \
                      -force

    assign_bd_address -offset "0x40030000" -range "0x00010000"                              \
                      -target_address_space                                                 \
                        [get_bd_addr_spaces processing_system7_0/Data]                      \
                        [get_bd_addr_segs eth_audio_0/s_axi_control/Reg]                    \
                      -force
}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------
# TODO

}
}
