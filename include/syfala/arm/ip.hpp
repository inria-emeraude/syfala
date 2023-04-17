#pragma once

#include <syfala/utilities.hpp>
#include <xsyfala.h>

namespace Syfala::IP {
/** Functions matching HLS top-level function arguments
 * Utility macros are used in order to make it more 'readable'
 * /!\ This has to be updated whenever the top-level function arguments change
 * specifically: arguments that are read/written from/to ARM
*/
constexpr auto
write_control_f = XSYFALA_WRITE(arm_control_f);

constexpr auto
write_control_i = XSYFALA_WRITE(arm_control_i);

constexpr auto
read_control_p  = XSYFALA_READ(arm_control_p);

constexpr auto
set_arm_ok      = XSYFALA_SET(arm_ok);

constexpr auto
get_control_block = XSYFALA_GET(control_block_o);

constexpr auto
get_control_block_vld = XSYFALA_GET(control_block_o_vld);

constexpr auto
set_control_block = XSYFALA_SET(control_block_i);

#if SYFALA_AUDIO_DEBUG_UART // ------------------
constexpr auto
read_audio_out_arm = XSYFALA_READ(audio_out_arm);
#endif // ---------------------------------------

constexpr auto
set_mem_zone_f  = XSYFALA_SET(mem_zone_f);

constexpr auto
set_mem_zone_i  = XSYFALA_SET(mem_zone_i);

extern void initialize(XSyfala& x);

}
