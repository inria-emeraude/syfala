#pragma once

#include <syfala/utilities.hpp>
#include <xsyfala.h>

#if SYFALA_FAUST_TARGET
    #include <syfala/arm/faust/control.hpp>
#endif

namespace Syfala::ARM::DSP {
/**
 * @brief Intializes and configures the Syfala DSP IP.
 * This has to be done before setting the 'arm_ok' flag,
 * which is shared from the ARM through an AXI-Lite bus.
 */
extern void initialize(XSyfala& x);

// ----------------------------------------------------------------------------
/**
 * Functions matching HLS top-level function arguments
 * /!\ This has to be updated whenever the top-level function arguments change,
 * specifically: arguments that are read/written from/to ARM through AXI-Lite.
*/
// ----------------------------------------------------------------------------

constexpr auto set_arm_ok       = XSYFALA_SET(arm_ok);
constexpr auto set_mem_zone_f   = XSYFALA_SET(mem_zone_f);
constexpr auto set_mem_zone_i   = XSYFALA_SET(mem_zone_i);

/**
 * Warning: for control arrays, such as arm_control_f, arm_control_i and
 * arm_control_p, the Xilinx-generated function's name changes from
 * 'Set_Arm_Control_F' (whenever the array size == 1) to
 * 'Write_Arm_Control_F_Words' (whenever the array size > 1)
 * When the array size is 0, the function is not generated.
 */

#if SYFALA_FAUST_TARGET
#if (FAUST_REAL_CONTROLS == 1) // --------------------------------
    constexpr auto write_control_f = XSYFALA_SET(arm_control_f);
#elif (FAUST_REAL_CONTROLS > 1)
    constexpr auto write_control_f = XSYFALA_WRITE(arm_control_f);
#endif
#if (FAUST_INT_CONTROLS == 1) // ---------------------------------
    constexpr auto write_control_i = XSYFALA_SET(arm_control_i);
#elif (FAUST_INT_CONTROLS > 1)
    constexpr auto write_control_i = XSYFALA_WRITE(arm_control_i);
#if (FAUST_PASSIVES == 1) // -------------------------------------
    constexpr auto read_control_p  = XSYFALA_SET(arm_control_p);
#elif (FAUST_PASSIVES > 1)
    constexpr auto read_control_p  = XSYFALA_READ(arm_control_p);
#endif // --------------------------------------------------------
#endif
#endif

#if SYFALA_CONTROL_BLOCK
    constexpr auto get_control_block      = XSYFALA_GET(control_block_o);
    constexpr auto get_control_block_vld  = XSYFALA_GET(control_block_o_vld);
    constexpr auto set_control_block      = XSYFALA_SET(control_block_i);
#endif

#if SYFALA_DEBUG_AUDIO
    constexpr auto read_arm_debug = XSYFALA_READ(arm_debug);
#endif

}
