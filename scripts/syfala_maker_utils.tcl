#-------------------------------------------------------------------------------------------------------------------------------------------------------
#-------------------generate_I2S_file------------------------------------------
# Function to generate i2s_transceiver.vhd with automatic In/Out channels number adjustment.
# Replace all "right_" and "left_" words with "ch0, ch1, ch2,..."
# Can handle nested "if" only if the nested conditions don't imply "right" or "left"
# AND write the generic header with the right ratio values
# (Easier to do all in one function to avoid processing the file twice)
proc generate_I2S_file {input_file output_file channelNb header_generic} {
	set ifStatement false
	set ifLevel 0
	while {[gets $input_file line] >= 0} {
		if {$ifStatement} {
			if {[string match "end if*" [string trim $line]]} {
				incr ifLevel -1
			} elseif {[string first "if" $line] != -1} {
				incr ifLevel
			}
			append ifBloc "$line\n"
			if {[string match "end if*" [string trim $line]] && $ifLevel<=0 } { ;#if we leave the if statement
				set ifStatement false
				for {set i 0} {$i < $channelNb} {incr i 2} {
					foreach ifLine [split $ifBloc \n] {
						set newline [string map "left ch$i" $ifLine]
						set increment [expr {$i + 1}]
						set newline [string map "right ch$increment" $newline]
						puts $output_file $newline
					}
				}
			}


		} else {
			if {([string first "left_" $line] != -1 || [string first "right_" $line] != -1) && [ string first "end if" $line] == -1 } {
				if {[string match "if*" [string trim $line]]} { ;#if we're in a if statement, wait for the end of statement and copy all the bloc.
					set ifStatement true
					set ifLevel 1
					set ifBloc "$line\n"
				} else {
					for {set i 0} {$i < $channelNb} {incr i} {
						set newline [string map "left ch$i" $line] ;# Use "", not {·} in map for var: https://community.f5.com/t5/technical-forum/string-map-does-it-accept-variables/td-p/208031
						incr i
						set newline [string map "right ch$i" $newline]
						puts $output_file $newline
					}
				}
			} elseif {[string first "<<GENERIC_HEADER>>" $line] != -1} {
			            puts $output_file $header_generic
			}  else {
				puts $output_file $line
			}
		}
	}
}


#-------------------------------------------------------------------------------------------------------------------------------------------------------
# Function to generate the bloc design of project.tcl

proc declare_user_module {name path} {

	global declarations_path
	append declarations_path $path\n

	global module_names
	append module_names $name\n

	global user_instances
	append user_instances "set block_name $name\n \
							 set block_cell_name $name\_0\n \
							 if { \[catch {set $name\_0 \[create_bd_cell -type module -reference \$block_name \$block_cell_name\] } errmsg\] } {\n \
								catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity \"ERROR\" \"Unable to add referenced block <\$block_name>. Please add the files for \${block_name}'s definition into the project.\"}\n\
								return 1\n\
							 } elseif { \$$name\_0 eq \"\" } {\n\
								catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity \"ERROR\" \"Unable to referenced block <\$block_name>. Please add the files for \${block_name}'s definition into the project.\"}\n\
								return 1\n\
							}\n"



}

proc create_port {name dir {size 1}} {
	global ports
	if {$size<=1} {
    	append ports "set $name \[ create_bd_port -dir $dir $name \]\n"
    } else {
        append ports "set $name \[ create_bd_port -dir $dir -from [expr {$size-1}] -to 0 $name \]\n" ; #TO CHECK!
    }
}

proc connect {type1 conn1 type2 conn2 {connection_type "bd_net"}} {

	global connections
	#check if pin/port is already connected to put it on the same line:
	#Generate:
	#	connect_bd_net [get_bd_ports port1] [get_bd_ports port2]  [get_bd_pins pin3]
	#Instead of
	#	connect_bd_net [get_bd_ports port1] [get_bd_pins pin3]
	#	connect_bd_net [get_bd_ports port2] [get_bd_pins pin3]
	# BUT NOT MANDATORY, now I know that vivado accept multiple connection declaration. But now that it's coded...
	set conn1_already_connected [string first " $conn1\]" $connections] ;#add \] to ensure the complete word is found, not just a corresponding part
	set conn2_already_connected [string first " $conn2\]" $connections]

	if {$conn1_already_connected != -1 || $conn2_already_connected != -1} {;#if a pin/port of args is already connected, use the same connection line
		if {$conn1_already_connected != -1} {
			set newConnection [string map "$conn1\] $conn1\]\\ \[get_bd_$type2\\ $conn2\]" $connections]
		} else {
			set newConnection [string map "$conn2\] $conn2\]\\ \[get_bd_$type1\\ $conn1\]" $connections]
		}
		set connections $newConnection
	} else {
    	append connections "connect_$connection_type \[get_bd_$type1 $conn1\] \[get_bd_$type2 $conn2\]\n" ;#only this line is needed if we don't want to put same declaration on the same line
	}
}

proc create_axi_interconnect {name num_i {type "default"}} {
	global system_instances
	append system_instances " # Create instance: $name, and set properties \n"
	if {$type == "default"} {
		append system_instances "  set $name \[ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 $name \]\n \
		 set_property -dict \[ list \\\n \
			 CONFIG.NUM_MI {$num_i} \\\n \
		 \] \$$name\n \n"
   } elseif {$type == "smartconnect"} {
   append system_instances "  set $name \[ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 $name \]\n \
    set_property -dict \[ list \\\n \
      CONFIG.NUM_SI {$num_i} \\\n \
		 \] \$$name\n \n"
   }
}

proc create_axi_gpio {name type} {
	global system_instances
	append system_instances " # Create instance: $name, and set properties \n\
	  set $name \[ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 $name \]\n\
    set_property -dict \[ list \\\n\
    CONFIG.C_ALL_INPUTS {0} \\\n\
    CONFIG.C_ALL_OUTPUTS {1} \\\n\
    CONFIG.C_ALL_OUTPUTS_2 {1} \\\n\
    CONFIG.C_GPIO2_WIDTH {3} \\\n\
    CONFIG.C_GPIO_WIDTH {4} \\\n\
    CONFIG.C_IS_DUAL {1} \\\n"
	if {$type == "zybo"} {
		append system_instances " CONFIG.GPIO2_BOARD_INTERFACE {rgb_led} \\\n\
   													CONFIG.GPIO_BOARD_INTERFACE {leds_4bits} \\\n"
   } elseif {$type == "genesys"} {
   append system_instances " CONFIG.GPIO2_BOARD_INTERFACE {rgbled_3bits} \\\n\
   													CONFIG.GPIO_BOARD_INTERFACE {led_4bits} \\\n"
   }
   append system_instances " CONFIG.USE_BOARD_FLOW {true} \\\n\
      		 \] \$$name\n \n"
}
