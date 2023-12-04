import("stdfaust.lib");
declare options "[osc:on]";
declare options "[midi:on]";

// sliders
oscFreq = hslider("oscFreq [midi:ctrl 79]",80,50,500,0.01);
lfoFreq = hslider("lfoFreq [midi:ctrl 77]",1,0.01,8,0.01);
lfoRange = hslider("lfoRange [midi:ctrl 78]",1000,10,5000,0.01) : si.smoo;
noiseGain = hslider("noiseGain [midi:ctrl 80]",0,0,1,0.01) <: _*_;
masterVol = hslider("masterVol [midi:ctrl 81]",0.8,0,1,0.01) <: _*_;
panning = hslider("pan [midi:ctrl 49]",0.5,0,1,0.01)  : si.smoo;
// buttons
activateNoise = button("activateNoise [midi:ctrl 19]");
killSwitch = 1-button("killSwitch [midi:ctrl 20]");

LFO = os.lf_triangle(lfoFreq)*0.5 + 0.5;
process = os.oscrc(440)* 0.25 * killSwitch * os.sawtooth(oscFreq) + no.noise*noiseGain*activateNoise : fi.resonlp(LFO*lfoRange+50,5,1)*masterVol <: _*(1-panning),_*panning;

