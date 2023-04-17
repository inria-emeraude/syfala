//#include <syfala/faust/pc-uart-interface.hpp>
#include <faust/gui/GTKUI.h>
#include <faust/gui/meta.h>
#include <faust/dsp/dsp.h>
#include <faust/gui/DecoratorUI.h>
#include <faust/gui/httpdUI.h>

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

std::list<GUI*> GUI::fGuiList;
ztimedmap GUI::gTimedZoneMap;

#if   (SYFALA_UART_BAUD_RATE == 115200)
    #define BAUD_RATE B115200
#elif (SYFALA_UART_BAUD_RATE == 921600)
    #define BAUD_RATE B921600
#endif

namespace UART // -------------------------------------------------------------
{
#define SERIAL_PORT "/dev/ttyUSB1"
using byte_t = uint8_t;

struct message {
    int index = 0;
    float value = 0;
};

struct result {
    message msg;
    bool valid = false;
};

using message_queue = std::vector<UART::message>;
typedef void (*read_callback)(void*, UART::message);
typedef message_queue const& (*write_callback)(void*);

struct data;

struct callback_data {
    UART::data* uart;
    void* udata;
    read_callback  rd_fn;
    write_callback wr_fn;
};

struct data {
    int fd;
    bool running = false;
    std::thread thread;
    callback_data callback;
};

static void initialize(UART::data& u) {
    struct termios options;
    u.fd = open(SERIAL_PORT, O_RDWR | O_NOCTTY | O_NDELAY);
    if (u.fd == -1) {
        printf("error %d opening /dev/ttyUSB1: %s\n", errno, strerror(errno));
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

// read an UART message
static UART::result read_message(data& d) {
    UART::result r;
    int nbytes;
    nbytes = read(d.fd, &r.msg, sizeof(UART::message));
    byte_t* mu8 = reinterpret_cast<byte_t*>(&r.msg);
    if (nbytes >= sizeof(UART::message)) {
        for (int i = 0; i < sizeof(UART::message); ++i) {
             printf("%d, ", mu8[i]);
        }
        printf("\n");
        r.valid = true;
    }
    return r;
}

// write an UART message
static void write_message(data& d, UART::message m) {
    int nbytes = 0;
    // write message as an 8-byte sequence
    nbytes += write(d.fd, &m, sizeof(UART::message));
    if (nbytes < 0) {
        printf("[UART] error writing data (%s)\n", strerror(errno));
        exit(1);
    } else {
        printf("|UART] written %d bytes\n", nbytes);
    }
}

void run(void* udata) {
    auto callback_data = static_cast<UART::callback_data*>(udata);
    UART::data& uart = *callback_data->uart;
    while (uart.running) {
        // for each run:
        // 1. call user-defined read callback
        // 2. call user-defined write callback, and get a UART::message queue
        // 3. write each message
        // 4. wait to N milliseconds (UART_POLL_TIME_USEC)
    #if FAUST_PASSIVES
        UART::result r = read_message(uart);
        if (r.valid) {
//            printf("received valid uart message, index: %d\n", r.msg.index);
            callback_data->rd_fn(callback_data->udata, r.msg);
        }
    #endif
    #if FAUST_ACTIVES
        UART::message_queue const& mq = callback_data->wr_fn(callback_data->udata);
        for (auto const& message : mq)
             write_message(uart, message);
    #endif
        usleep(5000);
    }
}

void start(data& d, void* udata, read_callback rd, write_callback wr) {
    d.running = true;
    d.callback = { &d, udata, rd, wr };
    d.thread = std::thread(run, &d.callback);
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
    UART::message_queue mqueue;

    void add_controller(FAUSTFLOAT* zone, const char* name, controller_direction io) {
        printf("declaring parameter %s at index %d\n", name, (int)controllers.size());
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

void read_callback(void* udata, UART::message m) {
    auto c = static_cast<Control*>(udata);
    if (m.index < c->controllers.size()) {
        auto& controller = c->controllers[m.index];
        if (controller.io == Passive) {
            *controller.zone = m.value;
        }
    }
}

UART::message_queue const& write_callback(void* udata) {
    auto ctrl = static_cast<Control*>(udata);
    ctrl->mqueue.clear();
    for (auto& c : ctrl->controllers) {
        if (c.second.io == Active &&
           *c.second.zone != c.second.value) {
            // value has changed, update it on UART
            c.second.value = *c.second.zone;
            UART::message m;
            m.index = c.first;
            m.value = c.second.value;
            ctrl->mqueue.push_back(m);
            printf("sending controller value %f at controller index %d\n",
                   m.value, m.index);
        }
    }
    return ctrl->mqueue;
}

int main(int argc, char* argv[])
{
    // initialize UART
    UART::data u;
    UART::initialize(u);
    Control c;

    // instantiate DSP & user interface (GTK)
    mydsp dsp;
    GTKUI gui((char*)"Controller", &argc, &argv);
    httpdUI http("http", dsp.getNumInputs(), dsp.getNumOutputs(), 0, 0);
    dsp.buildUserInterface(&gui);
    dsp.buildUserInterface(&c);
    dsp.buildUserInterface(&http);
    c.mqueue.reserve(c.controllers.size());
    UART::start(u, &c, read_callback, write_callback);
    // run
    http.run();
    gui.run();    
    u.thread.join();
    return 0;
}
