#!/usr/bin/tclsh

namespace eval g {
    set root            [file normalize ../..]
    set syfala          $root/syfala.tcl
    set build_dir       $root/build
    set build_ip_dir    $build_dir/syfala_ip
    set report_dir      $build_ip_dir/syfala/syn/report
    set rpt_global      $report_dir/syfala_csynth.rpt
    set rpt_summary     $report_dir/csynth.rpt
    set output_dir      $root/reports

    variable target_name     ""
    variable target_type     ""
    variable target_file     ""
    variable out_target_dir  ""
    variable rpt_header      ""
    variable csv_header      ""
    variable pattern_a       ""
    variable pattern_b       ""
    variable patterns       [list]
    variable N               0
    variable multisample     0
    variable mcd             16
    variable umo             0
}

namespace eval a {
    variable board      ""
    variable target     ""
    variable reset      0
    variable verbose    0
}

source $::g::root/scripts/sylib.tcl
namespace import Syfala::*

# gets command line argument value at next '::argv' index
proc get_argument_value {index} {
    upvar $index idx
    return [lindex $::argv [incr idx]]
}

proc add_csv_field {f {comma 1}} {
    append ::g::csv_header $f
    if $comma {
        append ::g::csv_header ","
    }
}

proc freplacepl {F A B} {
    set fr     [open $F r]
    set data   [read $fr]
    close      $fr
    set fw     [open $F w]
    foreach line [split $data "\n"] {
        if [regexp $A $line] {
            print_ok "Found pattern: '$A'"
            set l [list $A $B]
            set line [string map $l $line]
            print_info "Resulting line: $line"
        }
        puts $fw $line
    }
    close $fw
}

# -----------------------------------------------------------------------------
# Parsing arguments
# -----------------------------------------------------------------------------

proc get_argument_list {index} {
    upvar $index idx
    set n [expr $idx + 1]
    set w 1
    set l [list]
    while {$w} {
        set arg [lindex $::argv $n]
        if [regexp {[0-9]+} $arg] {
            incr n
            lappend l $arg
        } else {
            set w 0
        }
    }
    set idx [expr $n-1]
    return $l
}

for {set index 0} {$index < [llength $::argv]} {incr index} {
    set argument [lindex $::argv $index]
    switch $argument {
        -r - --reset {
            set ::a::reset 1
        }
        -v - --verbose {
            set ::a::verbose 1
        }
        -b - --board {
            set ::a::board [get_argument_value index]
        }
        --mcd {
            set ::g::mcd [get_argument_value index]
        }
        --multisample {
            set ::g::multisample [get_argument_value index]
        }
        -u - --umo {
            set ::g::umo 1
        }
        -p - --p - --pattern {
            # --pattern "N = " "N = %" 0 1 2 3 4 5 6
            set A [get_argument_value index]
            set B [get_argument_value index]
            set L [get_argument_list index]
            set P [list $A $B $L]
            print_info "Added [emph pattern]: $P"
            lappend ::g::patterns $P
            if {$::g::N == 0} {
                set ::g::N [llength $L]
            } else {
                set ::g::N [expr min($::g::N, [llength $L])]
            }
        }
        -N - --N {
        # shortcut for --pattern "#N" "%" [Nlist]
            set A "#N"
            set B "%"
            set L [get_argument_list index]
            set P [list $A $B $L]
            print_info "Added [emph pattern]: $P"
            lappend ::g::patterns $P
            set ::g::N [llength $L]
        }
        -o - --output {
            set ::g::out_target_dir [get_argument_value index]
        }
        default {
            # check DSP target file
            if [string match "*.dsp" $argument] {
                set ::a::target [file normalize $argument]
                set ::g::target_name [file rootname [file tail $argument]]
                set ::g::target_type "faust"
                set ::g::target_file $::g::build_dir/[file tail $argument]
                if [is_empty $::g::out_target_dir] {
                    set ::g::out_target_dir $::g::output_dir/$::g::target_name
                }
            } elseif [string match "*.cpp" $argument] {
                set ::a::target [file normalize $argument]
                set ::g::target_name [file rootname [file tail $argument]]
                set ::g::target_type "cpp"
                set ::g::target_file $::g::build_ip_dir/syfala_ip.cpp
                if [is_empty $::g::out_target_dir] {
                    set ::g::out_target_dir $::g::output_dir/$::g::target_name
                }
            } else {
                print_error "Invalid argument ($argument), aborting"
                exit 1
            }
        }
    }
}

# -----------------------------------------------------------------------------
# Report headers
# -----------------------------------------------------------------------------

print_info "[emph Target]: $::a::target"
print_info "[emph Board]:  $::a::board"
print_info "[emph Output]: $::g::out_target_dir"

# -----------------------------------------------------------------------------
# Report outputs
# -----------------------------------------------------------------------------

proc remove_lines {txt n} {
    set s [split $txt "\n"]
    set r ""
    set i 0
    foreach l $s {
        if [expr $i >= $n] {
            append r $l
            append r "\n"
        }
        incr i
    }
    return $r
}

proc write_report_output {f txt} {
    if [file exists $f] {
        exec echo $::g::rpt_header >> $f
        exec echo $txt >> $f
    } else {
        exec echo $::g::rpt_header > $f
        exec echo $txt >> $f
    }
}

proc copy_write_latency_report {} {
    set f $::g::out_target_dir/latency.txt
    set rpt [exec sed -n {/\+\sLatency/,/^\s*$/p} $::g::rpt_global]
    set rpt [remove_lines $rpt 2]
    write_report_output $f $rpt
    return $rpt
}

proc copy_write_resources_report {} {
    set f $::g::out_target_dir/resources.txt
    set rpt [exec sed -n {/==\sUtilization/,/^\s*$/p} $::g::rpt_global]
    set rpt [remove_lines $rpt 3]
    write_report_output $f $rpt
    return $rpt
}

proc copy_write_performance_report {} {
    set f $::g::out_target_dir/performance.txt
    set rpt [exec sed -n {/PS:/,/^\s*$/p} $::g::rpt_summary]
    write_report_output $f $rpt
    return $rpt
}

proc write_csv_output {N l r p mem arch_t hls_t} {
    set csv $::g::out_target_dir/$::g::target_name.csv
    if ![file exists $csv] {
        # Write header -------------------------------
        exec echo $::g::csv_header > $csv
    }
    # Board, N -------------------------------
    set line $::a::board
    foreach pat $::g::patterns {
        set L [lindex $pat 2]
        set nvalue [lindex $L $N]
        lappend line $nvalue
    }
    # Interval ---------------------------------------
    set d [split $p "\n"]
    # get line 5, column 7 & trim leading whitespace
    lappend line [string trimleft [lindex [split [lindex $d 5] "|"] 7]]
#    print_info "Last is interval: $line ($d)"

    # Latency data -----------------------------------
    set d [regexp -inline -all {[0-9]+\.*[0-9]*} $l]
    # Append column 1 (Cycles_Max) & column 3 (Latency_Max)
    lappend line [lindex $d 1]
    lappend line [lindex $d 3]

    # Append memory read & write ---------------------
    lappend line [lindex $mem 0]
    lappend line [lindex $mem 1]

    # Append faust time & hls time -------------------
    lappend line $arch_t
    lappend line $hls_t

    # Resources data ---------------------------------
    set d [regexp -inline -all {[0-9]+\.*[0-9]*} $r]
    set dl [llength $d]
    # Get 15 last numbers
    set stop [expr $dl - 15]
    set res [list]
    for {set n [expr $dl-1]} {$n >= $stop} {incr n -1} {
        lappend res [lindex $d $n]
    }
    set res [lreverse $res]
    # BRAM, DSP, FF, LUT, URAM -----------------------
    lappend line [lindex $res 0]
    lappend line [lindex $res 1]
    lappend line [lindex $res 2]
    lappend line [lindex $res 3]
    # BRAM(%), DSP(%), FF(%), LUT(%), URAM(%) --------
    lappend line [lindex $res 10]
    lappend line [lindex $res 11]
    lappend line [lindex $res 12]
    lappend line [lindex $res 13]
    # Concatenate with commas, add line --------------
    exec echo [join $line ", "] >> $csv
}

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------

proc add_rpt_header_separator {} {
    for {set n 0} {$n < 53} {incr n} {
         append ::g::rpt_header "-"
    }
    append ::g::rpt_header "|\n"
}

proc close_header_line {l} {
    set n [string length $l]
    set N 53
    for {set i $n} {$i < $N} {incr i} {
        # Pad with whitespace until last character
        append l " "
    }
    # Close with '|' and '\n' characters
    append l "|\n"
    return $l
}

proc set_rpt_header {} {
    set date [clock seconds]
    set date [clock format $date -format {%D - %H:%M:%S}]
    set commit [exec git rev-parse HEAD]
    set branch [exec git symbolic-ref --short HEAD]
    set author [exec git config user.name]
    set ::g::rpt_header ""

    add_rpt_header_separator
    append ::g::rpt_header [close_header_line "+ Date: $date"]
    append ::g::rpt_header [close_header_line "+ Branch: $branch"]
    append ::g::rpt_header [close_header_line "+ Commit: $commit"]
    append ::g::rpt_header [close_header_line "+ Report author: $author"]
    append ::g::rpt_header [close_header_line "+ Board: $::a::board"]
    append ::g::rpt_header [close_header_line "+ Target: [file tail $::a::target]"]
    append ::g::rpt_header [close_header_line "+ Multisample: $::g::multisample"]
    append ::g::rpt_header [close_header_line "+ MCD: $::g::mcd"]
}

proc generate_hls_sources {} {
    print_info "Generating HLS [emph sources]"
    set command [list]
    lappend command $::g::syfala
    lappend command $::a::target
    lappend command --board
    lappend command $::a::board
    lappend command --multisample
    lappend command $::g::multisample
    lappend command --mcd
    lappend command $::g::mcd
    if $::g::umo {
        lappend command --umo
    }
    if {$::g::target_type == "cpp"} {
        lappend command --sources
    } else {
        lappend command --faust
    }
    if $::a::verbose {
        exec {*}$command >&@stdout
    } else {
        exec {*}$command
    }
}

# -----------------------------------------------------------------------------
# CSV Header
# -----------------------------------------------------------------------------

add_csv_field "Board"

for {set n 0} {$n < [llength $::g::patterns]} {incr n} {
    add_csv_field "P$n"
}

add_csv_field "Interval_Max"
add_csv_field "Cycles_Max"
add_csv_field "Latency_Max"
add_csv_field "Memory_Read"
add_csv_field "Memory_Write"
add_csv_field "Faust_Time"
add_csv_field "HLS_Time"
add_csv_field "BRAM"
add_csv_field "DSP"
add_csv_field "FF"
add_csv_field "LUT"
add_csv_field "BRAM_prct"
add_csv_field "DSP_prct"
add_csv_field "FF_prct"
add_csv_field "LUT_prct" 0

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------

cd $::g::root

# Reset syfala --------------------------------
if $::a::reset {
    print_info "Resetting $::g::out_target_dir"
    exec rm -rf $::g::out_target_dir
}
print_info "Resetting syfala build"
exec rm -rf "makefile.env"

# Create reports output directory -------------
exec mkdir -p $::g::out_target_dir

print_info "Number of runs: $::g::N"

for {set N 0} {$N < $::g::N} {incr N} {
    print_info "Starting run ([expr $N+1]/$::g::N)"
    exec rm -rf $::g::build_dir

    # Generate syfala sources ----------------------------------------
    set tstart [clock milliseconds]
    generate_hls_sources
    set arch_t [get_elapsed_time_msec $tstart]
    append ::g::rpt_header "+ Sources generated in $arch_t milliseconds\n"
    set_rpt_header

    # Replace patterns -----------------------------------------------
    foreach p $::g::patterns {
        set A [lindex $p 0]
        set B [lindex $p 1]
        set L [lindex $p 2]
        set nvalue [lindex $L $N]
        set M [string map [list "%" $nvalue] $B]
        print_info "Replacing pattern [emph $A] with [emph $M] in $::g::target_file"
        append ::g::rpt_header [close_header_line "+ $A: $nvalue"]
        freplacepl $::g::target_file $A $M
    }

    # Run HLS --------------------------------------------------------
    print_info "Running Vitis [emph HLS] on target file, please wait..."
    set tstart [clock seconds]
    if $::a::verbose {
        exec make hls >&@stdout
    } else {
        exec make hls
    }
    set hls_t [get_elapsed_time_sec $tstart]
    append ::g::rpt_header [close_header_line "+ HLS done in $hls_t seconds"]

    # Write Latency/resources/performance reports --------------------
    print_info "Writing/Updating concatenated [emph reports]"
    add_rpt_header_separator

    # Write .csv file ------------------------------------------------
    write_csv_output $N                                 \
                     [copy_write_latency_report]        \
                     [copy_write_resources_report]      \
                     [copy_write_performance_report]    \
                     [Faust::mem_access_count]          \
                     $arch_t $hls_t
    print_ok "Run ([expr $N+1]/$::g::N) done!"
}
