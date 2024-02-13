// lecomteWFS.dsp
// WFS implementation adapted from Pierre Lecomte's 'lecomteOrigWFS.dsp'
// Currently only one source is synthesized (since more sources won't fit on the FPGA).

import("stdfaust.lib");

nSpeakers = 32; // number of speakers
speakersDist = 0.0783; // distance between speakers

// reference point
xref = 0;
yref = 0;
zref = 0;

// source position
inGain = hslider("inGain",1,0,10,0.01);
xs = hslider("xs", 0, -nSpeakers*speakersDist, nSpeakers*speakersDist, 0.01) ;
ys = hslider("ys", 1.5,  1, 10, 0.01) ;
zs = hslider("zs", 0, -10, 10, 0.01) ;

c = 340; // speed of sound

filter = fi.tf2(b0,b1,b2,a1,a2)
with{
    b0 = 1;
    b1 = -0.8715;
    b2 = 0.0412;
    a1 = -0.31134;
    a2 = -0.088955;
};

// norm
norm(x1, y1, z1, x2, y2, z2) = sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2);

// driving function
driving(pregain,r,rLong) = _ * pregain / r^2 : de.fdelay(rmax, d)
with{
    rmax = (nSpeakers*speakersDist)/c*ma.SR;
    d = (r-rLong)/c*ma.SR;
};

// min function taking N arguments
mins(1) = _;
mins(2) = min;
mins(N) = mins(int(N/2)),mins(N-int(N/2)) : min;

// x position of each speaker in meters
speakersXpos = par(i,nSpeakers,(-speakersDist*nSpeakers/2 + speakersDist/2 + i*speakersDist));

// synthesize one source
oneSource = *(inGain) : filter <: (speakersXpos <:
par(i,nSpeakers,norm(xref,yref,zref,_,0,0)*ys),(par(i,nSpeakers,norm(xs,ys,zs,_,0,0)) <: par(i,nSpeakers,_),(mins(nSpeakers) <: par(i,nSpeakers,_)))),par(i,nSpeakers,_) : route(nSpeakers*4,nSpeakers*4,par(i,(nSpeakers*4)-1,(((i*nSpeakers))%(nSpeakers*4-1)+1,i+1)),(nSpeakers*4,nSpeakers*4)) : par(i,nSpeakers,driving);

process = oneSource;
