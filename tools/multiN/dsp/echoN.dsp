import ("stdfaust.lib");

N = 48;
process = _ <: par(i, N, ef.echo(1, 0.06 + i/100, 0.90)) :> _,_;
