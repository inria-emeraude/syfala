%% Modal extraction from impulse response
%
% This script generates a c++ header file (coefs.h) for modes_multisample.cpp.
% It requires Orchisama Das' amazing modal estimation toolbox:
% https://github.com/orchidas/Modal-estimation/tree/main
% 
% Additional resources:
% https://github.com/Esgrove/modalreverb
% https://www.aes.org/e-lib/browse.cfm?elib=17531
% https://www.semanticscholar.org/reader/1309b92894e8e70dbbe6ff71ba233c5a2cd502aa

%% Running mode extraction on every channel of IR

[rir, fs] = audioread('sdf.wav');
max_length = 82000; % max IR length in samples (somehow values higher than 82000 don't seem to work)
r = 64;  % downsampling factor
gain_scaling = 3; % scaling factor of coefs to adjust gain of biquads

chans = width(rir);
mode_ir = [];
mode_max = 1;
mode_params = [];

for c = 1:chans
    [p, rirhat] = frequency_zoomed_modal(rir(1:max_length,c),fs,[],r,0,1);

    if c == 1 | mode_max > length(p(:,3))
        mode_max = length(p(:,3));
    end

    if c == 1
        mode_params = p;
    else
        mode_params = [p(1:mode_max,:),mode_params(1:mode_max,:)];
    end

    mode_ir = [mode_ir,rirhat];
end
 
% hear results
soundsc(rir,fs);pause(2);
soundsc(mode_ir,fs);

%% Converting to poles and zeros and writing down to coefs.h

for c = 1:chans
    v = (c-1)*3;
    b0(:,c) = real(mode_params(:,3+v))/gain_scaling;
    b1(:,c) = -mode_params(:,2+v).*real(mode_params(:,3+v).*exp(-2*1j*pi*mode_params(:,1+v) / fs))/gain_scaling;
    a1(:,c) = -2*mode_params(:,2+v) .* cos(2*pi*mode_params(:,1+v) / fs);
    a2(:,c) = mode_params(:,2+v).^2;
end

fileID = fopen('../coefs.h','w');
fprintf(fileID,'#define NCHANS %d\n',chans);
fprintf(fileID,'#define NMODES %d\n\n',mode_max);
fprintf(fileID,'float b0[NCHANS][NMODES] = {');
for c = 1:chans
    fprintf(fileID,'{');
    fprintf(fileID,'%.16ff,',b0(1:(mode_max-1),c));
    fprintf(fileID,'%.16ff}',b0(mode_max,c));
    if c == chans
        fprintf(fileID,'};\n\n');
    else
        fprintf(fileID,',\n');
    end
end
fprintf(fileID,'float b1[NCHANS][NMODES] = {');
for c = 1:chans
    fprintf(fileID,'{');
    fprintf(fileID,'%.16ff,',b1(1:(mode_max-1),c));
    fprintf(fileID,'%.16ff}',b1(mode_max,c));
    if c == chans
        fprintf(fileID,'};\n\n');
    else
        fprintf(fileID,',\n');
    end
end
fprintf(fileID,'float a1[NCHANS][NMODES] = {');
for c = 1:chans
    fprintf(fileID,'{');
    fprintf(fileID,'%.16ff,',a1(1:(mode_max-1),c));
    fprintf(fileID,'%.16ff}',a1(mode_max,c));
    if c == chans
        fprintf(fileID,'};\n\n');
    else
        fprintf(fileID,',\n');
    end
end
fprintf(fileID,'float a2[NCHANS][NMODES] = {');
for c = 1:chans
    fprintf(fileID,'{');
    fprintf(fileID,'%.16ff,',a2(1:(mode_max-1),c));
    fprintf(fileID,'%.16ff}',a2(mode_max,c));
    if c == chans
        fprintf(fileID,'};\n\n');
    else
        fprintf(fileID,',\n');
    end
end
fclose(fileID);

%% IR Resynthesis With Biquads

dur = 5*fs;
imp = zeros(1,dur);
imp(1) = 1;
% imp = rand(1,dur)*2-1;
w = zeros(1,mode_max);
w1 = zeros(1,mode_max);
w2 = zeros(1,mode_max);
y = zeros(1,dur);
x1 = zeros(1,dur);
x2 = zeros(1,dur);

% direct form 2
current_chan = 1;
for i = 1:mode_max
    for n = 1:dur
        w(i) = imp(n) - w1(i)*a1(i,current_chan) - w2(i)*a2(i,current_chan);
        y(n) = y(n) + b0(i,current_chan)*w(i) + b1(i,current_chan)*w1(i);
        w2(i) = w1(i);
        w1(i) = w(i);
    end
end

% % direct form 1
% for i = 1:nModes
%     for n = 1:dur
%         yy = b0(i)*imp(n) + b1(i)*x1(i) - a1(i)*w1(i) - a2(i)*w2(i);
%         x1(i) = x2(i);
%         x1(i) = imp(n);
%         w2(i) = w1(i);
%         w1(i) = yy;
%         y(n) = y(n) + yy;
%     end
% end

soundsc(y,fs)

