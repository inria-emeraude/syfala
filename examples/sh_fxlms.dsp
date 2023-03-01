declare name    "Spherical harmonics FxLMS algorithm";
declare version "1.0";
declare author  "Pierre Lecomte";
declare author  "Loic Alexandre";
declare license "CC-BY-NC-SA-4.0";

import("stdfaust.lib");
import("radial.lib");
import("ylm.lib");

// Tetramic encoder (Pierre Lecomte) ------------------------------------------------------

in_enc = 4; // Number of inputs
out_enc = 4; // Number of outputs
L = 1; // Ambisonic order

tetra(i,x) = case {
                (0) => ba.take(1, node(i)) * ma.PI/180;
                (1) => ba.take(2, node(i)) * ma.PI/180;
                (2) => weight(i);
             }(x)
             with {
                weight(i) = 1/4; // all nodes have the same weight
                node(0) = (0, 90);
                node(1) = (240, -19.471);
                node(2) = (120, -19.471);
                node(3) = (0, -19.471);
             };

row(i) = par(n, in_enc, yacn(i, tetra(n, 0), tetra(n, 1)) * tetra(n, 2));

matrix	=	par(i, out_enc, buswg(row(i)):>_);

encoder = si.bus(in_enc) <: matrix : par(l, L+1, par(m, 2*l+1, eqlr(l, L, 0.05, 20)));

//------------------------------------------------------------------------------------------

// SH-FxLMS Algorithm ----------------------------------------------------------------------

N = 2;
coeffs = si.bus(N);
in = 4;
out = 4;
in_out = si.bus(in*out);

freq_band = fi.bandpass(4,hslider("s:[0]Signal/s:[2]Noise/[2]Low frequency cut", 100,50,10000,1), hslider("s:[0]Signal/s:[2]Noise/[3]High frequency cut", 500,50,10000,1));
noise = (no.noise:freq_band)*hslider("s:[0]Signal/s:[2]Noise/[1]Volume" , 1,0,10,0.1);
sine_freq = hslider("s:[0]Signal/s:[1]Sine/[2]Frequency",300,50,10000,10);
sine = os.osc(sine_freq)*hslider("s:[0]Signal/s:[1]Sine/[1]Volume" , 0.5,0,10,0.1);
signal = (sine*checkbox("s:[0]Signal/s:[1]Sine/[0]On/Off"), noise*checkbox("s:[0]Signal/s:[2]Noise/[0]On/Off")):>_*(1-checkbox("s:[0]Signal/[0]Mute")); // Reference signal
x = (signal:_<:(_,_,_)); // Input signal

// Convergence coefficients
mu = -0.001*checkbox("a:[1]ANC/[0]On/Off");
lambda = 0.9;
delta = 1e-5;

reset = 1-button("a:[1]ANC/[1]reset");

// Adapted filters
filter_adapt(n) = (si.bus(n),(_<:(si.bus(n)))):ro.interleave(n,2):sum(i, n, (_,@(i):*));

H = (si.bus(in*out*N):par(i,in*N*out,_*reset)),(_<:par(i, in*out, _)):seq(i,in*out-1,si.bus(N*(i+1)+i), ro.crossn1(N*in*out-N*(i+1)), si.bus(in*out-(i+1))):par(i,in*out,((si.bus(N)<:si.bus(2*N)),_):(si.bus(N),filter_adapt(N))):seq(i,in*out-1, si.bus(N*in*out - (N*(i+1)) + out*in-(i+1)-1), ro.cross1n(N*(i+1)), si.bus(1+i)):(si.bus(in*out*N),par(i,out,si.bus(out):>_));

C11 = fi.fir((0.36824137335353946,0.1344698483063542));
C12 = fi.fir((0.49305379395471016,0.32224160966837667));
C13 = fi.fir((0.6137461681615921,0.3832431599216761));
C14 = fi.fir((0.7825273252978009,0.6203300900505291));
C21 = fi.fir((0.49305379395471016,0.32224160966837667));
C22 = fi.fir((0.6137461681615921,0.3832431599216761));
C23 = fi.fir((0.7825273252978009,0.6203300900505291));
C24 = fi.fir((0.21071454705409587,1.4008975865601723));
C31 = fi.fir((0.6137461681615921,0.3832431599216761));
C32 = fi.fir((0.7825273252978009,0.6203300900505291));
C33 = fi.fir((0.21071454705409587,1.4008975865601723));
C34 = fi.fir((0.30922917656286875,0.8529553144340982));
C41 = fi.fir((0.7825273252978009,0.6203300900505291));
C42 = fi.fir((0.21071454705409587,1.4008975865601723));
C43 = fi.fir((0.30922917656286875,0.8529553144340982));
C44 = fi.fir((0.15306151591169526,1.2462587339054818));


C_stack = C11, C12, C13, C14, C21, C22, C23, C24, C31, C32, C33, C34, C41, C42, C43, C44;

C_hat = _<:par(i,in*out,_):C_stack:par(i,out,encoder):par(i,in*out,buffer);

buffer = _<:par(i,N,@(i)); // To obtain x_n the reference signal at time n

norm2(n) = par(i,n,^(2)):>sqrt:_^(2);

E = par(i,in,_<:(_,_)):par(i,in,(((_':_^(2):_*(1-lambda)),(*(lambda))):>_));

LMS = ((par(i,in*out*N,_<:(_,_)):ro.interleave(2,N*out*in):(si.bus(N*out*in),norm2(in*out*N))), (par(i,in,_<:(_,_)):ro.interleave(2,in):(si.bus(in),E))):(si.bus(in*out*N), ro.cross1n(in), si.bus(in)):(si.bus(in*out*N),par(i,in,_*mu), (((_<:par(i,in,_)), si.bus(in)):ro.interleave(in,2):par(i,in,(_,_):>_):par(i,in,_+delta))):(si.bus(N*out*in),(ro.interleave(in,2):par(i,in,/))):(si.bus(in*out*N),par(i,in,_<:par(i,N*out,_))):(ro.interleave(N*in*out,2):par(i,in*out*N,*));

// 4 inputs / 6 outputs
// INPUTS : 4 microphones
// OUTPUTS : 4 Loudspeaker signals, 1 reference signal, 1 rms error signal

process = ((par(i,in*out,coeffs), x, encoder):(H,C_hat,(ro.cross1n(in):((par(i,in,_<:(_,_)):ro.interleave(2,in)),_))):(si.bus(N*in*out+out),LMS,(par(i,in,_):>_),_):(par(i,in*out,coeffs),ro.crossNM(out,in*out*N),_,_):((ro.interleave(in*N*out,2):par(i,in*out*N,+)),si.bus(out),_,_))~(par(i,in*out,coeffs)):(par(i,in*out*N,!),si.bus(out),ro.cross1n(1));

