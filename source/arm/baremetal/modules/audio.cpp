#include <xil_types.h>
#include <xiicps.h>
#include <syfala/utilities.hpp>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/codecs/ADAU17xx.hpp>
#include <syfala/arm/codecs/SSM2603.hpp>

#define IIC_SCLK_RATE       400000
#define IIC_DEVICE_ID_0     XPAR_XIICPS_0_DEVICE_ID
#define IIC_DEVICE_ID_1     XPAR_XIICPS_1_DEVICE_ID

namespace xiicps {
using handle = XIicPs;
using config = XIicPs_Config;

constexpr auto lookup_config        = XIicPs_LookupConfig;
constexpr auto initialize_config    = XIicPs_CfgInitialize;
constexpr auto self_test            = XIicPs_SelfTest;
constexpr auto set_sclk             = XIicPs_SetSClk;
constexpr auto master_send_polled   = XIicPs_MasterSendPolled;
constexpr auto bus_is_busy          = XIicPs_BusIsBusy;
}

using namespace Syfala;
static xiicps::handle x[2];

static void initialize_device(int device) {
    xiicps::config* c = xiicps::lookup_config(device);
    /* Initialize the IIC driver so that it's ready to use
     * Look up the configuration in the config table,
     * then initialize it. */
    if (c == nullptr) {
        Status::fatal(RN("Could not find XIICPS configuration"));
    }
    if (xiicps::initialize_config(&x[device], c, c->BaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("Could not initialize XIICPS configuration"));
    }
    // Perform a self-test to ensure that the hardware was built correctly.
    if (xiicps::self_test(&x[device]) != XST_SUCCESS) {
        Status::fatal(RN("XIICPS self-test failed, aborting..."));
    }
    // Set the IIC serial clock rate.
    if (xiicps::set_sclk(&x[device], IIC_SCLK_RATE) != XST_SUCCESS) {
        Status::fatal(RN("Failed setting XIICPS serial clock rate, aborting..."));
    }
    sy_printf("XIICPS (device: %d) successfully initialized.", device);
}

int Audio::initialize() {
    int adau1777_ndevices = 0;
    int adau1787_ndevices = 0;
    initialize_device(IIC_DEVICE_ID_0);
    initialize_device(IIC_DEVICE_ID_1);
    sy_printf("[I2C] Succesfully initialized IIC buses 0 & 1");
    // Initialize on-board codecs
#if SYFALA_BOARD_GENESYS // --------------------------------------
    ADAU1761::initialize(audio.x);
#elif SYFALA_BOARD_ZYBO // ---------------------------------------
    SSM2603::initialize(0);
#endif // --------------------------------------------------------
    sy_printf("[Audio] Succesfully initialized on-board device");
#if SYFALA_ADAU_EXTERN // ----------------------------------------
    // Initialize external codecs
    // ADAU1777 (4 possible slots)   
    for (int n = 0; n < 4; ++n) {
         int addr = IIC_ADAU1777_SLAVE_ADDR_0+n;
         adau1777_ndevices += ADAU1777::initialize(1, addr);
    }
    sy_printf("[ADAU1777] Found: %d registered devices", adau1777_ndevices);
    // ADAU1787 (16 possible slots)
    for (int n = 0; n < MAX_EXTERNAL_1787; ++n) {
         int addr = ((n/4)<<8) | (IIC_ADAU1787_SLAVE_ADDR_0+(n%4));
         if (ADAU1787::boot_sequence(1, addr)) {
             adau1787_ndevices += ADAU1787::initialize(1, addr);
         }
    }
    sy_printf("[ADAU1787] Found: %d registered devices", adau1787_ndevices);
#endif //--------------------------------------------------------
    return XST_SUCCESS;
}

int SSM2603::regwrite(int bus, unsigned int addr, unsigned int data) {
    unsigned char buffer[2];
    buffer[0] = addr << 1;
    buffer[0] = buffer[0] | ((data >> 8) & 0b1);
    buffer[1] = data & 0xFF;
    if (xiicps::master_send_polled(&x[bus], buffer, 2, IIC_SSM_SLAVE_ADDR) != XST_SUCCESS) {
        printf("[SSM2603] Could not write register at offset: %d, "
               "with data: %d\r\n", addr, data);
        return XST_FAILURE;
    } else {
        // Wait until bus is idle to start another transfer.
        while (xiicps::bus_is_busy(&x[bus]));
        return XST_SUCCESS;
    }
}

int ADAU17xx::regwrite(int bus,
                   unsigned long codec_addr,
                   unsigned int addr,
                   unsigned int data,
                   unsigned int offset) {
    int status;
    unsigned char tx_data[3];
    addr = addr + offset;
    data = data >> (8*offset) & 0xff;
    // register subaddress high byte
    // (0x40 for ADAU1761, 0xc0 for ADAU1787)
    tx_data[0] = addr >> 8 & 0xff;
    tx_data[1] = addr & 0xff;
    tx_data[2] = data;
    status = xiicps::master_send_polled(&x[bus], tx_data, sizeof(tx_data), codec_addr & 0xff);
    if (status != XST_SUCCESS) {
        return status;
    }
    while (xiicps::bus_is_busy(&x[bus])) {}
    return status;
}

