// echo.dsp

import("stdfaust.lib");

stereoEcho = par(i, 2, echo(delay, fback)) 
with {
  echo(d,f) = + ~ (de.delay(30000,d) : *(f));
  delay = hslider("delay [knob:1]", 22500, 1, 30000, 1) - 1 : si.smoo;
  fback = hslider("feedback [knob:2]", 0.7, 0, 0.99, 0.01);
};

process = stereoEcho;
