SR = 1250000;
import("stdfaust.lib");

set = hslider("Frequency", 440, 20, 10000, 0.1);

phasor(freq) = (+(freq / SR) ~ ma.frac);
osc(freq) = sin(phasor(freq) * 2 * ma.PI);
process = osc(set)*0.5;
