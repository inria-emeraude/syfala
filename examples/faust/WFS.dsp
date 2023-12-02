import("stdfaust.lib");

celerity = 343;

speakerArray(NC,SD,x,y) = par(i,NC,de.delay(ma.SR,d(i)))
with{
    d(j) = (x-(SD*j))^2 + y^2 : sqrt : /(celerity)*ma.SR;
};

speakerArraySpheric(NC,SD,x,y) = par(i,NC,de.delay(ma.SR,d(i)*(1/d(i))))
with{
    d(j) = (x-(SD*j))^2 + y^2 : sqrt : /(celerity)*ma.SR;
};

sourcesArray(NC,SD,s) = par(i,ba.count(s),ba.take(i+1,s) <: speakerArray(NC,SD,x(i),y(i))) :> par(i,NC,_)
with {
    x(p) = hslider("v: Source %p/x coordinate of source %p",SD*NC/2,0,SD*NC,0.01);
    y(p) = hslider("v: Source %p/y coordinate of source %p",10,1,20,0.01);
};

sourcesArraySpheric(NC,SD,s) = par(i,ba.count(s),ba.take(i+1,s) <: speakerArraySpheric(NC,SD,x(i),y(i))) :> par(i,NC,_)
with{
    x(p) = hslider("v: Source %p/x coordinate of source %p",SD*NC/2,0,SD*NC,0.01);
    y(p) = hslider("v: Source %p/y coordinate of source %p",10,1,20,0.01);
};

// ------------------ Implementation ----------------------------------

nSpeakers = 24;
speakersDist = 0.0783;

process = _,_ :> sourcesArray(nSpeakers,speakersDist,_) :> _,_;
