
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 1 PORTS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Physical ports
# -----------------------------------------------------------------------------
#add_port "debug_btn" I
add_port "syfala_out_debug0" O
add_port "syfala_out_debug1" O
add_port "syfala_out_debug2" O
add_port "syfala_out_debug3" O

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 2 IP/MODULES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
set ip "xilinx.com:hls:syfala:1.0"

check_ip $ip
lappend ip_list $ip
create_bd_cell -type "ip" -vlnv "xilinx.com:hls:syfala:1.0" "syfala"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 3 CONNECTIONS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# S-AXI
# -----------------------------------------------------------------------------
connect "intf_pins" syfala/s_axi_control            \
        "intf_pins" axi_periph_interconn/M01_AXI
# -----------------------------------------------------------------------------
# M-AXI (DDR)
# -----------------------------------------------------------------------------
connect "intf_pins" syfala/m_axi_ram                \
        "intf_pins" axi_mem_interconn/S00_AXI
# ---------------------------------------------------
connect "pins" syfala/mute                          \
        "pins" sw0/Dout
# ---------------------------------------------------
connect "pins" syfala/bypass                        \
        "pins" sw1/Dout
# ---------------------------------------------------
#connect "pins" syfala/outGPIO                       \
#        "ports" syfala_out_debug0
# ---------------------------------------------------
#WARNING: not compatible with multisample
#connect "pins" syfala/audio_out_0_ap_vld            \
#        "ports" syfala_out_debug1
# ---------------------------------------------------
connect "pins" syfala/ap_start                      \
        "ports" syfala_out_debug3
# ---------------------------------------------------
connect "pins" syfala/ap_rst_n                      \
        "pins" rst_global/peripheral_aresetn
# ---------------------------------------------------
connect "pins" syfala/i2s_rst                       \
        "pins" $i2s_clk_instance_name/reset
# ---------------------------------------------------
connect "pins" $system_clock                        \
        "pins" syfala/ap_clk
# ---------------------------------------------------

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 4 ADDRESSES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
    assign_bd_address -offset "0x00000000" -range "0x40000000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "syfala/Data_m_axi_ram"]        \
                        [get_bd_addr_segs "processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM"] \
                      -force

    assign_bd_address -offset "0x40010000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "processing_system7_0/Data"]    \
                        [get_bd_addr_segs "syfala/s_axi_control/Reg"]       \
                      -force
}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------
    assign_bd_address -offset "0x000800000000" -range "0x000800000000"      \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "syfala/Data_m_axi_ram"]        \
                        [get_bd_addr_segs "zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_HIGH"] \
                      -force

    assign_bd_address -offset "0x00000000" -range "0x80000000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "syfala/Data_m_axi_ram"]        \
                        [get_bd_addr_segs "zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW"] \
                      -force

    assign_bd_address -offset "0xC0000000" -range "0x20000000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "syfala/Data_m_axi_ram"]        \
                        [get_bd_addr_segs "zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI"] \
                      -force

    assign_bd_address -offset "0x80020000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "zynq_ultra_ps_e_0/Data"]       \
                        [get_bd_addr_segs "syfala/s_axi_control/Reg"]       \
                      -force

  exclude_bd_addr_seg -offset "0xFF000000" -range "0x01000000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "syfala/Data_m_axi_ram"]        \
                        [get_bd_addr_segs "zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM"]
}
}
