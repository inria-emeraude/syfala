
create_bd_design "main"

# -----------------------------------------------------------------------------
# IP pre-checks
# -----------------------------------------------------------------------------
set ip_list [list                       \
    "xilinx.com:ip:xlconstant:1.1"      \
    "xilinx.com:ip:axi_gpio:2.0"        \
    "xilinx.com:ip:clk_wiz:6.0"         \
    "xilinx.com:hls:syfala:1.0"         \
    "xilinx.com:ip:proc_sys_reset:5.0"  \
    "xilinx.com:ip:xlslice:1.0"         \
]

if $::rt::ethernet {
    lappend ip_list "xilinx.com:hls:eth_audio:1.0"
}

switch $::rt::board {
Z10 - Z20 {
    lappend ip_list "xilinx.com:ip:processing_system7:5.5"
}
GENESYS {
    lappend ip_list "xilinx.com:ip:smartconnect:1.0"
    lappend ip_list "xilinx.com:ip:zynq_ultra_ps_e:3.3"
}
}

set printable_list [join $ip_list "\n- "]
print_info "Checking if the following IPs exist in the project's catalog:\n- $printable_list"

foreach ip $ip_list {
    set ipdefs [get_ipdefs -all $ip]
    if [is_empty $ipdefs] {
        print_error "Missing IP: $ip, aborting"
        exit 1
    } else {
        print_ok "$ip IP succesfully checked!"
    }
}

print_ok "All IPs succesfully added and checked"

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
# Port creation
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

switch $::rt::board {
# -----------------------------------------------------------------------------
Z10 - Z20 {
# -----------------------------------------------------------------------------
set p_ddr        [add_intf_port "xilinx.com:interface:ddrx_rtl:1.0" DDR]
set p_fixed_io   [add_intf_port "xilinx.com:display_processing_system7:fixedio_rtl:1.0" FIXED_IO]
set p_board_clk  [create_bd_port -dir "I" -type "clk" -freq_hz "125000000" board_clk]
}
# -----------------------------------------------------------------------------
GENESYS {
# -----------------------------------------------------------------------------
set p_board_clk  [create_bd_port -dir "I" -type "clk" -freq_hz "25000000" board_clk]
}
}
# -----------------------------------------------------------------------------
# Common ports
# -----------------------------------------------------------------------------
set p_iic_0       [add_intf_port "xilinx.com:interface:iic_rtl:1.0" IIC_0]
set p_iic_1       [add_intf_port "xilinx.com:interface:iic_rtl:1.0" IIC_1]
set p_leds_4bits  [add_intf_port "xilinx.com:interface:gpio_rtl:1.0" leds_4bits]
set p_rgb_led     [add_intf_port "xilinx.com:interface:gpio_rtl:1.0" rgb_led]
set p_switches    [create_bd_port -dir "I" -from "3" -to "0" switches]

# -----------------------------------------------------------------------------
# CODEC ports
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
# Onboard CODEC ports (SSM for Zybo, ADAU for Genesys...)
# -----------------------------------------------------------------------------
add_port "internal_codec_bclk"   O
add_port "internal_codec_mclk"   O
add_port "internal_codec_sd_rx"  I
add_port "internal_codec_sd_tx"  O
add_port "internal_codec_ws_tx"  O
# -----------------------------------------------------------------------------
# External CODEC ports
# Only one WS, MCLK and BCLK for all
# -----------------------------------------------------------------------------
add_port "external_codec_bclk"   O
add_port "external_codec_mclk"   O
add_port "external_codec_ws"     O

switch $::rt::board {
Z10 - Z20 {
    add_port "internal_codec_ws_rx"     O
    add_port "internal_codec_out_mute"  O
}
}
# -----------------------------------------------------------------------------
# SPI ports
# -----------------------------------------------------------------------------
add_port "spi_MISO" I
add_port "spi_MOSI" O
add_port "spi_SS"   O
add_port "spi_clk"  O
# -----------------------------------------------------------------------------
# Misc ports
# -----------------------------------------------------------------------------
add_port "debug_btn" I

if {$::rt::board == "GENESYS"} {
    add_port "vadj_level0" O
    add_port "vadj_level1" O
    add_port "vadj_auton"  O
}
# -----------------------------------------------------------------------------
# AXI INTERCONNECT
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
    add_axi_interconnect "axi_periph_interconn" 4
#    set rst_sys_clk_125M [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:proc_sys_reset:5.0" rst_sys_clk_125M]
} else {
    add_axi_interconnect "axi_periph_interconn" 3
}

switch $::rt::board {
    Z10 - Z20  { add_axi_interconnect "axi_mem_interconn" 1 }
    GENESYS    { add_axi_interconnect "axi_mem_interconn" 1 smartconnect }
}

print_ok "Successfully added axi_interconnects"

# -----------------------------------------------------------------------------
# AXI GPIO
# -----------------------------------------------------------------------------

proc add_axi_gpio {name} {
    set name [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:axi_gpio:2.0" $name]
    set config [list                \
        CONFIG.C_ALL_INPUTS {0}     \
        CONFIG.C_ALL_OUTPUTS {1}    \
        CONFIG.C_ALL_OUTPUTS_2 {1}  \
        CONFIG.C_GPIO2_WIDTH {3}    \
        CONFIG.C_GPIO_WIDTH {4}     \
        CONFIG.C_IS_DUAL {1}        \
    ]
    switch $::rt::board {
        Z10 - Z20 {
            lappend config "CONFIG.GPIO2_BOARD_INTERFACE" {rgb_led}
            lappend config "CONFIG.GPIO_BOARD_INTERFACE" {leds_4bits}
        }
        GENESYS {
            lappend config "CONFIG.GPIO2_BOARD_INTERFACE" {rgbled_3bits}
            lappend config "CONFIG.GPIO_BOARD_INTERFACE" {led_4bits}
        }
    }
    lappend config "CONFIG.USE_BOARD_FLOW" {true}
    set_property -dict $config $name
}

add_axi_gpio "axi_gpio_LED"

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
    CONFIG.RESET_PORT {false}               \
    CONFIG.RESET_TYPE {ACTIVE_HIGH}         \
    CONFIG.USE_POWER_DOWN {false}           \
    CONFIG.USE_DYN_RECONFIG $::globals::clk_dynamic_reconfig   \

] $i2s_clk_instance_name

# -----------------------------------------------------------------------------
# AXI GPIO
# -----------------------------------------------------------------------------
set axi_gpio_SW [create_bd_cell -type "ip" -vlnv "xilinx.com:ip:axi_gpio:2.0" axi_gpio_SW]
set_property -dict [list                                \
    CONFIG.C_ALL_INPUTS {1}                             \
    CONFIG.C_GPIO_WIDTH {4}                             \
    CONFIG.C_IS_DUAL {0}                                \
    CONFIG.GPIO_BOARD_INTERFACE {Custom}                \
] $axi_gpio_SW

# -----------------------------------------------------------------------------
# Switches
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
# Processing system (PS) configuration
# -----------------------------------------------------------------------------
switch $::rt::board {
    Z10 - Z20 {source $::Syfala::SOURCE_DIR/bd/ps/zybo_ps7.tcl}
    GENESYS   {source $::Syfala::SOURCE_DIR/bd/ps/genesys_psu.tcl}
}
# -----------------------------------------------------------------------------
# Other IPs
# -----------------------------------------------------------------------------
create_bd_cell -type "ip" -vlnv "xilinx.com:hls:syfala:1.0" "syfala"
create_bd_cell -type "ip" -vlnv "xilinx.com:ip:proc_sys_reset:5.0" "rst_global"

# -----------------------------------------------------------------------------
# Util vector logic (invert signals)
# -----------------------------------------------------------------------------

proc set_uvl_properties {uvl} {
    set_property -dict [list \
      CONFIG.C_OPERATION {not} \
      CONFIG.C_SIZE {1} \
    ] $uvl
}

set uvl_not_rst [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 uvl_not_rst]
set_uvl_properties $uvl_not_rst

# We need one 'not' per input channel
# it connects the 'empty' signal from the FIFOs to the empty_n pin on 'syfala'

foreach_n $::rt::nchannels_i {{n} {
    set uvl [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 "uvl_in_$n"]
    set_uvl_properties $uvl
}}

foreach_n $::rt::nchannels_o {{n} {
    set uvl [create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 "uvl_out_$n"]
    set_uvl_properties $uvl
}}

# -----------------------------------------------------------------------------
# FIFOs
# -----------------------------------------------------------------------------

proc set_fifo_properties {fifo} {
    set_property -dict [list                                    \
      CONFIG.Data_Count {false}                                 \
      CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}       \
      CONFIG.Input_Data_Width $::rt::sample_width               \
      CONFIG.Input_Depth $::rt::nsamples_norm                   \
      CONFIG.Performance_Options {First_Word_Fall_Through}      \
      CONFIG.Valid_Flag {false}                                 \
      CONFIG.Write_Acknowledge_Flag {false}                     \
    ] $fifo
}

print_info "Setting FIFOs' size to $::rt::nsamples_norm"

# one FIFO per input and output (properties remain the same for input/output)
foreach_n $::rt::nchannels_i {{n} {
    set fifo [create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 "fifo_in_$n"]
    set_fifo_properties $fifo
}}

foreach_n $::rt::nchannels_o {{n} {
    set fifo [create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 "fifo_out_$n"]
    set_fifo_properties $fifo
}}

# -----------------------------------------------------------------------------
# User modules
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
declare_user_module "i2s_transceiver" $::Syfala::BUILD_SOURCES_DIR/i2s_transceiver.vhd
declare_user_module "mux_2to1" $::Syfala::BUILD_SOURCES_DIR/mux_2to1.vhd

# -------------------------------------------------------------------------------------------------
# CONNECTIONS
# -------------------------------------------------------------------------------------------------

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

# Invert reset for FIFO through the 'NOT' unit vector logic
connect "pins" rst_global/peripheral_aresetn        \
        "pins" uvl_not_rst/Op1

foreach_n $::rt::nchannels_i {{n} {
# ---------------------------------------------------
connect "pins" clk_wiz_sys_clk/sys_clk              \
        "pins" fifo_in_$n/clk
# ---------------------------------------------------
connect "pins" uvl_not_rst/Res                      \
        "pins" fifo_in_$n/srst
# ---------------------------------------------------
connect "pins" i2s_transceiver_0/to_faust_ch$n      \
        "pins" fifo_in_$n/din
# ---------------------------------------------------
connect "pins" i2s_transceiver_0/to_faust_ch$n\_wr  \
        "pins" fifo_in_$n/wr_en
# ---------------------------------------------------
connect "pins" fifo_in_$n/full                      \
        "pins" i2s_transceiver_0/to_faust_ch$n\_full
# ---------------------------------------------------
connect "pins" fifo_in_$n/dout                      \
        "pins" syfala/audio_in_$n\_dout
# ---------------------------------------------------
connect "pins" syfala/audio_in_$n\_read             \
        "pins" fifo_in_$n/rd_en
# ---------------------------------------------------
connect "pins" fifo_in_$n/empty                     \
        "pins" uvl_in_$n/Op1
# ---------------------------------------------------
connect "pins" uvl_in_$n/Res                        \
        "pins" syfala/audio_in_$n\_empty_n
}}

# ---------------------------------------------------
foreach_n $::rt::nchannels_o {{n} {
# ---------------------------------------------------
connect "pins" clk_wiz_sys_clk/sys_clk              \
        "pins" fifo_out_$n/clk
# ---------------------------------------------------
connect "pins" uvl_not_rst/Res                      \
        "pins" fifo_out_$n/srst
# ---------------------------------------------------
connect "pins" syfala/audio_out_$n\_din             \
        "pins" fifo_out_$n/din
# ---------------------------------------------------
connect "pins" syfala/audio_out_$n\_write           \
        "pins" fifo_out_$n/wr_en
# ---------------------------------------------------
connect "pins" fifo_out_$n/full                     \
        "pins" uvl_out_$n/Op1
# ---------------------------------------------------
connect "pins" uvl_out_$n/Res                       \
        "pins" syfala/audio_out_$n\_full_n
# ---------------------------------------------------
connect "pins" fifo_out_$n/dout                     \
        "pins" i2s_transceiver_0/from_faust_ch$n
# ---------------------------------------------------
connect "pins" i2s_transceiver_0/faust_ch$n\_rd     \
        "pins" fifo_out_$n/rd_en
}}

# ---------------------------------------------------
connect "ports" debug_btn                           \
        "pins"  syfala/debug
# ---------------------------------------------------
connect "pins" syfala/ap_done                       \
        "pins" i2s_transceiver_0/ap_done
# ---------------------------------------------------
connect "pins" syfala/ap_start                      \
        "pins" i2s_transceiver_0/faust_compute
# ---------------------------------------------------
connect "pins" syfala/mute                          \
        "pins" sw0/Dout
# ---------------------------------------------------
connect "pins" syfala/bypass                        \
        "pins" sw1/Dout

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
# Connections I2S/FAUST/Other
# -----------------------------------------------------------------------------
connect "pins" mux_2to1_0/Sel             "pins" sw2/Dout
connect "pins" i2s_transceiver_0/mclk     "pins" $i2s_clk_instance_name/clk_I2S
connect "pins" i2s_transceiver_0/sys_clk  "pins" $system_clock
connect "pins" syfala/ap_rst_n            "pins" rst_global/peripheral_aresetn
connect "pins" i2s_transceiver_0/reset_n  "pins" $i2s_clk_instance_name/locked
connect "pins" i2s_transceiver_0/start    "pins" vdd33/dout
connect "pins" syfala/i2s_rst             "pins" $i2s_clk_instance_name/reset
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
connect "intf_pins" processing_system7_0/IIC_0          \
        "intf_ports" IIC_0
# -------------------------------------------------------
connect "intf_pins" processing_system7_0/M_AXI_GP0      \
        "intf_pins" axi_periph_interconn/S00_AXI
# -------------------------------------------------------
connect "pins" processing_system7_0/FCLK_RESET0_N       \
        "pins" rst_global/ext_reset_in
# -------------------------------------------------------
connect "pins" processing_system7_0/SPI0_MOSI_O         \
        "ports" spi_MOSI
# -------------------------------------------------------
connect	"pins" processing_system7_0/SPI0_SCLK_O         \
        "ports" spi_clk
# -------------------------------------------------------
connect	"pins" processing_system7_0/SPI0_SS_O           \
        "ports" spi_SS
# -------------------------------------------------------
connect	"pins" processing_system7_0/SPI0_MISO_I         \
        "ports" spi_MISO
# -------------------------------------------------------
connect "pins" processing_system7_0/SPI0_SS_I           \
        "pins" vdd33/dout
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
connect "intf_pins" zynq_ultra_ps_e_0/IIC_0             \
        "intf_ports" IIC_0
# -------------------------------------------------------
connect "intf_pins" zynq_ultra_ps_e_0/M_AXI_HPM0_LPD    \
        "intf_pins" axi_periph_interconn/S00_AXI
# -------------------------------------------------------
connect "pins" zynq_ultra_ps_e_0/pl_resetn0             \
        "pins" rst_global/ext_reset_in
# -----------------------------------------------------------------------------
# SPI
# -----------------------------------------------------------------------------
connect	"pins" zynq_ultra_ps_e_0/emio_spi0_s_i    "ports" spi_MISO
connect "pins" zynq_ultra_ps_e_0/emio_spi0_m_o    "ports" spi_MOSI
connect	"pins" zynq_ultra_ps_e_0/emio_spi0_sclk_o "ports" spi_clk
connect	"pins" zynq_ultra_ps_e_0/emio_spi0_ss_o_n "ports" spi_SS
#connect "pins" zynq_ultra_ps_e_0/emio_spi0_ss_i_n "pins" vdd33/dout
}
}
# -----------------------------------------------------------------------------
# Connection interfaces (other)
# -----------------------------------------------------------------------------
connect "intf_ports" rgb_led             "intf_pins" axi_gpio_LED/GPIO2
connect "intf_ports" leds_4bits          "intf_pins" axi_gpio_LED/GPIO
connect "intf_pins" axi_gpio_LED/S_AXI   "intf_pins" axi_periph_interconn/M00_AXI
connect "intf_pins" syfala/s_axi_control "intf_pins" axi_periph_interconn/M01_AXI
connect "intf_pins" axi_gpio_SW/S_AXI    "intf_pins" axi_periph_interconn/M02_AXI

# -----------------------------------------------------------------------------
# AXI DDR
# -----------------------------------------------------------------------------
connect "intf_pins" syfala/m_axi_ram "intf_pins" axi_mem_interconn/S00_AXI

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
connect "pins" $system_clock "pins" syfala/ap_clk
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
# Switches connections
# -----------------------------------------------------------------------------
connect "ports" switches "pins" axi_gpio_SW/gpio_io_i
connect "ports" switches "pins" sw0/Din
connect "ports" switches "pins" sw1/Din
connect "ports" switches "pins" sw2/Din
# -----------------------------------------------------------------------------
# MCU connections
# -----------------------------------------------------------------------------
if {$::rt::board == "GENESYS"} {
    connect "ports" vadj_level0 "pins" vdd33/dout
    connect "ports" vadj_level1 "pins" vdd33/dout
    connect "ports" vadj_auton  "pins" vdd33/dout
}
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
    assign_bd_address -offset "0x00000000" -range "0x40000000"              \
                      -target_address_space                                 \
                        [get_bd_addr_spaces "syfala/Data_m_axi_ram"]        \
                        [get_bd_addr_segs "processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM"] \
                      -force

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
