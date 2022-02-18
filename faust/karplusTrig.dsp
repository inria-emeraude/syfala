import("stdfaust.lib");

// Karplus Strong (1/2)
process = (button("gate")'==0)&(button("gate")==1) :
        + ~ transformation;
        
transformation = @(hslider("delay", 128, 0, 200, 1)) : moyenne : *(hslider("gain", 0.98, -0.98, 0.98, 0.01));

moyenne(x) = (x+x')/2;

