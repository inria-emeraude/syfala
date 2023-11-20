import("stdfaust.lib");

// Karplus Strong (1/2)
freq=192000;
delay=10000;
time=ba.time%(delay*4);

f1=freq/hslider("Freq1 [knob:1]", 440, 100, 1000, 1);
f2=freq/hslider("Freq2 [knob:2]", 440, 100, 1000, 1);
f3=freq/hslider("Freq3 [knob:3]", 440, 100, 1000, 1);
f4=freq/hslider("Freq4 [knob:4]", 440, 100, 1000, 1);
karplusString = ba.pulse(delay) :
        + ~ transformation;

transformation = @(
    f1*((time>=(0)) & (time<(delay)))+
    f2*((time>=(delay)) & (time<(delay*2))) +
    f3*((time>=(delay*2)) & (time<(delay*3))) +
    f4*((time>=(delay*3)) & (time<(delay*4)))) 
: moyenne : *(0.99);

moyenne(x) = (x+x')/2;

process=karplusString<:_*((time>=(0)) & (time<(delay))),
                        _*((time>=(delay)) & (time<(delay*2))),
                        _*((time>=(delay*2)) & (time<(delay*3))),
                        _*((time>=(delay*3)) & (time<(delay*4))),
                        _*((time>=(0)) & (time<(delay*2))),
                        _*((time>=(delay*2)) & (time<(delay*4)));
