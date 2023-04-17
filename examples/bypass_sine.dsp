import("stdfaust.lib");

in_out = 8;

freqs = par(i,in_out,hgroup("%i",os.osc(hslider("Frequency",10*(i+1),5,3000,100))*hslider("Volume",1,0,10,1)));

process = par(i,in_out,_),freqs:ro.interleave(in_out,2):par(i,in_out,(_,_):>_);
