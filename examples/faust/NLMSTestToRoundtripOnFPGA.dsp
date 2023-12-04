declare name    "Normalized Least Mean Square Algorithm for System Identification";
declare version "0.1";
declare author  "Niels Mortensen - Sonotronex AG";

import("stdfaust.lib");
N = 32; // FIR Filter Length // Q: Syfala doesn't work for bigger N's (like 64)...

Adaption = checkbox("Adaption on/off") ;
Reset = 1-button("Reset") ;
mu = nentry("mu",0.0001, 0.0000001, 1, 0.0000001)*Adaption ; // Q: Is there a logarithmic Slider ? 

Nbus = si.bus(N);
CoefsScope = par(i, N, hbargraph("",-5,5)); // Q: Is there a way to plot a vector on a plot ? With AutoScale ? 
TapDelay = _<:(_, par(i,N-1,@(i+1)));
SQNorm = (par(i, N, _^2):>_);

NLMSCoefficientsUpdater = _*mu, (Nbus<:Nbus, Nbus) : _, SQNorm, Nbus : (/<:Nbus), Nbus : ro.interleave(N, 2) : par(i, N, *) : (ro.interleave(N, 2):par(i, N, +))~( Nbus:par(i, N, *(Reset)) ): CoefsScope; // Or use SQNormedScope
// Inputs: ErrorSignal e, RefSignal x DlyChain // Q: Is there a way to add labels to inut and output signals paths that appear in generated Diagrams ? 
// Outputs: FIRCoefsNbus

LMSBlock = _, (TapDelay<:Nbus,Nbus) : NLMSCoefficientsUpdater, Nbus : ro.interleave(N, 2) : par(i, N, *) :>_;
// Inputs: ErrorSignal e, ReferenceSignal x
// Outputs: OutputSignal yhat

Excitation = no.noise:fi.resonlp(10000, .7, 1);

NLMS_toDeploy = _, _, (Excitation<:_,_) : (ro.cross(2):-), _, _ : LMSBlock, _ ;
// Inputs : yhat (Roundtrip From Output 1), y
// Outputs : yhat (to Roundtrip to input 1), ExcitationSignal x to send to system to identify.

process = NLMS_toDeploy; //NLMS_toDeploy~(_,_); // Use last commented statement to run in faust editor before deployement on FPGA.
