#include <syfala/arm/faust/control.hpp> 
#include <string.h>

using namespace Syfala::Faust::Control;

static void assign_controller_hw(handle& h, controller& c) {
    if (c.hw_assign < 0) {
        for (int n = 0; n < ncontrols(); ++n) {
            if (h.controllers[n].hw_assign < 0) {
                c.hw_assign = n;
            }
        }
    }
}

static void add_controller(handle& h, float* zone, const char* name, direction io) {
    controller& c = h.controllers[h.N];
    c.zone = zone;
    c.io = io;
    assign_controller_hw(h, c);
    printf("Added controller '%s' at index %d, hardware index: %d\r\n",
              name, h.N++, c.hw_assign);
}


static void add_controller(handle& h, float* zone, const char* name,
                           float init, float min, float max, float step,
                           direction io)
{
    h.controllers[h.N] = controller {
        .zone = zone,
        .init = init,
        .min  = min,
        .max  = max,
        .step = step,
        .io   = io
    };
    controller& c = h.controllers[h.N];
    assign_controller_hw(h, c);
    printf("Added controller '%s' at index %d, hardware index: %d\r\n",
            name, h.N++, c.hw_assign);
}
/*
 * Metadata declarations
 * - declare(...) is called before the addX... functions
 */
void handle::declare(float* zone, const char* key, const char* val) {
    if (strcmp(key, "switch") == 0 ||
        strcmp(key, "knob")   == 0 ||
        strcmp(key, "slider") == 0 ){
        int index = atoi(val)-1;
        controllers[N].hw_assign = index;
    }
}

void handle::addButton(const char *label, float *zone) {
    add_controller(*this, zone, label, Active);
}

void handle::addHorizontalSlider(
        const char *label, float *zone,
        float init, float min, float max, float step) {
    add_controller(*this, zone, label, init, min, max, step, Active);
}
void handle::addVerticalSlider(
        const char *label, float *zone,
        float init, float min, float max, float step) {
    add_controller(*this, zone, label, init, min, max, step, Active);
}
void handle::addNumEntry(
        const char *label, float *zone,
        float init, float min, float max, float step) {
    add_controller(*this, zone, label, init, min, max, step, Active);
}
void handle::addVerticalBargraph(const char *label, float *zone, float min, float max) {
    add_controller(*this, zone, label, Passive);
}
void handle::addHorizontalBargraph(const char *label, float *zone, float min, float max) {
    add_controller(*this, zone, label, Passive);
}
void handle::addCheckButton(const char *label, float *zone) {
    add_controller(*this, zone, label, 0, 0, 1, 1, Active);
}
