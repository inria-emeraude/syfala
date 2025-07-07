#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/uart.hpp>
#include <syfala/arm/ip.hpp>
#include <syfala/arm/memory.hpp>

#include <linux/version.h>
#include <linux/input.h>

// #include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <getopt.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/select.h>
#include <assert.h>
#include <string>
#include <stdint.h>
#include <math.h>

#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

typedef int8_t i8;
typedef int16_t i16;
typedef uint16_t u16;
typedef int32_t i32;
typedef uint32_t u32;

#define global_const static const
#define local_const static const
#define global static
#define local_persist static

// Ideally this should be declared in a shared .h file but this seems to break the system
#define NSOURCES    8       // number of sources...
#define INPUTS      0       // number of audio inputs to the hls
#define OUTPUTS     32      // number of speakers...
#define BLOCK_SIZE  1024    // audio block size, different from the HLS audio block size (16)

#define DEV_INPUT_EVENT         "/dev/input"
#define EVENT_DEV_NAME          "event"
// The controller has to respect the "Microsoft X-Box 360 pad" protocol
#define XBOX_CONTROLLER_NAME    "Microsoft X-Box 360 pad"

static inline float norm(float x1, float y1, float x2, float y2){
    return sqrtf(powf((x1-x2),2.0) + powf((y1-y2),2.0));
}

static inline float atodb(float amp) {
    return 20.0f * log10f(amp);
}

static inline float dbtoa(float amp) {
    return powf(10.0f, amp/20.0f);
}

int is_event_device(const struct dirent *dir) {
	return strncmp(EVENT_DEV_NAME, dir->d_name, 5) == 0;
}

static inline float CLIP(float x, float min, float max) {
    return x < min ? min : x > max ? max : x;
}

static inline float scale(float x, float min, float max, float newmin, float newmax) {
    return (x - min) / (max - min) * (newmax - newmin) + newmin;
}

// global_const int isTUI = false;

// const static float speakers_dist = 0.0783f;
global_const float speakers_dist = 0.061f;
global_const float sound_speed = 340.0f;
global_const float xref = 0.0f;
global_const float yref = 0.0f;
global_const float static_gain = dbtoa(-3.0f);

global_const u32 mem_f_buffer_size = NSOURCES * BLOCK_SIZE;
global_const u32 nbuffers = 32;
global_const u32 mem_f_length = mem_f_buffer_size * nbuffers;


using namespace Syfala::ARM;


enum ButtonCodes {

    LStickX = 0,
    LStickY = 1,
    RStickX = 3,
    RStickY = 4,
    DPadX = 16,

    DPadY = 17,
    B = 304,
    A = 305,
    Y = 307,
    X = 308,
    L = 310,
    R = 311,
    L2 = 312,
    R2 = 313,
    Select = 314,
    Start = 315,

    NumButtons = 16
};


enum Directions: u16 {
    None = 0,
    Up = 1,
    Right = 2,
    Down = 4,
    Left = 8,
    UpRight = Up | Right,
    DownRight = Down | Right,
    DownLeft = Down | Left,
    UpLeft = Up | Left
};


struct Sources {
    float xs[NSOURCES] = {0};
    float ys[NSOURCES] = {0};

    float x_speakers_pos[OUTPUTS];
    float speakers_norm[OUTPUTS];

    float control_values[NSOURCES*OUTPUTS*2] = {0};

    float volume_control = 0.1f;
    float active = 1.0f;
    i32 selected_source = 0;
};


struct PositionSmoother {
    float b0;
    float a1;
    float states[NSOURCES];
};


struct Controller {

    struct {
        i16 DPadX = 0;
        i16 DPadY = 0;
        i16 B = 0;
        i16 A = 0;
        i16 Y = 0;
        i16 X = 0;
        i16 L = 0;
        i16 R = 0;
        i16 L2 = 0;
        i16 R2 = 0;
        i16 Select = 0;
        i16 Start = 0;
    } state;

    struct {
        u16 L = None;
        u16 R = None;
        float x_speed = 0.0f;
        float y_speed = 0.0f;
    } stick_directions;

    i32 file_descriptor = -1;
    bool change_demo_and_reset = false;
};


enum Demos {
    DemoCarlSagan,
    DemoRock,
    NDemos,
};


struct AudioFile {
    drwav wav;
    u32 write_index = 0;
    i32 file_index = 0;
    u32 demo_index = DemoCarlSagan;
    std::string filenames[2] { "carlsagan.wav", "demo_romain.wav" };
    // float sample_buffer[mem_f_buffer_size] = {0};
};


static void init_audio_file(AudioFile *audiofile, Memory::data *mem) {

    drwav_bool32 ok = drwav_init_file(&audiofile->wav, audiofile->filenames[audiofile->file_index].data(), NULL);
    assert(ok && "Erreur dans la lecture du fichier audio\n");

    fprintf(stderr, "Nom du fichier audio : %s\n", audiofile->filenames[audiofile->file_index].data());
    fprintf(stderr, "Longueur du fichier en frames : %d\n", (int)audiofile->wav.totalPCMFrameCount);
    fprintf(stderr, "Samplerate du fichier : %d\n", (int)audiofile->wav.sampleRate);
    fprintf(stderr, "Nombre de canaux du fichier : %d\n", (int)audiofile->wav.channels);

    assert(NSOURCES == audiofile->wav.channels);

    // preremplir mem_zone_f
    // for (u32 block_index = 0; block_index < nbuffers; block_index++) {
    //     drwav_read_pcm_frames_f32(&audiofile->wav, BLOCK_SIZE, &mem->f_zone[block_index*mem_f_buffer_size]);
    // }

    memset(mem->f_zone, 0, mem_f_length * sizeof(float));
}

static void init_sources(Sources *sources, u32 demo_index) {

    for (int input_index = 0; input_index < NSOURCES; ++input_index) {
        sources->xs[input_index] = 0.0f;
        sources->ys[input_index] = 12.0f;
    }

    // initialisation des sources différente et manuelle pour chaque demo
    if (demo_index == DemoCarlSagan) {
        sources->xs[0] = 0.0f;
        sources->ys[0] = 2.0f;
    }

    if (demo_index == DemoRock) {
        sources->xs[0] = 0.0f;
        sources->ys[0] = 2.0f;

        sources->xs[1] = -0.7f;
        sources->xs[2] = 0.0f;
        sources->xs[3] = 0.7f;
    }
}

static void init_controller(Controller *controller) {

    dirent **namelist;
    i32 devnum;
    i32 max_device = 0;

    i32 num_devices = scandir(DEV_INPUT_EVENT, &namelist, is_event_device, versionsort);
    assert(num_devices > 0 && "num_dev est negatif, la manette n'est pas detectée ou pas branchée");

    char controller_name[256] = "???";

    char controller_filename[256] = {0};
    for (int i = 0; i < num_devices; i++) {

        snprintf(controller_filename, sizeof(controller_filename),
             "%s/%s", DEV_INPUT_EVENT, namelist[i]->d_name);
        controller->file_descriptor = open(controller_filename, 00);
        if (controller->file_descriptor < 0) {
            continue;
        }

        ioctl(controller->file_descriptor, EVIOCGNAME(sizeof(controller_name)), controller_name);

        close(controller->file_descriptor);

        if (strcmp(controller_name, XBOX_CONTROLLER_NAME) == 0)
        {
            sscanf(namelist[i]->d_name, "event%d", &devnum);
            if (devnum > max_device) {
                max_device = devnum;
            }
            break;
        }
        free(namelist[i]);
    }

    controller->file_descriptor = open(controller_filename, 00);
    if (controller->file_descriptor < 0) {
        printf("Erreur, impossible d'ouvrir %s\n", controller_filename);
        exit(-1);
    }

    fprintf(stderr, "Manette ouverte : %s: %s\n", controller_filename, controller_name);
}

static void get_controller_events(Controller *controller, XSyfala *dsp, Sources *sources) {
    ssize_t rd = 0;

    local_const float stick_deadzone = 0.1f;

    timeval select_timeout;
    select_timeout.tv_sec = 0;
    select_timeout.tv_usec = 10;

    input_event events[64];

    // read file events
    fd_set rdfs;
    FD_ZERO(&rdfs);
    FD_SET(controller->file_descriptor, &rdfs);

    int result = select(controller->file_descriptor + 1, &rdfs, NULL, NULL, &select_timeout);
    if (result == 0) {
        rd = 0;
    } else if (FD_ISSET(controller->file_descriptor, &rdfs)) {
        rd = read(controller->file_descriptor, events, sizeof(events));

        if (rd < (int) sizeof(struct input_event)) {
            printf("expected %d bytes, got %d\n", (int) sizeof(struct input_event), (int)rd);
            assert(false && "\nerreur pendant la lecture, sortie du programme");
        }
    }

    // ------------ Reconnaissance des boutons pressés ------------
    i32 nb_input_events = (i32)rd / sizeof(struct input_event);
    for (int i = 0; i < nb_input_events; i++) {

        u32 event_type = events[i].type;
        u32 event_code = events[i].code;

        if (event_type == 0) { continue; }

        i16 button_value = (i16)events[i].value;

        local_const float inv_int16_max = 1.0f/INT16_MAX;

        switch (event_code) {
            case ButtonCodes::LStickX: {
                float norm_value = (float)button_value * inv_int16_max;
                if (norm_value > stick_deadzone) {
                    controller->stick_directions.L |= Right;
                    controller->stick_directions.L &=  ~Left;
                    controller->stick_directions.x_speed = norm_value;

                } else if (norm_value < -stick_deadzone) {
                    controller->stick_directions.L |= Left;
                    controller->stick_directions.L &= ~Right;
                    controller->stick_directions.x_speed = norm_value;

                } else {
                    controller->stick_directions.L &= ~Right & ~Left;
                    controller->stick_directions.x_speed = 0.0f;
                }
                // printf("Bouton : LStickX ; Valeur : %d\n", controller->stick_directions.L);
                break;
            }
            case ButtonCodes::LStickY: {
                float norm_value = (float)button_value * inv_int16_max;
                if (norm_value > stick_deadzone) {
                    controller->stick_directions.L |= Down;
                    controller->stick_directions.L &= ~Up;
                    controller->stick_directions.y_speed = -norm_value;

                } else if (norm_value < -stick_deadzone) {
                    controller->stick_directions.L |= Up;
                    controller->stick_directions.L &=  ~Down;
                    controller->stick_directions.y_speed = -norm_value;

                } else {
                    controller->stick_directions.L &= ~Up & ~Down;
                    controller->stick_directions.y_speed = 0.0f;
                }
                // printf("Bouton : LStickY ; Valeur : %d\n", controller->stick_directions.L);
                break;
            }
            case ButtonCodes::RStickX: { break; }
            case ButtonCodes::RStickY: { break; }
            case ButtonCodes::DPadX: {
                // printf("Bouton : DPadX ; Valeur : %d\n", button_value);
                controller->state.DPadX = button_value;
                break;
            }
            case ButtonCodes::DPadY: {
                // printf("Bouton : DPadY ; Valeur : %d\n", button_value);
                controller->state.DPadY = button_value;

                if (button_value == -1) {
                    sources->volume_control = CLIP(sources->volume_control + 0.1f, 0.0f, 1.0f);

                } else if (button_value == +1) {
                    sources->volume_control = CLIP(sources->volume_control - 0.1f, 0.0f, 1.0f);
                }

                printf("Volume : %.4f\n", sources->volume_control);

                float send_value = sources->volume_control * sources->active * static_gain;

                XSyfala_Set_gain(dsp, *reinterpret_cast<u32*>(&send_value));

                break;
            }

            case ButtonCodes::A: {
                printf("Bouton : A ; Valeur : %d\n", button_value);
                controller->state.A = button_value;
                if (button_value == 1) {
                    sources->selected_source = 0;
                }
                break;
            }
            case ButtonCodes::B: {
                printf("Bouton : B ; Valeur : %d\n", button_value);
                controller->state.B = button_value;
                if (button_value == 1) {
                    sources->selected_source = 1;
                }
                break;
            }
            case ButtonCodes::Y: {
                printf("Bouton : Y ; Valeur : %d\n", button_value);
                controller->state.Y = button_value;
                if (button_value == 1) {
                    sources->selected_source = 2;
                }
                break;
            }
            case ButtonCodes::X: {
                printf("Bouton : X ; Valeur : %d\n", button_value);
                controller->state.X = button_value;
                if (button_value == 1) {
                    sources->selected_source = 3;
                }
                break;
            }
            case ButtonCodes::L: {
                printf("Bouton : L ; Valeur : %d\n", button_value);
                controller->state.L = button_value;
                break;
            }
            case ButtonCodes::R: {
                printf("Bouton : R ; Valeur : %d\n", button_value);
                controller->state.R = button_value;
                break;
            }
            case ButtonCodes::L2: { break; }
            case ButtonCodes::R2: { break; }
            case ButtonCodes::Select: {
                printf("Bouton : Select ; Valeur : %d\n", button_value);
                controller->state.Select = button_value;
                break;
            }
            case ButtonCodes::Start: {
                printf("Bouton : Start ; Valeur : %d\n", button_value);
                controller->state.Start = button_value;
                break;
            }
            default: {
                printf("Bouton pressé inconnu.\n");
            }
        }
    }

    // toggle active
    if (controller->state.Start == 1 && controller->state.Select == 1) {

        sources->active += 1.0f;
        if (sources->active > 1.0f) { sources->active = 0.0f; }

        float send_value = sources->volume_control * sources->active;

        fprintf(stderr, "Start + Select : mute\n");
        XSyfala_Set_gain(dsp, *reinterpret_cast<u32*>(&send_value));

        controller->state.Start = 0;
        controller->state.Select = 0;
    }

    if (controller->state.Select == 1
        && controller->state.R == 1 && controller->state.L == 1)
    {
        fprintf(stderr, "Start + Select + R + L : changement de la demo et reinitialisation.\n");
        controller->change_demo_and_reset = true;

        controller->state.R = 0;
        controller->state.L = 0;
        controller->state.Select = 0;
    }
}


static void update_sources_positions(Controller *controller, Sources *sources) {

    // printf("Source selectionnée : %d\n", controller.sources->selected_source);
    local_const float minX = sources->x_speakers_pos[0];
    local_const float maxX = sources->x_speakers_pos[OUTPUTS-1];
    local_const float minY = 1.5f;
    local_const float maxY = 15.0f;

    local_const float max_speed = 0.01f;
    local_const float min_speed = 0.001f;
    // local_const float speed = 0.001f;
    // local_const float diagonal_speed = sqrtf(2.0f * speed*speed);

    u32 source_index = sources->selected_source;

    float x_speed = controller->stick_directions.x_speed;
    float y_speed = controller->stick_directions.y_speed;

    x_speed = scale(x_speed, -1.0f, 1.0f, -max_speed, max_speed);
    y_speed = scale(y_speed, -1.0f, 1.0f, -max_speed, max_speed);

    // dispatch the direction of the stick
    bool source_has_moved = false;
    switch (controller->stick_directions.L) {
        case Up: {
            sources->ys[source_index] = CLIP(sources->ys[source_index] + y_speed, minY, maxY);
            source_has_moved = true;
            break;
        }
        case Right: {
            sources->xs[source_index] = CLIP(sources->xs[source_index] + x_speed, minX, maxX);
            source_has_moved = true;
            break;
        }
        case Down: {
            sources->ys[source_index] = CLIP(sources->ys[source_index] + y_speed, minY, maxY);
            source_has_moved = true;
            break;
        }
        case Left: {
            sources->xs[source_index] = CLIP(sources->xs[source_index] + x_speed, minX, maxX);
            source_has_moved = true;
            break;
        }
        case UpRight: {
            sources->xs[source_index] = CLIP(sources->xs[source_index] + x_speed, minX, maxX);
            sources->ys[source_index] = CLIP(sources->ys[source_index] + y_speed, minY, maxY);
            source_has_moved = true;
            break;
        }
        case DownRight: {
            sources->xs[source_index] = CLIP(sources->xs[source_index] + x_speed, minX, maxX);
            sources->ys[source_index] = CLIP(sources->ys[source_index] + y_speed, minY, maxY);
            source_has_moved = true;
            break;
        }
        case DownLeft: {
            sources->xs[source_index] = CLIP(sources->xs[source_index] + x_speed, minX, maxX);
            sources->ys[source_index] = CLIP(sources->ys[source_index] + y_speed, minY, maxY);
            source_has_moved = true;
            break;
        }
        case UpLeft: {
            sources->xs[source_index] = CLIP(sources->xs[source_index] + x_speed, minX, maxX);
            sources->ys[source_index] = CLIP(sources->ys[source_index] + y_speed, minY, maxY);
            source_has_moved = true;
            break;
        }
        case None:
        default: {}
    }

    // printf("------------------------------------------\n");
    if (source_has_moved) {
        fprintf(stderr, "Source %d : %.4f, %.4f\n", sources->selected_source, sources->xs[source_index], sources->ys[source_index]);
    }
}


static void load_and_write_audio_to_HLS(AudioFile *audiofile, Memory::data *mem, XSyfala *dsp) {

    u32 hls_current_index = XSyfala_Get_hls_current_index(dsp);

    if (!(audiofile->write_index < hls_current_index
        && audiofile->write_index + mem_f_buffer_size > hls_current_index))
    {
        // fprintf(stderr, "hls current reading index : %d\n", hls_current_index);
        u32 frames_read = (u32)drwav_read_pcm_frames_f32(&audiofile->wav, BLOCK_SIZE, &mem->f_zone[audiofile->write_index]);

        if (frames_read < BLOCK_SIZE) {
            u32 remaining_frames = BLOCK_SIZE - frames_read;
            drwav_seek_to_pcm_frame(&audiofile->wav, 0);
            fprintf(stderr, "Rembobinnage\n");

            frames_read = (u32)drwav_read_pcm_frames_f32(&audiofile->wav, remaining_frames, &mem->f_zone[audiofile->write_index + (frames_read)*NSOURCES]);
            assert(frames_read == remaining_frames);
        }

        // fprintf(stderr, "Wrote to mem_f, last sample : %.4f\n", mem->f_zone[audiofile->write_index]);
        audiofile->write_index += mem_f_buffer_size;
        if (audiofile->write_index >= mem_f_length) { audiofile->write_index = 0; }
    }

    // u32 hls_last_sample_int = XSyfala_Get_last_sample(dsp);
    // float hls_last_sample = *(float*)(&hls_last_sample_int);
    // fprintf(stderr, "Last sample from hls %.4f\n", hls_last_sample);
}


static void write_positions_to_HLS(Sources *sources, XSyfala *dsp) {

    local_persist float r[OUTPUTS];
    for (int input_index = 0; input_index < NSOURCES; ++input_index){
        float r_long = 1000.0f;

        for (int output_index = 0; output_index < OUTPUTS; ++output_index){
            r[output_index] = norm(sources->xs[input_index], sources->ys[input_index], sources->x_speakers_pos[output_index], 1.0f);
            if (r[output_index] < r_long) {
                r_long = r[output_index];
            }
        }

        for (int output_index = 0; output_index < OUTPUTS; ++output_index){
            int d_idx = output_index + OUTPUTS*input_index*2;
            int g_idx = d_idx + OUTPUTS;
            sources->control_values[g_idx] = sources->speakers_norm[output_index]*sources->ys[input_index]/powf(r[output_index], 2.0f);
            sources->control_values[d_idx] = (r[output_index] - r_long)/sound_speed*SYFALA_SAMPLE_RATE;
        }
    }
    XSyfala_Write_ctrl_Words(dsp, 0, reinterpret_cast<u32*>(sources->control_values), NSOURCES*OUTPUTS*2);
}



int main() {

    XSyfala dsp;

    // UART & GPIO should be initialized first,
    // i.e. before outputing any information on leds & stdout.
    GPIO::initialize();
    // Wait for all peripherals to be initialized
    Status::waiting("[status] Initializing peripherals & modules");
    Audio::initialize();
    DSP::initialize(dsp);

    Memory::data mem;
    Memory::initialize(dsp, mem, 0, mem_f_length);


    // ------------ sources initialisation ------------
    Sources sources;
    local_const float time_step_ms = 5.0;

    // set the speakers positions
    for (int output_index = 0; output_index < OUTPUTS; ++output_index) {
        sources.x_speakers_pos[output_index] = -speakers_dist*OUTPUTS/2.0f + speakers_dist/2.0f + (float)output_index*speakers_dist;
        sources.speakers_norm[output_index] = norm(xref, yref, sources.x_speakers_pos[output_index], 1.0);
    }

    Controller controller;
    AudioFile audiofile;

    bool initialisation = true;
    // ------------ main loop ------------
    while (1) {

        if (controller.change_demo_and_reset || initialisation) {
            if (controller.change_demo_and_reset) {

                DSP::set_arm_ok(&dsp, false);
                Status::waiting("Changing the demo and reseting...\n");

                if (audiofile.file_index == DemoCarlSagan) {
                    audiofile.file_index = DemoRock;

                } else if (audiofile.file_index == DemoRock) {
                    audiofile.file_index = DemoCarlSagan;
                }

                close(controller.file_descriptor);
                drwav_uninit(&audiofile.wav);
            }


            init_controller(&controller);

            init_sources(&sources, audiofile.demo_index);

            init_audio_file(&audiofile, &mem);
            XSyfala_Set_gain(&dsp, *reinterpret_cast<u32*>(&sources.volume_control));


            DSP::set_arm_ok(&dsp, true);
            Status::ok("[status] arm_ok : lancement de la boucle de traitement...\n");

            controller.change_demo_and_reset = false;
            initialisation = false;
        }

        get_controller_events(&controller, &dsp, &sources);

        update_sources_positions(&controller, &sources);

        load_and_write_audio_to_HLS(&audiofile, &mem, &dsp);

        write_positions_to_HLS(&sources, &dsp);

        // fprintf(stderr, "Done transfering data\n");

        usleep(time_step_ms * 1000);
    }

    close(controller.file_descriptor);
    drwav_uninit(&audiofile.wav);
    return 0;
}
