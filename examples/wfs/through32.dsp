import("stdfaust.lib");

N = 32;

sources = hgroup("main",par(i,N,*(hslider("[%i]gain%i[style:knob]",0.5,0,1,0.01))));

process = _,_ <: sources;
