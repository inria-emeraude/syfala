#include <syfala/utilities.hpp>
#include <syfala/../../tests/csim/csim_template_utilities.hpp>
#include <hls_stream.h>

#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

typedef int8_t i8;
typedef int16_t i16;
typedef uint16_t u16;
typedef int32_t i32;
typedef uint32_t u32;
typedef uint64_t u64;

#define INPUTS 8 // number of sources...
#define OUTPUTS 32 // number of speakers...
#define BLOCK_SIZE 1024
#define SYFALA_BLOCK_NSAMPLES 16

const static float speakers_dist = 0.061f;

#include "wfs_hls.cpp"

static const int isTUI = false;

static const float sound_speed = 340.0;
static const float xref = 0;
static const float yref = 0;

static float x_speakers_pos[OUTPUTS] = {0};
static float speakers_norm[OUTPUTS] = {0};

static float control_values[INPUTS*OUTPUTS*2] = {0};

static void error_hdl(int no, const char* m, const char* path) {
    fprintf(stderr, "Error starting OSC client: %d, %s, %s\n", no, m, path);
}

static float norm(float x1, float y1, float x2, float y2){
    return sqrt(pow((x1-x2),2.0) + pow((y1-y2),2.0));
}

static inline float atodb(float amp) {
    return 20.0 * log10f(amp);
}

static inline float dbtoa(float amp) {
    return powf(10.0f, amp/20.0f);
}

#define CLIP(x, min, max) (x < min ? min : x > max ? max : x)

static const std::string input_filename = "test_signal.wav";
static const std::string output_filename = "csim_output_file.wav";


int main() {
    AudioFile<float> output_file;

    drwav wav;
    drwav_result result;

    drwav_bool32 ok = drwav_init_file(&wav, input_filename.data(), NULL);
    assert(ok && "Erreur dans la lecture du fichier audio\n");

    drwav_uint64 file_cursor = 0;

    fprintf(stderr, "Longueur du fichier en frames : %d\n", (int)wav.totalPCMFrameCount);
    fprintf(stderr, "Samplerate du fichier : %d\n", (int)wav.sampleRate);
    fprintf(stderr, "Nombre de canaux du fichier : %d\n", (int)wav.channels);

    assert(INPUTS == wav.channels);

    output_file.setNumChannels(OUTPUTS);
    output_file.setNumSamplesPerChannel(wav.totalPCMFrameCount *3);
    output_file.setSampleRate(wav.sampleRate);
    // output_file.printSummary();

    static const u32 mem_f_buffer_size = INPUTS * BLOCK_SIZE;
    static const u32 nbuffers = 32;
    static const u32 mem_f_length = mem_f_buffer_size * nbuffers;

    // float* mem_f = (float*)calloc(mem_f_length, sizeof(float));
    float mem_f[mem_f_length] = {0};
    float sample_buffer[mem_f_buffer_size] = {0};
    sy_ap_int audio_out[OUTPUTS][SYFALA_BLOCK_NSAMPLES];

    u32 write_index = 0;
    int hls_current_index = 0;

    bool i2s_rst = false;

    float sources[INPUTS][2] = {0};

    sources[0][0] = 0.0;
    sources[0][1] = 1.5;

    // sources[1][0] = -2.0;
    // sources[1][1] = 1.5;

    for (int i = 1; i < INPUTS; ++i) {
        sources[i][0] = 0.0f;
        sources[i][1] = 1.5f;
    }

    u32 output_file_cursor = 0;

    for (int o = 0; o < OUTPUTS; ++o) {
        x_speakers_pos[o] = -speakers_dist*OUTPUTS/2.0f + speakers_dist/2.0f + o*speakers_dist;
        speakers_norm[o] = norm(xref,yref,x_speakers_pos[o], 1.0f);
    }


    // preremplir mem_zone_f
    for (u32 block_index = 0; block_index < nbuffers; block_index++) {
        u32 frames_read = drwav_read_pcm_frames_f32(&wav, BLOCK_SIZE, &mem_f[block_index*mem_f_buffer_size]);
    }

    while(output_file_cursor < output_file.getNumSamplesPerChannel()) {
        if (!(write_index < hls_current_index
            && (write_index + mem_f_buffer_size) > hls_current_index))
        {
            u64 frames_read = drwav_read_pcm_frames_f32(&wav, BLOCK_SIZE, &mem_f[write_index]);

            if (frames_read < BLOCK_SIZE) {
                u32 remaining_frames = BLOCK_SIZE - frames_read;
                drwav_seek_to_pcm_frame(&wav, 0);
                // printf("Rembobinnage\n");

                frames_read = drwav_read_pcm_frames_f32(&wav, remaining_frames, &mem_f[write_index + (frames_read)*INPUTS]);
                assert(frames_read == remaining_frames);
            }

            write_index += mem_f_buffer_size;
            if (write_index >= mem_f_length) { write_index = 0; }



            // ------------ ecriture des positions ------------
            float r[OUTPUTS];
            for (int i = 0; i < INPUTS; ++i){
                float r_long = 1000.0f;

                for (int o = 0; o < OUTPUTS; ++o){
                    r[o] = norm(sources[i][0], sources[i][1], x_speakers_pos[o], 1.0f);
                    if (r[o] < r_long) { r_long = r[o]; }
                }

                for (int o = 0; o < OUTPUTS; ++o){
                    int d_idx = o + OUTPUTS*i*2;
                    int g_idx = d_idx + OUTPUTS;
                    control_values[g_idx] = speakers_norm[o]*sources[i][1]/pow(r[o], 2.0f);
                    control_values[d_idx] = (r[o] - r_long)/sound_speed*SYFALA_SAMPLE_RATE;
                }
            }
        }
        // else {
        //     printf("trop en avance, attente\n");

        // }

        float hls_last_sample = 0.0f;

        syfala(
            nullptr, audio_out,
            1, &i2s_rst,
            mem_f, nullptr,
            false, false, false,
            control_values,
            &hls_current_index,
            mem_f_length,
            1.0f,
            &hls_last_sample
        );

        printf("Last hls sample : %.4f\n", hls_last_sample);

        for (u32 channel_index = 0; channel_index < OUTPUTS; channel_index++) {
            for (u32 sample_index = 0; sample_index < SYFALA_BLOCK_NSAMPLES; sample_index++) {

                float sample = Syfala::HLS::ioreadf(audio_out[channel_index][sample_index]);
                output_file.samples[channel_index][output_file_cursor+sample_index] = sample;
            }
        }
        output_file_cursor += SYFALA_BLOCK_NSAMPLES;


    }

    result = output_file.save(output_filename, AudioFileFormat::Wave);

    return 0;
}