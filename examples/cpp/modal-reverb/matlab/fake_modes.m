%% Mode Generator 
% Simple program generating mode series parameters.
% Mode values are to be used with biquad filters in parallel.

fs = 48000;
t60 = 15;
nModes = 10000;
dur = 10;

f = (1:nModes)*2+500;
w = 2*pi*f/fs;
r = 0.001^(1/(t60*fs));
a1 = -2*r*cos(w);
a2 = r^2;

fileID = fopen('coefs.h','w');
fprintf(fileID,'float a2 = %.32ff;\n\n',a2);
fprintf(fileID,'float a1[%d] = {',nModes);
fprintf(fileID,'%.32ff,\n',a1(1:(nModes-1)));
fprintf(fileID,'%.32ff};\n',a1(nModes));
fclose(fileID);

%% Simulate Modes

b0 = 1.0;
b1 = 0.0;
b2 = -1.0;
durS = fs*dur;
ex = zeros(1,durS);
y = zeros(1,durS);
ex(1) = 1;
w = zeros(nModes,3);

for i = 1:durS
    for j = 1:nModes
        w(j,1) = ex(i) - a1(j)*w(j,2) - a2*w(j,3);
        y(i) = y(i) + b0*w(j,1) + b1*w(j,2) + b2*w(j,3);
        w(j,3) = w(j,2);
        w(j,2) = w(j,1);
    end
    y(i) = y(i)/nModes;
end

%plot(y(1:100000))
