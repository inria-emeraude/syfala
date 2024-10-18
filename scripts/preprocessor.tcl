#!/usr/bin/tclsh

source scripts/sylib.tcl
namespace import Syfala::*

set target [lindex $::argv 0]

proc freplacep {F A B {start ""} {end ""}} {
    set fr     [open $F r]
    set data   [read $fr]
    close      $fr
    set fw     [open $F w]
    foreach line [split $data "\n"] {
        set pattern [regexp -inline $A $line]
        if [not_empty $pattern] {
            set map [list $A $B]
            set line [string map $map $line]
        }
        puts $fw $line
    }
    close $fw
}

proc freplacepl {F A fn} {
    set fr     [open $F r]
    set data   [read $fr]
    close      $fr
    set fw     [open $F w]
    foreach line [split $data "\n"] {
        if [regexp $A $line] {
            set line [apply $fn $line]
        }
        puts $fw $line
    }
    close $fw
}

# -----------------------------------------------------------------------------
# I2S_Transceiver scripting
# -----------------------------------------------------------------------------

proc encoded {line} {
    if {[contains "#L" $line]
     || [contains "#R" $line]} {
         return 1
    } else {
         return 0
    }
}

proc encoded_clkdiv {line} {
    if [contains "#SLOW_CLOCK_DIVIDER" $line] {
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

proc encoded_tdm {line pattern} {
    if [contains $pattern $line] {
        return 1
    } else {
        return 0
    }
}

proc get_tdm_buffer_nchannels {index nchannels_o} {
    set nchannels [expr max($nchannels_o,8)]
    set nchannels [expr ($nchannels-$index) % 8]
    if {$nchannels == 0} {
        set nchannels 8
    }
    return $nchannels
}

proc encode_tdm_1 {line index} {
     return [string map "#T1 $index" $line]
}

proc encode_tdm_2 {line index nchannels} {
     set l [string map "#T2 [expr $index/8]" $line]
     set max [expr $index + 8]
     for {set n $index} {$n < $max} {incr n} {
          if [expr $n%8] {
            append l " & "
          } else {
            append l " <= "
          }
          if {$n < $nchannels} {
            append l "from_faust_ch$n\_latched"
          } else {
            append l "X\"0000\""
          }
     }
     append l ";"
     print_info "Adding line: $l"
     return $l;
}

proc encode_tdm_3 {line index nchannels swidth} {
    set nbits   [expr $nchannels * $swidth - 1]
    set line    [string map "#T3 $nbits" $line]
    print_info "Setting buffer ($index) size to: $nbits bits ($nchannels channels, width = $swidth bits per channel) "
    return $line
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

proc insert_i2s_header {f sw nsamples} {
    switch $sw   {
        16       {set ws_ratio 32}
        24 - 32  {set ws_ratio 64}
    }
    # TODO: set clock ratios programmatically (directly from Makefile?)
    set header_generic " -- AUTO GENERATED WITH Syfala preprocessor \n\
    --------------------------------------------------------------------------\n\
    mclk_sclk_ratio : integer := 4; \n\
    sclk_ws_ratio   : integer := $ws_ratio; \n\
    d_width         : integer := $sw; \n\
    nsamples        : integer := $nsamples \n\
    --------------------------------------------------------------------------"
    freplacel $f "\[HEADER\]" $header_generic
}


proc run_i2s_preprocessor {fsource ftarget nchannels_i nchannels_o swidth srate nsamples} {
    set nchannels_min [expr min($nchannels_i, $nchannels_o)]
    set nchannels_max [expr max($nchannels_i, $nchannels_o)]
    set N0 [expr $nchannels_max - $nchannels_min]
    print_info "fsource = $fsource, ftarget = $ftarget"
    set source_file [open $fsource r]
    set target_file [open $ftarget w]
    set if_scope  0
    set scope_buf ""

    switch $srate {
        24000    {set clock_divider 2}
        16000    {set clock_divider 3}
        12000    {set clock_divider 4}
        8000     {set clock_divider 6}
        default  {set clock_divider 1}
    }

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
            } elseif [encoded_tdm $line "#T1"] {
                print_info "Found TDM-encoded variable (pattern #1)"
                print_info "Line: $line"
                set N 0
                for {set n 0} {$n < $nchannels_o} {incr n 8} {
                     set line_t1 [encode_tdm_1 $line $N]
                     if [encoded_tdm $line_t1 "#T3"] {
                         print_info "Encoded with pattern #T3"
                         set nchannels [get_tdm_buffer_nchannels $n $nchannels_o]
                         set line_t3 [encode_tdm_3 $line_t1 $N $nchannels $swidth]
                         print_info "Adding line: $line_t3"
                         puts $target_file $line_t3
                     } else {
                        print_info "Adding line: $line_t1"
                        puts $target_file $line_t1
                     }
                     incr N
                }
            } elseif [encoded_tdm $line "#T2"] {
                print_info "Found TDM-encoded variable (pattern #2)"
                set N 0
                for {set n 0} {$n < $nchannels_o} {incr n 8} {
                     set nchannels [get_tdm_buffer_nchannels $n $nchannels_o]
                     set l [encode_tdm_2 $line $n $nchannels_o]
                     puts $target_file $l
                     incr N
                }
            } elseif [encoded_tdm $line "#T3"] {
                print_info "Found TDM-encoded variable (pattern #3)"
                set nchannels [get_tdm_buffer_nchannels $n $nchannels_o]
                set line [encode_tdm_3 $line 0 $nchannels $swidth]
                puts $target_file $line
            } elseif [encoded_clkdiv $line] {
                set l [string map "#SLOW_CLOCK_DIVIDER $clock_divider" $line]
                puts $target_file $l
            } else {
                puts $target_file $line
            }
        }
    }
    close $source_file
    close $target_file
    insert_i2s_header $ftarget $swidth $nsamples
}

print_info "Arguments: $::argv"

switch $target {
    --i2s {
        set src         [lindex $::argv 1]
        set target      [lindex $::argv 2]
        set nchannels_i [lindex $::argv 3]
        set nchannels_o [lindex $::argv 4]
        set swidth      [lindex $::argv 5]
        set srate       [lindex $::argv 6]
        set nsamples    [lindex $::argv 7]
        run_i2s_preprocessor $src           \
                             $target        \
                             $nchannels_i   \
                             $nchannels_o   \
                             $swidth        \
                             $srate         \
                             $nsamples
    }
}
