import("stdfaust.lib");
freq = 440;
gate=button("gate");
delay=hslider("delay", 128, 0, 200, 1);
gain=hslider("gain", 0.98, -0.98, 0.98, 0.01);
nlf2(f,r,x) = ((_<:_,_),(_<:_,_+(cond2*delay*gain)) : (*(cond*s),*(c),*(c),*(0-s)) :>
              (*(r),+(x))) ~ cross
with {
     cond = (gate==1)|(gate==0);//|(delay==128) | (gain = 0.98);
     cond2 = (gate==1)&(gate==0);//|(delay==128) | (gain = 0.98);
  //
  //th = 2*ma.PI*f/ma.SR; 
  // with ma.SR=48000
  th = 5.75958653158129e-02 * cond;
  //c = cos(th);		
  c = 9.98341816614028e-01;
  //s = sin(th);
  s= 5.75640269595673e-02;
  cross = _,_ <: !,_,_,!;
};

impulse = 1-1';
process =  impulse : nlf2(freq,1) : !,_  <: _,_;
