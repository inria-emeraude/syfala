#include <faust/gui/meta.h>
#include <faust/gui/DecoratorUI.h>
#include <faust/dsp/one-sample-dsp.h>
#include <syfala/arm/gpio.hpp>
#include <cstring>
#include <cstdint>
#include <vector>

#ifndef __linux__
    #include <xil_io.h>
#endif

#include <syfala/utilities.hpp>

// -----------------------------------------------
/**
 * @brief control.hpp
 * ARM Control Architecture File
 * This file is not to be used as is:
 * it is meant to be used as a Faust architecture
 * file with a DSP file
 */
// -----------------------------------------------
/* Faust IP configuration */
// -----------------------------------------------
#define FAUST_UIMACROS 1
// -----------------------------------------------
/* Generic definition used to accept a variable
 * number of controllers */

#define FAUST_ADDBUTTON(l,f)
#define FAUST_ADDCHECKBOX(l,f)
#define FAUST_ADDVERTICALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDHORIZONTALSLIDER(l,f,i,a,b,s)
#define FAUST_ADDNUMENTRY(l,f,i,a,b,s)
#define FAUST_ADDVERTICALBARGRAPH(l,f,a,b)
#define FAUST_ADDHORIZONTALBARGRAPH(l,f,a,b)

#define ACTIVE_ELEMENT_IN(type, ident, name, var, def, min, max, step)  \
d.dsp.var = *(float*) &d.control.p[field++];

#ifdef SYFALA_TESTING_PRECOMPILED // -----------------
    #include FAUST_PRECOMPILED_EXAMPLE_ARM_TARGET
#else // ---------------------------------------------
    // The Faust compiler will insert the C code here
    <<includeIntrinsic>>
    <<includeclass>>
#endif // --------------------------------------------

namespace Syfala::Faust {

constexpr uint32_t ncontrols_i() {
    return FAUST_INT_CONTROLS;
}

constexpr uint32_t ncontrols_f() {
    return FAUST_REAL_CONTROLS;
}

constexpr uint32_t npassives() {
    return FAUST_PASSIVES;
}

constexpr uint32_t inputs() {
    return FAUST_INPUTS;
}

constexpr uint32_t outputs() {
    return FAUST_OUTPUTS;
}

/**
 * @brief Scales normalized signal value between min & max values.
 * @param v Normalized value to be scaled (for float: 0.f to 1.f).
 * @param min Minimum scale value.
 * @param max Maximum scale value.
 * @return Scaled value.
 */
template<typename T>
constexpr inline T scale_value(T v, T min, T max) {
    return v*(max-min)+min;
}

/**
 * @brief Returns the total number of Faust control expression
 */
static constexpr int ctrlexpr_n() {
    return FAUST_INT_CONTROLS
         + FAUST_REAL_CONTROLS
         + FAUST_PASSIVES;
}

/**
 * @brief Type of Faust controlers:
 * 'Active' designates controllers which produce values,
 * such as sliders, buttons, checkboxes, etc.
 * 'Passive' designates controllers which receive values:
 * such as bargraphs.
 */
enum direction  { Active, Passive };

/**
 * @brief Internal representation of a Faust controller's properties.
 */
struct controller {
  std::string id;
       float* zone = nullptr;
        float init = 0;
        float min  = 0;
        float max  = 1;
        float step = 1;
          int map = -1;
    direction io;
};

struct handle final : public GenericUI {
    /*
     * FAUST_INT_CONTROLS, FAUST_REAL_CONTROLS
     * & FAUST_PASSIVES are the sum of the control expressions
     * passed to the FPGA with AXI Lite. The actual number
     * of buttons/sliders/knobs... is the controllers vector's length */
      int i[FAUST_INT_CONTROLS];
    float f[FAUST_REAL_CONTROLS];
    float p[FAUST_PASSIVES];
    int map_assign_for_next_controller = -1;
    std::vector<controller> controllers;

    inline int ncontrollers() const noexcept {
        return controllers.size();
    }

    void declare(float* zone, const char* key, const char* val) override;
    void addButton(const char *label, float *zone) override;

    void addHorizontalSlider(
            const char *label, float *zone,
            float init, float min, float max, float step) override;

    void addVerticalSlider(
            const char *label, float *zone,
            float init, float min, float max, float step) override;

    void addNumEntry(const char *label, float *zone,
                     float init, float min, float max, float step) override;

    void addVerticalBargraph(const char *label, float *zone,
                             float min, float max) override;

    void addHorizontalBargraph(const char *label, float *zone,
                               float min, float max) override;

    void addCheckButton(const char *label, float *zone) override;
};


/**
 * @brief Update controller's value from the outside
 * (from, for example, an Hardware SPI controller, or from a PC through UART).
 * @param h
 * @param index Index of the controller to update.
 * @param value Value to send to the target controller.
 * @param scale Enables scaling from normalized values.
 * @param map Retrieve controller mappings, if they have been set.
 */
inline void update(handle& h, uint32_t index, float value,
                   bool scale = false,
                   bool map = false) {
    // Check bounds first, there might be some weird
    // indexes coming from UART &| SPI from times to times (TODO).
    if (index < h.ncontrollers()) {
        // Check if controller has been explicitly mapped in the
        // Faust DSP file (with metadata).
        if (map) {
            int n = 0;
            for (controller& c : h.controllers) {
                 // If controller has been mapped, and if the index
                 // matches that map:
                 if (c.map >= 0 && c.map == index) {
                     printf("[faust] Mapped controller: %d\n, index: %d", c.map, index);
                     index = n;
                     break;
                 }
                n++;
            }
        }
        // Retrieve controller from 'index', scale value if needed
        // & update value from the 'zone' float pointer.
        controller& c = h.controllers[index];
        *c.zone = scale ? scale_value(value, c.min, c.max) : value;
        printf("[faust] Updating controller %s (%d) with value %f\r\n",
               c.id.c_str(), index, value);
    } else {
        printf("[faust] Warning /!\\ wrong controller index (%d)!\r\n", index);
    }
}

struct data {
    mydsp dsp;
    handle control;
};

inline void initialize(data& d, int* i_zone, float* f_zone) {
    d.dsp = mydsp(d.control.i, d.control.f, i_zone, f_zone);
    d.control.controllers.reserve(ctrlexpr_n());
    d.dsp.init(SYFALA_SAMPLE_RATE, i_zone, f_zone);
    d.dsp.buildUserInterface(&d.control);
    printf("[faust] Faust controller successfully initialized.\r\n");
}
}
