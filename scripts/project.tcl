source ../scripts/sylib.tcl
namespace import Xilinx::Boards::*
namespace import Syfala::*

variable PROJECT
variable BOARD_PART
variable BOARD_PROPERTY
variable BOARD_ID

set ARGUMENTS	    [lindex $argv 0]
set BOARD           [lindex $ARGUMENTS 0]
set PROJECT_NAME    "syfala_project"

namespace eval Syfala {
#    set SAMPLE_RATE  [lindex $ARGUMENTS 1]
#    set SAMPLE_WIDTH [lindex $ARGUMENTS 2]
    set HLS_IP_NAME  "syfala"
}

namespace eval Xilinx {
    # Note (Pierre): since this script is called from a Vivado environment
    # we have to pass Xilinx::ROOT as an argument and set it from here
    # it will also propagate to the sylib.tcl source
    # (we need Xilinx::ROOT to retrieve the proper board_files version)
    set ROOT [lindex $ARGUMENTS 1]
}

set BOARD_PART          [Xilinx::get_board_part $BOARD]
set BOARD_PROPERTY      [Xilinx::get_board_part_full $BOARD]
set BOARD_ID            [Xilinx::get_board_id $BOARD]
set CONSTRAINT_FILE     "$Syfala::XDC_DIR/[Xilinx::get_board_constraint $BOARD]"

set PROJECT_PATH     "$PROJECT_NAME"
set PROJECT_IP_PATH   $Syfala::BUILD_IP_DIR/$Syfala::HLS_IP_NAME

# Create project, store the reference in ::Xilinx::PROJECT
create_project $PROJECT_NAME $PROJECT_PATH -part $BOARD_PART -force
set PROJECT [current_project]

set_property -objects $PROJECT -name "board_part" -value $BOARD_PROPERTY
set_property -objects $PROJECT -name "platform.board_id" -value $BOARD_ID
set_property -objects $PROJECT -name "default_lib" -value "xil_defaultlib"
set_property -objects $PROJECT -name "enable_vhdl_2008" -value "1"
set_property -objects $PROJECT -name "ip_cache_permissions" -value "read write"
set_property -objects $PROJECT -name "ip_output_repo" -value "$PROJECT_PATH/.cache/ip"
set_property -objects $PROJECT -name "mem.enable_memory_map_generation" -value "1"
set_property -objects $PROJECT -name "sim.central_dir" -value "$$PROJECT_PATH/.ip_user_files"
set_property -objects $PROJECT -name "sim.ip.auto_export_scripts" -value "1"
set_property -objects $PROJECT -name "simulator_language" -value "Mixed"
set_property -objects $PROJECT -name "target_language" -value "VHDL"
set_property -objects $PROJECT -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY"

# Create 'sources_1' fileset (if doesn't exist)
if {[string equal [get_filesets -quiet sources_1] ""]} {
     create_fileset -srcset sources_1
}

# Set IP repository paths
set fset_sources_1 [get_filesets sources_1]
set_property -objects $fset_sources_1 -name "ip_repo_paths" -value [file normalize $PROJECT_IP_PATH]
update_ip_catalog -rebuild

# Import VHDL files, setting their properties
set files [list	    \
<<IMPORT_FILES>>    \
]

set imported_files [import_files -fileset sources_1 $files]

set sources_1_files [get_files -of [get_filesets sources_1]]
set_property -objects $sources_1_files -name "file_type" -value "VHDL"

# Set 'sources_1' fileset properties
set_property -objects $fset_sources_1 -name "top" -value "main_wrapper"

# Create 'constrs_1' fileset (if doesn't exist)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}
# Set 'constrs_1' fileset object
set fset_constrs_1 [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set f_master_xdc [file normalize $CONSTRAINT_FILE]
set imported_files [import_files -fileset constrs_1 [list $f_master_xdc]]
set constrs_1_files [get_files -of [get_filesets constrs_1]]
set_property -objects $constrs_1_files -name "file_type" -value "XDC"

# Set 'constrs_1' fileset properties
# set obj [get_filesets constrs_1]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
     create_fileset -simset sim_1
}

# Set 'sim_1' fileset object and its properties
set fset_sim_1 [get_filesets sim_1]
set_property -objects $fset_sim_1 -name "hbs.configure_design_for_hier_access" -value "1"
set_property -objects $fset_sim_1 -name "top" -value "main_wrapper"
set_property -objects $fset_sim_1 -name "top_lib" -value "xil_defaultlib"

# Set 'utils_1' fileset object
set fset_utils_1 [get_filesets utils_1]
# Empty (no sources present)
# Set 'utils_1' fileset properties
# set obj [get_filesets utils_1]

# Proc to create BD main
proc cr_bd_main { parentCell } {
  # CHANGE DESIGN NAME HERE
  set design_name main

  common::send_gid_msg -ssname BD::TCL -id 2010 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\
  <<IP_CHECK>> \
  xilinx.com:ip:xlconstant:1.1\
  xilinx.com:ip:axi_gpio:2.0\
  xilinx.com:ip:clk_wiz:6.0\
  xilinx.com:hls:syfala:1.0\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:xlslice:1.0\
  "

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  ##################################################################
  # CHECK Modules
  ##################################################################
  set bCheckModules 1
  if { $bCheckModules == 1 } {
     set list_check_mods "\
    <<MODULE_NAMES>>
  "

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create ports
  <<GENERATED_PORTS>>


  # Create instance: axi_gpio_SW, and set properties
  set axi_gpio_SW [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_SW ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_GPIO_WIDTH {4} \
   CONFIG.C_IS_DUAL {0} \
   CONFIG.GPIO_BOARD_INTERFACE {Custom} \
 ] $axi_gpio_SW

	<<GENERATED_CLOCKWIZ>>

  # Create instance: syfala, and set properties
  set syfala [create_bd_cell -type ip -vlnv xilinx.com:hls:syfala:1.0 syfala]

  <<CREATED_INSTANCES>>

  <<PS_CONFIG>>

  # Create instance: rst_global, and set properties
  set rst_global [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_global ]

  # Create instance: sw0, and set properties
  set sw0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw0 ]
  set_property -dict [ list \
   CONFIG.DIN_WIDTH {4} \
 ] $sw0

  # Create instance: sw1, and set properties
  set sw1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {4} \
   CONFIG.DOUT_WIDTH {1} \
 ] $sw1

  # Create instance: sw2, and set properties
  set sw2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 sw2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {4} \
   CONFIG.DOUT_WIDTH {1} \
 ] $sw2


  # Generated port and interface connections
  <<GENERATED_CONNECTIONS>>


  # Create address segments
  <<GENERATED_ADDRESS>>

  # Restore current instance
 # current_bd_instance $oldCurInst
#  validate_bd_design
#  save_bd_design
#  close_bd_design $design_name
}
# End of cr_bd_main()
cr_bd_main ""
set_property REGISTERED_WITH_MANAGER "1" [get_files main.bd ]
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files main.bd ]

#call make_wrapper to create wrapper files
if { [get_property IS_LOCKED [ get_files -norecurse main.bd] ] == 1  } {
  import_files -fileset sources_1 [file normalize "$Syfala::BUILD_DIR/syfala_project/syfala_project.gen/sources_1/bd/main/hdl/main_wrapper.vhd" ]
} else {
  set wrapper_path [make_wrapper -fileset sources_1 -files [ get_files -norecurse main.bd] -top]
  add_files -norecurse -fileset sources_1 $wrapper_path
}


# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
     create_run -name synth_1 -part $BOARD_PART			\
                -flow {Vivado Synthesis 2020}		\
                -strategy "Vivado Synthesis Defaults"	\
                -report_strategy {No Reports}			\
                -constrset constrs_1				\
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
if {[string equal [get_runs -quiet impl_1] ""]} {
     create_run -name impl_1 -part $BOARD_PART			\
                -flow {Vivado Implementation 2020}		\
                -strategy "Vivado Implementation Defaults"	\
                -report_strategy {No Reports}			\
                -constrset constrs_1				\
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
