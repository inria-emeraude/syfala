import("stdfaust.lib");

reson(d) = +~(@(d):mean);
mean = *(0.498) <: _, mem :> _;

preson(N, d1, d2) = _ <: par(i, N, reson(d1+(d2-d1)*i/(N-1)));

panner (fx) = fx : par(i, N, pan(i/(N-1))) :> _,_ 
	with { 
		N = outputs(fx); 
		pan(p) = _ <: *(sqrt(1-p)), *(sqrt(p)); 
	};

enhancer(fx) = fx : par(i, N, *(1+g*prox(i,p*(N-1))))
	with {
		N = outputs(fx);
		g = hslider("gain", 0, 0, 5, 0.01);
		p = hslider("pos", 0, 0, 1, 0.01);
		prox(x,y) = 1 - min(1,abs(x-y));
	};


echo = par(i,2, +~(@(ma.SR*4):*(hslider("feedback", 0.75,0,1,0.01))));	// <- Here

lfo(n) = hgroup("LFO %n",  osc(freq) : *(gain) : +(1)) 
    with {
        // user interface
        freq = vslider("freq[style:knob][unit:Hz][scale:log]", 1, 0.1, 40, 0.1);
        gain = vslider("gain[style:knob]", 0, 0, 1, 0.01);
        // sinewave oscillator
        osc(f) = f/ma.SR : (+,1:fmod) ~ _ : *(2*ma.PI) : sin;
    };

process = no.noise * lfo(1) * hslider("noise", 0, 0, 1, 0.01) 
		: panner(enhancer(preson(4, 400, 80))) 
		: echo			// <- Here
		: co.limiter_1176_R4_stereo;



