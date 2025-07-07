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
# -----------------------------------------------------------------------------
# 3 CONNECTIONS
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# Invert reset for FIFO through the 'NOT' unit vector logic
connect "pins" rst_global/peripheral_aresetn        \
        "pins" uvl_not_rst/Op1
        
# ---------------------------------------------------------------
connect "pins" syfala/ap_done                                   \
        "pins" i2s_transceiver_0/ap_done

# -----------------------------------------------------------------------------
# Transceiver <-> IP Faust
# -----------------------------------------------------------------------------

if {$::rt::nchannels_i == 1} {
# ---------------------------------------------------
connect "pins" fifo_in_0/dout                       \
        "pins" syfala/audio_in\_dout
# ---------------------------------------------------
connect "pins" syfala/audio_in_read                 \
        "pins" fifo_in_0/rd_en
# ---------------------------------------------------
connect "pins" uvl_in_0/Res                         \
        "pins" syfala/audio_in_empty_n
} else {
    foreach_n $::rt::nchannels_i {{n} {
    # ---------------------------------------------------
    connect "pins" fifo_in_$n/dout                      \
            "pins" syfala/audio_in_$n\_dout
    # ---------------------------------------------------
    connect "pins" syfala/audio_in_$n\_read             \
            "pins" fifo_in_$n/rd_en
    # ---------------------------------------------------
    connect "pins" uvl_in_$n/Res                        \
            "pins" syfala/audio_in_$n\_empty_n
    }}
}

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
connect "pins" fifo_in_$n/empty                     \
        "pins" uvl_in_$n/Op1
}}

if {$::rt::nchannels_o == 1} {
# ---------------------------------------------------
connect "pins" syfala/audio_out_din                 \
        "pins" fifo_out_0/din
# ---------------------------------------------------
connect "pins" syfala/audio_out_write               \
        "pins" fifo_out_0/wr_en
# ---------------------------------------------------
connect "pins" uvl_out_0/Res                        \
        "pins" syfala/audio_out_full_n
} else {
    foreach_n $::rt::nchannels_o {{n} {
    # ---------------------------------------------------
    connect "pins" syfala/audio_out_$n\_din             \
            "pins" fifo_out_$n/din
    # ---------------------------------------------------
    connect "pins" syfala/audio_out_$n\_write           \
            "pins" fifo_out_$n/wr_en
    # ---------------------------------------------------
    connect "pins" uvl_out_$n/Res                       \
            "pins" syfala/audio_out_$n\_full_n
    }}
}

# ---------------------------------------------------
foreach_n $::rt::nchannels_o {{n} {
# ---------------------------------------------------
connect "pins" clk_wiz_sys_clk/sys_clk              \
        "pins" fifo_out_$n/clk
# ---------------------------------------------------
connect "pins" uvl_not_rst/Res                      \
        "pins" fifo_out_$n/srst
# ---------------------------------------------------
connect "pins" fifo_out_$n/full                     \
        "pins" uvl_out_$n/Op1
# ---------------------------------------------------
connect "pins" fifo_out_$n/dout                     \
        "pins" i2s_transceiver_0/from_faust_ch$n
# ---------------------------------------------------
connect "pins" i2s_transceiver_0/faust_ch$n\_rd     \
        "pins" fifo_out_$n/rd_en
}}

