%% Convolution Fun and Testing...
% Some useful resources:
% https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/convolution.html
% https://github.com/sjfloat/jconvolver/tree/master/source
% https://github.com/zamaudio/zam-plugins/blob/master/lib/zita-convolver-4.0.0/zita-convolver.cpp
%

x=[1,3,5,7,9]; 
h=[5,4,3,2,1];

m=length(x);
n=length(h);

X=[x,zeros(1,n)]; 
H=[h,zeros(1,m)]; 

for i=1:n+m-1
    Y(i)=0;
    for j=1:m
        if(i-j+1>0)
            Y(i)=Y(i)+X(i-j+1)*H(j);
        else
        end
    end
end

Y
