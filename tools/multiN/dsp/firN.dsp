import("stdfaust.lib");

N = 3;
process  = fi.fir(par(i,N,i/N));
