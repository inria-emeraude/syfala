import("stdfaust.lib");

dist = par(i, 2, ef.cubicnl(0.8,5)) : *(0.125),*(0.125);
bypass = _,_;
process = bypass,dist;

