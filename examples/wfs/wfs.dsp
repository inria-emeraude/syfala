/*
 * Currently implements a primitive WFS system with 32 speakers, and 2 audio
 * inputs corresponding to 2 different sound sources to be spatialized. The
 * X/Y position of each source can be controlled using UI elements.
 */

import("stdfaust.lib");

celerity = 343;

// Creates a speaker array for one source
speakerArray(NC,SD,x,y) = _ <:
    par(i,NC,de.fdelay(intSpeakMaxDel,smallDel(i))/d(i))
with{
    maxDistanceDel = mD*ma.SR/celerity;
    intSpeakMaxDel = NC*SD*ma.SR/celerity;
    d(j) = (x-(SD*j))^2 + y^2 : sqrt;
    largeDel = y*ma.SR/celerity;
    smallDel(j) = (d(j)-y)*ma.SR/celerity;
};

// For future versions...
speakerArraySpheric(NC,SD,x,y) = par(i,NC,de.delay(ma.SR,d(i))*(1/d(i)))
with{
    d(j) = (x-(SD*j))^2 + y^2 : sqrt : *(ma.SR)/celerity;
};

// In the current version the position of sources is static...
sourcesArray(NC,SD,s) = par(i,ba.count(s),ba.take(i+1,s) :
    speakerArray(NC,SD,x(i),y(i))) :> par(i,NC,_)
with{
    x(p) = hslider("v: Source %p/x",SD*NC/2,0,SD*NC,0.01);
    y(p) = hslider("v: Source %p/y",mD/2,1,mD,0.01);
};

// This will do for future versions when we can use mobile sources
sourcesArraySpheric(NC,SD,s) = par(i,ba.count(s),ba.take(i+1,s) <:
    speakerArraySpheric(NC,SD,x(i),y(i))) :> par(i,NC,_)
with{
    x(p) = hslider("v: Source %p/x",SD*NC/2,0,SD*NC,0.01);
    y(p) = hslider("v: Source %p/y",10,1,20,0.01);
};

// ------------------ Implementation ----------------------------------

nSpeakers = 32; // number of speakers
nSources = 2; // number of sources
mD = 40; // maxim distance in meters
speakersDist = 0.0783; // distance between speakers

process = sourcesArray(nSpeakers,speakersDist,par(i,nSources,_));
