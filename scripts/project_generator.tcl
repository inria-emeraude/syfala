#!/usr/bin/tclsh

source ../scripts/sylib.tcl
namespace import Syfala::*

namespace eval arguments {
    set board [lindex $::argv 0]
}

namespace eval runtime {
    variable nchannels_i
    variable nchannels_o
    variable ncontrols_i
    variable ncontrols_f
    variable ncontrols_p
}

proc get_definition_value { f pattern } {
    set line [ffindl $f $pattern]
    return [lindex [split $line] end]
}

proc lambda {argl body} {
     set name {}
     proc $name $argl $body
     return $name
}

proc io_tlvl { io N } {
    switch $io {
        I {return "in_ch$N\_V"}
        O {return "*out_ch$N\_V"}
    }
}

proc io_stat { io N } {
    switch $io {
        I {return "inputs\[$N\]"}
        O {return "outputs\[$N\]"}
    }
}

proc replace { A N lambda } {
    set B ""
    for {set i 0} {$i < $N} {incr i} {
        if [is_empty $B] {
            set B "[$lambda $i]"
        } else {
            set B "$B\n[$lambda $i]"
        }
    }
    return $B
}

proc overwrite { F A N lambda } {
    set B ""
    for {set i 0} {$i < $N} {incr i} {
        if [is_empty $B] {
            set B "[$lambda $i]"
        } else {
            set B "$B\n[$lambda $i]"
        }
    }
    freplacel $F $A $B
}

# create a 'sources' directory in build directory
# copy fpga.cpp template file to be modified accordingly
file mkdir $::Syfala::BUILD_DIR/sources
file copy -force $::Faust::ARCH_FPGA_TEMPLATE_FILE $::Syfala::BUILD_DIR/sources

# retrieve number of I/O channels from Faust macro definitions
# in the generated syfala_ip.cpp file
print_info "Now parsing Faust-generated IP file"
set f $::Syfala::BUILD_IP_DIR/syfala_ip.cpp
set ::runtime::nchannels_i [get_definition_value $f "#define FAUST_INPUTS"]
set ::runtime::nchannels_o [get_definition_value $f "#define FAUST_OUTPUTS"]
set ::runtime::ncontrols_i [get_definition_value $f "#define FAUST_INT_CONTROLS"]
set ::runtime::ncontrols_f [get_definition_value $f "#define FAUST_REAL_CONTROLS"]
set ::runtime::ncontrols_p [get_definition_value $f "#define FAUST_PASSIVES"]

set channels_min [expr min($::runtime::nchannels_i, $::runtime::nchannels_o)]
set channels_max [expr max($::runtime::nchannels_i, $::runtime::nchannels_o)]
set N0 [expr $channels_max - $channels_min]

print_info "Number of input channels: $::runtime::nchannels_i"
print_info "Number of output channels: $::runtime::nchannels_o"
print_info "Number of int-based controls: $::runtime::ncontrols_i"
print_info "Number of real-based controls: $::runtime::ncontrols_f"
print_info "Number of passive controls: $::runtime::ncontrols_p"

# -----------------------------------------------------------------------------
# Top-level arguments (no input arguments if no inputs etc.)
# -----------------------------------------------------------------------------
overwrite $f "sy_ap_int in_chX_V" $::runtime::nchannels_i \
    [lambda i {return [indent "sy_ap_int [io_tlvl I $i],"]
}]
overwrite $f "sy_ap_int* out_chX_V" $::runtime::nchannels_o \
    [lambda i {return [indent "sy_ap_int [io_tlvl O $i],"]
}]
# -----------------------------------------------------------------------------
# Static i/o local arrays
# -----------------------------------------------------------------------------
set A "FAUSTFLOAT inputs"
if {$::runtime::nchannels_i > 0} {
    set i $::runtime::nchannels_i
    set o $::runtime::nchannels_o
    set B "static FAUSTFLOAT inputs\[$i\], outputs\[$o\];
    // Prepare inputs for 'compute' method"
    for {set n 0} {$n < $::runtime::nchannels_i} {incr n} {
      set B "$B
      inputs\[$n\] = [io_tlvl I $n].to_float() / scaleFactor;"
    }
} else {
    set B "static FAUSTFLOAT outputs\[$::runtime::nchannels_o\];"
}

freplacel $f $A [indent $B]

# -----------------------------------------------------------------------------
# computemydsp function call
# -----------------------------------------------------------------------------
set A "computemydsp(&DSP"
set B ""
if {$::runtime::nchannels_i == 0} {
    set B "computemydsp(&DSP, 0, outputs, icontrol, fcontrol, I_ZONE, F_ZONE);"
} else {
    set B "computemydsp(&DSP, inputs, outputs, icontrol, fcontrol, I_ZONE, F_ZONE);"
}
freplacel $f $A [indent $B 2]
# -----------------------------------------------------------------------------
# Adapt the 'ram-not-ready' bypass check
# -----------------------------------------------------------------------------
# matching channels will have 'input[n] = output[n]'
# others will have 'outputs[n] = 0'
set A "outputs\[0\] = inputs\[0\]"
set B [replace $A $channels_min                                             \
      [lambda i {return [indent "outputs\[$i\] = inputs\[$i\];"]}]]
set C [replace $A $N0                                                       \
      [lambda i {return [indent "outputs\[$i\] = 0;"]}]]

freplacel $f $A "$B$C"

# -----------------------------------------------------------------------------
# Adapt the bypass subfunction
# -----------------------------------------------------------------------------
set A "*out_chX_V = in_chX_V;"
set B [replace $A $channels_min                                             \
      [lambda i {return [indent "[io_tlvl O $i] = [io_tlvl I $i];"]}]]
set C [replace $A $N0                                                       \
      [lambda i {return [indent "[io_tlvl O $i] = 0;"]}]]

freplacel $f $A "$B$C"

# -----------------------------------------------------------------------------
# Adapt the mute subfunction
# -----------------------------------------------------------------------------
overwrite $f "*out_chX_V = 0;" $::runtime::nchannels_o \
    [lambda i {return [indent "[io_tlvl O $i] = 0;"]
}]
# -----------------------------------------------------------------------------
# Adapt the output writes
# -----------------------------------------------------------------------------
overwrite $f "*out_chX_V = sy_ap_int" $::runtime::nchannels_o \
    [lambda i {
     return [indent "[io_tlvl O $i] = sy_ap_int(outputs\[$i\] * scaleFactor);"]
}]
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

freplacel $f "int ARM_fControl"                                             \
     [indent "int ARM_fControl\[$nf\]," 2]

freplacel $f "int ARM_iControl"                                             \
     [indent "int ARM_iControl\[$ni\]," 2]

freplacel $f "int ARM_passive_controller"                                   \
     [indent "int ARM_passive_controller\[$np\]," 2]

freplacel $f "static int icontrol\[FAUST_INT_CONTROLS\]"                    \
             "static int icontrol\[$ni\];"

freplacel $f "static float fcontrol\[FAUST_REAL_CONTROLS\]"                 \
             "static float fcontrol\[$nf\];"

# -----------------------------------------------------------------------------
# call syfala maker
# -----------------------------------------------------------------------------

exec $::Syfala::SCRIPTS_DIR/syfala_maker.tcl $::runtime::nchannels_i        \
                                             $::runtime::nchannels_o        \
                                             $channels_max                  \
                                             $::arguments::board            \
                                             >&@stdout

