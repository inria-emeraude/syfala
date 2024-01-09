declare name "bird";
declare author "Pierre Cochard";
declare options "[osc:on]";
declare options "[midi:on]";

/* Modifications by Grame July 2014 */

import("stdfaust.lib");

/* =============== DESCRIPTION ================= :

- Bird singing generator.
- Head = Reverberation, birds heard from far away.
- Bottom = Maximum proximity of the birds.
- Right = maximum speed of whistles.
- Left = minimum speed, birds rarely heard.

*/

  volume = hslider("[4] Gain [style:knob][midi:ctrl 16]", 0.25, 0, 1, 0.01) : si.smooth(0.999);

// PROCESS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

process = hgroup("Birds", mainOsc(noteTrig : rdm(72,94) : mtof , noteTrig) * envWrapper(noteTrig, ampEnv, amp_xp(2510)) : fi.lowpass(1, 2000) *(0.8) * volume <: _,_, (rdmPanner : panSte) : panConnect : *,* : reverb);



// AUTO TRIGGER

autoTrig = ba.beat(t) * (abs(no.noise) <= p) : trigger(48) //tempo(2.5*t))
	with {
		t = hslider("[1]Speed (Granulator)[style:knob][midi:ctrl 13][acc:0 1 -10 0 10]", 240, 120, 480, 0.1) : si.smooth(0.999);
		p = hslider("[2]Probability (Granulator)[unit:%][style:knob][midi:ctrl 14][acc:1 0 -10 0 10]", 50, 25, 100, 1)*(0.01) : si.smooth(0.999);
		trigger(n) 	= upfront : release(n) : >(0.0) with {
			upfront(x) 	= (x-x') > 0.0;
			decay(n,x)	= x - (x>0.0)/n;
			release(n)	= + ~ decay(n);
		};
	};


// BIRD TRIGGER

noteTrig = autoTrig : min(1.0);
//noteTrig = autoTrig;


// OSCILLATORS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/* base */
carrierOsc(freq) = os.osci(freq);
modOsc(freq) = os.triangleN(3,freq);

/* fm oscillator */
mainOsc(freq,trig) = freq <: +(*(harmRatio <: +(*(envWrapper(trig,harmEnv,harm_xp(1700))))) : modOsc : *(modIndex <: +(*(envWrapper(trig,modIndexEnv,modIndex_xp(550)))))) <: +(*(envWrapper(trig,freqEnv,freq_xp(943)))) : carrierOsc;

envWrapper(trig,env,sus) = trig : mstosamps(rdm(100,3000)), sus : hitLength : env;

// FIXED PARAMETERS - - - - - - - - - - - - - - - - - - - - - - - - - - -

/* fm */
harmRatio = 0.063;
modIndex = 3.24;

// TIME FUNCTIONS - - - - - - - - - - - - - - - - - - - - - - - - - - - -

metro(ms) =  (%(+(1),mstosamps(ms))) ~_ : ==(1);
mstosamps(ms) = ms : /(1000) * ma.SR : int;
rdmInc = _ <: @(1), @(2) : + : *(2994.2313) : int : +(38125);
rdm(rdmin,rdmax) = _,(fmod(_,rdmax - rdmin : int) ~ rdmInc : +(rdmin)) : gater : -(1) : abs;
gater = (_,_,_ <: !,_,!,_,!,!,!,!,_ : select2) ~_;

// MIDI RELATED - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/* midi pitch */
mtof(midinote) = pow(2,(midinote - 69) / 12) * 440;

// ENVELOPPES - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/* envelope "reader" (phaser) */

hitLength(length,sustain) = *((==(length,@(length,1))), +(1))~_ <: gater(<(sustain));

/* amplitude envelope */

ampEnvbpf = ba.bpf.start(0, 0) :
	ba.bpf.point(amp_xp(60.241), 1.) :
	ba.bpf.point(amp_xp(461.847), 0.) :
	ba.bpf.point(amp_xp(582.329), 0.928) :
	ba.bpf.point(amp_xp(682.731), 0.5) :
	ba.bpf.point(amp_xp(983.936), 0.) :
	ba.bpf.point(amp_xp(1064.257), 0.) :
	ba.bpf.point(amp_xp(1345.382), 0.) :
	ba.bpf.point(amp_xp(1526.105), 0.) :
	ba.bpf.point(amp_xp(1746.988), 0.) :
	ba.bpf.point(amp_xp(1827.309), 0.) :
	ba.bpf.point(amp_xp(2088.353), 0.) :
	ba.bpf.point(amp_xp(2188.755), 0.) : /* sustain point */
	ba.bpf.end(amp_xp(2510.040), 0.);

ampEnv = ampEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
amp_xp(x) = x * ma.SR / 1000. * ampEnv_speed;
ampEnv_speed = noteTrig : rdm(0,2000) : /(1000);

/* freq envelope */

freqEnvbpf =  ba.bpf.start(0, 0) :
	ba.bpf.point(freq_xp(147.751), 1.) :
	ba.bpf.point(freq_xp(193.213), 0.) :
	ba.bpf.point(freq_xp(318.233), yp) :
	ba.bpf.point(freq_xp(431.888), 0.) :
	ba.bpf.point(freq_xp(488.715), 0.434) :
	ba.bpf.point(freq_xp(613.735), yp) :
	ba.bpf.point(freq_xp(659.197), 1.) :
	ba.bpf.point(freq_xp(716.024), yp) :
	ba.bpf.point(freq_xp(806.948), 1.) :
	ba.bpf.point(freq_xp(829.679), yp) : /* sustain point */
	ba.bpf.end(freq_xp(943.333), 0.);

freqEnv = freqEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
freq_xp(x) = x * ma.SR / 1000. * freqEnv_speed;
freqEnv_speed = noteTrig : rdm(0,2000) : /(1000);
yp = noteTrig : rdm(0,1000) : /(1000);

/* harmRatio envelope */

harmEnvbpf = ba.bpf.start(0, 0.) :
	ba.bpf.point(harm_xp(863.454), 0.490) :
	ba.bpf.point(harm_xp(865), 0.) :
	ba.bpf.point (harm_xp(1305.221), 1.) :
	ba.bpf.point(harm_xp(1646.586), 0.) : /* sustain point */
	ba.bpf.end(harm_xp(1700), 0.);

harmEnv = harmEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
harm_xp(x) = x * ma.SR / 1000. * harmEnv_speed;
harmEnv_speed = noteTrig : rdm(0,2000) : /(1000);

/* modIndex envelope */

modIndexEnvbpf = ba.bpf.start(0, 0.) :
	ba.bpf.point(modIndex_xp(240.964), 0.554) :
	ba.bpf.point(modIndex_xp(502.068), 0.) : /* sustain point */
	ba.bpf.end(modIndex_xp(550), 0.);

modIndexEnv = modIndexEnvbpf : si.smooth(0.999) : fi.lowpass(1, 3000);
modIndex_xp(x) = x * ma.SR / 1000. * modIndexEnv_speed;
modIndexEnv_speed = noteTrig : rdm(0,2000) : /(1000);

// PANNER STEREO - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

panSte = _ <: -(1,_),_ : sqrt,sqrt;
rdmPanner = noteTrig : rdm(0,1000) : /(1000);

/* cable crosser = 1,3 & 2,4 */
panConnect = _,_,_,_ <: _,!,!,!,!,!,_,!,!,_,!,!,!,!,!,_;

// REVERB BASED OF ZITA - - - - - - - - - - - - - - - - - - - - - - - - - -

reverb(x,y) = re.zita_rev1_stereo(rdel,f1,f2,t60dc,t60m,fsmax,x,y)
	  : out_eq : dry_wet(x,y) : out_level
with {

  fsmax = 48000.0;  // highest sampling rate that will be used
  rdel = 60;
  f1 = 200;
  t60dc = 3;
  t60m = 2;
  f2 = 6000;
  out_eq = pareq_stereo(eq1f,eq1l,eq1q) : pareq_stereo(eq2f,eq2l,eq2q);

  pareq_stereo(eqf,eql,Q) = fi.peak_eq_rm(eql,eqf,tpbt), fi.peak_eq_rm(eql,eqf,tpbt)
  with {
    tpbt = wcT/sqrt(max(0,g)); // tan(ma.PI*B/ma.SR), B bw in Hz (Q^2 ~ g/4)
    wcT = 2*ma.PI*eqf/ma.SR;  // peak frequency in rad/sample
    g = ba.db2linear(eql); // peak gain
  };

  eq1f = 315;
  eq1l = 0;
  eq1q = 3;
  eq2f = 1500;
  eq2l = 0.0;
  eq2q = 3.0;

  //out_group(x)  = x; //fdn_group(hgroup("[5] Output", x));

  dry_wet(x,y) = *(wet) + dry*x, *(wet) + dry*y with {
    wet = 0.5*(drywet+1.0);
    dry = 1.0-wet;
  };

  presence = hslider("[3]Proximity (InstrReverb)[style:knob][midi:ctrl 15][acc:1 0 -15 0 10]", 0.5, 0, 1, 0.01) : si.smooth(0.999);

  drywet = 1 - 2*presence;
  out_level = *(gain),*(gain);

  //gain = vslider("[5]Reverberation Volume[unit:dB][style:knob]", -20, -70, 20, 0.1)
  gain = -10 : +(6*presence) : ba.db2linear : si.smooth(0.999);

};
