#include <xil_cache.h>
#include <syfala/arm/memory.hpp>
#include <syfala/utilities.hpp>

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

#if SYFALA_MEMORY_USE_DDR
    static u32* ddr_ptr = (u32*) FRAME_BUFFER_BASEADDR;
#endif

using namespace Syfala;

static void reset() {
    // Disable the Data cache for DDR read and write
    // NOTE: If we disable the cache after reset_ddr,
    // it's much faster and the ddr seems still fully reset.
    // But i suppose it's safer to disable it before...?
    // Xil_DCacheDisable();
    Xil_DCacheEnable();
    for (u32 i = 0; i < FRAME_BUFFER_DEPTH; i += DDR_CLEAR_STEP) {
        for (u32 j = i; j < (i + DDR_CLEAR_STEP); j += 4) {
            Xil_Out32(FRAME_BUFFER_BASEADDR + j, (int)0);
        }
    }
    Xil_DCacheFlush();
    Xil_DCacheDisable();
}

void Memory::initialize(XSyfala& x, Memory::data& d, int ilen, int flen) {
    // Get iZone/fZone from the global DDR zone
    sy_printf("[mem] Initializing Memory");
    d.i_zone = reinterpret_cast<int*>(ddr_ptr);
    d.f_zone = reinterpret_cast<float*>(ddr_ptr + ilen);
    reset();
    /* Send base address and depth to IP  */
    IP::set_mem_zone_i(&x, reinterpret_cast<u64>(d.i_zone));
    IP::set_mem_zone_f(&x, reinterpret_cast<u64>(d.f_zone));
    sy_printf("[mem] Memory successfully initialized.");
}
