import("stdfaust.lib");
drive = hslider("drive",0,0,1,0.01);
offset = hslider("offset",0,-1,1,0.01);
process = ef.cubicnl(drive,offset) <: _,_;

