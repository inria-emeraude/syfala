#include <jack/jack.h>
#include <jack/midiport.h>
#include <memory.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
#include <regex.h>
#include <assert.h>

enum MIDI {
    MIDI_NOTE_OFF   = 0x80,
    MIDI_NOTE_ON    = 0x90,
    MIDI_CC         = 0xb0
};

enum {
    LAUNCHCONTROL_CC_TRACK_SELECT_PREV    = 106,
    LAUNCHCONTROL_CC_TRACK_SELECT_NEXT    = 107,
    LAUNCHCONTROL_NOTE_DEVICE             = 105,
    LAUNCHCONTROL_NOTE_MUTE               = 106,
    LAUNCHCONTROL_COLOR_OFF               = 0x0c,
    LAUNCHCONTROL_COLOR_RED_LOW           = 0x0d,
    LAUNCHCONTROL_COLOR_RED_FULL          = 0x0f,
    LAUNCHCONTROL_COLOR_AMBER_LOW         = 0x1d,
    LAUNCHCONTROL_COLOR_AMBER_FULL        = 0x3f,
    LAUNCHCONTROL_COLOR_YELLOW_FULL       = 0x3e,
    LAUNCHCONTROL_COLOR_GREEN_LOW         = 0x1c,
    LAUNCHCONTROL_COLOR_GREEN_FULL        = 0x3c,
    LAUNCHCONTROL_COLOR_RED_FLASHING      = 0x0b,
    LAUNCHCONTROL_COLOR_AMBER_FLASHING    = 0x3b,
    LAUNCHCONTROL_COLOR_YELLOW_FLASHING   = 0x3a,
    LAUNCHCONTROL_COLOR_GREEN_FLASHING    = 0x38
};

#define maplen(map) (sizeof(map)/sizeof(struct smc23_ctrl_map))

// These are the CC indexes sent to the device
static constexpr unsigned char pads_map[16] = {
    // lower row (CC):
    73, 74, 75, 76, 89, 90, 91, 92,
    // upper row (CC):
    41, 42, 43, 44, 57, 58, 59, 60
};

// These are the CC indexes sent from the device
static constexpr unsigned char knobs_map[32] = {
    // first row, to last (CC)
    13, 14, 15, 16, 17, 18, 19, 20,
    29, 30, 31, 32, 33, 34, 35, 36,
    49, 50, 51, 52, 53, 54, 55, 56,
    77, 78, 79, 80, 81, 82, 83, 84
};

// These are the NOTE indexes sent to the device
static constexpr unsigned char knobs_map_notes[32] = {
    13, 29, 45, 61, 77, 93, 109, 125,
    14, 30, 46, 62, 78, 94, 110, 126,
    15, 31, 47, 63, 79, 95, 111, 127,
    41, 42, 43, 44, 57, 58, 59, 60
};

// midi cc as well:
static unsigned char sliders_map[8] = {
    77, 78, 79, 80, 81, 82, 83, 84
};

struct smc23_ctrl_map {
    unsigned char k_recv;
    unsigned char k_send;
    unsigned char k_color;
};

struct smc23_dsp_target {
    const char* name;
    int n_knobs;
    struct smc23_ctrl_map* knobs;
    pthread_t thread;
};

static constexpr struct smc23_ctrl_map ctrl_map(
        unsigned char index,
        unsigned char color = LAUNCHCONTROL_COLOR_GREEN_FULL
){
    for (int n = 0; n < 32; ++n) {
         if (knobs_map[n] == index) {
             return smc23_ctrl_map {
                 .k_recv = index,
                 .k_send = knobs_map_notes[n],
                 .k_color = color
             };
         }
    }
    fprintf(stderr, "[SMC23] Could not find index %d in knobs map\n", index);
    assert(false);
}

// ----------------------------------------------------------------------------
// Minimoog
// ----------------------------------------------------------------------------

static struct smc23_ctrl_map minimoog_map[] = {
    // --------------------------------------------------------
    ctrl_map(13), // Oscillator 1: Waveform,
    ctrl_map(29), // Oscillator 1: Fine Tuning
    ctrl_map(49), // Oscillator 1: Octave
    ctrl_map(77), // Oscillator 1: Level (Slider)
    // --------------------------------------------------------
    ctrl_map(14), // Oscillator 2: Waveform,
    ctrl_map(30), // Oscillator 2: Fine Tuning,
    ctrl_map(50), // Oscillator 2: Octave
    ctrl_map(78), // Oscillator 2: Level (Slider)
    // --------------------------------------------------------
    ctrl_map(15), // Oscillator 3: Waveform,
    ctrl_map(31), // Oscillator 3: Fine Tuning,
    ctrl_map(51), // Oscillator 3: Octave
    ctrl_map(79), // Oscillator 3: Level (Slider)
    // --------------------------------------------------------
    ctrl_map(16, LAUNCHCONTROL_COLOR_AMBER_FULL), // Noise: ?
    ctrl_map(32, LAUNCHCONTROL_COLOR_AMBER_FULL), // Noise: ?
    ctrl_map(52, LAUNCHCONTROL_COLOR_AMBER_FULL), // Noise: ?
    ctrl_map(80, LAUNCHCONTROL_COLOR_AMBER_FULL), // Noise: Level (Slider)
    // --------------------------------------------------------
    ctrl_map(17, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Filter: Cutoff
    ctrl_map(33, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Filter: Q
    ctrl_map(81, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Filter: ?
    // --------------------------------------------------------
    ctrl_map(53, LAUNCHCONTROL_COLOR_RED_FULL), // Filter Env: Attack
    ctrl_map(54, LAUNCHCONTROL_COLOR_RED_FULL), // Filter Env: Decay
    ctrl_map(55, LAUNCHCONTROL_COLOR_RED_FULL), // Filter Env: Sustain
    ctrl_map(55, LAUNCHCONTROL_COLOR_RED_FULL), // Filter Contour
    // --------------------------------------------------------
    ctrl_map(81, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env: Attack
    ctrl_map(82, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env: Decay
    ctrl_map(83, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env: Decay
    // --------------------------------------------------------
    ctrl_map(84, LAUNCHCONTROL_COLOR_RED_FULL), // Master Volume
    // --------------------------------------------------------
};

static constexpr struct smc23_dsp_target minimoog = {
    .name = "minimoog-novation",
    .n_knobs = maplen(minimoog_map),
    .knobs = minimoog_map
};

// ----------------------------------------------------------------------------
// virtualAnalog
// ----------------------------------------------------------------------------

static struct smc23_ctrl_map vanalog_map[] = {
    // ------------------------------
    ctrl_map(79, LAUNCHCONTROL_COLOR_YELLOW_FULL),  // Oscillator frequency
    ctrl_map(77),                                   // LFO frequency
    ctrl_map(78),                                   // LFO range
    ctrl_map(80, LAUNCHCONTROL_COLOR_AMBER_FULL),   // Noise gain
    ctrl_map(81, LAUNCHCONTROL_COLOR_RED_FULL),     // Master volume
    ctrl_map(49),                                   // Pan
    ctrl_map(19, LAUNCHCONTROL_COLOR_AMBER_FULL),   // Activate noise
    ctrl_map(20, LAUNCHCONTROL_COLOR_RED_FULL),     // Kill switch
};

static constexpr struct smc23_dsp_target vanalog = {
    .name = "virtualAnalog",
    .n_knobs = maplen(vanalog_map),
    .knobs = vanalog_map
};

// ----------------------------------------------------------------------------
// HARP
// ----------------------------------------------------------------------------

static struct smc23_ctrl_map harp_map[] = {
    ctrl_map(77, LAUNCHCONTROL_COLOR_RED_FULL), // Hand (Slider)
    ctrl_map(78, LAUNCHCONTROL_COLOR_AMBER_FULL), // Attenuation (Slider)
    ctrl_map(79), // Level (Slider)
};

static constexpr struct smc23_dsp_target harp = {
    .name = "harp",
    .n_knobs = maplen(harp_map),
    .knobs = harp_map
};

// ----------------------------------------------------------------------------
// PRO3
// ----------------------------------------------------------------------------

static struct smc23_ctrl_map pro3_map[] = {
    // --------------------------------------
    ctrl_map(13), // Oscillator A - Semitones
    ctrl_map(14), // Oscillator A - Octaves
    ctrl_map(15), // Oscillator A - Saw
    ctrl_map(16), // Oscillator A - Square
    // -----------------------------------------------------------------
    ctrl_map(29, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Oscillator B - Semitones
    ctrl_map(30, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Oscillator B - Octaves
    ctrl_map(31, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Oscillator B - Saw
    ctrl_map(32, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Oscillator B - Square
    ctrl_map(33, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Oscillator B - Triangle
    // ----------------------------------------------------------------
    ctrl_map(18, LAUNCHCONTROL_COLOR_RED_FULL), // Mixer - Oscillator A
    ctrl_map(19, LAUNCHCONTROL_COLOR_RED_FULL), // Mixer - Oscillator B
    ctrl_map(20, LAUNCHCONTROL_COLOR_RED_FULL), // Mixer - Noise
    // ----------------------------------------------------------------
    ctrl_map(49, LAUNCHCONTROL_COLOR_AMBER_FULL), // Filter - Cutoff
    ctrl_map(50, LAUNCHCONTROL_COLOR_AMBER_FULL), // Filter - Res
    ctrl_map(51, LAUNCHCONTROL_COLOR_AMBER_FULL), // Filter - Env
    ctrl_map(52, LAUNCHCONTROL_COLOR_AMBER_FULL), // Filter - Key
    // ----------------------------------------------------------------
    ctrl_map(77, LAUNCHCONTROL_COLOR_GREEN_FULL), // Filter Env - A
    ctrl_map(78, LAUNCHCONTROL_COLOR_GREEN_FULL), // Filter Env - D
    ctrl_map(79, LAUNCHCONTROL_COLOR_GREEN_FULL), // Filter Env - S
    ctrl_map(80, LAUNCHCONTROL_COLOR_GREEN_FULL), // Filter Env - R
    // ----------------------------------------------------------------
    ctrl_map(81, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env - A
    ctrl_map(82, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env - D
    ctrl_map(83, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env - S
    ctrl_map(84, LAUNCHCONTROL_COLOR_YELLOW_FULL), // Amp Env - R
    // ----------------------------------------------------------------
    ctrl_map(53, LAUNCHCONTROL_COLOR_RED_FULL), // Flanger - Delay Left
    ctrl_map(54, LAUNCHCONTROL_COLOR_RED_FULL), // Flanger - Delay Right
    ctrl_map(55, LAUNCHCONTROL_COLOR_RED_FULL), // Flanger - Depth
    ctrl_map(56, LAUNCHCONTROL_COLOR_RED_FULL), // Flanger - Feedback
    // ----------------------------------------------------------------
    ctrl_map(36, LAUNCHCONTROL_COLOR_RED_FULL), // Master Volume
};

static constexpr struct smc23_dsp_target pro3 = {
    .name = "pro3",
    .n_knobs = maplen(pro3_map),
    .knobs = pro3_map
};

// ----------------------------------------------------------------------------
// MAIN STRUCT
// ----------------------------------------------------------------------------

struct smc23_midi_hdl {
    jack_client_t* client;
      jack_port_t* from_device;
      jack_port_t* to_device;
      jack_port_t* to_dsp;
      struct smc23_dsp_target dsp_targets[4];
      int target;
      int ptarget;
      bool initialize;
      bool connected;
      bool device;
};

#define SMC23_N_DSP_TARGETS 4

static struct smc23_midi_hdl s = {
    .client        = nullptr,
    .from_device   = nullptr,
    .to_device     = nullptr,
    .to_dsp        = nullptr,
    .dsp_targets   = {pro3, minimoog, harp, vanalog},
    .target        = 0,
    .ptarget       = 0,
    .initialize    = true,
    .connected     = false,
    .device        = false
};

static struct smc23_dsp_target& get_target(struct smc23_midi_hdl& s) {
    return s.dsp_targets[s.target];
}

static struct smc23_dsp_target& get_previous_target(struct smc23_midi_hdl& s) {
    return s.dsp_targets[s.ptarget];
}

static void* dsp_thread_fn(void* udata) {
    auto s = (struct smc23_midi_hdl*)(udata);
    char cmd[128];
    if (s->initialize) {
        sprintf(cmd, "syfala-load %s", get_target(*s).name);
    } else {
        // don't reset the audio codecs when changing the DSP program
        // in order to avoid the unpleasantly loud audio clicks..!
        sprintf(cmd, "syfala-load %s --no-reset", get_target(*s).name);
    }
    printf("[SMC23] Executing command: %s\n", cmd);
    system(cmd);
    return NULL;
}

static int update_dsp(struct smc23_midi_hdl& s) {
    // We start the DSP process in another thread
    int err = 0;
    struct smc23_dsp_target& t = get_target(s);
    fprintf(stdout, "[SMC23] Updating DSP with new target: %s\n", t.name);
    err = pthread_create(&t.thread, 0, dsp_thread_fn, (void*)(&s));
    if (s.target != s.ptarget) {
        struct smc23_dsp_target& p = get_previous_target(s);
        // syfala-load command sends sigstop to previous application,
        // we can safely wait for it to join.
        // this may causes a few xruns, but that's okay for now...
        pthread_join(p.thread, nullptr);
    }
    if (err) {
        fprintf(stderr, "%s", strerror(err));
        exit(1);
    } else {
        printf("[SMC23] Loaded DSP: %s\n", t.name);
    }
    return 0;
}

static void reset_upper_pads(void* to_device) {
    for (int n = 8; n < 16; ++n) {
        jack_midi_data_t* mdt;
        mdt = jack_midi_event_reserve(to_device, 0, 3);
        mdt[0] = MIDI_NOTE_OFF;
        mdt[1] = pads_map[n];
        mdt[2] = 0;
    }
}

static void initialize_pads(struct smc23_midi_hdl& s, void* to_device) {
    printf("[SMC23] Reinitializing pads\n");
    reset_upper_pads(to_device);
    for (int n = 0; n < SMC23_N_DSP_TARGETS; ++n) {
         jack_midi_data_t* mdt;
         mdt = jack_midi_event_reserve(to_device, 0, 3);
         mdt[0] = MIDI_NOTE_ON;
         mdt[1] = pads_map[n];
         if (s.target == n) {
             mdt[2] = LAUNCHCONTROL_COLOR_GREEN_FLASHING;
         } else {
             mdt[2] = LAUNCHCONTROL_COLOR_YELLOW_FULL;
         }
    }
}

static void update_pads(struct smc23_midi_hdl& s, void* to_device) {
    jack_midi_data_t* mdt, *mdt2;
    reset_upper_pads(to_device);
    mdt = jack_midi_event_reserve(to_device, 0, 3);
    mdt2 = jack_midi_event_reserve(to_device, 0, 3);
    unsigned char index = pads_map[s.ptarget];
    mdt[0] = MIDI_NOTE_ON;
    mdt[1] = index;
    mdt[2] = LAUNCHCONTROL_COLOR_YELLOW_FULL;
    index = pads_map[s.target];
    mdt2[0] = MIDI_NOTE_ON;
    mdt2[1] = index;
    mdt2[2] = LAUNCHCONTROL_COLOR_GREEN_FLASHING;
}

static void initialize_knobs(void* to_device) {
    printf("[SMC23] Initializing knobs\n");
    for (int n = 0; n < 24; ++n) {
        jack_midi_data_t* mdt;
        mdt = jack_midi_event_reserve(to_device, 0, 3);
        mdt[0] = MIDI_NOTE_ON;
        mdt[1] = knobs_map_notes[n];
        mdt[2] = 0;
    }
}

static void update_knobs(struct smc23_midi_hdl& s, void* to_device) {
    initialize_knobs(to_device);
    struct smc23_dsp_target& t = get_target(s);
    printf("[SMC23] Updating knobs (%d) for target: %s\n", t.n_knobs, t.name);
    for (int n = 0; n < t.n_knobs; ++n) {
         auto& knob = t.knobs[n];
         printf("[SMC23] Updating knob: %d (cc: %d, note: %d)\n", n, knob.k_recv, knob.k_send);
         jack_midi_data_t* mdt;
         mdt = jack_midi_event_reserve(to_device, 0, 3);
         mdt[0] = MIDI_NOTE_ON;
         mdt[1] = knob.k_send;
         mdt[2] = knob.k_color;
    }
    fprintf(stderr, "[SMC23] Finished updating knobs\n");
}

static inline void
update_target(struct smc23_midi_hdl& s, void* to_device, int target) {
    s.ptarget = s.target;
    s.target  = target;
    update_pads(s, to_device);
    update_knobs(s, to_device);
    update_dsp(s);
}

static unsigned int
SMC23_DSP_TARGET_MIN = 73;

static unsigned int
SMC23_DSP_TARGET_MAX = (SMC23_DSP_TARGET_MIN + SMC23_N_DSP_TARGETS);

#define MIDI_STATUS(ev) ev.buffer[0]
#define MIDI_INDEX(ev)  ev.buffer[1]
#define MIDI_VALUE(ev)  ev.buffer[2]

static void
parse_midi_event(struct smc23_midi_hdl& s,
                 jack_midi_event_t event,
                 void* to_device)
{
    switch (MIDI_STATUS(event) & 0xf0) {
    case MIDI_NOTE_OFF: {
         if (MIDI_INDEX(event) == LAUNCHCONTROL_NOTE_DEVICE) {
             s.device = false;
        } else if (s.device &&
                   MIDI_INDEX(event) >= SMC23_DSP_TARGET_MIN &&
                   MIDI_INDEX(event) <  SMC23_DSP_TARGET_MAX) {
             unsigned char target = MIDI_INDEX(event)-SMC23_DSP_TARGET_MIN;
             if (target != s.target) {
                 update_target(s, to_device, target);
             }
        }
        break;
    }
    case MIDI_NOTE_ON: {
        if (MIDI_INDEX(event) == LAUNCHCONTROL_NOTE_DEVICE) {
             s.device = true;
        }
        break;
    }
    case MIDI_CC: {
        switch (MIDI_INDEX(event)) {
        case LAUNCHCONTROL_CC_TRACK_SELECT_PREV: {
            // TRACK PREVIOUS
            // -> PREVIOUS BITSTREAM/APPLICATION
             if (MIDI_VALUE(event) == 0 && s.target > 0) {
                 update_target(s, to_device, s.target-1);
            }
            break;
        }
        case LAUNCHCONTROL_CC_TRACK_SELECT_NEXT: {
            // -> NEXT BITSTREAM/APPLICATION
            if (MIDI_VALUE(event) == 0 &&
                s.target < (SMC23_N_DSP_TARGETS-1)) {
                update_target(s, to_device, s.target+1);
            }
            break;
        }
        }
        break;
    }
    }
}

static int smc23_proc_fn(jack_nframes_t nframes, void* udata) {
    struct smc23_midi_hdl* s = (struct smc23_midi_hdl*)(udata);
    jack_midi_event_t event;
    unsigned int n_events;
    void* from_device = jack_port_get_buffer(s->from_device, nframes);
    void* to_device   = jack_port_get_buffer(s->to_device, nframes);
    void* to_dsp      = jack_port_get_buffer(s->to_dsp, nframes);
    n_events = jack_midi_get_event_count(from_device);
    jack_midi_clear_buffer(to_device);
    jack_midi_clear_buffer(to_dsp);
    if (s->initialize && s->connected) {
        initialize_pads(*s, to_device);
        update_target(*s, to_device, 0);
        s->initialize = false;
    }
    for (int n = 0; n < n_events; ++n) {
         // get event from device
         // send it to dsp regardless
         // catch next-prev controls, and mute note (?)
         jack_midi_data_t* mdt;
         jack_midi_event_get(&event, from_device, n);
         mdt = jack_midi_event_reserve(to_dsp, 0, event.size);
         memcpy(mdt, event.buffer, event.size);
         parse_midi_event(*s, event, to_device);
    }
    return 0;
}

// ----------------------------------------------------------------------------
// Utilities
// ----------------------------------------------------------------------------

static jack_port_t*
jack_declare_midi_port_o(jack_client_t* client, const char* name){
    return jack_port_register(client, name, JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput, 0);
}

static jack_port_t*
jack_declare_midi_port_i(jack_client_t* client, const char* name) {
    return jack_port_register(client, name, JACK_DEFAULT_MIDI_TYPE, JackPortIsInput, 0);
}

static const char**
jack_get_midi_port_i(jack_client_t* client, const char* device) {
    return jack_get_ports(client, device, JACK_DEFAULT_MIDI_TYPE, JackPortIsInput);
}

static const char**
jack_get_midi_port_o(jack_client_t* client, const char* device) {
    return jack_get_ports(client, device, JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput);
}

// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------

int main(int argc, char* argv[]) {
    // start jack client with cmd:
    // jackd -d dummy -p 256 & sleep 5; a2jmidid -e & sleep 3; smc23
    const char** p_from_device;
    const char** p_to_device;
    const char** p_to_dsp;
    static const char* device = "Launch Control XL";

    s.client       = jack_client_open("smc23", JackNullOption, NULL);
    s.from_device  = jack_declare_midi_port_i(s.client, "from-device");
    s.to_device    = jack_declare_midi_port_o(s.client, "to-device");
    s.to_dsp       = jack_declare_midi_port_o(s.client, "to-dsp");
    p_from_device  = jack_get_midi_port_o(s.client, device);
    p_to_device    = jack_get_midi_port_i(s.client, device);

    jack_set_process_callback(s.client, smc23_proc_fn, &s);
    jack_activate(s.client);

    if (p_from_device) {
        printf("[SMC23] %s output port: ok\n", device);
        jack_connect(s.client, p_from_device[0], jack_port_name(s.from_device));
        jack_connect(s.client, jack_port_name(s.to_device), p_to_device[0]);
        s.connected = true;
    } else {
        fprintf(stderr, "[SMC23] Couldn't find device: %s, aborting\n", device);
        exit(1);
    }
    // Start DSP process, it will connect to this client automatically
    while (true) {
        usleep(1000);
    }
}
