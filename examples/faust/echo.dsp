// echo.dsp

stereoEcho = par(i, 2, echo(delay, fback)) 
with {
  echo(d,f) = + ~ (@(d) : *(f));
  delay = hslider("delay [knob:1]", 22500, 1, 30000, 1) - 1;
  fback = hslider("feedback [knob:2]", 0.7, 0, 0.99, 0.01);
};

process = stereoEcho;
