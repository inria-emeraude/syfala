import("stdfaust.lib");

counter = +(0.01) ~ _;
process = fmod(counter, 1) * 0.125 <: _,_;
