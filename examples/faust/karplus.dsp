import("stdfaust.lib");

// Karplus Strong (1/2)
process = ba.pulse(10000) :
        + ~ transformation;

transformation = @(hslider("delay", 128, 0, 200, 1)) : moyenne : *(hslider("gain", 0.98, -0.98, 0.98, 0.01));

moyenne(x) = (x+x')/2;