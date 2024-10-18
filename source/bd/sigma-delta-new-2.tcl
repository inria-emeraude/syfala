

source source/bd/modules/base_design.tcl
source source/bd/modules/syfala_ip.tcl
source source/bd/modules/spi.tcl

set ncodecs $::rt::nchannels_o

foreach_n $ncodecs {{n} {
    add_port "CODEC$n\_sd_rx" O
    add_port "CODEC$n\_sd_tx" O
    print_info "Added CODEC$n"
}} {1}; # starting at 'CODEC1'


# workaround (FIXME)
set_property -dict [list        \
    CONFIG.PRIM_IN_FREQ 125     \
] $i2s_clk_instance_name

# -----------------------------------------------------------------------------
# Clock dividers
# -----------------------------------------------------------------------------

set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {130.680} \
  CONFIG.CLKOUT1_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
  CONFIG.CLKOUT2_JITTER {249.501} \
  CONFIG.CLKOUT2_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {5} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_JITTER {181.315} \
  CONFIG.CLKOUT3_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {25} \
  CONFIG.CLKOUT3_USED {true} \
  CONFIG.CLKOUT4_JITTER {165.743} \
  CONFIG.CLKOUT4_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {38} \
  CONFIG.CLKOUT4_USED {true} \
  CONFIG.CLKOUT5_JITTER {163.597} \
  CONFIG.CLKOUT5_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {41.66667} \
  CONFIG.CLKOUT5_USED {true} \
  CONFIG.CLKOUT6_JITTER {238.790} \
  CONFIG.CLKOUT6_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {6.25} \
  CONFIG.CLKOUT6_USED {true} \
  CONFIG.CLKOUT7_JITTER {208.210} \
  CONFIG.CLKOUT7_PHASE_ERROR {122.096} \
  CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {12.5} \
  CONFIG.CLKOUT7_USED  {true} \
  CONFIG.CLK_OUT1_PORT {sys_clk} \
  CONFIG.CLK_OUT2_PORT {five_mhz_clk} \
  CONFIG.CLK_OUT3_PORT {sd_clk} \
  CONFIG.CLK_OUT4_PORT {faster3125_sd_clk} \
  CONFIG.CLK_OUT5_PORT {ef4166_sd_clk} \
  CONFIG.CLK_OUT6_PORT {slow6144_sd_clk} \
  CONFIG.CLK_OUT7_PORT {slow125_sd_clk} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {5.000} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {5.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {125} \
  CONFIG.MMCM_CLKOUT2_DIVIDE {25} \
  CONFIG.MMCM_CLKOUT3_DIVIDE {16} \
  CONFIG.MMCM_CLKOUT4_DIVIDE {15} \
  CONFIG.MMCM_CLKOUT5_DIVIDE {100} \
  CONFIG.MMCM_CLKOUT6_DIVIDE {50} \
  CONFIG.MMCM_DIVCLK_DIVIDE {1} \
  CONFIG.NUM_OUT_CLKS {7} \
  CONFIG.PRIM_IN_FREQ {125} \
  CONFIG.PRIM_SOURCE {Global_buffer} \
  CONFIG.USE_LOCKED {true} \
  CONFIG.USE_RESET {false} \
] $sys_clk_instance_name

namespace eval r {
    set sys_clk $sys_clk_instance_name
}

# -------------------------------------------------------
set clock_divider_0 [                                   \
    create_bd_cell -type "module"                       \
                   -reference clock_divider             \
                    clock_divider_0                     \
]
# -------------------------------------------------------
connect "pins" clk_wiz_sys_clk/five_mhz_clk             \
        "pins" clock_divider_0/clk
# -------------------------------------------------------

# TODO:
# disconnect_bd_net rst_global_slowest_sync_clk [get_bd_pins rst_global/slowest_sync_clk] [get_bd_pins $::r::sys_clk/sys_clk]

print_info "sigma_delta order: $::rt::sigma_delta"

namespace eval rt {
    switch $sigma_delta {
        1 {
            set bd_module "sd_dac_first_fixed"
            set sd_clk $::r::sys_clk/ef4166_sd_clk
        }
        2 {
            set bd_module "sd_dac_second_fixed"
            set sd_clk $::r::sys_clk/faster3125_sd_clk
        }
        3 {
            set bd_module "sd_dac_third_fixed"
            set sd_clk $::r::sys_clk/faster3125_sd_clk
        }
        4 {
            set bd_module "sd_dac_fourth_fixed"
            set sd_clk $::r::sys_clk/sd_clk
        }
        5 {
            set bd_module "sd_dac_fifth_fixed"
            set sd_clk $::r::sys_clk/sd_clk
        }
    }
}

print_info "bd_module: $::rt::bd_module, sd_clk: $::rt::sd_clk"

# ------------------------------------------------------
connect "pins" clk_wiz_sys_clk/five_mhz_clk             \
        "pins" rst_global/slowest_sync_clk
# -------------------------------------------------------
connect "pins" clock_divider_0/clock_out                \
        "pins" syfala/ap_start

# -----------------------------------------------------------
foreach_n $::rt::nchannels_o {{n} {
    # -------------------------------------------------------
    set bd_cell [                                           \
        create_bd_cell -type "module"                       \
                       -reference $::rt::bd_module          \
                        $::rt::bd_module\_$n                \
    ]
    # -------------------------------------------------------
    # sd_clk connections
    # -------------------------------------------------------
    connect "pins" $::rt::sd_clk                             \
            "pins" $::rt::bd_module\_$n/sd_clk
    # -------------------------------------------------------
    # sys_clk connections
    # -------------------------------------------------------
#    connect "pins" $::r::sys_clk/sys_clk                    \
#            "pins" $::rt::bd_module\_$n/sys_clk
    # -------------------------------------------------------
    # SD_DAC outputs
    # -------------------------------------------------------
    connect "pins" $::rt::bd_module\_$n/sd_output           \
            "ports" CODEC[expr $n+1]\_sd_tx
    # -------------------------------------------------------
}}

if {$::rt::nchannels_o == 1} {
    # ---------------------------------------------------
    connect "pins" syfala/audio_out                     \
            "pins" $::rt::bd_module\_0/sd_input
    # ---------------------------------------------------
    # ap_vld -> samp_clock
    # ---------------------------------------------------
    connect "pins" syfala/audio_out_ap_vld              \
            "pins" $::rt::bd_module\_0/samp_clk
    # ---------------------------------------------------

} else {
    # ---------------------------------------------------
    foreach_n $::rt::nchannels_o {{n} {
    # ---------------------------------------------------
    connect "pins" syfala/audio_out_$n                  \
            "pins" $::rt::bd_module\_$n/sd_input
    # ---------------------------------------------------
    # ap_vld -> samp_clock
    # ---------------------------------------------------
    connect "pins" syfala/audio_out_$n\_ap_vld           \
            "pins" $::rt::bd_module\_$n/samp_clk
    }}
}
