
#include <string>
#include <stdio.h>
#include <unistd.h>
#include <iostream>
#include <thread>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <termios.h>
#include <time.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>

#include <syfala/utilities.hpp>

#include <faust/gui/GTKUI.h>
#include <faust/gui/meta.h>
#include <faust/dsp/dsp.h>
#include <faust/gui/DecoratorUI.h>

#if SYFALA_CONTROL_HTTP // --------
    #include <faust/gui/httpdUI.h>
#endif
#if SYFALA_CONTROL_MIDI // --------
    #include <faust/gui/MidiUI.h>
    #include <faust/midi/rt-midi.h>
    #include <faust/midi/RtMidi.cpp>
#endif
#if SYFALA_CONTROL_OSC // ---------
    #include <faust/gui/OSCUI.h>
#endif // -------------------------

#define FAUST_UIMACROS
#define FAUST_ADDBUTTON(l,f)
#define FAUST_ADDCHECKBOX(l,f)
#define FAUST_ADDVERTICALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDHORIZONTALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDNUMENTRY(l,f,i,a,b,s)
#define FAUST_ADDVERTICALBARGRAPH(l,f,a,b)
#define FAUST_ADDHORIZONTALBARGRAPH(l,f,a,b)

#ifdef SYFALA_TESTING_PRECOMPILED
    #include FAUST_PRECOMPILED_EXAMPLE_GUI_TARGET
#else
    <<includeIntrinsic>>
    <<includeclass>>
#endif

#define SERIAL_PORT "/dev/ttyUSB1"

std::list<GUI*> GUI::fGuiList;
ztimedmap GUI::gTimedZoneMap;

#if (SYFALA_UART_BAUD_RATE == 115200)
    #define BAUD_RATE B115200
#elif (SYFALA_UART_BAUD_RATE == 921600)
    #define BAUD_RATE B921600
#endif

namespace UART
{
using byte_t = uint8_t;

struct Message {
    int index = 0;
    float value = 0;
};

using Queue = std::vector<Message>;

struct Result {
    Message msg;
    bool valid = false;
};

struct Data {
    int fd;
    bool running = false;
    std::thread thread;
};

/**
 * @brief initialize low-level file device.
 */
static void initialize(UART::Data& u) {
    struct termios options;
    u.fd = open(SERIAL_PORT, O_RDWR | O_NOCTTY | O_NDELAY);
    if (u.fd == -1) {
        printf("Error %d opening /dev/ttyUSB1: %s\n", errno, strerror(errno));
        exit(1);
    }
    // Open the device in nonblocking mode
    fcntl(u.fd, F_SETFL, FNDELAY);
    // Get the current options of the port
    tcgetattr(u.fd, &options);
    // Clear all the options
    bzero(&options, sizeof(options));
    // Prepare speed (Bauds)
    speed_t speed = BAUD_RATE;
    // Set the baud rate
    cfsetispeed(&options, speed);
    cfsetospeed(&options, speed);
    // Configure the device : 8 data bits, no parity, no control
    options.c_cflag |= ( CLOCAL | CREAD |  CS8);
    options.c_iflag |= ( IGNPAR | IGNBRK );
    // Timer unused
    options.c_cc[VTIME] = 0;
    // At least on character before satisfy reading
    options.c_cc[VMIN] = 0;
    // Activate the settings
    if (tcsetattr(u.fd, TCSANOW, &options) != 0) {
        printf("error from tcsetattr: %s\n", strerror(errno));
        exit(errno);
    }
}

/**
 * @brief read uart messages from sys, using file device.
 */
static Result read_message(UART::Data& d) {
    Result r;
    int nbytes = read(d.fd, &r.msg, sizeof(Message));
    if (nbytes >= sizeof(Message)) {
        r.valid = true;
    }
    return r;
}

/**
 * @brief Write contents of an uart message to the
 * uart file device.
 */
static void write_message(UART::Data& d, Message m) {
    // Write message as an 8-byte sequence
    int nbytes = write(d.fd, &m, sizeof(Message));
    if (nbytes < sizeof(Message)) {
        fprintf(stderr, "[uart] incomplete message sent: %d bytes\n", nbytes);
    }
    if (nbytes < 0) {
        perror("[uart] Error while writing data");
        exit(1);
    } else {
//        printf("[uart] written %d bytes\n", nbytes);
    }
}
}

// ----------------------------------------------------------------------------

enum controller_direction { Active, Passive };

struct Controller {
    float* zone = nullptr;
    float value = 0.f;
    controller_direction io;
};

struct Control : public GenericUI
{
    std::map<int, Controller> controllers;
    UART::Queue mqueue;

    void add_controller(FAUSTFLOAT* zone, const char* name, controller_direction io) {
        printf("Declaring parameter %s at index %d\n", name, (int)controllers.size());
        auto c = Controller { zone, *zone, io };
        controllers.emplace(std::make_pair(controllers.size(), c));
    }
    void addHorizontalSlider(const char *label, float *zone, float, float, float, float)
    final override {
        add_controller(zone, label, Active);
    }

    void addButton(const char *label, float *zone) final override {
        add_controller(zone, label, Active);
    }

    void addVerticalSlider(const char *label, float *zone, float, float, float, float) final override {
        add_controller(zone, label, Active);
    }

    void addNumEntry(const char *label, float *zone, float, float, float, float)
    final override {
        add_controller(zone, label, Active);
    }

    void addVerticalBargraph(const char *label, float *zone, float, float)
    final override {
        add_controller(zone, label, Passive);
    }
};

/**
 * @brief update passive controller values,
 */
void update(Control& ctrl, UART::Message m) {
    if (m.index < ctrl.controllers.size()) {
        auto& controller = ctrl.controllers[m.index];
        if (controller.io == Passive) {
            *controller.zone = m.value;
        }
    }
}

/**
 * @brief If controller values changed from last loop iteration,
 * push a new UART::Message with the new value in the message queue
 * awaiting to be written...
 */
UART::Queue const& get_wqueue(Control& ctrl) {
    // First, clear the queue,
    ctrl.mqueue.clear();
    for (auto& c : ctrl.controllers) {
        if (c.second.io == Active && *c.second.zone != c.second.value) {
            // Controller value has changed, add it on the queue.
            c.second.value = *c.second.zone;
            UART::Message m;
            m.index = c.first;
            m.value = c.second.value;
            ctrl.mqueue.push_back(m);
            fprintf(stderr, "sending controller value %f at controller index %d\n",
                   m.value, m.index);
        }
    }
    return ctrl.mqueue;
}

/**
 * @brief r/w loop, polls incoming messages,
 * writes messages waiting in the queue.
 */
static void run(UART::Data& uart, Control& c) {
    while (uart.running) {
        if constexpr (FAUST_PASSIVES) {
            // If there are 'passive' controllers (bargraphs)
            // poll UART messages, update controller values.
            UART::Result r = read_message(uart);
            if (r.valid) {
                update(c, r.msg);
            }
        }
        if constexpr (FAUST_ACTIVES) {
            UART::Queue const& mq = get_wqueue(c);
            for (auto const& message : mq) {
                 write_message(uart, message);
            }
        }
//        usleep(1000);
    }
}

/**
 * @brief starts the r/w loop in a separate thread.
 */
static void start(UART::Data& uart, Control& c) {
    uart.running = true;
    uart.thread = std::thread(run, std::ref(uart), std::ref(c));
}

int main(int argc, char* argv[])
{
    UART::Data u;
    UART::initialize(u);
    Control c;
    mydsp dsp;
    GTKUI gui((char*)"Controller", &argc, &argv);

#if (SYFALA_CONTROL_HTTP)
    httpdUI http("http", dsp.getNumInputs(), dsp.getNumOutputs(), 0, 0);
    dsp.buildUserInterface(&http);
    http.run();
#endif
#if (SYFALA_CONTROL_MIDI)
    rt_midi rt("MIDI");
    MidiUI midi_ui(&rt);
    dsp.buildUserInterface(&midi_ui);
    midi_ui.run();
#endif
#if (SYFALA_CONTROL_OSC)
    OSCUI osc("osc", 0, 0);
    dsp.buildUserInterface(&osc);
    osc.run();
#endif
    dsp.buildUserInterface(&gui);
    dsp.buildUserInterface(&c);
    c.mqueue.reserve(c.controllers.size());
    start(u, c);
    gui.run();
    u.thread.join();
    return 0;
}
