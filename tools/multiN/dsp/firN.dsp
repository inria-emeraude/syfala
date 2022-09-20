import("stdfaust.lib");

N = 350;
process  = fi.fir(par(i,N,i/N));
