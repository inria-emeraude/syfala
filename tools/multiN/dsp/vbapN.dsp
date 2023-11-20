import("hoa.lib");

osc(amp,freq) = cos(phasor(freq)*2*ma.PI)*amp
with{
    phasor(f) = (+(delta) ~ ma.frac)'
    with{
        delta = f/ma.SR;
    };
};

fm(a,fc,fm0,fm1,z0,z1) = car
with{
    mod0 = fm1 + osc(z0*fm0,fm0);
    mod1 = fc + osc(z1*mod0,mod0);
    car = osc(a,mod1);
};

N = 256;
phase = 360/N;
speakers = par(i, N, i*phase);
source = hslider("source_pos", 0, 0, 360, 1);

process = fm(1,440,440,440,3,2) : circularScaledVBAP(speakers, source);






















































