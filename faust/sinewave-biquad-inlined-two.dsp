
freq440(r,x) = ((_<:_,_),(_<:_,_) : (*(s),*(c),*(c),*(0-s)) :>
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

freq105(r,x) = ((_<:_,_),(_<:_,_) : (*(s),*(c),*(c),*(0-s)) :>
              (*(r),+(x))) ~ cross
with {
  //th = 2*ma.PI*f/ma.SR;
  // with ma.SR=48000
  th = 0.013744468;
  //c = cos(th);
  c = 0.9999055463;
  //s = sin(th);
  s= 0.01374403526;
  cross = _,_ <: !,_,_,!;
};

impulse = 1-1';
process =  impulse :_<: (freq105(1),freq440(1)): !,_,_,!  ;
