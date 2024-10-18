#pragma once

#include <syfala/arm/ip.hpp>

/* DDR zone coherent with linker script lscript.ld */
#if SYFALA_BOARD_ZYBO // -----------------------------------------------------
    #define FRAME_BUFFER_BASEADDR   0x1D000000
    #define FRAME_BUFFER_DEPTH      0x02000000
    #define FRAME_BUFFER_HIGHADDR   FRAME_BUFFER_BASEADDR + FRAME_BUFFER_DEPTH
#elif SYFALA_BOARD_GENESYS // ------------------------------------------------
    #define FRAME_BUFFER_BASEADDR   0x0
    #define FRAME_BUFFER_DEPTH      0x40000000	// 1go
    #define FRAME_BUFFER_HIGHADDR   FRAME_BUFFER_BASEADDR + FRAME_BUFFER_DEPTH
#else // ---------------------------------------------------------------------
    #error("Unsupported board model")
#endif

#define DDR_CLEAR_STEP  0x1000000
// 0x1000000 = 16mo (Quantity of memory clear for each printed dot during ddr clear)

namespace Syfala::ARM::Memory {

#if SYFALA_MEMORY_USE_DDR
    static u32* ddr_ptr = (u32*) FRAME_BUFFER_BASEADDR;
#endif

struct data {
    int*    i_zone;
    float*  f_zone;
};

/**
 * @brief Initializes the shared memory (DDR by default) between
 * the Syfala DSP IP and the ARM Host control application.
 * @param ilen The length of the 'integer' memory zone (in number of i32 values, not in bytes),
 * @param flen The length of the 'float' memory zone (in number of f32 values, not in bytes).
 */
extern void initialize(XSyfala& x, data& d, int ilen, int flen);

}
