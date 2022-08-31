#!/usr/bin/tclsh

source ../../scripts/sylib.tcl
namespace import Syfala::*

proc ffindl { f target } {
    set fr   [open $f r]
    set data [read $fr]
    close    $fr
    foreach line [split $data "\n"] {
        if [contains $target $line] {
            return $line
        }
    }
}

proc ffindlN { f target N {offset 0}} {
    set fr   [open $f r]
    set data [read $fr]
    set out   ""
    set index $offset
    close     $fr
    set data_l [split $data "\n"]
    foreach line $data_l {
        if [contains $target $line] {
            append out "[lindex $data_l $index]\n"
            for {set i 0} {$i < $N} {incr i} {
                 append out "[lindex $data_l [incr index]]\n"
            }
        }
        incr index
    }
    return $out
}

proc freplacel { f A B } {
    set fr     [open $f r]
    set data   [read $fr]
    set index  0
    close      $fr
    set fw     [open $f w]
    foreach line [split $data "\n"] {
        foreach a $A {
            if [contains $a $line] {
                set line [lindex $B $index]
                incr index
            }
        }
        puts $fw $line
    }
    close $fw
}
