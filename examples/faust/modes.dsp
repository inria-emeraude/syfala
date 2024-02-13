import("stdfaust.lib");

N = 100;
process = _ <: par(i,N,pm.modeFilter(200+i,5,1)) :> _ <: _,_;
