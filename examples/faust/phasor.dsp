import("stdfaust.lib");

accumulator = fmod(+(440 / 48000), 1.0) ~ _;
process = accumulator / 8.0 <: _,_;
