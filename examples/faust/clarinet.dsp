import("stdfaust.lib");

maxLength = 2;

notesPerMin = hslider("notesPerMin",1,0.1,2,0.01);

openTube(maxLength,length) = pm.waveguideUd(nMax,n)
with{
    nMax = maxLength : pm.l2s;
    n = length : pm.l2s/2;
};

clarinetModel(tubeLength,pressure,reedStiffness,bellOpening) = pm.endChain(modelChain)
with{
	maxTubeLength = maxLength;
	tunedLength = tubeLength/2;
	modelChain =
		pm.chain(
			pm.clarinetMouthPiece(reedStiffness,pressure) :
			openTube(maxTubeLength,tunedLength) :
			pm.wBell(bellOpening) : pm.out
		);
};

playClarinet(NPM) = timer <: ((_==1),((no.noise+1.4)*0.8) : ba.sAndH),(_ < (maxCycle*0.8)  : en.asre(0.2,0.8,0.2))
with{
    maxCycle = NPM*ma.SR;
    timer = _~+(1)%(maxCycle);
};

process = playClarinet(notesPerMin),0.5,0.5 : clarinetModel;
