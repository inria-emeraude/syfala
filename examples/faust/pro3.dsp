import("stdfaust.lib");
declare options "[midi:on]";

// ----------------------------------------------------------------------------
// Keys (LaunchControl Pads)
// ----------------------------------------------------------------------------
keys_base = 47;
keys_N = 16;

keys = (
    // Bottom-left pads (1-to-4)
    checkbox("n1  [midi:key 73][hidden:1]"),
    checkbox("n2  [midi:key 74][hidden:1]"),
    checkbox("n3  [midi:key 75][hidden:1]"),
    checkbox("n4  [midi:key 76][hidden:1]"),
    // Bottom-right pads (5-to-8)
    checkbox("n5  [midi:key 89][hidden:1]"),
    checkbox("n6  [midi:key 90][hidden:1]"),
    checkbox("n7  [midi:key 91][hidden:1]"),
    checkbox("n8  [midi:key 92][hidden:1]"),
    // Top-left pads (1-to-4)
    checkbox("n9  [midi:key 41][hidden:1]"),
    checkbox("n10 [midi:key 42][hidden:1]"),
    checkbox("n11 [midi:key 43][hidden:1]"),
    checkbox("n12 [midi:key 44][hidden:1]"),
    // Top-right pads (5-to-8)
    checkbox("n13 [midi:key 57][hidden:1]"),
    checkbox("n14 [midi:key 58][hidden:1]"),
    checkbox("n15 [midi:key 59][hidden:1]"),
    checkbox("n16 [midi:key 60][hidden:1]")
);

monophonic(n,b) = index(n) : ba.parallelMax(keys_N) : offset with {
    index(n)  = n : par(i, keys_N, *(i+1));
    offset(x) = (x > 0) * b + x;
};

master_note = monophonic(keys, keys_base);
master_gate = master_note > 0;

master_amp = hslider("v:[0]Master/h:[1]Output [style:knob][midi:ctrl 36]", 25, 0, 100, 0.1)/100;

process = (mixer : filter(master_gate)) * amp_env(master_gate) * master_amp <: flanger;

// ----------------------------------------------------------------------------
// Oscillator (A)
// ----------------------------------------------------------------------------
osc_a_semitones     = hslider("v:[1]Oscillators/h:[0]OscA/[0]Semitones [style:knob][midi:ctrl 13] ", 7, -12, 12, 0.20);
osc_a_octaves       = hslider("v:[1]Oscillators/h:[0]OscA/[1]Octaves [style:knob][midi:ctrl 14]", 0, 0, 3, 1) : int;
osc_a_pulse_width   = hslider("v:[1]Oscillators/h:[0]OscA/[2]PulseWidth [style:knob]", 78.5, 0, 100, 0.1);
osc_a_wf_saw_on     = hslider("v:[1]Oscillators/h:[0]OscA/[3]Saw [midi:ctrl 15]", 1, 0, 1, 1) : int;
osc_a_wf_sqr_on     = hslider("v:[1]Oscillators/h:[0]OscA/[4]Square [midi:ctrl 16]", 0, 0, 1, 1) : int;
osc_a_sync_on       = checkbox("v:[1]Oscillators/h:[0]OscA/[5]Sync");

// m = master
// pw TODO
osc_a_freq = ba.midikey2hz(master_note + osc_a_semitones + (osc_a_octaves * 12));
osc_a_saw = os.sawtooth(osc_a_freq) * osc_a_wf_saw_on;
osc_a_sqr = os.square(osc_a_freq) * osc_a_wf_sqr_on;
osc_a = (osc_a_saw + osc_a_sqr) / 2;

// ----------------------------------------------------------------------------
// Oscillator (B)
// ----------------------------------------------------------------------------
osc_b_semitones     = hslider("v:[1]Oscillators/h:[1]OscB/[0]Semitones [style:knob][midi:ctrl 29]", 0, -12, 12, 0.20);
osc_b_octaves       = hslider("v:[1]Oscillators/h:[1]OscB/[1]Octaves [style:knob][midi:ctrl 30]", 1, 0, 3, 1) : int;
osc_b_pulse_width   = hslider("v:[1]Oscillators/h:[1]OscB/[2]PulseWidth [style:knob]", 50, 0, 100, 0.1);
osc_b_wf_saw_on     = hslider("v:[1]Oscillators/h:[1]OscB/[3]Saw [midi:ctrl 31]", 0, 0, 1, 1): int;
osc_b_wf_sqr_on     = hslider("v:[1]Oscillators/h:[1]OscB/[4]Square [midi:ctrl 32]", 1, 0, 1, 1): int;
osc_b_wf_tri_on     = hslider("v:[1]Oscillators/h:[1]OscB/[5]Tri [midi:ctrl 33]", 0, 0, 1, 1): int;

osc_b_freq = ba.midikey2hz(master_note + osc_b_semitones + (osc_b_octaves * 12));
osc_b_saw = os.sawtooth(osc_b_freq) * osc_b_wf_saw_on;
osc_b_sqr = os.square(osc_b_freq) * osc_b_wf_sqr_on;
osc_b_tri = os.triangle(osc_b_freq) * osc_b_wf_tri_on;
osc_b = (osc_b_saw + osc_b_sqr + osc_b_tri) / 3;

// ----------------------------------------------------------------------------
// Noise
// ----------------------------------------------------------------------------
noise = no.noise;

// ----------------------------------------------------------------------------
// Mixer
// ----------------------------------------------------------------------------
mixer_osc_a         = hslider("v:[2]Mixer/h:[0]OscA [style:knob] [midi:ctrl 18]", 75, 0, 100, 0.1);
mixer_osc_b         = hslider("v:[2]Mixer/h:[0]OscB [style:knob] [midi:ctrl 19]", 75, 0, 100, 0.1);
mixer_fbk_noise     = hslider("v:[2]Mixer/h:[0]Noise [style:knob] [midi:ctrl 20]", 25, 0, 100, 0.1);
// feedback TODO

mixer = ((osc_a * mixer_osc_a)
       + (osc_b * mixer_osc_b)
       + (noise * mixer_fbk_noise)
        ) / 3
;

// ----------------------------------------------------------------------------
// Filter
// ----------------------------------------------------------------------------
filter_cutoff       = hslider("v:[3]Filter/h:[0]Cutoff [style:knob][midi:ctrl 49]", 25, 0, 100, 0.1);
filter_cutoff_res   = hslider("v:[3]Filter/h:[1]Res [style:knob][midi:ctrl 50]", 35, 0, 100, 0.1);
filter_env_amount   = hslider("v:[3]Filter/h:[2]Env [style:knob][midi:ctrl 51]", 50, 0, 100, 0.1);
filter_key_amount   = hslider("v:[3]Filter/h:[3]Key [style:knob][midi:ctrl 52]", 50, 0, 100, 0.1);

filter(g) =
    ve.moogLadder(
       (filter_cutoff/100) * filter_env(g),
       (filter_cutoff_res/100*24.3) + 0.7
//    )
);

// ----------------------------------------------------------------------------
// Filter envelope
// ----------------------------------------------------------------------------
filter_env_attack   = hslider("v:[4]FilterEnv/h:[0]Attack [style:knob][midi:ctrl 77]", 50, 0, 100, 0.1);
filter_env_decay    = hslider("v:[4]FilterEnv/h:[1]Decay [style:knob][midi:ctrl 78]", 50, 0, 100, 0.1);
filter_env_sustain  = hslider("v:[4]FilterEnv/h:[2]Sustain [style:knob][midi:ctrl 79]", 50, 0, 100, 0.1);
filter_env_release  = hslider("v:[4]FilterEnv/h:[3]Release [style:knob][midi:ctrl 80]", 50, 0, 100, 0.1);

filter_env(g) =
       g : en.adsr(filter_env_attack/100,
                   filter_env_decay/100,
                   filter_env_sustain/100,
                   filter_env_release/100
//    )
);

// ----------------------------------------------------------------------------
// Amp envelope
// ----------------------------------------------------------------------------
amp_env_attack = hslider("v:[5]AmpEnv/h:[0]Attack [style:knob][midi:ctrl 81]", 50, 0, 100, 0.1);
amp_env_decay  = hslider("v:[5]AmpEnv/h:[1]Decay [style:knob][midi:ctrl 82]", 50, 0, 100, 0.1);
amp_env_sustain = hslider("v:[5]AmpEnv/h:[2]Sustain [style:knob][midi:ctrl 83]", 50, 0, 100, 0.1);
amp_env_release = hslider("v:[5]AmpEnv/h:[3]Release [style:knob][midi:ctrl 84]", 50, 0, 100, 0.1);

// at: attack time (sec)
// dt: decay time (sec)
// sl: sustain level (between 0..1)
// rt: release time (sec)
// t: trigger signal (attack is triggered when t>0, release is triggered when t=0)
amp_env(g) =
       g : en.adsr(amp_env_attack/100,
                   amp_env_decay/100,
                   amp_env_sustain/100,
                   amp_env_release/100
//    )
);

// ----------------------------------------------------------------------------
// FX: distortion
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// FX: Chorus/Delay/Flanger
// ----------------------------------------------------------------------------
flanger = pf.flanger_stereo(dmax, dl, dr, depth, fb, inv) with {
    dmax = 8192;
    dl = hslider("v:[6]Chorus/[0]delay_left [midi:ctrl 53]", 4096, 0, 8192, 1);
    dr = hslider("v:[6]Chorus/[1]delay_right[midi:ctrl 54]", 4096, 0, 8192, 1);
    depth = hslider("v:[6]Chorus/[2]depth [midi:ctrl 55]", 0.5, 0, 1, 0.01);
    fb = hslider("v:[6]Chorus/[3]feedback [midi:ctrl 56]" , 0.5, 0, 1, 0.01);
    inv = checkbox("v:[6]Chorus/[4]invert");
};
// ----------------------------------------------------------------------------
// FX: ResQ
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// FX: verb
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// FX: master
// ----------------------------------------------------------------------------

