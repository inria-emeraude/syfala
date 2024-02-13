#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/memory.hpp>
#include <lo/lo.h>
#include <cmath>

// Ideally this should be declared in a shared .h file but this seems to break the system
#define INPUTS 4 // number of sources...
#define OUTPUTS 32 // number of speakers...
const static float speakers_dist = 0.0783f;

int isTUI = false;

static float c = 340.0;
static float xref = 0;
static float yref = 0;
static float zref = 0;

static float x_speakers_pos[OUTPUTS];
static float speakers_norm[OUTPUTS];

static float x_pos[INPUTS];
static float y_pos[INPUTS];
static float z_pos[INPUTS];
static float ctrl[INPUTS*OUTPUTS*2];

using namespace Syfala;

static XSyfala dsp;

static lo_server_thread osc;

static void error_hdl(int no, const char* m, const char* path) {
    fprintf(stderr, "Error starting OSC client: %d, %s, %s\n", no, m, path);
}

static float norm(float x1, float y1, float z1, float x2, float y2, float z2){
    return sqrt(pow((x1-x2),2.0) + pow((y1-y2),2.0) + pow((z1-z2),2.0));
}

static void update_state(){
    for (int i = 0; i < INPUTS; ++i){
        float r[OUTPUTS];
        float r_long = 1000;
        for (int o = 0; o < OUTPUTS; ++o){
            r[o] = norm(x_pos[i],y_pos[i],z_pos[i],x_speakers_pos[o],0,0);
            if (r[o]<r_long) r_long = r[o];
        }
        for (int o = 0; o < OUTPUTS; ++o){
            int d_idx = o + OUTPUTS*i*2;
            int g_idx = d_idx + OUTPUTS;
            ctrl[g_idx] = speakers_norm[o]*y_pos[i]/pow(r[o],2.0f)*2.0f;
            ctrl[d_idx] = (r[o]-r_long)/c*SYFALA_SAMPLE_RATE;
        }
    }
    XSyfala_Write_ctrl_Words(&dsp,0,reinterpret_cast<u32*>(ctrl),INPUTS*OUTPUTS*2);
}

static void initialize_dsp(){
    for (int i = 0; i < INPUTS; ++i){
        x_pos[i] = 0;
        y_pos[i] = 1.5;
        z_pos[i] = 0;
    }
    for (int o = 0; o < OUTPUTS; ++o){
        x_speakers_pos[o] = -speakers_dist*OUTPUTS/2 + speakers_dist/2 + o*speakers_dist;
        speakers_norm[o] = norm(xref,yref,zref,x_speakers_pos[o],0,0);
    }
    update_state();
};

static int osc_hdl (
        const char* path,
        const char* types,
           lo_arg** argv, int argc,
         lo_message data, void* udata
){
    float* val = static_cast<float*>(udata);
    *val = argv[0]->f;
    update_state();
    return 0;
}

static void initialize_osc() {
    osc = lo_server_thread_new("5510", error_hdl);
    int addr_size = 15;
    for (int i = 0; i < INPUTS; ++i){
        if (i>10) addr_size = 16;
        char x_addr[addr_size];
        char y_addr[addr_size];
        char z_addr[addr_size];
        snprintf(x_addr, addr_size, "/wfs/source%d/x", i);
        snprintf(y_addr, addr_size, "/wfs/source%d/y", i);
        snprintf(z_addr, addr_size, "/wfs/source%d/z", i);
        lo_server_thread_add_method(osc, x_addr, "f", osc_hdl, &x_pos[i]);
        lo_server_thread_add_method(osc, y_addr, "f", osc_hdl, &y_pos[i]);
        lo_server_thread_add_method(osc, z_addr, "f", osc_hdl, &z_pos[i]);
    }
    lo_server_thread_start(osc);
}

int main(int argc, char* argv[]) {
    Memory::data mem;
    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    // Wait for all peripherals to be initialized
    Status::waiting(RN("[status] Initializing peripherals & modules"));
    Audio::initialize();
    IP::initialize(dsp);

    Memory::initialize(dsp, mem, 0, 0);

    // In case we'd want to use DDR instead of block RAMs (doesn't work yet...)
    // Memory::initialize(x, mem, 0, INPUTS*OUTPUTS*2);
    // for (int i = 0; i < INPUTS; ++i){
    //     for (int o = 0; o < OUTPUTS; ++o){
    //         int d_idx = o + OUTPUTS*i*2;
    //         int g_idx = d_idx + OUTPUTS;
    //         ctrl[d_idx] = 100.5;
    //         ctrl[g_idx] = 1.0;
    //     }
    // }
    //
    // XSyfala_Write_ctrl_Words(&dsp,0,reinterpret_cast<u32*>(ctrl),INPUTS*OUTPUTS*2);

    initialize_dsp();
    initialize_osc();

    IP::set_arm_ok(&dsp, true);
    Status::ok(RN("[status] Application ready, now running..."));
    // main event loop:
    while (true) {
        usleep(10000000);
    }
    lo_server_thread_free(osc);
    return 0;
}
