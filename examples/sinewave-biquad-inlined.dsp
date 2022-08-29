import("stdfaust.lib");

freq = hslider("freq",440,50,1000,0.01);
nlf2(f,r,x) = ((_<:_,_),(_<:_,_) : (*(s),*(c),*(c),*(0-s)) :>
              (*(r),+(x))) ~ cross
with {
  th = 2*ma.PI*f/ma.SR;
  c = cos(th);
  s = sin(th);
  cross = _,_ <: !,_,_,!;
};


impulse = 1-1';
process =  impulse : nlf2(freq,1) : !,_  <: _,_;  
