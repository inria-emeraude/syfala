#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/memory.hpp>
#include <lo/lo.h>
#include <cmath>
#include <signal.h>
#include "common.h"
#include <string>

static bool running = true; 

using namespace Syfala::ARM;

static lo_server_thread osc;

// initial parameters
static float frequencies[N_FILTERS] = {20.0f, 250.0f, 500.0f, 2000.0f, 20000.0f};
static float Qs[N_FILTERS]          = {0.7f,  0.7f,   0.7f,   0.7f,    0.7f};
static float gains_dB[N_FILTERS]    = {0.0f,  0.0f,   0.0f,   0.0f,    0.0f};
static float master_vol             = 0.5f;

static Biquad filters_array[N_FILTERS];
static uint32_t filters_array_size = N_FILTERS * sizeof(Biquad);

static void sig_hdl(int signo) {
    switch (signo) {
        case SIGINT:
        case SIGKILL:
        case SIGSTOP: {
            printf("Terminating program\n");
            running = false;
            break;
        }
    }
}

static void error_hdl(int no, const char* m, const char* path) {
    fprintf(stderr, "Error starting OSC client: %d, %s, %s\n", no, m, path);
}

// function for osc parameter reactivity
static int osc_axi_filters_hdl(const char* path, const char* types,
                                  lo_arg** argv, int argc, 
                                  lo_message data, void* udata)
{
    XSyfala* dsp = static_cast<XSyfala*>(udata);
    float* params = &argv[0]->f;
    float* freqs = &params[PARAM_FREQ_OFFSET];
    float* Qs    = &params[PARAM_Q_OFFSET];
    float* gains = &params[PARAM_GAIN_OFFSET];

    for (uint8_t i = 0; i < N_FILTERS; i++) {        
        uint8_t mode = (i == 0) ? HighpassFilter 
                     : (i == N_FILTERS-1) ? LowpassFilter 
                     : PeakFilter; 
        
        biquad_compute_coeffs(&filters_array[i], mode,
            freqs[i], Qs[i], gains[i]);
    }


    printf("[OSC] Updating /osc/filters_coeffs with values: \n");

    for (size_t i = 0; i < PARAM_SIZE; i++) {
        printf("%.2f  ", params[i]);
    }
    printf("\n");

    XSyfala_Write_axi_filters_Words(dsp, 0, reinterpret_cast<u32*>(filters_array), filters_array_size);

    return 0;
}

static int osc_master_vol_hdl(const char* path, const char* types,
                              lo_arg** argv, int argc, 
                              lo_message data, void* udata)
{
    XSyfala* dsp = static_cast<XSyfala*>(udata);
    master_vol = argv[0]->f;
    printf("[OSC] Updating /osc/master_vol with value: %f\n", master_vol);
    XSyfala_Set_master_vol(dsp, *reinterpret_cast<u32*>(&master_vol));
    return 0;
}

static void initialize_osc(XSyfala* dsp) {

    osc = lo_server_thread_new("8888", error_hdl);

    static std::string param_format = "";

    for (size_t i = 0; i < PARAM_SIZE; i++) {
        param_format.append("f");
    }

    lo_server_thread_add_method(osc, "/osc/filters_coeffs", param_format.c_str(), osc_axi_filters_hdl, dsp);
    lo_server_thread_add_method(osc, "/osc/master_vol", "f", osc_master_vol_hdl, dsp);
    lo_server_thread_start(osc);
}


static void initialize_default_values(XSyfala* dsp) {

    float params[PARAM_SIZE];
    for (size_t i = 0; i < N_FILTERS; i++) {
        params[i + PARAM_FREQ_OFFSET] = frequencies[i];
        params[i + PARAM_Q_OFFSET] = Qs[i];
        params[i + PARAM_GAIN_OFFSET] = gains_dB[i];
    }
    
    XSyfala_Write_axi_filters_Words(dsp, 0, reinterpret_cast<u32*>(params), PARAM_SIZE);

    XSyfala_Set_master_vol(dsp, *reinterpret_cast<u32*>(&master_vol));
}

static void initialize_filters() {

    biquad_compute_coeffs(reinterpret_cast<Biquad*>(filters_array), HighpassFilter, 
                          frequencies[0], Qs[0], gains_dB[0]);

    for (size_t i = 1; i < N_FILTERS - 1; i++) {
        biquad_compute_coeffs(reinterpret_cast<Biquad*>(filters_array + i*sizeof(Biquad)), PeakFilter,
                              frequencies[i], Qs[i], gains_dB[i]);
    }

    biquad_compute_coeffs(reinterpret_cast<Biquad*>(filters_array + (N_FILTERS-1)*sizeof(Biquad)), LowpassFilter, 
                          frequencies[N_FILTERS-1], Qs[N_FILTERS-1], gains_dB[N_FILTERS-1]);

}


int main(int argc, char** argv) {

    XSyfala dsp;
    Memory::data mem;
    signal(SIGINT, sig_hdl);
    signal(SIGKILL, sig_hdl);
    signal(SIGSTOP, sig_hdl);

    GPIO::initialize();

    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    DSP::initialize(dsp);

    Memory::initialize(dsp, mem, 0, 0);
    initialize_default_values(&dsp);
    initialize_filters();
    initialize_osc(&dsp);

    DSP::set_arm_ok(&dsp, true);
    Status::ok("[status] Application ready, now running...");
    printf("Number of filters running : %d\n", N_FILTERS);

    while (running) {
        usleep(5000);
    }

    Status::waiting("[status] Exiting Program");

    lo_server_thread_free(osc);
    return 0;
}
