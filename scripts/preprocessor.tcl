#!/usr/bin/tclsh

source ../scripts/sylib.tcl
namespace import Syfala::*

proc replace {A N fn {offset 0}} {
    set B ""
    for {set i $offset} {$i < $N} {incr i} {
        if [is_empty $B] {
            set B "[apply $fn $i]"
        } else {
            set B "$B\n[apply $fn $i]"
        }
    }
    return $B
}
proc overwrite {F A N fn} {
    set B [replace $A $N $fn]
    freplacel $F $A $B
}

namespace eval preprocessor {

proc run_hls_preprocessor {} {
    set nchannels_min [expr min($::runtime::nchannels_i, $::runtime::nchannels_o)]
    set nchannels_max [expr max($::runtime::nchannels_i, $::runtime::nchannels_o)]
    set N0 [expr $nchannels_max - $nchannels_min]
    set f $::Syfala::BUILD_IP_FILE
    print_info "Running [emph preprocessor] on [emph HLS] file $f"
    # -----------------------------------------------------------------------------
    # Top-level arguments (no input arguments if no inputs etc.)
    # -----------------------------------------------------------------------------
    overwrite $f "sy_ap_int audio_in" $::runtime::nchannels_i {{n} {
        return [indent "sy_ap_int audio_in_$n,"]
    }}
    overwrite $f "sy_ap_int* audio_out" $::runtime::nchannels_o {{n} {
        return [indent "sy_ap_int* audio_out_$n,"]
    }}
    # -----------------------------------------------------------------------------
    # Static i/o local arrays
    # -----------------------------------------------------------------------------
    set A "static sy_real_t inputs"
    if {$::runtime::nchannels_i > 0} {
        set i $::runtime::nchannels_i
        set o $::runtime::nchannels_o
        set B "sy_real_t inputs\[$i\], outputs\[$o\];
        // Prepare inputs for 'compute' method"
        for {set n 0} {$n < $i} {incr n} {
          set B "$B
          inputs\[$n\] = audio_in_$n.to_float() / SCALE_FACTOR;"
        }
    } else {
        set B "static sy_real_t outputs\[$::runtime::nchannels_o\];"
    }

    freplacel $f $A [indent $B]
    # -----------------------------------------------------------------------------
    # computemydsp function call
    # -----------------------------------------------------------------------------
    set A "computemydsp(&DSP"
    set B ""
    if {$::runtime::nchannels_i == 0} {
        set B "computemydsp(&DSP, 0, outputs, control_i, control_f, mem_zone_i, ffp);"
    } else {
        set B "computemydsp(&DSP, inputs, outputs, control_i, control_f, mem_zone_i, ffp);"
    }
    freplacel $f $A [indent $B 2]
    # -----------------------------------------------------------------------------
    # Adapt the 'ram-not-ready' bypass check
    # -----------------------------------------------------------------------------

    # matching channels will have 'input[n] = output[n]'
    # others will have 'outputs[n] = 0'
    set A "outputs\[X\] = inputs\[X\]"
    set B [replace $A $nchannels_min {{n} {
           return [indent "outputs\[$n\] = inputs\[$n\];" 2]
    }}]
    set C [replace $A $N0 {{n} {
          return [indent "outputs\[$n\] = 0;" 2]
    }} $nchannels_min]

    freplacel $f $A "$B\n$C"
    # -----------------------------------------------------------------------------
    # Adapt the bypass subfunction
    # -----------------------------------------------------------------------------
    set A "*audio_out = audio_in;"
    set B [replace $A $nchannels_min {{n} {
           return [indent "*audio_out_$n = audio_in_$n;" 2]
    }}]
    set C [replace $A $N0 {{n} {
           return [indent "*audio_out_$n = 0;" 2]
    }} $nchannels_min]
    freplacel $f $A "$B\n$C"
    # -----------------------------------------------------------------------------
    # Adapt the mute subfunction
    # -----------------------------------------------------------------------------
    overwrite $f "*audio_out = 0;" $::runtime::nchannels_o {{n} {
        return [indent "*audio_out_$n = 0;" 2]
    }}
    # -----------------------------------------------------------------------------
    # Adapt the output writes
    # -----------------------------------------------------------------------------
    overwrite $f "*audio_out = sy_ap_int" $::runtime::nchannels_o {{n} {
        return [indent "*audio_out_$n = sy_ap_int(outputs\[$n\] * SCALE_FACTOR);" 2]
    }}
    # -----------------------------------------------------------------------------
    # Hardcode control arrays for top-level arguments
    # -----------------------------------------------------------------------------
    # The reason we limit controller numbers to 2 is that:
    # - ARM_fControl[0] doesn't compile (obviously)
    # - ARM_fControl[1] generates a different driver function in xsyfala.h
    # so this is a temporary workaround until we get the arm.cpp modifications
    # in which we'll be able to determine the right function to call (or none)
    # at compilation time
    set nf [expr max($::runtime::ncontrols_f, 2)]
    set ni [expr max($::runtime::ncontrols_i, 2)]
    set np [expr max($::runtime::ncontrols_p, 2)]

    freplacel $f "float arm_control_f"                  \
         [indent "float arm_control_f\[$nf\]," 2]

    freplacel $f "int arm_control_i"                    \
         [indent "int arm_control_i\[$ni\]," 2]

    freplacel $f "float arm_control_p"                    \
         [indent "float arm_control_p\[$np\]," 2]

    freplacel $f "control_i\[FAUST_INT_CONTROLS\]"      \
                 "control_i\[$ni\];"

    freplacel $f "control_f\[FAUST_REAL_CONTROLS\]"     \
                 "control_f\[$nf\];"
}

# -----------------------------------------------------------------------------
# I2S_Transceiver scripting
# -----------------------------------------------------------------------------

proc encoded {line} {
    if {[contains "#L" $line] || [contains "#R" $line]} {
         return 1
    } else {
         return 0
    }
}
proc encode {line index} {
    set i1 [expr $index+1]
    if [encoded $line] {
        set l [string map "#L ch$index" $line]
        set l [string map "#R ch$i1" $l]
        return $l
    } else {
        return $line
    }
}
proc parse_scope_level {line lvl} {
    if {[encoded $line] && [regexp { *if *\(} $line]} {
        return 1
    } elseif {$lvl && [regexp { *if *\(} $line]} {
        return 1
    } elseif {$lvl && [regexp { * end if;} $line]} {
        return -1
    } else {
        return 0
    }
}

proc insert_i2s_header {f} {
    print_info "Setting I2S Header"
    switch [get_rt_value $::runtime::sample_width] {
        16       {set ws_ratio 32}
        24 - 32  {set ws_ratio 64}
    }
    print_info $ws_ratio
    set header_generic " -- AUTO GENERATED WITH Syfala preprocessor \n\
    --------------------------------------------------------------------------\n\
    mclk_sclk_ratio : integer := 4; \n\
    sclk_ws_ratio   : integer := $ws_ratio; \n\
    d_width         : integer := [get_rt_value $::runtime::sample_width] \n\
    --------------------------------------------------------------------------"
    freplacel $f "\[HEADER\]" $header_generic
}

proc run_i2s_preprocessor {} {
    set nchannels_min [expr min($::runtime::nchannels_i, $::runtime::nchannels_o)]
    set nchannels_max [expr max($::runtime::nchannels_i, $::runtime::nchannels_o)]
    set N0 [expr $nchannels_max - $nchannels_min]
    set source_path $::Syfala::I2S_DIR/i2s_template.vhd
    set target_path $::Syfala::BUILD_SOURCES_DIR/i2s_transceiver.vhd
    set source_file [open $source_path r]
    set target_file [open $target_path w]
    set if_scope  0
    set scope_buf ""
    print_info "Running [emph preprocessor] on [emph I2S] file: $source_path"
    while {[gets $source_file line] >= 0} {
        incr if_scope [parse_scope_level $line $if_scope]
        if $if_scope {
            append scope_buf "$line\n"
        } elseif ![is_empty $scope_buf] {
            for {set n 0} {$n < $nchannels_max} {incr n 2} {
                 foreach bline [split $scope_buf \n] {
                    if [not_empty $bline] {
                        puts $target_file [encode $bline $n]
                    }
                 }
                 puts $target_file $line
            }
            set scope_buf ""
        } else {
            if [encoded $line] {
                for {set n 0} {$n < $nchannels_max} {incr n 2} {
                     puts $target_file [encode $line $n]
                }
            } else {
                puts $target_file $line
            }
        }
    }
    close $source_file    
    close $target_file
    insert_i2s_header $target_path
}
}
