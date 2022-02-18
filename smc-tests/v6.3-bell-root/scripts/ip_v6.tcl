open_project -reset faust_v6_ip
set_top faust_v6
add_files faust_v6_ip/faust_v6.cpp -cflags "-fbracket-depth=1024"
#add_files -tb faust_ip_hls/project_1/faust_bench.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"

open_solution -reset "faust_v6"
set_part {xc7z010clg400-1}
create_clock -period 8

#csim_design
csynth_design
#cosim_design
export_design -rtl vhdl -format ip_catalog

exit
