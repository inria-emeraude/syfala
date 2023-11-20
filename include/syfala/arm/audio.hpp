#pragma once

#define IIC_SCLK_RATE       400000

namespace Syfala::Audio {
/**
 * @brief Initialize Audio module.
 * This means initializing & configuring the i2c drivers,
 * and setting the audio codecs' register values properly,
 * depending on the target board:
 * - SSM2603 for Zybo Z10/20.
 * - ADAU1761 for Genesys zu-3eg.
 * + Optional external codecs, such as ADAU1777, ADAU1787
 *   & the ADAU 'motherboard'.
 */
extern int initialize();

}
