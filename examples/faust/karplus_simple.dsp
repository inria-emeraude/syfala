import("stdfaust.lib");

// Karplus Strong (1/2)
process = ba.pulse(20) :
        + ~ transformation <: _,_;

transformation = @(5) : moyenne;

moyenne(x) = (x+x')/2;
