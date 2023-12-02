#include <faust/gui/meta.h>
#include <faust/gui/DecoratorUI.h>
#include <faust/dsp/one-sample-dsp.h>
#include <syfala/arm/gpio.hpp>
#include <syfala/utilities.hpp>
#include <cstring>
#include <cstdint>

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

namespace Syfala::Faust::Control {

template<typename T>
constexpr inline T scale(T v, T min, T max) {
    return v*(max-min)+min;
}

static constexpr unsigned int ncontrols() {
    return FAUST_INT_CONTROLS
         + FAUST_REAL_CONTROLS
         + FAUST_PASSIVES;
}

enum type       { Software, Hardware };
enum direction  { Active, Passive };

struct controller {
       float* zone = nullptr;
        float init = 0;
        float min  = 0;
        float max  = 1;
        float step = 1;
          int hw_assign = -1;
    direction io;
};

static inline type get_current_controller_type() {
    return static_cast<Control::type>(GPIO::read_sw3());
}

struct handle final : public GenericUI {
    int   i[FAUST_INT_CONTROLS];
    float f[FAUST_REAL_CONTROLS];
    float p[FAUST_PASSIVES];
    unsigned int N = 0;
    controller controllers[ncontrols()];

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

inline void update_controller_hw(handle& h, unsigned int index, float value) {
    for (int n = 0; n < h.N; ++n) {
         controller& c = h.controllers[n];
         if (index == c.hw_assign)
             *c.zone = scale(value, c.min, c.max);
    }
}
inline void update_controller_sw(handle& h, unsigned int index, float value) {
    if (index < h.N) {
        controller& c = h.controllers[index];
        *c.zone = value;
        printf("Updating controller %d with value %f\r\n", index, value);
    } else {
        printf("Warning /!\\ wrong controller index (%d)!\r\n", index);
    }
}

struct data {
    mydsp  dsp;
    handle control;
};

inline void initialize(data& d, int* i_zone, float* f_zone) {
    d.dsp = mydsp(d.control.i, d.control.f, i_zone, f_zone);
    d.dsp.init(SYFALA_SAMPLE_RATE, i_zone, f_zone);
    d.dsp.buildUserInterface(&d.control);
    printf("Faust controller successfully initialized.\r\n");
}
}
