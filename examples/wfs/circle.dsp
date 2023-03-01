import("stdfaust.lib");

vol = hslider("volume [unit:dB]", -20, -96, 0, 0.1) : ba.db2linear ;
t = checkbox("on");
speed = hslider("speed",48000,1,48000,1);

phasor(freq) = (+(freq/ma.SR) ~ ma.frac);
osc(freq) = sin(phasor(freq)*2*ma.PI);

process = (_~(+(1)%speed) : _==0 : +~%(32) <: _,(+(50) : ba.pianokey2hz : osc*vol) <: par(i,32,select2(i==_,0,_))); 
