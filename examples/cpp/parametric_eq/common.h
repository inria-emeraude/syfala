#ifndef __COMMON
#define __COMMON

#include <cmath>
#include <syfala/utilities.hpp>


#define N_FILTERS 5

#define CLIP(x, min, max) (x > max ? max : x < min ? min : x)

// Biquad filter in direct form 2 to reduce resource use.
struct Biquad {

    float b0 = 1.0f;
    float b1 = 0.0f;
    float b2 = 0.0f;
    float a1 = 0.0f;
    float a2 = 0.0f;

    float w1L = 0.0f;
    float w2L = 0.0f;
    float w1R = 0.0f;
    float w2R = 0.0f;

};

// Pointer offsets to the different filter parameters for use in the hls syfala procedure
enum OFFSETS : uint16_t {
    PARAM_FREQ_OFFSET = 0,
    PARAM_Q_OFFSET    = N_FILTERS,
    PARAM_GAIN_OFFSET = 2*N_FILTERS,
    PARAM_SIZE        = 3*N_FILTERS
};

enum FilterMode : uint8_t {
    LowpassFilter,
    HighpassFilter,
    PeakFilter,
};


// biquad formulas found at https://www.w3.org/TR/audio-eq-cookbook/
static void biquad_compute_coeffs(Biquad* f, int type, float freq, float Q, float gain_dB) {

    float w0 = 2.0f * M_PI * freq / SYFALA_SAMPLE_RATE;
    float cos_w0 = cosf(w0);

    float alpha = sinf(w0) / (2.0f * Q);

    switch(type) {
        case LowpassFilter: {
            float a0_inv = 1.0f/(1.0f + alpha);
            
            f->b0 = (1.0f - cos_w0)/(2.0f) * a0_inv;
            f->b1 = 2.0f * f->b0;
            f->b2 = f->b0;
            f->a1 = -2.0f * cos_w0 * a0_inv;
            f->a2 = (1.0f - alpha) * a0_inv;
            return;
        }

        case HighpassFilter: {
            float a0_inv = 1.0f/(1.0f + alpha);

            f->b0 = (1.0f + cos_w0) * 0.5f * a0_inv;
            f->b1 = -2.0f * f->b0;
            f->b2 = f->b0;
            f->a1 = -2.0f * cos_w0 * a0_inv;
            f->a2 = (1.0f - alpha) * a0_inv;
            return;
        }

        case PeakFilter: {
            float A = powf(10.0f, gain_dB/40.0f);
            float A_inv = 1.0f/A;
            float a0_inv = 1.0f/(1.0f + alpha * A_inv);

            f->b0 = (1.0f + alpha * A) * a0_inv;
            f->b1 = -2.0f * cos_w0 * a0_inv; 
            f->b2 = (1.0f - alpha * A) * a0_inv; 
            f->a1 = f->b1; 
            f->a2 = (1.0f - alpha * A_inv) * a0_inv;
            return;
        }
    }
}

static void biquad_process(Biquad* f, float* sampleL, float* sampleR) { 

    float wL = *sampleL - f->a1*f->w1L - f->a2*f->w2L;
    float outputL = f->b0*wL+ f->b1*f->w1L + f->b2*f->w2L;

    float wR = *sampleR - f->a1*f->w1R - f->a2*f->w2R;
    float outputR = f->b0*wR+ f->b1*f->w1R + f->b2*f->w2R;

    f->w2L = f->w1L;
    f->w1L = wL;
    *sampleL = outputL;

    f->w2R = f->w1R;
    f->w1R = wR;
    *sampleR = outputR;
}


static inline void biquad_reset_feedback(Biquad* f) {
    f->w1L = 0.0f;
    f->w2L = 0.0f;
    f->w1R = 0.0f;
    f->w2R = 0.0f;
}

#endif // __COMMON
