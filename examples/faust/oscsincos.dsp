//-----------------------------------------------
// 			Sin/cos Oscillator
//-----------------------------------------------

import("stdfaust.lib");

vol = hslider("volume [unit:dB]", 0, -96, 0, 0.1) : si.smoo : ba.db2linear ;
freq = hslider("freq [unit:Hz]", 1000, 20, 24000, 1);
select = nentry("Selector",0,0,1,1) : int;

process = (os.oscrs(freq) * vol),(os.oscrc(freq) * vol): select2(select)<:_,_ ;  
