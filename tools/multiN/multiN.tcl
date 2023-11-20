#!/usr/bin/tclsh

namespace eval globals {
    set syroot ../..
    set report $syroot/build/syfala_csynth.rpt
    set csv_header "BOARD,N,MAXCYC,MAXLAT,MEMR,MEMW,ARCHT,HLST,BRAM,DSP,FF,LUT,BRAMN,DSPN,FFN,LUTN"
}

source $::globals::syroot/scripts/sylib.tcl
namespace import Syfala::*

namespace eval arguments {
    set name   [lindex $::argv 0]
    set dsp    [file normalize "dsp/$name.dsp"]
    set board  [lindex $::argv 1]
    set N      [lreplace $::argv 0 1]   
    set fcsv   "csv-outputs/$name.csv"
}
set fpattern "report-outputs/$::arguments::name-$::arguments::board"
print_info "Running multiN script with board $::arguments::board and N = '$::arguments::N'"

if {![file exists $::arguments::fcsv]} {
    print_info "adding header to .csv file"
    set f [open $::arguments::fcsv w]
    puts $f $::globals::csv_header
    close $f
}
if {![file exists $fpattern-latency.txt]} {
    set f1 [open $fpattern-latency.txt w]
    set f2 [open $fpattern-utilization.txt w]   
    close $f1
    close $f2
}

# -------------------------------------------------------------------------------------------------
# reports concatenation
# -------------------------------------------------------------------------------------------------

proc write_latency {f header} {
    puts $f $header
    puts $f [ffindlN $::globals::report "+ Latency:" 5 2]
}

proc write_utilization {f header} {
    puts $f $header
    puts $f [ffindlN $::globals::report "Utilization Estimates" 16 3]
}

proc lookup_generic {N ftarget f data header} {
    set pattern "+ With N = "
    set spl [split $data "\n"]
    set len [llength $spl]
    set done   0
    set index  0
    foreach line $spl {
    # go through file, get to next pattern
        if {[contains $pattern $line] && !$done} {
        # get the value of 'N' for this line, set it as 'n'
            set n [lindex $line 4]
            # if we're inferior to 'n', write it now
            if {$N < $n}  {
                print_info "Found writing location where N ($N) < n ($n)"
                switch $ftarget {
                    l { write_latency $f $header }
                    u { write_utilization $f $header }
                }
                set done 1
            } elseif {$N == $n && !$done} {
            # if same pattern, set as done
                print_info "N output already exists, nothing to be done..."
                set done 1
            }
            # otherwise, we just lookup next pattern.
        }
        if {$index < [expr $len - 1]} {
            # we don't want to output the last empty line
            puts $f $line
        }
        incr index
    }
    return $done
}

proc write_reports { N mem arch_t hls_t} {
    set fpattern "report-outputs/$::arguments::name-$::arguments::board"
    set m_s [clock format $hls_t -format {%M minutes and %S seconds}]
    set header "+ With N = $N (board: $::arguments::board)
    - Memory accesses: [lindex $mem 0] read(s), [lindex $mem 1] write(s)
    - IP & application files generated in $arch_t milliseconds
    - High-level synthesis done in $m_s"

    set file_l_r  [open $fpattern-latency.txt r]
    set file_u_r  [open $fpattern-utilization.txt r]
    set data_l    [read $file_l_r]
    set data_u    [read $file_u_r]
    close         $file_l_r
    close         $file_u_r
    set file_l_w  [open $fpattern-latency.txt w]
    set file_u_w  [open $fpattern-utilization.txt w]

    set done_l [lookup_generic $N "l" $file_l_w $data_l $header]
    set done_u [lookup_generic $N "u" $file_u_w $data_u $header]
    if {!$done_l || !$done_u} {
        # that means that we didn't find any 'n' for which 'N' is inferior
        # so append it at the end
        write_latency       $file_l_w $header
        write_utilization   $file_u_w $header
    }
    close $file_l_w
    close $file_u_w
}

# -------------------------------------------------------------------------------------------------
# csv writing/updating
# -------------------------------------------------------------------------------------------------

proc parse_latency_data { N } {
    set d [ffindlN $::globals::report "+ Latency:" 5 2]
    set r [regexp -inline -all {[0-9]+\.*[0-9]*} $d]
    return [list [lindex $r 1] [lindex $r 3]]
}

proc parse_utilization_data { N } {
    set d    [ffindlN $::globals::report "Utilization Estimates" 16 3]
    set s    [split $d "\n"]
    set l11  [lindex $s 11]
    set l15  [lindex $s 15]
    # Parse 'Total' line, and then 'Utilisation (%)' line
    set s1 [regexp -inline -all {[0-9]+} $l11]
    set s2 [regexp -inline -all {[0-9]+} $l15]
    # Append total LUT to s2
    lappend s2 {*}$s1
    return $s2
}

proc write_csv_line { f N mem arch_t hls_t  } {
    set ldata [parse_latency_data $N]
    set udata [parse_utilization_data $N]
    set nline [list $::arguments::board]
    lappend nline $N
    # parse latency data
    lappend nline [lindex [lindex $ldata 0] 0]
    lappend nline [lindex [lindex $ldata 1] 0]
    lappend nline [lindex $mem 0]
    lappend nline [lindex $mem 1]
    lappend nline $arch_t
    lappend nline $hls_t
    # parse utilization data (%)
    lappend nline [lindex $udata 0]
    lappend nline [lindex $udata 1]
    lappend nline [lindex $udata 2]
    lappend nline [lindex $udata 3]
    # parse utilization data (total)
    lappend nline [lindex $udata 5]
    lappend nline [lindex $udata 6]
    lappend nline [lindex $udata 7]
    lappend nline [lindex $udata 8]

    print_info $nline
    set nline [string map { " " ", "} $nline]
    puts $f $nline
}

proc write_csv { N mem arch_t hls_t } {
    set csv_r     [open $::arguments::fcsv r]
    set csv_data  [read $csv_r]
    close         $csv_r
    set data      [split $csv_data "\n"]
    set len       [llength $data]
    set csv_w     [open $::arguments::fcsv w]
    set done      0
    set index     0

    foreach line $data {
        set l_board  [string trimright [lindex $line 0] ","]
        set l_N      [string trimright [lindex $line 1] ","]

        if {!$done && $l_board == $::arguments::board} {
            if {$N < $l_N} {
                write_csv_line $csv_w $N $mem $arch_t $hls_t
                set done 1
            } elseif {$N == $l_N} {
                set done 1
            }
        }
        if {$index < [expr $len - 1]} {
            # we don't want to output the last empty line
            puts $csv_w $line
        }
        incr index
    }
    if {!$done} {
        write_csv_line $csv_w $N $mem $arch_t $hls_t
    }
    close $csv_w
}

# -------------------------------------------------------------------------------------------------
# main 'run(N)' function
# -------------------------------------------------------------------------------------------------

proc run { N } {
    # replace 'N =' line  in Faust .dsp file
    print_info "Attempting to replace [emph N] parameter ($N) in $::arguments::dsp"
    freplacel $::arguments::dsp "N = " "N = $N;"

    # generate ip/app files from faust architecture files
    print_info "Generating IP file from architecture file"
    set tstart [clock milliseconds]
    exec ./$::globals::syroot/syfala.tcl $::arguments::dsp --board $::arguments::board --arch --xversion 2022.2 --mcd 32 --reset
    set arch_t [get_elapsed_time_msec $tstart]
    set mem [Faust::mem_access_count]
    print_info "ip/app files generated in $arch_t milliseconds"

    print_info "Synthesizing $::arguments::name with [emph N] = $N, please wait..."
    set tstart [clock seconds]
    exec ./$::globals::syroot/syfala.tcl $::arguments::dsp --board $::arguments::board --hls --xversion 2022.2 >&@stdout
    set hls_t [get_elapsed_time_sec $tstart]
    print_info "hls done in $hls_t seconds"

    print_info "Writing/Updating concatenated reports"
    write_reports $N $mem $arch_t $hls_t

    print_info "Updating $::arguments::fcsv file"
    write_csv $N $mem $arch_t $hls_t

    print_ok "Done with N = $N, cleaning up..."
    exec $::globals::syroot/syfala.tcl clean
}

foreach n $::arguments::N { run $n }

print_ok "All done!"
print_ok "Latency output successfully written in file '$fpattern-latency.txt'"
print_ok "Utilization output successfully written in file '$fpattern-utilization.txt'"
print_ok "Global output written in '$::arguments::fcsv'"
#print_info "Compiling file 'tex/output-template.tex' with pdflatex"
#cd tex
#exec pdflatex output-template.tex
#print_ok "Compiled/updated file 'tex/output-template.pdf'"
