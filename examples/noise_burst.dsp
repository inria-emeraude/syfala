import ("stdfaust.lib");

counter = +(1)~_ % ma.SR;
burst(count) = count <= ma.SR/2;
bgraph = attach(_,abs : ba.linear2db : vbargraph("Level",-60,0));
process = no.pink_noise * burst(counter) * 0.250 <: bgraph <: _,_;
