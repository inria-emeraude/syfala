source ../scripts/sylib.tcl
namespace import Xilinx::Boards::*
namespace import Syfala::*

# -----------------------------------------------------------------------------
# configuration
# -----------------------------------------------------------------------------
set arguments [lindex $::argv 0]
print_info "Arguments: $arguments"

namespace eval Xilinx {
    # Note (Pierre): since this script is called from a Vivado environment
    # we have to pass Xilinx::ROOT as an argument and set it from here
    # it will also propagate to the sylib.tcl source
    # (we need Xilinx::ROOT to retrieve the proper board_files version)
    set ROOT     [lindex $arguments 6]
    set VERSION  [lindex $arguments 7]
}
print_info "Xilinx Version: $::Xilinx::VERSION"

namespace eval rt {
    set board           [lindex $arguments 0]
    set board_part      [Xilinx::get_board_part $board]
    set board_property  [Xilinx::get_board_part_full $board]
    set board_id        [Xilinx::get_board_id $board]
    set sample_rate     [lindex $arguments 1]
    set sample_width    [lindex $arguments 2]
    set nchannels_i     [lindex $arguments 3]
    set nchannels_o     [lindex $arguments 4]
    set block_design    [lindex $arguments 5]
    set nchannels_max   [expr max($nchannels_i, $nchannels_o)]
    set constraint_file  $::Syfala::CONSTRAINTS_DIR/[Xilinx::get_board_constraint $board]
}
namespace eval globals {
    variable project
    set project_path $::Syfala::BUILD_PROJECT_DIR
    set project_name [file tail $project_path]
    set ip_path $::Syfala::BUILD_IP_DIR/syfala
    set clk_dynamic_reconfig 0
}

# -----------------------------------------------------------------------------
# Create project, set properties
# -----------------------------------------------------------------------------

create_project $::globals::project_name         \
               $::globals::project_path         \
               -part $::rt::board_part -force

set ::globals::project [current_project]
set_property -objects $::globals::project -name "board_part" -value $::rt::board_property
set_property -objects $::globals::project -name "platform.board_id" -value $::rt::board_id
set_property -objects $::globals::project -name "default_lib" -value "xil_defaultlib"
set_property -objects $::globals::project -name "enable_vhdl_2008" -value "1"
set_property -objects $::globals::project -name "ip_cache_permissions" -value "read write"
set_property -objects $::globals::project -name "ip_output_repo" -value "$::globals::project_path/.cache/ip"
set_property -objects $::globals::project -name "mem.enable_memory_map_generation" -value "1"
set_property -objects $::globals::project -name "sim.central_dir" -value "$::globals::project_path/.ip_user_files"
set_property -objects $::globals::project -name "sim.ip.auto_export_scripts" -value "1"
set_property -objects $::globals::project -name "simulator_language" -value "Mixed"
set_property -objects $::globals::project -name "target_language" -value "VHDL"
set_property -objects $::globals::project -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY"

# -----------------------------------------------------------------------------
# File imports
# -----------------------------------------------------------------------------
# Create 'sources_1' fileset (if doesn't exist)
if [is_empty [get_filesets -quiet "sources_1"]] {
    create_fileset -srcset "sources_1"
}
# Set IP repository paths, update catalog
set sources_1_fset [get_filesets "sources_1"]
set_property -objects $sources_1_fset -name "ip_repo_paths" -value $::globals::ip_path
update_ip_catalog -rebuild

# Import VHDL files, setting their properties
set sources_1 [list]
foreach f [glob -directory $::Syfala::BUILD_SOURCES_DIR *.vhd] {
    print_ok "Added $f RTL file to project"
    lappend sources_1 [file normalize $f]
}
set sources_1 [import_files -fileset "sources_1" $sources_1]]
set sources_1 [get_files -of [get_filesets "sources_1"]]
set_property -objects $sources_1 -name "file_type" -value "VHDL"
set_property -objects $sources_1_fset -name "top" -value "main_wrapper"

# Constraint file
if [is_empty [get_filesets -quiet "constrs_1"]] {
    create_fileset -constrset "constrs_1"
}
set constrs_1 [get_filesets "constrs_1"]
set constraint_file [file normalize $::rt::constraint_file]
set constrs_1 [import_files -fileset "constrs_1" [list $::rt::constraint_file]]
set constrs_1 [get_files -of [get_filesets "constrs_1"]]
set_property -objects $constrs_1 -name "file_type" -value "XDC"

# -----------------------------------------------------------------------------
# Block design source
# -----------------------------------------------------------------------------
source $::rt::block_design

# -----------------------------------------------------------------------------
# Finalization
# -----------------------------------------------------------------------------

set_property REGISTERED_WITH_MANAGER "1" [get_files main.bd]
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files main.bd]

if {[get_property IS_LOCKED [get_files -norecurse main.bd]] == 1} {
     import_files -fileset sources_1 [file normalize "$::Syfala::BUILD_PROJECT_DIR/syfala_project.gen/sources_1/bd/main/hdl/main_wrapper.vhd" ]
} else {
    set wrapper_path [make_wrapper -fileset sources_1 -files [ get_files -norecurse main.bd] -top]
    add_files -norecurse -fileset sources_1 $wrapper_path
}
# -----------------------------------------------------------------------------
# Create 'synth_1' run (if not found)
# -----------------------------------------------------------------------------

if [is_empty [get_runs -quiet synth_1]] {
     create_run -name synth_1                           \
                -part $::rt::board                      \
                -flow {Vivado Synthesis 2020}           \
                -strategy "Vivado Synthesis Defaults"	\
                -report_strategy {No Reports}			\
                -constrset constrs_1                	\
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2020" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if [is_empty [get_runs -quiet impl_1]] {
     create_run -name impl_1                                \
                -part $::rt::board                          \
                -flow {Vivado Implementation 2020}          \
                -strategy "Vivado Implementation Defaults"	\
                -report_strategy {No Reports}               \
                -constrset constrs_1                        \
                -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2020" [get_runs impl_1]
}

set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj

set obj [get_runs impl_1]
set_property -name "strategy" -value "Vivado Implementation Defaults" -objects $obj
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]
