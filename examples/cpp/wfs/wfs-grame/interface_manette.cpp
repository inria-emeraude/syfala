#include <linux/version.h>
#include <linux/input.h>

#include <string.h>
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
#include <stdint.h>
#include <math.h>

/*
modules kernels à activer pour le support de la manette depuis la zybo
CONFIG_HID_SUPPORT=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_HID=y
CONFIG_INPUT_JOYDEV=y
*/

typedef int8_t i8;
typedef int16_t i16;
typedef uint16_t u16;
typedef int32_t i32;
typedef uint32_t u32;

#define DEV_INPUT_EVENT "/dev/input"
#define EVENT_DEV_NAME "event"
#define SWITCH_CONTROLLER_NAME "Nintendo Co., Ltd. Pro Controller"
#define XBOX_CONTROLLER_NAME "Microsoft X-Box 360 pad"

#define BITS_PER_LONG (sizeof(long) * 8)
#define NBITS(x) ((((x)-1)/BITS_PER_LONG)+1)
#define OFF(x)  ((x)%BITS_PER_LONG)
#define BIT(x)  (1UL<<OFF(x))
#define LONG(x) ((x)/BITS_PER_LONG)
#define test_bit(bit, array)	((array[LONG(bit)] >> OFF(bit)) & 1)

static int is_event_device(const struct dirent *dir) {
	return strncmp(EVENT_DEV_NAME, dir->d_name, 5) == 0;
}

inline float CLIP(float x, float min, float max) {
    return x < min ? min : x > max ? max : x;
}

enum ButtonCodes{

    LStickX = 0,
    LStickY = 1,
    RStickX = 3,
    RStickY = 4,
    DPadX = 16,

    DPadY = 17,
    B = 304,
    A = 305,
    Y = 308,
    X = 307,
    L = 310,
    R = 311,
    L2 = 312,
    R2 = 313,
    Select = 314,
    Start = 315,

    NumButtons = 16
};

enum Directions : u16 {
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

int main() {
// int interface_manette() {

    dirent **namelist;
    int devnum;
    int max_device = 0;

    int num_devices = scandir(DEV_INPUT_EVENT, &namelist, is_event_device, versionsort);
    assert(num_devices > 0 && "n dev est negatif, probleme");

    char filename[64] = {0};
    for (int i = 0; i < num_devices; i++) {

        int file_descriptor = -1;
        char controller_name[256] = "???";

        snprintf(filename, sizeof(filename),
             "%s/%s", DEV_INPUT_EVENT, namelist[i]->d_name);
        file_descriptor = open(filename, 00);
        if (file_descriptor < 0) {
            continue;
        }

        ioctl(file_descriptor, EVIOCGNAME(sizeof(controller_name)), controller_name);


        fprintf(stderr, "%s:    %s\n", filename, controller_name);
        close(file_descriptor);

        if (strcmp(controller_name, SWITCH_CONTROLLER_NAME) == 0
            || strcmp(controller_name, XBOX_CONTROLLER_NAME) == 0)
        {
            sscanf(namelist[i]->d_name, "event%d", &devnum);

            if (devnum > max_device) {
                max_device = devnum;
            }
            break;
        }

        free(namelist[i]);
    }

    int file_descriptor = open(filename, 00);
    if (file_descriptor < 0) {
        printf("Erreur, j'arrive pas a ouvrir le fichier d'input\n");
        return 1;
    }


    struct {
        i16 selected_source = 1;

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

        u16 LStickDirection = None;
        u16 RStickDirection = None;

    } controller_state;


    struct {
        float source1[2] = {0};
        float source2[2] = {0};
        float source3[2] = {0};
        float source4[2] = {0};
    } source_positions;

    input_event events[64];
    bool stop = false;

    const float stick_deadzone_thresh = 0.3f;
    const float time_step_ms = 0.33;
    const float speed = 0.0001;
    const float diagonal_speed = sqrt(2 * speed*speed);


    while (!stop) { // lecture en boucle des entrées
        if (stop) { break; }

        int rd = 0;
        timeval select_timeout;
        select_timeout.tv_sec = 0;
        select_timeout.tv_usec = 10;

        // acquisitions des entrées
        fd_set rdfs;
        FD_ZERO(&rdfs);
        FD_SET(file_descriptor, &rdfs);

        int result = select(file_descriptor + 1, &rdfs, NULL, NULL, &select_timeout);

        if (result == 0) {
            rd = 0;
        } else if (FD_ISSET(file_descriptor, &rdfs)) {
            rd = read(file_descriptor, events, sizeof(events));

            if (rd < (int) sizeof(struct input_event)) {
                printf("expected %d bytes, got %d\n", (int) sizeof(struct input_event), rd);
                perror("\nerreur pendant la lecture, sortie du programme");
                return 1;
            }
        }

        int nb_input_events = rd / sizeof(struct input_event);
        if (nb_input_events) {
            printf("nombre d'event en entrée : %d\n", nb_input_events);
        }

        for (int i = 0; i < nb_input_events; i++) { // reconnaissance des boutons

            u32 event_type = events[i].type;
            u32 event_code = events[i].code;

            if (event_type == 0) {
                continue;
            }

            int button_value = events[i].value;

            switch (event_code) {
                case ButtonCodes::LStickX: {
                    float norm_value = (float)button_value / INT16_MAX;
                    if (norm_value > stick_deadzone_thresh) {
                        controller_state.LStickDirection |= Right;
                        controller_state.LStickDirection &=  ~Left;

                    } else if (norm_value < -stick_deadzone_thresh) {
                        controller_state.LStickDirection |= Left;
                        controller_state.LStickDirection &= ~Right;

                    } else {
                        controller_state.LStickDirection &= ~Right & ~Left;
                    }
                    // printf("Bouton : LStickX ; Valeur : %d\n", controller_state.LStickDirection);
                    break;
                }
                case ButtonCodes::LStickY: {
                    float norm_value = (float)button_value / INT16_MAX;
                    if (norm_value > stick_deadzone_thresh) {
                        controller_state.LStickDirection |= Down;
                        controller_state.LStickDirection &= ~Up;

                    } else if (norm_value < -stick_deadzone_thresh) {
                        controller_state.LStickDirection |= Up;
                        controller_state.LStickDirection &=  ~Down;

                    } else {
                        controller_state.LStickDirection &= ~Up & ~Down;
                    }
                    // printf("Bouton : LStickY ; Valeur : %d\n", controller_state.LStickDirection);
                    break;
                }
                case ButtonCodes::RStickX: {
                    float norm_value = (float)button_value / INT16_MAX;
                    if (norm_value > stick_deadzone_thresh) {
                        controller_state.RStickDirection |= Left;
                        controller_state.RStickDirection &= ~Right;

                    } else if (norm_value < -stick_deadzone_thresh) {
                        controller_state.RStickDirection |= Right;
                        controller_state.RStickDirection &=  ~Left;

                    } else {
                        controller_state.RStickDirection &= ~Right & ~Left;
                    }
                    // printf("Bouton : LStickX ; Valeur : %d\n", controller_state.RStickDirection);
                    break;
                }
                case ButtonCodes::RStickY: {
                    float norm_value = (float)button_value / INT16_MAX;
                    if (norm_value > stick_deadzone_thresh) {
                        controller_state.RStickDirection |= Down;
                        controller_state.RStickDirection &= ~Up;

                    } else if (norm_value < -stick_deadzone_thresh) {
                        controller_state.RStickDirection |= Up;
                        controller_state.RStickDirection &=  ~Down;

                    } else {
                        controller_state.RStickDirection &= ~Up & ~Down;
                    }
                    // printf("Bouton : LStickY ; Valeur : %d\n", controller_state.RStickDirection);
                    break;
                }
                case ButtonCodes::DPadX: {
                    printf("Bouton : DPadX ; Valeur : %d\n", button_value);
                    controller_state.DPadX = button_value;
                    break;
                }
                case ButtonCodes::DPadY: {
                    printf("Bouton : DPadY ; Valeur : %d\n", button_value);
                    controller_state.DPadY = button_value;
                    break;
                }
                case ButtonCodes::A: {
                    printf("Bouton : A ; Valeur : %d\n", button_value);
                    controller_state.A = button_value;
                    if (button_value == 1) {
                        controller_state.selected_source = 1;
                    }
                    break;
                }
                case ButtonCodes::B: {
                    printf("Bouton : B ; Valeur : %d\n", button_value);
                    controller_state.B = button_value;
                    if (button_value == 1) {
                        controller_state.selected_source = 2;
                    }
                    break;
                }
                case ButtonCodes::Y: {
                    printf("Bouton : Y ; Valeur : %d\n", button_value);
                    controller_state.Y = button_value;
                    if (button_value == 1) {
                        controller_state.selected_source = 3;
                    }
                    break;
                }
                case ButtonCodes::X: {
                    printf("Bouton : X ; Valeur : %d\n", button_value);
                    controller_state.X = button_value;
                    if (button_value == 1) {
                        controller_state.selected_source = 4;
                    }
                    break;
                }
                case ButtonCodes::L: {
                    printf("Bouton : L ; Valeur : %d\n", button_value);
                    controller_state.L = button_value;
                    break;
                }
                case ButtonCodes::R: {
                    printf("Bouton : R ; Valeur : %d\n", button_value);
                    controller_state.R = button_value;
                    break;
                }
                case ButtonCodes::L2: {
                    printf("Bouton : L2 ; Valeur : %d\n", button_value);
                    controller_state.L2 = button_value;
                    break;
                }
                case ButtonCodes::R2: {
                    printf("Bouton : R2 ; Valeur : %d\n", button_value);
                    controller_state.R2 = button_value;
                    break;
                }
                case ButtonCodes::Select: {
                    printf("Bouton : Select ; Valeur : %d\n", button_value);
                    controller_state.Select = button_value;
                    break;
                }
                case ButtonCodes::Start: {
                    printf("Bouton : Start ; Valeur : %d\n", button_value);
                    controller_state.Start = button_value;
                    break;
                }
                default: {
                    printf("Bouton pressé inconnu.\n");
                }
            }
        }

        // printf("Source selectionnée : %d\n", controller_state.selected_source);

        float* source = nullptr;
        switch (controller_state.selected_source) {
            case 1: { source = source_positions.source1; break; }
            case 2: { source = source_positions.source2; break; }
            case 3: { source = source_positions.source3; break; }
            case 4: { source = source_positions.source4; break; }
        }

        bool source_has_moved = false;
        switch (controller_state.LStickDirection) {
            case Up: {
                source[1] = CLIP(source[1] + speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case Right: {
                source[0] = CLIP(source[0] + speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case Down: {
                source[1] = CLIP(source[1] - speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case Left: {
                source[0] = CLIP(source[0] - speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case UpRight: {
                source[0] = CLIP(source[0] + diagonal_speed, 0.0f, 1.0f);
                source[1] = CLIP(source[1] + diagonal_speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case DownRight: {
                source[0] = CLIP(source[0] - diagonal_speed, 0.0f, 1.0f);
                source[1] = CLIP(source[1] + diagonal_speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case DownLeft: {
                source[0] = CLIP(source[0] - diagonal_speed, 0.0f, 1.0f);
                source[1] = CLIP(source[1] - diagonal_speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case UpLeft: {
                source[0] = CLIP(source[0] + diagonal_speed, 0.0f, 1.0f);
                source[1] = CLIP(source[1] - diagonal_speed, 0.0f, 1.0f);
                source_has_moved = true;
                break;
            }
            case None:
            default: {}
        }

        // if (source_has_moved) {
        //     printf("Source %d : %.4f, %.4f\n", controller_state.selected_source, source[0], source[1]);
        // }
        // printf("source1 position : %.4f, %.4f\n", source_positions.source1[0], source_positions.source1[1]);
        // printf("source2 position : %.4f, %.4f\n", source_positions.source2[0], source_positions.source2[1]);
        // printf("source3 position : %.4f, %.4f\n", source_positions.source3[0], source_positions.source3[1]);
        // printf("source4 position : %.4f, %.4f\n", source_positions.source4[0], source_positions.source4[1]);


        if (controller_state.Start == 1 && controller_state.Select == 1) {
            printf("Start + Select : sortie de l'application\n");
            stop = true;
        }

        usleep(time_step_ms * 1000);
    }

    close(file_descriptor);
    return 0;
}
