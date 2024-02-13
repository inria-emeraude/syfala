// lecomteOrigWFS.dsp
// WFS implementation by Pierre Lecomte

import("stdfaust.lib");
declare version     "1.0";
declare author      "Pierre Lecomte";
declare license     "CC-BY-NC-SA-4.0";
declare copyright   "(c) Pierre Lecomte 2022"; 

c = 340; // sound speed

// sqrt(i w) filter
b0 = 1;
b1 = -0.8715;
b2 = 0.0412;

a1 = -0.31134;
a2 = -0.088955;

filter = fi.tf2(b0,b1,b2, a1, a2) * sqrt(2 * ma.PI / c);


// reference point
xref = 0;
yref = 0;
zref = 0;

// source position
xs = vslider("xs", 0, -10, 10, 0.1) ;
ys = vslider("ys", 1.5,  1.5, 10, 0.1) ;
zs = vslider("zs", 0, -10, 10, 0.1) ;

rmax = sqrt(3) * 10;

// norm
norm(x1, y1, z1, x2, y2, z2) = sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2);

// Delay
ddelay(rmax, r)  = de.delay(rmax / c * ma.SR, r / c * ma.SR);

// Driving function
driving(xs, ys, zs, x, y, z) = _: filter * norm(xref, yref, zref, x, y, z) * ys / r^2 : ddelay(rmax, r)
                                    with {
                                    r = norm(xs, ys, zs, x, y, z) ; 
                                    };

process = 1-1':hgroup("WFS", driving(xs, ys, zs, 0, 1, 0));
