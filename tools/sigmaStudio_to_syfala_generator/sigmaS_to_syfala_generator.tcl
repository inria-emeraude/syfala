#!/usr/bin/tclsh

set spath   [file normalize [info script]]
set sroot   [file dirname [file dirname [file dirname $spath]]]

source $sroot/scripts/sylib.tcl
namespace import Syfala::*

set supported_codecs [list  \
    ADAU1761                \
    ADAU1777                \
    ADAU1787                \
]

set supported 0

if {[llength $::argv] == 0} {
    print_error "Usage: sigmaS_to_syfala_generator.tcl <target>"
    exit 1
} else {
    print_info "Running sigmaS_to_syfala_generator with arguments '$::argv'"
}

set target [lindex $::argv 0]

foreach c $supported_codecs {
    if {$target == $c} {
        set supported 1
        break
    }
}
if !$supported {
    set l [join $supported_codecs ", "]
    print_error "Target $target is unsupported"
    print_error "Supported targets: $l"
    exit 1
} else {
    print_ok "Target $target is supported"
}

set target_header $target\Reg.h
set target_source $target\Reg.cpp
set header_path $::Syfala::ARM_INCLUDE_DIR/codecs/$target_header
set source_path $::Syfala::ARM_SOURCE_DIR/codecs/$target_source
set template_path $::Syfala::ARM_SOURCE_DIR/codecs/template.pp

if ![file exists $header_path] {
    print_error "Could not find header: $header_path, aborting"
    print_error "Please re-generate the header file with sigmaStudio"
    exit 1
} else {
    print_ok "Header file $header_path found."
}

set systime [clock seconds]
set systime_d [clock format $systime -format %D]
set systime_h [clock format $systime -format %H:%M:%S]

print_info "Creating source file: $source_path"
file copy -force $template_path $source_path
freplacel $source_path "@file" " * @file $target_source"
freplacel $source_path "ADAU17xx." " * Registers configuration for $target"
freplacel $source_path "@date" " * @date: $systime_d $systime_h"
freplacel $source_path "ADAU17xxReg.h" "#include <syfala/arm/codecs/$target\Reg.h>"
freplacel $source_path "#define CTARGET" "#define CTARGET \"\[$target\]\""
freplacel $source_path "namespace" "namespace $target {"

# Parse all macros and append values to a list
print_info "Parsing header file data..."
set header_file [open $header_path r]
set header_data [read $header_file]
set source_data [list]

switch $target {
    ADAU1761 {
        set pattern {#define\sR[0-9]+_}
    }
    ADAU1777 - ADAU1787 {
        set pattern {#define\sREG_}
    }
}

foreach line [split $header_data "\n"] {
     set r [regexp $pattern $line]
     if $r {
        if [contains "BYTE" $line] {
            set v [lindex [split $line] end]
        } else {
            set v [lindex [split $line] 1]
        }
        lappend source_data $v
    }
}
close $header_file

set source_file_r [open $source_path r]
set source_data_r [read $source_file_r]
close $source_file_r

set source_file_w [open $source_path w]
foreach line [split $source_data_r "\n"] {
    if [contains "\[...\]" $line] {
        print_ok "Found insertion pattern"
        switch $target {
            ADAU1761 {
            for {set n 0} {$n < [llength $source_data]} {incr n 2} {
                 set n1 [expr $n+1]
                 set addr [lindex $source_data $n]
                 set data [lindex $source_data $n1]
                 set str [indent "REGWRITE($addr, $data, 0)" 1]
                 puts $source_file_w $str
            }}
            ADAU1777 - ADAU1787 {
            for {set n 0} {$n < [llength $source_data]} {incr n 3} {
                 set n1 [expr $n+1]
                 set n2 [expr $n+2]
                 set name [lindex $source_data $n]
                 set byte [lindex $source_data $n1]
                 set data [lindex $source_data $n2]
                 set offset [expr $byte-1]
                 if $byte {
                    set str [indent "REGWRITE($name, $data, $offset)" 1]
                    puts $source_file_w $str
                 }
            }}
        }
    } else {
        puts $source_file_w $line
    }
}

close $source_file_w
print_ok "Successfully generated file $source_path"
exit 0
