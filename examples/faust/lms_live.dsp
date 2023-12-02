declare name    "Least Mean Square Algorithm";
declare version "1.0";
declare author  "Pierre Lecomte";
declare author  "Loic Alexandre";
declare license "CC-BY-NC-SA-4.0";

import("stdfaust.lib");

N = 5; // Number of coefficients (should be >= 200 to identify a system with narrow frequency band)
coeffs = si.bus(N);

y = _; // y = x*[room impulse response]
h_hat(N) = (si.bus(N),(_<:(si.bus(N)))):ro.interleave(N,2):sum(i, N, (_,@(i):*)); // Adapted filter
y_hat(N) = ((si.bus(N)<:si.bus(2*N)),_):(si.bus(N),h_hat(N)); // Output from the adapted system 

buffer = _<:par(i,N,@(i)); // To obtain x_n, the reference signal at time n
filter_freq = fi.lowpass(4,800); // Lowpass filter for frequency band reduction
signal = no.noise; // Excitation signal
x = (signal:_<:(_,_,_)); // Reference signal
in = _,x:ro.crossn1(3); // Inputs including the external microphone signal and the reference signal
mu = -0.0001; // Convergence coefficient (smaller for slower convergence)

// Input = microphone signal whichcorresponds to the target system ouput y
// Output 0 = x (white noise signal)
// Output 1 = error signal (y - y_hat)

process = ((coeffs,in):(y_hat(N),y,_,_):(coeffs,(-<:(_,_*mu)),buffer,_):(coeffs,_,(_<:si.bus(N)),coeffs,_):(coeffs,_,ro.interleave(N,2),_):(coeffs,_,par(i,N,*),_):(coeffs,ro.cross1n(N),_):(ro.interleave(N,2),_,_):(par(i,N,+),_,_))~si.bus(N):(par(i,N,!),ro.cross(2));

