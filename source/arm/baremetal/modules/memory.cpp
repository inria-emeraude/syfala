#include <xil_cache.h>
#include <syfala/arm/memory.hpp>
#include <syfala/utilities.hpp>

using namespace Syfala::ARM;

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
    println("[mem] Initializing Memory");
    d.i_zone = reinterpret_cast<int*>(ddr_ptr);
    d.f_zone = reinterpret_cast<float*>(ddr_ptr + ilen);
    reset();
    /* Send base address and depth to IP  */
    DSP::set_mem_zone_i(&x, reinterpret_cast<u64>(d.i_zone));
    DSP::set_mem_zone_f(&x, reinterpret_cast<u64>(d.f_zone));
    println("[mem] Memory successfully initialized.");
}
