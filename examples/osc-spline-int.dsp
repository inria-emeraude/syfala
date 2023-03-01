// osc-spline-int.dsp
// AUTHORS: Julien Sourice and Romain Michon
// DESCRIPTION: Spline interpolation sine wave oscillator at 1k.
// Work carried out by Julien Sourice as part of an internship at Maynooth U.
// DATE: Sept. 30, 2022

import("stdfaust.lib");

varSR = ma.SR;   // Sampling rate in Hz

// Defined table size (default 65536)
tableSize = (1 << 16);
// Built the Lookup base with 65536 cases of float values -----------------------------
sineWave(tableSize) = int(ba.time)*(2.0*ma.PI)/(tableSize) : cos;

// Convert as a function -------------------------------------------------------------
osc(freq) = newWaveS(freq)
with{
    newWaveS(fr) =    ( newWaveP1 * ( (resfrac^(3))/6 ) )
                    + ( newWave00 * ( (1+resfrac)^(3) - 4*resfrac^(3) )/6 )
                    + ( newWaveM1 * ( (2-resfrac)^(3) - 4*(1-resfrac)^(3) )/6 )
                    + ( newWaveM2 * ( (1-resfrac)^(3) )/6 )
    with{
        phasorDec = ((+(fr/varSR) : ma.frac) ~ _)';
        resfrac = int(phasorDec*float(1<<30)) & ((1<<14)-1)*lofac
        with{
            lobits = 14;
            lomask = (2^(lobits))-1; // 16383
            lofac = 1/(lomask+1);
        };
        phasorInt = int(phasorDec*tableSize);
        newWaveM2 = tableSize,sineWave(tableSize),phasorInt : rdtable;
        newWaveM1 = tableSize,sineWave(tableSize),(phasorInt+1)%tableSize : rdtable;
        newWave00 = tableSize,sineWave(tableSize),(phasorInt+2)%tableSize : rdtable;
        newWaveP1 = tableSize,sineWave(tableSize),(phasorInt+3)%tableSize : rdtable;
    };
};

process = osc(1000);
