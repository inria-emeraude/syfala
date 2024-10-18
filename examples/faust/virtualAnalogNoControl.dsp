import("stdfaust.lib");
// sliders
//oscFreq = hslider("oscFreq [knob:1]",80,50,500,0.01);
//lfoFreq = hslider("lfoFreq [knob:2]",1,0.01,8,0.01);
//lfoRange = hslider("lfoRange [knob:3]",1000,10,5000,0.01) : si.smoo;
//noiseGain = hslider("noiseGain [slider:7]",0,0,1,0.01) <: _*_;
//masterVol = hslider("masterVol [slider:8]",0.8,0,1,0.01) <: _*_;
//panning = hslider("pan [knob:4]",0.5,0,1,0.01)  : si.smoo;

oscFreq = 80;
lfoFreq = 1;
lfoRange = 1000;
noiseGain = 0 <: _*_;
masterVol = 0.8 <: _*_;
panning = 0.5;
// buttons
activateNoise = 0;
killSwitch = 1;

LFO = os.lf_triangle(lfoFreq)*0.5 + 0.5;
process = os.oscrc(440)* 0.25 * killSwitch * os.sawtooth(oscFreq) + no.noise*noiseGain*activateNoise : fi.resonlp(LFO*lfoRange+50,5,1)*masterVol <: _*(1-panning),_*panning;
