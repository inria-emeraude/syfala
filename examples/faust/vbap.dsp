declare name "VBAP";
declare version "2.0";

import("stdfaust.lib");

//Parameters
source = ba.pulsen(1, 10000);
speakerPerRing = 16;
sourceNumber = 2;
ringNumber = 2;
outputNumber = speakerPerRing*ringNumber;

//Controls
azimuth(n) = hslider("azimuth %n", 1, 1, speakerPerRing, 0.01):si.smoo;
elevation(n) = hslider("elevation %n", 1, 1, ringNumber, 0.01):si.smoo;

//Triangular function:
//x: x-coordinate of median
//shift: shifting value of the triangular function
triangular(x, shift) = (1 - ((x - shift):abs), 0):max;

//Outputs for one ring:
//s: input to control panning value
//nS: number of speakers
singleRing(s, nS) = _ <: par(i, nS, _*triangular(s, i+1));

//Outputs for multiple rings:
//sE: input to control the elevation
//sA: input to control the azimuth
//nS: number of speakers
//nR: number of rings
multiRing(sA, sE, nR, nS) = _ <: par(i, nR, _*triangular(sE, i+1) : singleRing(sA, nS));

process = par(j, sourceNumber, source <: multiRing(azimuth(j), elevation(j), ringNumber, speakerPerRing)) :> par(j,  outputNumber, _);
