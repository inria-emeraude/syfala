import("stdfaust.lib");


process = trigger : + ~ transformation: _ * vol * (modulation+1) <:_,_;
        

transformation = @(hslider("delay", 128, 0, 200, 1)) : moyenne : *(hslider("gain", 0.999, -0.98, 0.999, 0.01));
modulation=os.oscrs(freq)*rate/100;
moyenne(x) = (x+x')/2;

vol = hslider("volume [unit:dB]", 0, -96, 0, 0.1) : si.smoo : ba.db2linear ;
freq = hslider("freq [unit:Hz]", 2, 0, 10, 1);
rate = hslider("modulation rate [unit:%]", 50, 0, 100, 1);
trigger = (button("gate")'==0)&(button("gate")==1);

