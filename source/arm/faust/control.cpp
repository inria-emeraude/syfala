#include <syfala/arm/faust/control.hpp>
#include <string.h>
#include <syfala/utilities.hpp>

using namespace Syfala::ARM;
using namespace Syfala::ARM::Faust;
/**
 * @brief Adds new controller with no specific information about its bounds &
 * default value (buttons, checkboxes...)
 */
static void add_controller(handle& h, float* zone, const char* name, direction io) {
    controller c = {
          .id = name,
        .zone = zone,
         .map = h.map_assign_for_next_controller,
          .io = io
    };
    h.controllers.push_back(c);
    println("[faust] Added controller '%s' at index %d", name, h.ncontrollers());
}
/**
 * @brief Adds new controller with the following information:
 * - initialization value (init)
 * - minimum value (min)
 * - maximum value (max)
 * - step value (step)
 * This applies to Slider, Knob, NumEntry type of controllers.
 */
static void add_controller(handle& h, float* zone, const char* name,
                           float init, float min, float max, float step,
                           direction io)
{
    controller c = {
        .id   = name,
        .zone = zone,
        .init = init,
        .min  = min,
        .max  = max,
        .step = step,
        .map  = h.map_assign_for_next_controller,
        .io   = io,
    };
    h.controllers.push_back(c);
    println("[faust] Added controller '%s' at index %d\r\n", name, h.ncontrollers());
}

static bool streq(const char* a, const char* b) {
    return (strcmp(a,b) == 0);
}

/*
 * ---------------------
 * Metadata declarations
 * ---------------------
 * Note: declare(...) is called before the addX... functions
 * so we have to save metadata values before controller vector gets filled,
 * and assign them afterwards...
 * We use this for PCB controllers, the format:
 * - [knob:1] [slider:2] [switch:3] is used
 */
void handle::declare(float* zone, const char* key, const char* val) {
    // Detect metadata format
    println("[faust] Retrieved metadata: [%s:%s]\r\n", key, val);
    if (streq(key, "switch")
     || streq(key, "knob")
     || streq(key, "slider")) {
        // Index is not zero-based here.
        int index = atoi(val)-1;
        // Retrieve controller and assign it the map value
        map_assign_for_next_controller = index;
    } else {
        map_assign_for_next_controller = -1;
    }
}
/**
 * @brief Adds a new Button controller, redirect to the proper
 * 'add_controller' member function
 */
void handle::addButton(const char *label, float *zone) {
    add_controller(*this, zone, label, Active);
}
/**
 * @brief Adds a new Slider controller, redirect to the proper
 * 'add_controller' member function
 */
void handle::addHorizontalSlider(
        const char *label, float *zone,
        float init, float min, float max, float step) {
    add_controller(*this, zone, label, init, min, max, step, Active);
}

/**
 * @brief Adds a new Slider controller, redirect to the proper
 * 'add_controller' member function
 */
void handle::addVerticalSlider(
        const char *label, float *zone,
        float init, float min, float max, float step) {
    add_controller(*this, zone, label, init, min, max, step, Active);
}

/**
 * @brief Adds a new NumEntry controller, redirect to the proper
 * 'add_controller' member function
 */
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
