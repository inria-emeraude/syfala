#pragma once

#include <cstdarg>
#include <cstdint>
#include <stdio.h>

#if defined (__SYNTHESIS__) || defined (__CSIM__)

#include <syfala/config_common.hpp>
#include <ap_int.h>

#if SYFALA_REAL_FIXED_POINT
    #include <ap_fixed.h>
    using sy_real_t = ap_fixed<32, 8, AP_RND_CONV, AP_SAT>;
    using sy_ap_int = ap_fixed<SYFALA_SAMPLE_WIDTH, 0, AP_RND_CONV, AP_SAT>;
#else
    using sy_real_t = float;
    using sy_ap_int = ap_int<SYFALA_SAMPLE_WIDTH>;
#endif

/**
 * @brief (deprecated) use Syfala::HLS::scale_factor() instead
 */
static sy_real_t
SCALE_FACTOR = (1 << (SYFALA_SAMPLE_WIDTH-1)) -1;

namespace Syfala {
namespace HLS {

/**
 * @brief Scale factor to use when converting float32
 * signals to Vitis arbitrary_precision integers (ap_int)
 */
static constexpr sy_real_t scale_factor() {
    return (1 << (SYFALA_SAMPLE_WIDTH-1)) -1;
}

/**
 * @brief ioreadf Read sy_ap_int as float
 * @param input sy_ap_int data input
 * @return floating-point conversion of input
 */
static inline float ioreadf(sy_ap_int const& input) {
    return input.to_float() / scale_factor();
}

/**
 * @brief iowritef write floating point data to ap_int
 * top-level function output.
 * @param f float data input
 * @param output ap_int interface output.
 */
static inline void iowritef(float f, sy_ap_int& output) {
    output = sy_ap_int(f * scale_factor());
}

static inline void iowritef(float f, sy_ap_int* output) {
    *output = sy_ap_int(f * scale_factor());
}
}
}
#else
// ----------------------------------------------------------------------------
#include <syfala/config_arm.hpp>
// ----------------------------------------------------------------------------

namespace Syfala::ARM {

#define SYFALA_VERBOSE_INFO   1
#define SYFALA_VERBOSE_DEBUG  2

#ifdef __linux__
    constexpr auto print = printf;
#else
    constexpr auto print = xil_printf;
#endif

inline void println(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    print(fmt, args);
    print("\r\n");
    va_end(args);
}

#if (SYFALA_VERBOSE >= SYFALA_VERBOSE_INFO)
    constexpr auto info = println;
#else
    constexpr void info(const char* fmt, ...) {}
#endif

#if (SYFALA_VERBOSE >= SYFALA_VERBOSE_DEBUG)
    constexpr auto debug = println;
#else
    constexpr void debug(const char* fmt, ...) {}
#endif

#if (SYFALA_TUI)
    constexpr auto TUIprint = println;
#else
    constexpr void TUIprint(const char* fmt, ...) {}
#endif

}
#endif // ARM

// --------------------------------------------------------
#define FAUST_PRECOMPILED_EXAMPLE_ARM_TARGET                \
"syfala/precompiled/virtual-analog-arm-precompiled.hpp"

#define FAUST_PRECOMPILED_EXAMPLE_FPGA_TARGET               \
"syfala/precompiled/virtual-analog-fpga-precompiled.hpp"

#define FAUST_PRECOMPILED_EXAMPLE_GUI_TARGET                \
"syfala/precompiled/virtual-analog-gui-precompiled.hpp"

// --------------------------------------------------------
#define CONCATENATE_2(_A,_B) _A ## _B
#define CONCATENATE_3(_A,_B,_C) _A ## _B ## _C
#define CONCATENATE_4(_A, _B, _C, _D) _A ## _B ## _C ## _D
// --------------------------------------------------------
#define SYFALA_HLS_TARGET        syfala
#define XSYFALA_TARGET_NAME      XSyfala
#define XSYFALA_INCLUDE_FILE    "xsyfala.h"
// --------------------------------------------------------

#define _XSYFALA_INITIALIZE_(_TARGET)                    \
CONCATENATE_2(_TARGET, _Initialize)

#define _XSYFALA_READ_(_TARGET, _LVALUE)                 \
CONCATENATE_4(_TARGET, _Read_, _LVALUE, _Words)

#define _XSYFALA_WRITE_(_TARGET, _LVALUE)                \
CONCATENATE_4(_TARGET, _Write_, _LVALUE, _Words)

#define _XSYFALA_SET_(_TARGET, _LVALUE)                  \
CONCATENATE_3(_TARGET, _Set_, _LVALUE)

#define _XSYFALA_GET_(_TARGET, _LVALUE)                  \
CONCATENATE_3(_TARGET, _Get_, _LVALUE)

#define XSYFALA_INITIALIZE                               \
_XSYFALA_INITIALIZE_(XSYFALA_TARGET_NAME)

#define XSYFALA_READ(_F)                                 \
_XSYFALA_READ_(XSYFALA_TARGET_NAME, _F)

#define XSYFALA_WRITE(_F)                                \
_XSYFALA_WRITE_(XSYFALA_TARGET_NAME, _F)

#define XSYFALA_SET(_V)                                  \
_XSYFALA_SET_(XSYFALA_TARGET_NAME, _V)

#define XSYFALA_GET(_V)                                  \
_XSYFALA_GET_(XSYFALA_TARGET_NAME, _V)

// --------------------------------------------------------

using byte_t = uint8_t;

template<typename T>
struct Result { bool valid = false; T data; };

template<typename T>
inline constexpr T clip(const T x, const T min, const T max) {
    if (x > max) {
        return max;
    } else if (x < min) {
        return min;
    } else {
        return x;
    }
}
