#pragma once

#include <syfala/utilities.hpp>

#if SYFALA_FAUST_TARGET // ----------------
    #include <syfala/arm/faust/control.hpp>
#endif // ---------------------------------

#include <xsyfala.h>

namespace Syfala::IP {
/**
 * Functions matching HLS top-level function arguments
 * Utility macros are used in order to make it more 'readable'
 * /!\ This has to be updated whenever the top-level function arguments change
 * specifically: arguments that are read/written from/to ARM
*/

extern void initialize(XSyfala& x);

#if (SYFALA_FAUST_TARGET && FAUST_REAL_CONTROLS) // ----------
constexpr auto write_control_f = XSYFALA_WRITE(arm_control_f);
#endif // ----------------------------------------------------

#if (SYFALA_FAUST_TARGET && FAUST_INT_CONTROLS) // -----------
constexpr auto write_control_i = XSYFALA_WRITE(arm_control_i);
#endif // ----------------------------------------------------

#if (SYFALA_FAUST_TARGET && FAUST_PASSIVES) // ---------------
constexpr auto read_control_p  = XSYFALA_READ(arm_control_p);
#endif // ----------------------------------------------------

constexpr auto set_arm_ok = XSYFALA_SET(arm_ok);

#if SYFALA_CONTROL_BLOCK // --------------------------------------------
constexpr auto get_control_block     = XSYFALA_GET(control_block_o);
constexpr auto get_control_block_vld = XSYFALA_GET(control_block_o_vld);
constexpr auto set_control_block     = XSYFALA_SET(control_block_i);
#endif // --------------------------------------------------------------

#if SYFALA_AUDIO_DEBUG_UART //-------------------------
constexpr auto read_arm_debug = XSYFALA_READ(arm_debug);
#endif //----------------------------------------------

constexpr auto set_mem_zone_f  = XSYFALA_SET(mem_zone_f);
constexpr auto set_mem_zone_i  = XSYFALA_SET(mem_zone_i);

}
