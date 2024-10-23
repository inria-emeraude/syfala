#include <cstdio>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/memory.hpp>
#include <lo/lo.h>
#include <cmath>

#define EQ_PARAMS 19
#define FILTERS_PER_EQ 4
#define NUM_OSC 10

typedef struct {
    float freq = 440.f;
    float vel = 0.f;
} Key;

typedef struct {
    float out_gain = 1.f;
    float voice_gain = 1.f;
    float voice_attack = 1.f;
    float voice_release = 1.f;
    float voice_eq[EQ_PARAMS] = {1.f};
    float carrier_gain = 1.f;
    float carrier_eq[EQ_PARAMS] = {1.f};
    Key synth_key[NUM_OSC];
    float saw_gain = 1.f;
    float square_gain = 1.f;
    float tri_gain = 1.f;
} Ctrl;

#define OSC_PREFIX "/prosynth"
#define MIN_GAIN 1
#define MAX_GAIN 15


static Ctrl ctrl;

using namespace Syfala::ARM;

static XSyfala dsp;

static lo_server_thread osc;

static void error_hdl(int no, const char* m, const char* path) {
    fprintf(stderr, "Error starting OSC client: %d, %s, %s\n", no, m, path);
}

static void update_state(){
	XSyfala_Set_ctrl(&dsp,*reinterpret_cast<XSyfala_Ctrl*>(&ctrl));
}

static void initialize_dsp(){
	// Initialize all control parameters with default values
	// Done in the Ctrl struct.
	update_state();
};

static float midi_note_to_freq(const float note)
{
	return powf(2, (note-69)/12) * 440;
};

static float midi_vel_normalize(const float vel)
{
    return static_cast<int>(vel) > 0 ? (vel/127) : 0.f;
}

// This functions handles the polyvoice note allocation so that a maximum of NUM_OSC note
// are sent to the fpga to be generated. Further notes won't be played. When the velocity
// of a playing note is 0, the slot is released and a new note can be played.
static int polyvoice_select(const int note, const int velocity)
{
    static int poly_note_state[NUM_OSC] = {0};

    int note_select = -1; // Default to no available polyvoice slot
    for (int i=0; i<NUM_OSC; i++) {
        if (velocity == 0 && note == poly_note_state[i]) {
            // playing note off
            note_select = i;
            poly_note_state[i] = 0;
            break;
        } else if (velocity > 0 && poly_note_state[i] == 0) {
            // new note
            note_select = i;
            poly_note_state[i] = note;
            break;
        }
    }
    return note_select;
}

static int osc_float_hdl (
        const char* path,
        const char* types,
        lo_arg** argv, int argc,
        lo_message data, void* udata
){
    printf("[osc] OSC msg recieved: %s ", path);
    float* val = static_cast<float*>(udata);
    *val = argv[0]->f;
    printf("%f\n", *val);
    update_state();
    return 0;
}

static int osc_key_hdl (
        const char* path,
        const char* types,
        lo_arg** argv, int argc,
        lo_message data, void* udata
){
    printf("[osc] OSC msg recieved: %s\n", path);
    Key* val = static_cast<Key*>(udata);
    const float note = argv[0]->f;
    const float vel = argv[1]->f;
    printf("note: %d vel: %d\n", static_cast<int>(note), static_cast<int>(vel));
    int voice_select = polyvoice_select(static_cast<int>(note), static_cast<int>(vel));
    if (voice_select >= 0 && voice_select < NUM_OSC) {
        printf("[osc] note on voice %d\n", voice_select);
        printf("note: %f:%f vel: %f%f\n", note, val[voice_select].freq, vel, val[voice_select].vel);
        val[voice_select].freq = midi_note_to_freq(note);
        val[voice_select].vel = midi_vel_normalize(vel);
        update_state();
    }
    return 0;
}

static void initialize_osc() {
    osc = lo_server_thread_new("5510", error_hdl);
	// Vocoder control
    int id_size = 1;
    for (int i = 0; i < EQ_PARAMS; ++i){
        if (i>10) id_size = 2;
        char voice_eq_addr[20+id_size];
        char carrier_eq_addr[22+id_size];
        snprintf(voice_eq_addr, 20+id_size, "/prosynth/voice/eq/%d", i);
        snprintf(carrier_eq_addr, 22+id_size, "/prosynth/carrier/eq/%d", i);
        lo_server_thread_add_method(osc, voice_eq_addr, "f", osc_float_hdl, &ctrl.voice_eq[i]);
        lo_server_thread_add_method(osc, carrier_eq_addr, "f", osc_float_hdl, &ctrl.carrier_eq[i]);
    }
    lo_server_thread_add_method(osc, "/prosynth/keyboard/key", "ff", osc_key_hdl, &ctrl.synth_key);
    lo_server_thread_add_method(osc, "/prosynth/out_gain", "f", osc_float_hdl, &ctrl.out_gain);
    lo_server_thread_add_method(osc, "/prosynth/voice/gain", "f", osc_float_hdl, &ctrl.voice_gain);
    lo_server_thread_add_method(osc, "/prosynth/voice/attack", "f", osc_float_hdl, &ctrl.voice_attack);
    lo_server_thread_add_method(osc, "/prosynth/voice/release", "f", osc_float_hdl, &ctrl.voice_release);
    lo_server_thread_add_method(osc, "/prosynth/carrier/gain", "f", osc_float_hdl, &ctrl.carrier_gain);

	// Synthesizer
    lo_server_thread_add_method(osc, "/prosynth/keyboard/key", "ff", osc_key_hdl, &(ctrl.synth_key[0]));
    lo_server_thread_add_method(osc, "/prosynth/oscillator/saw_gain", "f", osc_float_hdl, &ctrl.saw_gain);
    lo_server_thread_add_method(osc, "/prosynth/oscillator/square_gain", "f", osc_float_hdl, &ctrl.square_gain);
    lo_server_thread_add_method(osc, "/prosynth/oscillator/tri_gain", "f", osc_float_hdl, &ctrl.tri_gain);

    lo_server_thread_start(osc);
    printf("[osc] Server ready, now listening on port %d\n", lo_server_thread_get_port(osc));
}

int main(int argc, char* argv[]) {
    Memory::data mem;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    // Wait for all peripherals to be initialized
    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    DSP::initialize(dsp);

    Memory::initialize(dsp, mem, 0, 0);

    initialize_dsp();
    initialize_osc();

    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");
    // main event loop:
    while (true) {
        usleep(10000000);
    }
    lo_server_thread_free(osc);
    return 0;
}
