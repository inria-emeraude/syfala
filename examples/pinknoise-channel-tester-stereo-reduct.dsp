import("stdfaust.lib");

// number of output channels
nchannels = 8;
length = 500;

// max-like gate
// note: if n == 0, gate is closed (which is not the case with ba.selectoutn) */
gate(o,n,s) = par(i,o, s*((n!=0)&(n==i+1)));
counter(t) = (t > mem(t)) : (+ : *(1)) ~ _;
ms2samples(ms) = ms/1000*ma.SR;
pn = no.pink_noise * 0.25;
nsamples = ms2samples(length);

// we count from 0 to 2nsamples
// if <= nsamples, signal passes
// otherwise we output 0
phase = ba.sweep(1, nsamples*2);
burst = phase <= nsamples;

// we increment channel index whenever sample counter reaches nsamples-1
// we wrap it around nchannels and add the offset
index = counter(burst) % nchannels;
process = gate(nchannels, index*burst, pn) :> _,_;
