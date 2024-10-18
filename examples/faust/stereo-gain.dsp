import("stdfaust.lib");

gain = hslider("gain", 1, 0, 2, 0.01);
process = *(gain), *(gain);
