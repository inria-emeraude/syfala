import("stdfaust.lib");

NChannels = 10;

vol = hslider("volume [unit:dB]", -20, -96, 0, 0.1) : ba.db2linear ;
t = checkbox("on");
speed = hslider("speed",48000,1,48000,1);

process = _~(+(1)%speed) : _==0 : +~%(NChannels) <: _,(+(60) : ba.pianokey2hz : os.oscrs*vol) <: par(i,NChannels,select2(i==_,0,_));
