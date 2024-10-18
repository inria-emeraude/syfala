NZ = 1;      % number of ZEROS in the filter to be designed
NP = 4;      % number of POLES in the filter to be designed
NG = 10;     % number of gain measurements
fmin = 100;  % lowest measurement frequency (Hz)
fmax = 3000; % highest measurement frequency (Hz)
fs = 10000;  % discrete-time sampling rate
Nfft = 512;  % FFT size to use 
df = (fmax/fmin)^(1/(NG-1)); % uniform log-freq spacing
f = fmin * df .^ (0:NG-1);   % measurement frequency axis

% Gain measurements (synthetic example = triangular amp response):
Gdb = 10*[1:NG/2,NG/2:-1:1]/(NG/2); % between 0 and 10 dB gain

% Must decide on a dc value.
% Either use what is known to be true or pick something "maximally
% smooth".  Here we do a simple linear extrapolation:
dc_amp = Gdb(1) - f(1)*(Gdb(2)-Gdb(1))/(f(2)-f(1));

% Must also decide on a value at half the sampling rate.
% Use either a realistic estimate or something "maximally smooth".
% Here we do a simple linear extrapolation. While zeroing it
% is appealing, we do not want any zeros on the unit circle here.
Gdb_last_slope = (Gdb(NG) - Gdb(NG-1)) / (f(NG) - f(NG-1));
nyq_amp = Gdb(NG) + Gdb_last_slope * (fs/2 - f(NG));

Gdbe = [dc_amp, Gdb, nyq_amp]; 
fe = [0,f,fs/2];
NGe = NG+2;

% Resample to a uniform frequency grid, as required by ifft.
% We do this by fitting cubic splines evaluated on the fft grid:
Gdbei = spline(fe,Gdbe); % say `help spline'
fk = fs*[0:Nfft/2]/Nfft; % fft frequency grid (nonneg freqs)
Gdbfk = ppval(Gdbei,fk); % Uniformly resampled amp-resp

figure(1);
semilogx(fk(2:end-1),Gdbfk(2:end-1),'-k'); grid('on'); 
axis([fmin/2 fmax*2 -3 11]);
hold('on'); semilogx(f,Gdb,'ok');
xlabel('Frequency (Hz)');   ylabel('Magnitude (dB)');
title(['Measured and Extrapolated/Interpolated/Resampled ',...
       'Amplitude Response']);

Ns = length(Gdbfk); if Ns~=Nfft/2+1, error("confusion"); end
Sdb = [Gdbfk,Gdbfk(Ns-1:-1:2)]; % install negative-frequencies

S = 10 .^ (Sdb/20); % convert to linear magnitude
s = ifft(S); % desired impulse response
s = real(s); % any imaginary part is quantization noise
tlerr = 100*norm(s(round(0.9*Ns:1.1*Ns)))/norm(s);
disp(sprintf(['Time-limitedness check: Outer 20%% of impulse ' ...
              'response is %0.2f %% of total rms'],tlerr));
% = 0.02 percent
if tlerr>1.0 % arbitrarily set 1% as the upper limit allowed
  error('Increase Nfft and/or smooth Sdb');
end

figure(2);
plot(s, '-k'); grid('on');   title('Impulse Response');
xlabel('Time (samples)');   ylabel('Amplitude');

c = ifft(Sdb); % compute real cepstrum from log magnitude spectrum
% Check aliasing of cepstrum (in theory there is always some):
caliaserr = 100*norm(c(round(Ns*0.9:Ns*1.1)))/norm(c);
disp(sprintf(['Cepstral time-aliasing check: Outer 20%% of ' ...
    'cepstrum holds %0.2f %% of total rms'],caliaserr));
% = 0.09 percent
if caliaserr>1.0 % arbitrary limit
  error('Increase Nfft and/or smooth Sdb to shorten cepstrum');
end
% Fold cepstrum to reflect non-min-phase zeros inside unit circle:
% If complex:
% cf = [c(1), c(2:Ns-1)+conj(c(Nfft:-1:Ns+1)), c(Ns), zeros(1,Nfft-Ns)];
cf = [c(1), c(2:Ns-1)+c(Nfft:-1:Ns+1), c(Ns), zeros(1,Nfft-Ns)];
Cf = fft(cf); % = dB_magnitude + j * minimum_phase
Smp = 10 .^ (Cf/20); % minimum-phase spectrum

Smpp = Smp(1:Ns); % nonnegative-frequency portion
wt = 1 ./ (fk+1); % typical weight fn for audio
wk = 2*pi*fk/fs;
[B,A] = invfreqz(Smpp,wk,NZ,NP,wt);
Hh = freqz(B,A,Ns);

figure(3);
plot(fk,db([Smpp(:),Hh(:)])); grid('on');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Frequency Response');
legend('Desired','Filter');