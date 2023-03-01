// osc-li-int.dsp
// AUTHORS: Julien Sourice and Romain Michon
// DESCRIPTION: Linear interpolation sine wave oscillator at 1k.
// Work carried out by Julien Sourice as part of an internship at Maynooth U.
// DATE: Sept. 30, 2022


import("stdfaust.lib");

varSR = 5000000;

// Defined table size (default 65536)
tableSize = (1 << 12);
// Built the Lookup base with 65536 cases of float values -----------------------------
sineWave(tableSize) = ba.time*(2.0*ma.PI)/tableSize : cos;

osc(freq) = newWaveS(freq)
with{
    newWaveS(fr) = newWave1 + ((newWave2-newWave1)*resfrac)
    with{
        phasorDec = ((+(fr/varSR) : ma.frac) ~ _)';
        resfrac = int(phasorDec*float(1<<30)) & ((1<<14)-1)*lofac
        with{
            lobits = 14;
            lomask = (2^(lobits))-1; // 16383
            lofac = 1/(lomask+1);
        };
        phasorInt = int(phasorDec*tableSize);
        newWave1 = tableSize,sineWave(tableSize),phasorInt : rdtable;
        newWave2 = tableSize,sineWave(tableSize),(phasorInt+1)%tableSize : rdtable;
    };
};

process = osc(1000)*0.9;
