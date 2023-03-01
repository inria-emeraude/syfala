/*
 * Currently implements a primitive WFS system with 32 speakers, 6 virtual sources,
 * and 2 audio inputs. Each output can be routed to one of the virtual sources using
 * UI elements.
 */

import("stdfaust.lib");

celerity = 343;

// Creates a speaker array for one source
//speakerArray(NC,SD,x,y) = de.delay(maxDistanceDel-intSpeakMaxDel,largeDel) <: 
speakerArray(NC,SD,x,y) = _ <: 
//    par(i,NC,de.delay(intSpeakMaxDel,smallDel(i))/d(i))
    par(i,NC,de.delay(intSpeakMaxDel,smallDel(i)))
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
    x(p) = p/(nSources-1)*SD*NC;
    y(p) = (1 - abs(p/((nSources-1)/2) - 1))*mD + 0.01;
};

// This will do for future versions when we can use mobile sources
sourcesArraySpheric(NC,SD,s) = par(i,ba.count(s),ba.take(i+1,s) <: 
    speakerArraySpheric(NC,SD,x(i),y(i))) :> par(i,NC,_)
with{
    x(p) = hslider("v: Source %p/x coordinate of source %p",SD*NC/2,0,SD*NC,0.01);
    y(p) = hslider("v: Source %p/y coordinate of source %p",10,1,20,0.01);
};

// ------------------ Implementation ----------------------------------

nSpeakers = 32; // number of speakers
nSources = 5; // number of sources
nInputs = 2; // number of inputs
mD = 5; // maxim distance in meters
speakersDist = 0.0783; // distance between speakers

// Simulate distance by changing gain and applying a lowpass in function
// of distance
dSim(p) = _;
// dSim(p) = *(dGain) : fi.lowpass(2,ct)
// with{
//     distance = (1 - abs(p/((nSources-1)/2) - 1))*mD + 0.01;
//     dGain = (mD-distance*0.5)/(mD); 
//     ct = dGain*15000 + 5000;
// };

// Take nInputs and send them to nSources. A slider allows us to select
// to which source the current input is routed.
dist = par(i,nInputs,dSim(s(i)) <: par(j,nSources,select2(s(i)==j,0)))
with{
    s(k) = hslider("pos%k",0,0,(nSources-1),1) : int;
};

// (dirty) Version implenting a crossfade between the sources
distXFade = dSim(mD,s) <: par(i,nSource,*(g(i)))
with{
    s = hslider("pos",0,0,(nSource-1),0.01) : si.smoo;
    sFrac = ma.frac(s);
    g(i) = (1-sFrac)*((s>=i) & (s<(i+1))) + sFrac*((s<=i) & (s>(i-1)));
};

process = dist :> sourcesArray(nSpeakers,speakersDist,par(i,nSources,_));
