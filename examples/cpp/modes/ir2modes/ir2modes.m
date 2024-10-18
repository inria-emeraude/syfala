[ir,Fs] = audioread("sdf.wav");
N = length(ir);
N2 = round(N/2+1);
order = 1000;

IR = fft(ir);
IRmp = 10 .^ (IR/20); % minimum-phase spectrum
IRmp = IRmp(1:N2); % nonnegative-frequency portion
wk = pi*(1:N2)/(N2);

[b,a] = invfreqz(IRmp,wk,order+1,order);

[h,w] = freqz(b,a,N2);

% plot(wk,db([Ymp(:),h(:)]))

% Impulse
dur = 3; % seconds
durS = dur*Fs; % samples
imp = zeros(1,durS);
imp(1) = 1;

fImp = filter(b,a,imp);
plot(fImp);

% sound(fImp,Fs);

[sos,g] = tf2sos(b,a);
% 
% fileID = fopen('coefs.lib','w');
% fprintf(fileID,'b0 = (');
% fprintf(fileID,'%.16f,',sos((1:20),1));
% fprintf(fileID,');\n');
% fprintf(fileID,'b1 = (');
% fprintf(fileID,'%.16f,',sos((1:20),2));
% fprintf(fileID,');\n');
% fprintf(fileID,'b2 = (');
% fprintf(fileID,'%.16f,',sos((1:20),3));
% fprintf(fileID,');\n');
% fprintf(fileID,'a1 = (');
% fprintf(fileID,'%.16f,',sos((1:20),5));
% fprintf(fileID,');\n');
% fprintf(fileID,'a2 = (');
% fprintf(fileID,'%.16f,',sos((1:20),6));
% fprintf(fileID,');\n');
% fclose(fileID);

% P2 = abs(Y/N);
% P1 = P2(1:N/2+1);
% 
% f = Fs/N*(0:(N/2));
% %plot(f,P1) 
% %plot(P1)