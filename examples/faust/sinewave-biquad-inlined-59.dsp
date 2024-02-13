
freq = 59;
nlf2(f,r,x) = ((_<:_,_),(_<:_,_) : (*(s),*(c),*(c),*(0-s)) :>
              (*(r),+(x))) ~ cross
with {
  //th = 2*ma.PI*f/ma.SR;
  // with ma.SR=48000
  th = 0.007723082;
  //c = cos(th);
  c = 0.9999701772;
  //s = sin(th);
  s= 0.0077230052;
  cross = _,_ <: !,_,_,!;
};

impulse = 1-1';
process =  impulse : nlf2(freq,1) : !,_  <: _,_;  
