import("stdfaust.lib");

process = generators : vcf * env <: echoes;

master = hslider("master_volume", 0.125, 0, 1, 0.001) * 0.125;

oscillators = par(i, 2, osc(osc_fratio(i), i+1) * osc_amp(i)) :> _;
generators = oscillators;

f_echo(i) = ef.echo(0.5, 0.1+i*0.1, 0.75);
echoes = par(i, 2, f_echo(i));

wselect(i)    = hslider("wselect_%i", i, 1, 2, 1) : int;
osc_fratio(i) = hslider("osc_fratio_%i", 1, 1, 10, 1) * 220 + 110;
osc_amp(i)    = hslider("osc_amp_%i", 0.04, 0, 1, 0.01);

//osc(f,i) = ba.selectn(3, wselect(i), tri(f), saw(f), sqr(f));
osc(f,i) = ba.selectn(2, wselect(i), saw(f), sqr(f));
//tri(f) = os.triangle(f);
saw(f) = os.sawtooth(f);
sqr(f) = os.square(f);

noise_amp = hslider("noise_amp", 0, 0, 1, 0.01) * 0.125;
noise_sel = hslider("noise_sel", 0, 0, 1, 1) : int;
noise     = select2(noise_sel, no.noise * 0.125, no.pink_noise) * noise_amp;

vcf_res   = hslider("vcf_res", 0, 0, 1, 0.01);
vcf_freq  = hslider("vcf_freq [unit:Log2(Hz)]", 10.6, log(40.0)/log(2), log(20000.0)/log(2), 0.000001) : si.smoo;
fc = min((0.5*ma.SR), pow(2.0, vcf_freq));
vcf = ve.moog_vcf(vcf_res, fc);

env_attack  = vslider("attack", 1400, 10, 10000, 1) * 0.001;
env_decay   = vslider("decay", 10, 10, 10000, 1) * 0.001;
env_sustain = vslider("sustain", 80, 0, 100, 0.1) * 0.01;
env_release = 1;
env_trigger = button("env_trigger");

env = en.adsr(env_attack, env_decay, env_sustain, env_release, env_trigger);



