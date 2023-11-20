#!/usr/bin/tclsh

exec ./multiN.tcl echoN Z10 2 4 8 16 32 48 64 >&@stdout
exec ./multiN.tcl echoN Z20 2 4 8 16 32 48 64 >&@stdout
exec ./multiN.tcl echoN GENESYS 2 4 8 16 32 48 64 >&@stdout

exec ./multiN.tcl bellN Z10 6 8 16 24 32 >&@stdout
exec ./multiN.tcl bellN Z20 6 8 16 24 32 >&@stdout
exec ./multiN.tcl bellN GENESYS 6 8 16 24 32 48 >&@stdout

exec ./multiN.tcl firN Z10 50 100 200 350 500 >&@stdout
exec ./multiN.tcl firN Z20 50 100 200 350 500 >&@stdout
exec ./multiN.tcl firN GENESYS 50 100 200 350 500 >&@stdout

exec ./multiN.tcl vbapN Z10 2 4 8 16 32 64 128 192 256 >&@stdout
exec ./multiN.tcl vbapN Z20 2 4 8 16 32 64 128 192 256 >&@stdout
exec ./multiN.tcl vbapN GENESYS 2 4 8 16 32 64 128 192 256 >&@stdout

exec ./multiN.tcl lmsN Z10 30 60 90 120 130 150 175 >&@stdout
exec ./multiN.tcl lmsN Z20 30 60 90 120 130 150 175 >&@stdout
exec ./multiN.tcl lmsN GENESYS 30 90 60 120 130 150 175 200 250 350 500 >&@stdout
