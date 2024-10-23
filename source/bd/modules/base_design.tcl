
create_bd_design "main"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 0 PROJECT CREATION
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Parent cells
# -----------------------------------------------------------------------------

set parent_cell    [get_bd_cells "/"]
set parent_object  [get_bd_cells $parent_cell]
set parent_type    [get_property "TYPE" $parent_object]

if [is_empty $parent_object] {
    print_error "Unable to find parent cell ($parent_cell), aborting..."
    exit 1
}
if {$parent_type != "hier"} {
    print_error "Parent <$parent_object> has TYPE = <$parent_type>. Expected to be '<hier>'"
}

# Save current instance, restore later.
set old_current_instance [current_bd_instance .]
# Set parent object as current instance.
current_bd_instance $parent_object

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 1 PORTS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# **PROC** Port creation
# -----------------------------------------------------------------------------

proc add_intf_port { vlnv name } {
    return [create_bd_intf_port -mode "Master" -vlnv $vlnv $name]
}

proc add_port { name dir {size 1} } {
    if {$size <= 1} {
        return [create_bd_port -dir $dir $name]
    } else {
        return [create_bd_port -dir $dir -from [expr {$size-1}] -to 0 $name]
    }
}

# -----------------------------------------------------------------------------
# Non-common ports
# -----------------------------------------------------------------------------
switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
set DDR        [add_intf_port "xilinx.com:interface:ddrx_rtl:1.0" DDR]
set FIXED_IO   [add_intf_port "xilinx.com:display_processing_system7:fixedio_rtl:1.0" FIXED_IO]
set board_clk  [create_bd_port -dir "I" -type "clk" -freq_hz "125000000" board_clk]
set btn        [create_bd_port -dir "I" -from "3" -to "0" btn]
}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------
set board_clk  [create_bd_port -dir "I" -type "clk" -freq_hz "25000000" board_clk]
# /!\ PLEASE DON'T CHANGE THAT!!
# The name differ from ZYBO to GENESYS but Vivado NEED theses names!
set btn           [create_bd_port -dir "I" -from "4" -to "0" btn]
}
}

# -----------------------------------------------------------------------------
# Common ports
# -----------------------------------------------------------------------------

# For switches and LED I now use the explicit declaration rather than the Xilinx
# interface to make it simpler between Zybo/Genesys. It uses exactly the same amount of resources.
set switches    [create_bd_port -dir "I" -from "3" -to "0" switches]
set green_leds  [create_bd_port -dir "O" -from "3" -to "0" green_leds]
set rgb_led     [create_bd_port -dir "O" -from "2" -to "0" rgb_led]

# -----------------------------------------------------------------------------
# Misc ports
# -----------------------------------------------------------------------------
if {$::rt::board == "GENESYS"} {
    add_port "vadj_level0" O
    add_port "vadj_level1" O
    add_port "vadj_auton"  O
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 2 IP/MODULES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# IP pre-checks
# -----------------------------------------------------------------------------
set ip_list [list                       \
    "xilinx.com:ip:xlconstant:1.1"      \
    "xilinx.com:ip:axi_gpio:2.0"        \
    "xilinx.com:ip:clk_wiz:6.0"         \
    "xilinx.com:ip:proc_sys_reset:5.0"  \
    "xilinx.com:ip:xlslice:1.0"         \
]

switch $::rt::board {
Z10 - Z20 {
    lappend ip_list "xilinx.com:ip:processing_system7:5.5"
}
GENESYS {
    lappend ip_list "xilinx.com:ip:smartconnect:1.0"
    lappend ip_list "xilinx.com:ip:zynq_ultra_ps_e:3.3"
}
}

# -----------------------------------------------------------------------------
# **PROC** for ip check
# -----------------------------------------------------------------------------
proc check_ip {list_of_ip} {
set printable_list [join $list_of_ip "\n- "]
print_info "Checking if the following IPs exist in the project's catalog:\n- $printable_list"

foreach ip $list_of_ip {
    set ipdefs [get_ipdefs -all $ip]
    if [is_empty $ipdefs] {
        print_error "Missing IP: $ip, aborting"
        exit 1
    } else {
        print_ok "$ip IP succesfully checked!"
    }
}

print_ok "All IPs succesfully added and checked"
}

check_ip $ip_list

# -----------------------------------------------------------------------------
# **PROC** AXI INTERCONNECT
# -----------------------------------------------------------------------------

proc add_axi_interconnect {name num_i {type "default"}} {
    switch $type {
        default {
            set name [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:axi_interconnect:2.1" $name]
            set_property -dict [list            \
                CONFIG.NUM_MI [list $num_i]     \
            ] $name
            return $name
        }
        smartconnect {
            set name [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:smartconnect:1.0" $name]
            set_property -dict [list            \
                CONFIG.NUM_SI [list $num_i]     \
            ] $name
            return $name
        }
    }
}
if {$::globals::clk_dynamic_reconfig} {
    set axi_periph_interconn [add_axi_interconnect "axi_periph_interconn" 4]
#    set rst_sys_clk_125M [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:proc_sys_reset:5.0" rst_sys_clk_125M]
} else {
    set axi_periph_interconn [add_axi_interconnect "axi_periph_interconn" 3]
}

switch $::rt::board {
    Z10 - Z20  {
        set axi_mem_interconn [add_axi_interconnect "axi_mem_interconn" 1]
    }
    GENESYS {
        set axi_mem_interconn [add_axi_interconnect "axi_mem_interconn" 1 smartconnect]
    }
}

print_ok "Successfully added axi_interconnects"

# -----------------------------------------------------------------------------
# AXI GPIO LED
# -----------------------------------------------------------------------------
# Custom to avoid different interface name between zybo/genesys
# GPIO: Greens leds
# GPIO2: RGB led
set axi_gpio_LED [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:axi_gpio:2.0" axi_gpio_LED]
set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {3} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {1} \
] $axi_gpio_LED

# -----------------------------------------------------------------------------
# AXI GPIO SWITCH/BTN
# -----------------------------------------------------------------------------

# Custom to avoid different interface name between zybo/genesys
# GPIO: Switches
# GPIO2: Btns
set axi_gpio_SW [ create_bd_cell -type "ip" -vlnv "xilinx.com:ip:axi_gpio:2.0" axi_gpio_SW ]
set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {4} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {1} \
] $axi_gpio_SW


# -----------------------------------------------------------------------------
# Switches logic
# -----------------------------------------------------------------------------
set sw0 [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:xlslice:1.0" sw0]
set sw1 [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:xlslice:1.0" sw1]
set sw2 [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:xlslice:1.0" sw2]

set_property -dict [list    \
    CONFIG.DIN_WIDTH {4}    \
] $sw0

set_property -dict [list    \
    CONFIG.DIN_FROM {1}     \
    CONFIG.DIN_TO {1}       \
    CONFIG.DIN_WIDTH {4}    \
    CONFIG.DOUT_WIDTH {1}   \
] $sw1

set_property -dict [list    \
    CONFIG.DIN_FROM {2}     \
    CONFIG.DIN_TO {2}       \
    CONFIG.DIN_WIDTH {4}    \
    CONFIG.DOUT_WIDTH {1}   \
] $sw2

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
set GND  [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:xlconstant:1.1" GND]
set vd33 [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:xlconstant:1.1" vdd33]
set_property -dict [list CONFIG.CONST_VAL {0}] $GND


# -----------------------------------------------------------------------------
# CLOCKS
# -----------------------------------------------------------------------------

switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
# Change sys_clk frequency here.
# Don"t forget to change the corresponding period in hls.tcl (not in master_zybo.xdc, this one is the board clk!)
# Tested frequency:
# |---SYS_CLK_FREQ--|------period-----|-SYSCLK_I2S_RATIO (for 48k)-|-CLK24M_RATIO-|--Functional---|
# |    122.885835   |     8.137634    |              10            |       5      |      YES      |
# |    245.748299   |     4.069204    |              20            |       10     |      YES      |
# |    491.596638   |     2.034188    |              40            |       20     |      NO       |
# |-----------------|-----------------|----------------------------|--------------|---------------|
    set in_clk_freq 125
    set sys_clk_freq 122.885835
}
# -----------------------------------------------------------------------------
GENESYS {
# Change sys_clk frequency here.
# Don"t forget to change the corresponding period in hls.tcl (not in master_zybo.xdc, this one is the board clk!)
# Tested frequency:
# |---SYS_CLK_FREQ--|------period-----|-SYSCLK_I2S_RATIO ----------|-CLK24M_RATIO-|----Functional---|
# |    122.875      |     8.138352    |              10 (48k)      |       5      |       YES       |
# |    122.875      |     8.138352    |             1.25 (384/768) |       5      |       YES       |
# |      737.5      |     1.355932    |              60            |       30     |        NO       |
# |-----------------|-----------------|----------------------------|--------------|-----------------|
    set in_clk_freq 25
    set sys_clk_freq 122.875
}
}

switch $::rt::sample_rate {
    24000  {set sys_clk_i2s_ratio 20}
    48000  {set sys_clk_i2s_ratio 10}
    96000  {set sys_clk_i2s_ratio 5}
    192000 {set sys_clk_i2s_ratio 2.5}
    384000 - 768000 {set sys_clk_i2s_ratio 1.25}
    default {set sys_clk_i2s_ratio 10}
}

# -----------------------------------------------------------------------------
# System clock wizard
# -----------------------------------------------------------------------------
set sys_clk_instance_name "clk_wiz_sys_clk"
set sys_clk_instance_name [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:clk_wiz:6.0" $sys_clk_instance_name]
set_property -dict [list                                \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ $sys_clk_freq     \
    CONFIG.CLK_OUT1_PORT {sys_clk}                      \
    CONFIG.PRIM_IN_FREQ $in_clk_freq                    \
    CONFIG.PRIM_SOURCE {Global buffer}                  \
    CONFIG.USE_LOCKED {true}                            \
    CONFIG.USE_RESET {false}                            \
] $sys_clk_instance_name

# -----------------------------------------------------------------------------
# I2S clock wizard
# -----------------------------------------------------------------------------
set i2s_clk_instance_name "clk_wiz_I2S"
set i2s_clk_instance_name [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:clk_wiz:6.0" $i2s_clk_instance_name]
set_property -dict [list                    \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ [expr {$sys_clk_freq/$sys_clk_i2s_ratio}]         \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ [expr {$sys_clk_freq/($sys_clk_i2s_ratio/2)}]     \
    CONFIG.CLKOUT2_USED {true}              \
    CONFIG.NUM_OUT_CLKS {2}                 \
    CONFIG.CLK_OUT1_PORT {clk_I2S}          \
    CONFIG.CLK_OUT2_PORT {clk_24Mhz}        \
    CONFIG.PRIM_IN_FREQ $sys_clk_freq       \
    CONFIG.USE_LOCKED {true}                \
    CONFIG.USE_RESET {true}                 \
    CONFIG.RESET_PORT {reset}               \
    CONFIG.RESET_TYPE {ACTIVE_HIGH}         \
    CONFIG.USE_POWER_DOWN {false}           \
    CONFIG.USE_DYN_RECONFIG $::globals::clk_dynamic_reconfig   \
] $i2s_clk_instance_name

# -----------------------------------------------------------------------------
# Processing system (PS) configuration
# -----------------------------------------------------------------------------

switch $::rt::board {
    Z10 - Z20 {
        source $::Syfala::SOURCE_DIR/bd/ps/zybo_ps7.tcl
    }
    GENESYS {
        source $::Syfala::SOURCE_DIR/bd/ps/genesys_psu.tcl
    }
}
# -----------------------------------------------------------------------------
# Other IPs
# -----------------------------------------------------------------------------
create_bd_cell -type "ip" -vlnv "xilinx.com:ip:proc_sys_reset:5.0" "rst_global"

# -----------------------------------------------------------------------------
# **PROC** for User modules
# -----------------------------------------------------------------------------
proc declare_user_module {name path} {
    set cell_name $name\_0
    set err 0
    if {[catch {set cell_name [create_bd_cell -type "module" -reference $name $cell_name]} err_msg]} {
         catch {set err 1}
    } elseif [is_empty $cell_name] {
         set err 1
    }
    if $err {
        print_error                                                     \
        "Unable to add referenced block <$name>.
         Please add the files for $name's definition into the project."
        exit 1
    }
}

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 3 CONNECTIONS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# **PROC** for connections
# -----------------------------------------------------------------------------
proc connect {args} {
    set cmd ""
    if {[lcontains "intf_pins" $args] ||
        [lcontains "intf_ports" $args]}  {
         set cmd "connect_bd_intf_net "
    } else {
         set cmd "connect_bd_net "
    }
    for {set n 0} {$n < [llength $args]} {incr n 2} {
         set t [lindex $args $n]
         set c [lindex $args [expr $n+1]]
         append cmd "\[get_bd_$t $c\] "
    }
    print_info $cmd
    eval $cmd
}

set system_clock "$sys_clk_instance_name/sys_clk"

# ---------------------------------------------------
connect "ports" board_clk                           \
        "pins" $sys_clk_instance_name/clk_in1
# ---------------------------------------------------
connect "pins" $system_clock                        \
        "pins" $i2s_clk_instance_name/clk_in1
# ---------------------------------------------------

if $::globals::clk_dynamic_reconfig {
# ---------------------------------------------------
connect "intf_pins" $i2s_clk_instance_name/s_axi_lite \
        "intf_pins" axi_periph_interconn/M03_AXI
# ---------------------------------------------------
connect "pins" $i2s_clk_instance_name/s_axi_aclk    \
        "pins" $system_clock
# ---------------------------------------------------
connect "pins" $i2s_clk_instance_name/s_axi_arestn  \
        "pins" rst_global/peripheral_aresetn
# ---------------------------------------------------
connect "pins" axi_periph_interconn/M03_ARESETN     \
        "pins" rst_global/peripheral_aresetn
# ---------------------------------------------------
connect "pins" axi_periph_interconn/M03_ACLK        \
        "pins" $system_clock
# ---------------------------------------------------
}
# ---------------------------------------------------
connect "pins" $sys_clk_instance_name/locked        \
        "pins" rst_global/dcm_locked
# ---------------------------------------------------
connect "pins" rst_global/slowest_sync_clk          \
       "pins" $system_clock
# ---------------------------------------------------

# -----------------------------------------------------------------------------
# Connections Processing System (PS)
# -----------------------------------------------------------------------------
switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
connect "intf_pins" processing_system7_0/S_AXI_HP0      \
        "intf_pins" axi_mem_interconn/M00_AXI
# -------------------------------------------------------
connect "pins" processing_system7_0/M_AXI_GP0_ACLK      \
        "pins" $system_clock
# -------------------------------------------------------
connect "pins" processing_system7_0/S_AXI_HP0_ACLK      \
        "pins" $system_clock
# -------------------------------------------------------
connect "intf_pins" processing_system7_0/DDR            \
        "intf_ports" DDR
# -------------------------------------------------------
connect "intf_pins" processing_system7_0/FIXED_IO       \
        "intf_ports" FIXED_IO
# -------------------------------------------------------
connect "intf_pins" processing_system7_0/M_AXI_GP0      \
        "intf_pins" axi_periph_interconn/S00_AXI
# -------------------------------------------------------
connect "pins" processing_system7_0/FCLK_RESET0_N       \
        "pins" rst_global/ext_reset_in
}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------
connect "intf_pins" zynq_ultra_ps_e_0/S_AXI_HP0_FPD     \
        "intf_pins" axi_mem_interconn/M00_AXI
# -------------------------------------------------------
connect "pins" zynq_ultra_ps_e_0/maxihpm0_lpd_aclk      \
        "pins" $system_clock
# -------------------------------------------------------
connect "pins" zynq_ultra_ps_e_0/saxihp0_fpd_aclk       \
        "pins" $system_clock
# -------------------------------------------------------
connect "intf_pins" zynq_ultra_ps_e_0/M_AXI_HPM0_LPD    \
        "intf_pins" axi_periph_interconn/S00_AXI
# -------------------------------------------------------
connect "pins" zynq_ultra_ps_e_0/pl_resetn0             \
        "pins" rst_global/ext_reset_in
}
}

# -----------------------------------------------------------------------------
# Connection interfaces (other)
# -----------------------------------------------------------------------------
connect "intf_pins" axi_gpio_LED/S_AXI   "intf_pins" axi_periph_interconn/M00_AXI
connect "intf_pins" axi_gpio_SW/S_AXI    "intf_pins" axi_periph_interconn/M02_AXI

switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
connect "pins" $system_clock "pins" axi_mem_interconn/ACLK
connect "pins" $system_clock "pins" axi_mem_interconn/M00_ACLK
connect "pins" $system_clock "pins" axi_mem_interconn/S00_ACLK
connect "pins" rst_global/peripheral_aresetn "pins" axi_mem_interconn/ARESETN
connect "pins" rst_global/peripheral_aresetn "pins" axi_mem_interconn/M00_ARESETN
connect "pins" rst_global/peripheral_aresetn "pins" axi_mem_interconn/S00_ARESETN
}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------
connect "pins" $system_clock "pins" axi_mem_interconn/aclk
connect "pins" rst_global/peripheral_aresetn "pins" axi_mem_interconn/aresetn
}
}
# -----------------------------------------------------------------------------
# SYS_CLK connections
# -----------------------------------------------------------------------------
connect "pins" $system_clock "pins" axi_gpio_LED/s_axi_aclk
connect "pins" $system_clock "pins" axi_gpio_SW/s_axi_aclk
connect "pins" $system_clock "pins" axi_periph_interconn/M00_ACLK
connect "pins" $system_clock "pins" axi_periph_interconn/M01_ACLK
connect "pins" $system_clock "pins" axi_periph_interconn/M02_ACLK
connect "pins" $system_clock "pins" axi_periph_interconn/S00_ACLK
connect "pins" $system_clock "pins" axi_periph_interconn/ACLK
# -----------------------------------------------------------------------------
# ARESTN connections
# -----------------------------------------------------------------------------
connect "pins" rst_global/peripheral_aresetn "pins" axi_gpio_LED/s_axi_aresetn
connect "pins" rst_global/peripheral_aresetn "pins" axi_gpio_SW/s_axi_aresetn
connect "pins" rst_global/peripheral_aresetn "pins" axi_periph_interconn/ARESETN
connect "pins" rst_global/peripheral_aresetn "pins" axi_periph_interconn/M00_ARESETN
connect "pins" rst_global/peripheral_aresetn "pins" axi_periph_interconn/M01_ARESETN
connect "pins" rst_global/peripheral_aresetn "pins" axi_periph_interconn/M02_ARESETN
connect "pins" rst_global/peripheral_aresetn "pins" axi_periph_interconn/S00_ARESETN

# -----------------------------------------------------------------------------
# LED connections
# -----------------------------------------------------------------------------
connect "ports" rgb_led     "pins" axi_gpio_LED/gpio2_io_o
connect "ports" green_leds  "pins" axi_gpio_LED/gpio_io_o
# -----------------------------------------------------------------------------
# Switches connections
# -----------------------------------------------------------------------------
connect "ports" switches "pins" axi_gpio_SW/gpio_io_i
connect "ports" switches "pins" sw0/Din
connect "ports" switches "pins" sw1/Din
connect "ports" switches "pins" sw2/Din
# -----------------------------------------------------------------------------
# Buttons connections
# -----------------------------------------------------------------------------
connect "ports" btn "pins" axi_gpio_SW/gpio2_io_i

# -----------------------------------------------------------------------------
# MCU connections
# -----------------------------------------------------------------------------
if {$::rt::board == "GENESYS"} {
    connect "ports" vadj_level0 "pins" vdd33/dout
    connect "ports" vadj_level1 "pins" vdd33/dout
    connect "ports" vadj_auton  "pins" vdd33/dout
}


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 4 ADDRESSES
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Block-design addresses
# -----------------------------------------------------------------------------
switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
if $::globals::clk_dynamic_reconfig {
    assign_bd_address -offset "0x44A00000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "processing_system7_0/Data"]    \
                        [get_bd_addr_segs "$i2s_clk_instance_name/s_axi_lite/Reg"]  \
                      -force
}

    assign_bd_address -offset "0x40000000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "processing_system7_0/Data"]    \
                        [get_bd_addr_segs "axi_gpio_LED/S_AXI/Reg"]         \
                      -force

    assign_bd_address -offset "0x40020000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "processing_system7_0/Data"]    \
                        [get_bd_addr_segs "axi_gpio_SW/S_AXI/Reg"]          \
                      -force

}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------

    assign_bd_address -offset "0x80000000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "zynq_ultra_ps_e_0/Data"]       \
                        [get_bd_addr_segs "axi_gpio_LED/S_AXI/Reg"]         \
                      -force

    assign_bd_address -offset "0x80010000" -range "0x00010000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "zynq_ultra_ps_e_0/Data"]       \
                        [get_bd_addr_segs "axi_gpio_SW/S_AXI/Reg"]          \
                      -force

}
}
