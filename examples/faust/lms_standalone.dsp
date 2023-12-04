declare name    "Least Mean Square Algorithm";
declare version "1.0";
declare author  "Pierre Lecomte";
declare author  "Loic Alexandre";
declare license "CC-BY-NC-SA-4.0";

import("stdfaust.lib");

N = 30; // Number of coefficients
coeffs = si.bus(N);

h = fi.fir((1,2,3,4,5)); // target filter
y = _:h; // Output signal from target system

h_hat(N) = (si.bus(N),(_<:(si.bus(N)))):ro.interleave(N,2):sum(i, N, (_,@(i):*)); // Adapted filter
y_hat(N) = ((si.bus(N)<:si.bus(2*N)),_):(si.bus(N),h_hat(N)); // Output signal from adapted system

buffer = _<:par(i,N,@(i)); // To obtain x_n, the reference signal at time n

signal = no.noise; // Reference signal
x = (signal:_<:(_,_,_));

mu = -0.0001; // Convergence coefficient (smaller for slower convergence)

// No input
// Output 0 = error signal (y - y_hat)

process = ((coeffs,x):(y_hat(N),y,_):(coeffs,(-<:(_,_*mu)),buffer):(coeffs,_,(_<:si.bus(N)),coeffs):(coeffs,_,ro.interleave(N,2)):(coeffs,_,par(i,N,*)):(coeffs,ro.cross1n(N)):(ro.interleave(N,2),_):(par(i,N,+),_))~si.bus(N):(par(i,N,!),_);
