
freq = 440;
nlf2(f,r,x) = ((_<:_,_),(_<:_,_) : (*(s),*(c),*(c),*(0-s)) :>
              (*(r),+(x))) ~ cross
with {
  //th = 2*ma.PI*f/ma.SR;
  // with ma.SR=48000
  th = 5.75958653158129e-02;
  //c = cos(th);
  c = 9.98341816614028e-01;
  //s = sin(th);
  s= 5.75640269595673e-02;
  cross = _,_ <: !,_,_,!;
};
vol = hslider("volume [unit:dB]", 1, 0, 1, 0.1);

impulse = 1-1';
process =  impulse : nlf2(freq,1) : !,_  <: _*vol,_*vol;
