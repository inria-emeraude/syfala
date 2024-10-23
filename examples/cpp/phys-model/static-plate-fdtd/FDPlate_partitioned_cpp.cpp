#include <iostream>
#include <cstdint>
#include <cassert>

#define ReaL double
#include "FDPlate_Cpp_Craig_Webb/CJW_Audio.h"


static const std::string outputfname =  "output_files/Plate_cpp.wav";

void display_formated(int value) {
    if (value < 10) { printf("%d ", value); }
    else            { printf("%d", value); }
}

int main() {    
    // ------------------------------------------------------------------------------
    // User Parameters
    bool trigger                      = true;

    constexpr float samplerate        = 48000.0f;
    constexpr int num_samples         = (int)(samplerate * 3);

    constexpr int grid_height         = 100;
    constexpr int grid_width          = 84;

    // constexpr int grid_width          = 28;
    // constexpr int grid_height         = 22;

    constexpr double outposX          = 0.72;
    constexpr double outposY          = 0.41;
    constexpr double inposX           = 0.41;
    constexpr double inposY           = 0.55;
    
    constexpr int grid_length         = grid_width * grid_height;
    constexpr unsigned int max_length = grid_length;
    constexpr int wid                 = grid_width+1;
    constexpr int inint               = ((int)((grid_height+1.0)*inposY))  * wid + (int)(wid*inposX);
    constexpr int outint              = ((int)((grid_height+1.0)*outposY)) * wid + (int)(wid*outposX);

    constexpr f32 B1 = 0.01320418438543748;
    constexpr f32 B2 = -0.0016492828531292285;
    constexpr f32 B3 = -0.003298565706258457;
    constexpr f32 B4 = 1.9668627317399512;
    constexpr f32 C1 = -9.92156040365111e-6;
    constexpr f32 C2 = -0.9999043497535969;

    constexpr int window_width        = 20;
    constexpr int window_height       = 20;
    constexpr int border_size         = 2;


    // ---------------------------------------------------------
    // Memory pointers
    double *ptr;
    
    if (grid_length > max_length) {
        printf("grid_length too large...\n");
        return 0;
    }
    
    alignas(32) double udata[max_length];
    alignas(32) double u1data[max_length];
    alignas(32) double u2data[max_length];
    
    for (int i = 0; i < max_length; ++i) {
        udata[i]  = 0.0;
        u1data[i] = 0.0;
        u2data[i] = 0.0;
    }
    
    double *u  = udata;
    double *u1 = u1data;
    double *u2 = u2data;
    
    double *out  = (double *)calloc(num_samples,sizeof(double));
    
    // -------------------------------------------------------------------------------
    printf("--- Plate Test Standalone --- \n\n");
    printf("Grid      : %d x %d = %d\n", grid_width+1, grid_height+1, grid_length);
    printf("Maxp_ss   : %d\n", max_length);
    printf("Dur       : %d\n", num_samples);
    printf("In_cell   : %d\n", inint);
    printf("Out_cell  : %d\n", outint);
    
    double start, end;
    timers(&start);
    int num_windows = 0;

    // --------------------------------------------------------------
    // Time loop
    for (int sample_index = 0; sample_index < num_samples; sample_index++) {

        int window_index_X = 0;
        int window_index_Y = 0;
        while (window_index_X <= grid_width - window_width && window_index_Y <= grid_height - window_height) {
            
            printf("%d\n", window_index_X + window_index_Y*grid_width);

            for (size_t row_index = border_size; row_index < window_width - border_size; row_index++) {
                for (size_t col_index = border_size; col_index < window_width - border_size; col_index++) {

                    int lin_index = (window_index_Y + row_index)*grid_width + window_index_X + col_index;

                    double result = B1 * (u1[lin_index-1] + u1[lin_index+1] + u1[lin_index-grid_width] + u1[lin_index+grid_width])
                                  + B2 * (u1[lin_index-2] + u1[lin_index+2] + u1[lin_index-2*grid_width] + u1[lin_index+2*grid_width])
                                  + B3 * (u1[lin_index+grid_width-1] + u1[lin_index+grid_width+1] + u1[lin_index-grid_width-1] + u1[lin_index-grid_width+1])
                                  + B4 * u1[lin_index]
                                  + C1 * (u2[lin_index-1] + u2[lin_index+1] + u2[lin_index-grid_width] + u2[lin_index+grid_width])
                                  + C2 * u2[lin_index];
                    
                    u[lin_index] = result;
                }
            }

            window_index_X += window_width - 2*border_size;

            if (window_index_X > grid_width - window_width) {
                window_index_X = 0;
                window_index_Y += window_height - 2*border_size;
            }
        }

        // Add impulse
        if (sample_index == 1) {
            u[inint] += 1.0;
        }
        
        // read output
        out[sample_index] = u[outint];

        // swap pointers
        ptr = u2;
        u2  = u1;
        u1  = u;
        u   = ptr;
    }

    printf("\n\n\n");
    
    timers(&end);
    printf("\nProcess time : %.6f seconds \n", (end-start));

    printf("num windows : %d\n", num_windows);
        
    writeWav(out, out, outputfname.data(), num_samples, samplerate);
    
    // -------------------------------------------------------------------------------
    free(out);
    
    printf("\nComplete...\n");
    return 0;
}
