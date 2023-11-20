import("stdfaust.lib");
N = 1024; // FIR Filter Length
f = 4000;
pi = ma.PI;
arg1 = par(i, N, cos(2*pi*f*1/ma.SR*i) * exp(-10*(i)/N));
ffir = fi.fir(arg1);
process = ffir;
