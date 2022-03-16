
################################################################################
# POPOFF M.: Please keep this block if you change this tcl.
######################### START configFAUST READING ########################

puts "Reading configFAUST.h values"
set fd [open ../configFAUST.h r]
set data [read $fd]
set input_list [split $data "\n"]
close $fd
foreach elem [lsearch -all -inline $input_list "*define ZYBO_VERSION*"] {
    set zybo_version "[lindex $elem 2]"
}


open_project -reset faust_v6_ip
set_top faust_v6
add_files faust_v6_ip/faust_v6.cpp
#add_files -tb faust_ip_hls/project_1/faust_bench.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"

open_solution -reset "faust_v6"
if { $zybo_version == "Z10" } {
    set_part {xc7z010clg400-1}
} elseif { $zybo_version == "Z20" } {
    set_part {xc7z020clg400-1}
} else {
     puts {[ERROR] No valid Zybo version found in configFAUST.h };
     exit 2;
}
create_clock -period 8

#csim_design
csynth_design
#cosim_design
export_design -rtl vhdl -format ip_catalog

exit
