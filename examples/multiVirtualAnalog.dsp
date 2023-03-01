import("stdfaust.lib");
// sliders
oscFreq = hslider("oscFreq [knob:1]",80,50,500,0.01);
lfoFreq = hslider("lfoFreq [knob:2]",1,0.01,8,0.01);
lfoRange = hslider("lfoRange [knob:3]",1000,10,5000,0.01) : si.smoo;
noiseGain = hslider("noiseGain [slider:7]",0,0,1,0.01) <: _*_;
// buttons
activateNoise = button("activateNoise [switch:6]");
killSwitch = 1-button("killSwitch [switch:5]");

// multi volume
vol0 = hslider("Volume ch00",0.8,0,1,0.01);
vol1 = hslider("Volume ch01",0.8,0,1,0.01);
vol2 = hslider("Volume ch02",0.8,0,1,0.01);
vol3 = hslider("Volume ch03",0.8,0,1,0.01);
vol4 = hslider("Volume ch04",0.8,0,1,0.01);
vol5 = hslider("Volume ch05",0.8,0,1,0.01);
vol6 = hslider("Volume ch06",0.8,0,1,0.01);
vol7 = hslider("Volume ch07",0.8,0,1,0.01);
vol8 = hslider("Volume ch08",0.8,0,1,0.01);
vol9 = hslider("Volume ch09",0.8,0,1,0.01);
vol10 = hslider("Volume ch10",0.8,0,1,0.01);
vol11 = hslider("Volume ch11",0.8,0,1,0.01);
vol12 = hslider("Volume ch12",0.8,0,1,0.01);
vol13 = hslider("Volume ch13",0.8,0,1,0.01);
vol14 = hslider("Volume ch14",0.8,0,1,0.01);
vol15 = hslider("Volume ch15",0.8,0,1,0.01);
vol16 = hslider("Volume ch16",0.8,0,1,0.01);
vol17 = hslider("Volume ch17",0.8,0,1,0.01);
vol18 = hslider("Volume ch18",0.8,0,1,0.01);
vol19 = hslider("Volume ch19",0.8,0,1,0.01);
vol20 = hslider("Volume ch20",0.8,0,1,0.01);
vol21 = hslider("Volume ch21",0.8,0,1,0.01);
vol22 = hslider("Volume ch22",0.8,0,1,0.01);
vol23 = hslider("Volume ch23",0.8,0,1,0.01);
vol24 = hslider("Volume ch24",0.8,0,1,0.01);
vol25 = hslider("Volume ch25",0.8,0,1,0.01);
vol26 = hslider("Volume ch26",0.8,0,1,0.01);
vol27 = hslider("Volume ch27",0.8,0,1,0.01);
vol28 = hslider("Volume ch28",0.8,0,1,0.01);
vol29 = hslider("Volume ch29",0.8,0,1,0.01);
vol30 = hslider("Volume ch30",0.8,0,1,0.01);
vol31 = hslider("Volume ch31",0.8,0,1,0.01);

LFO = os.lf_triangle(lfoFreq)*0.5 + 0.5;
process = os.oscrc(440)* 0.25 * killSwitch * os.sawtooth(oscFreq) + no.noise*noiseGain*activateNoise : fi.resonlp(LFO*lfoRange+50,5,1) <:_*vol0,_*vol1,_*vol2,_*vol3,_*vol4,_*vol5,_*vol6,_*vol7,_*vol8,_*vol9,_*vol10,_*vol11,_*vol12,_*vol13,_*vol14,_*vol15,_*vol16,_*vol17,_*vol18,_*vol19,_*vol20,_*vol21,_*vol22,_*vol23,_*vol24,_*vol25,_*vol26,_*vol27,_*vol28,_*vol29,_*vol30,_*vol31;
