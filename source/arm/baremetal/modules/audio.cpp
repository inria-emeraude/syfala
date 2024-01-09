/************************************************************************
 *
 *	SyFala: SSM2603, ADAU1761 and ADAU1787 codec initialisation,
 *  Based on audio_demo.h and exemples in https://github.com/Xilinx/embeddedsw/tree/master/XilinxProcessorIPLib/drivers/iicps/examples
 *
 *
 *****************************************************************************/

#include <xil_types.h>
#include <xiicps.h>
#include <syfala/utilities.hpp>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/codecs/ADAU17xx.hpp>
#include <syfala/arm/codecs/SSM2603.hpp>
#include <syfala/config_arm.hpp>


namespace xiicps {
using handle = XIicPs;
using config = XIicPs_Config;

constexpr auto lookup_config        = XIicPs_LookupConfig;
constexpr auto initialize_config    = XIicPs_CfgInitialize;
constexpr auto self_test            = XIicPs_SelfTest;
constexpr auto set_sclk             = XIicPs_SetSClk;
constexpr auto master_send_polled   = XIicPs_MasterSendPolled;
constexpr auto master_recv_polled   = XIicPs_MasterRecvPolled;
constexpr auto bus_is_busy          = XIicPs_BusIsBusy;
}

using namespace Syfala;
static xiicps::handle x[2];

static void initialize_device(int device) {
    xiicps::config* c = xiicps::lookup_config(device);
    /* Initialize the I2C driver so that it's ready to use
     * Look up the configuration in the config table,
     * then initialize it. */
    if (c == nullptr) {
        Status::warning(RN("[i2c] Could not find XIICPS configuration"));
    }
    if (xiicps::initialize_config(&x[device], c, c->BaseAddress) != XST_SUCCESS) {
        Status::warning(RN("[i2c] Could not initialize XIICPS configuration"));
    }
    // Perform a self-test to ensure that the hardware was built correctly.
    if (xiicps::self_test(&x[device]) != XST_SUCCESS) {
        Status::warning(RN("[i2c] XIICPS self-test failed, aborting..."));
    }
    // Set the I2C serial clock rate.
    if (xiicps::set_sclk(&x[device], IIC_SCLK_RATE) != XST_SUCCESS) {
        Status::warning(RN("[i2c] Failed setting XIICPS serial clock rate, aborting..."));
    }
    sy_printf("[i2c] XIICPS (device: %d) successfully initialized at %dHz.", device, IIC_SCLK_RATE);
}

//This function doesn't return any status, because it's hard to tell if the codec initialisation was a success (depend of how many codec you connected...)
void Audio::initialize() {
    int adau1777_ndevices = 0;
    uint8_t adau1787_tabDevices[32] = {0};
    int status = XST_FAILURE;

    sy_info("[i2c] Initialize I2C");
    initialize_device(IIC_DEVICE_ID_0);
#if IIC_NUM_INSTANCES > 1  // Maybe only one instance is declared in the bd...
    initialize_device(IIC_DEVICE_ID_1);
#endif
    // Initialize on-board codecs
#if SYFALA_BOARD_GENESYS
    sy_info("[Internal codec] Initialize ADAU1761 on I2C %d at address 0X%02x",IIC_ADAU1761_BUS,IIC_ADAU1761_SLAVE_ADDR_0);
    status = ADAU1761::initialize(IIC_ADAU1761_BUS, IIC_ADAU1761_SLAVE_ADDR_0);
#elif SYFALA_BOARD_ZYBO
    sy_info("[Internal codec] Initialize SSM2603 on I2C %d at address 0X%02x",IIC_SSM_BUS,IIC_SSM_SLAVE_ADDR);
    status = SSM2603::initialize(IIC_SSM_BUS);
#endif
    if (status != XST_SUCCESS) {
        Status::warning(RN("[audio] Could not initalize on-board device"));
    } else {
        sy_printf("[audio] Succesfully initialized on-board device");
    }

#if SYFALA_ADAU_EXTERN
    sy_info("[audio] Use external ADAU codecs");
    // Initialize external codecs
    // ADAU1777 (4 possible slots)
    sy_info("[audio] Initialize ADAU1777");
    for (int n = 0; n < 4; ++n) {
         int addr = IIC_ADAU1777_SLAVE_ADDR_0 + n;
         if ((addr==IIC_MOTHERBOARD_TCA9548A_ADDR || addr==IIC_MOTHERBOARD_PCA9956_ADDR) && SYFALA_ADAU_MOTHERBOARD){
            sy_info("[ADAU1777] WARNING: address conflict! This codec addresse (0X%02x) is already used by the motherboard.\n\r[ADAU1777] Codec 0X%02x will be ignored.",addr, addr);}
         else{
            sy_info("[ADAU1777] Initialize ADAU1777 on I2C %d at address 0X%02x",IIC_ADAU1777_BUS,addr);
            if (ADAU1777::initialize(IIC_ADAU1777_BUS, addr) == XST_SUCCESS) {
                adau1777_ndevices += 1;
            }
            else {sy_info("[ADAU1777] Could not initialize codec at address 0X%02x",addr);}
         }
    }
    sy_printf("[audio] Found: %d ADAU1777", adau1777_ndevices);//Not a warning or an error if 0 devices detected, maybe 0 ADAU1777 are connected, only ADAU1787 are.

#if SYFALA_ADAU_MOTHERBOARD
    status = XST_SUCCESS;
    sy_info("[audio] Use ADAU1787 Motherboard");
    //motherBoard::searchIIC();

    sy_info("[audio] Initialize LED driver on I2C %d at address 0X%02x",IIC_MOTHERBOARD_PCA9956_BUS,IIC_MOTHERBOARD_PCA9956_ADDR);
    if (LEDdriver::initialize() == XST_SUCCESS) {sy_info("[audio] LED driver detected");}
    else{
        sy_info("[audio] Cannot detect LED driver");
        status=XST_FAILURE;
    }
    sy_info("[audio] Initialize I2C Mux on I2C %d at address 0X%02x",IIC_MOTHERBOARD_TCA9548A_BUS,IIC_MOTHERBOARD_TCA9548A_ADDR);
    if (IICMUX::isConnected() == XST_SUCCESS) {sy_info("[audio] I2C Mux detected");}
    else{
        sy_info("[audio] Cannot detect I2C Mux");
        status=XST_FAILURE;
    }
    sy_info("[audio] Initialize MotherBoard UI");
    if (motherBoard::initializeUI() == XST_SUCCESS) {sy_info("[audio] MotherBoard UI initialized");}
    else{
        sy_info("[audio] MotherBoard UI initialization failed");
        status=XST_FAILURE;
    }

    if(status != XST_SUCCESS) Status::warning(RN("[audio] Could not initalize motherboard, please ensure that you used the correct I2C addresses in ADAU17XX.hpp"));
    //Here it's an error: if we declared the motherboard, it must be initialized.
    // ADAU1787
    sy_info("[audio] Initialize ADAU1787");
    for (int muxChannel = 0; muxChannel < 4; ++muxChannel) {
        IICMUX::setPort(1 << muxChannel);
        for (int codec_nb = 0; codec_nb < 4; ++codec_nb) {
            int addr = (IIC_ADAU1787_SLAVE_ADDR_0+(codec_nb%4));
            if ((addr==IIC_MOTHERBOARD_TCA9548A_ADDR || addr==IIC_MOTHERBOARD_PCA9956_ADDR) && SYFALA_ADAU_MOTHERBOARD){
                sy_info("[ADAU1787] WARNING: address conflict! This codec addresse (0X%02x) is already used by the motherboard.\n\r[ADAU1787] Codec 0X%02x will be ignored.",addr,addr);}
            else{
                sy_debug("\033[2K[ADAU1787] Initialize codec 0x%02x on channel %d \n\r",addr,muxChannel);
                ADAU1787::boot_sequence(1, addr);
                if ((ADAU1787::initialize(1, addr))==XST_SUCCESS) {
                    adau1787_tabDevices[(muxChannel*4)+codec_nb] = 1;
                    LEDdriver::ledOn((muxChannel*4)+codec_nb);
                }
                else {
                    adau1787_tabDevices[(muxChannel*4)+codec_nb] = 0;
                    LEDdriver::ledBlink((muxChannel*4)+codec_nb);
                }
            }
        }
    }
    motherBoard::printADAUTab(adau1787_tabDevices); //printed in sy_info, so verbose>=1
#else
    for (int n = 0; n < 4; ++n) {
         int addr = (IIC_ADAU1787_SLAVE_ADDR_0+(n%4));
         sy_debug("\033[2K[ADAU1787] Initialize codec @ 0x%02x \n\r",addr);
         ADAU1787::boot_sequence(1, addr);
         adau1787_tabDevices += ((ADAU1787::initialize(1, addr))==XST_SUCCESS?1:0);
    }
#endif
    int adau1787_ndevices=0;
    for(int i=0; i<32;i++){adau1787_ndevices+=adau1787_tabDevices[i];}
    sy_printf("[audio] Found: %d ADAU1787",adau1787_ndevices); //Not a warning or an error if 0 devices detected, maybe 0 ADAU1787 are connected, only ADAU1777 are.
#endif
}

/* Audio::regwrite 
 * Generic function to write on the I2C bus
 */
int Audio::regwrite(uint8_t* regAddr,int sizeOfRegAddr,uint8_t* value, int sizeOfValue, uint16_t addr, uint8_t bus) { 
    uint8_t buffer[sizeOfValue+sizeOfRegAddr];
    sy_debug("\033[2K[i2c] WRITE: I2C bus=%d, I2C Addr=0x%02x, Reg Addr=0x",bus,addr);
    for (int i=0;i<sizeOfRegAddr;i++){
        buffer[i]=regAddr[i];
        sy_debug("%02x",regAddr[i]);
    }
    sy_debug(", Value=0x");
    for (int i=sizeOfRegAddr;i<sizeOfRegAddr+sizeOfValue;i++){
        buffer[i]=value[i-sizeOfRegAddr];
        sy_debug("%02x",value[i-sizeOfRegAddr]);
    }
    sy_debug("\r\n");
    if (xiicps::master_send_polled(&x[bus], buffer, sizeOfValue+sizeOfRegAddr, addr) != XST_SUCCESS) {
        sy_debug("\033[2K[i2c] Could not write register!\r\n");
        return XST_FAILURE;
    } else {
        // Wait until bus is idle to start another transfer.
        while (xiicps::bus_is_busy(&x[bus]));
        return XST_SUCCESS;
    }
}

int SSM2603::regwrite(uint8_t bus, uint16_t addr, uint16_t data) {
    uint8_t regAddr[1],value[1];
    regAddr[0]  = (addr << 1) | ((data >> 8) & 0b1);
    value[0] = data & 0xFF;
    return Audio::regwrite(regAddr,sizeof(regAddr),value,sizeof(value),IIC_SSM_SLAVE_ADDR,bus);
}

int ADAU17xx::regwrite(int bus,
                   unsigned long codec_addr,
                   unsigned int reg_addr,
                   unsigned int data,
                   unsigned int offset) {
    uint8_t regAddr[2],value[1];
    reg_addr = reg_addr + offset;
    data = data >> (8*offset) & 0xff;
    regAddr[0] = (reg_addr >> 8) & 0xff;
    regAddr[1] = reg_addr & 0xff;
    value[0] = data;

    return Audio::regwrite(regAddr,sizeof(regAddr),value,sizeof(value),codec_addr & 0xff,bus);
}


//Writes a 8-bit value to mux
//Overwrites any other bits
//This allows us to enable/disable multiple ports at same time
int IICMUX::setPort(uint8_t portBits)
{
    uint8_t value[1];

    value[0] = portBits;

    return Audio::regwrite(0,0,value,sizeof(value),IIC_MOTHERBOARD_TCA9548A_ADDR, IIC_MOTHERBOARD_TCA9548A_BUS);
}


//Gets the current port state
//Returns byte that may have multiple bits set
uint8_t IICMUX::getPort()
{
  //Read the current mux settings
    uint8_t rx_data[1];

	int status = xiicps::master_recv_polled(&x[IIC_MOTHERBOARD_TCA9548A_BUS], rx_data,1, (IIC_MOTHERBOARD_TCA9548A_ADDR & 0xff));
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}
  return (rx_data[0]);
}


//Returns true if device is present
//Tests for device ack to I2C address
//Then tests if device behaves as we expect
//Leaves with all ports disabled
int IICMUX::isConnected()
{
    sy_debug("\033[2K[I2C MUX] Connection test ");
    uint8_t knownValue=123;
    if (IICMUX::setPort(knownValue) != XST_SUCCESS) return XST_FAILURE;
    sy_debug("send %d;", knownValue);

    uint8_t response = getPort();
    sy_debug("recv: %d \n\r", response);

    if (IICMUX::setPort(0x00) != XST_SUCCESS) return XST_FAILURE;//Disable all ports
    if (response == knownValue) return XST_SUCCESS;      //All good
    return XST_FAILURE;
}


int LEDdriver::regwrite(uint8_t reg,uint8_t data ) {
    uint8_t regAddr[1],value[1];

    regAddr[0] = reg;
    value[0] = data;
    return Audio::regwrite(regAddr,sizeof(regAddr),value,sizeof(value),IIC_MOTHERBOARD_PCA9956_ADDR,IIC_MOTHERBOARD_PCA9956_BUS);
}

uint8_t LEDdriver::regread()
{
  //Read the current mux settings
    uint8_t rx_data[1];
	int status = xiicps::master_recv_polled(&x[IIC_MOTHERBOARD_TCA9548A_BUS], rx_data,1, (IIC_MOTHERBOARD_PCA9956_ADDR & 0xff));
	if (status != XST_SUCCESS) {
		return XST_FAILURE;
	}
  return (rx_data[0]);
}

static uint8_t ledStatus[PCA9965_NUM_LEDS];

int LEDdriver::initialize() {

    int status=XST_SUCCESS; //XST_SUCCESS=0, XST_FAILURE=1
    status|=LEDdriver::regwrite(MODE1,MODE1_SETTING_NO_INCREMENT);

    for (int i=2; i<8; i++){
    status|=LEDdriver::regwrite(i,LEDMODE_FULLOFF);
    }


 // Use this if you want the same brightness for all the LED (but check the maximumm current of the differents led first! See above):
 //status|=LEDdriver::regwrite(0x40,0x22);

 //Use this code if you want different brightness on the codecs and on the UI motherboard:
    status|=LEDdriver::regwrite(MODE1,MODE1_SETTING_AUTO_INCREMENT_IREF);
    uint8_t cmd[25];
    cmd[0] = IREF0 | AUTO_INCREMENT_BIT;
    for(uint8_t i = 1; i < 17; i++){
        cmd[i] = CODEC_LED_BRIGHTNESS_LEVEL;
    }
    for(uint8_t i = 17; i < 25; i++){
        cmd[i] = UI_LED_BRIGHTNESS_LEVEL;
    }
    status = xiicps::master_send_polled(&x[IIC_MOTHERBOARD_PCA9956_BUS], cmd, sizeof(cmd), IIC_MOTHERBOARD_PCA9956_ADDR);
    while (xiicps::bus_is_busy(&x[IIC_MOTHERBOARD_PCA9956_BUS])) {}
    // stop auto INCREMENT
    status|=LEDdriver::regwrite(MODE1,MODE1_SETTING_NO_INCREMENT);

    status|=LEDdriver::setBlink(0x0D);
    return status;
}

 int LEDdriver::ledOn(uint8_t LEDNo){
    int status=XST_FAILURE;
    if (LEDNo < PCA9965_NUM_LEDS)
    {
        uint8_t LEDgroup = uint8_t(LEDNo / 4);
        uint8_t regAdr = LEDgroup + LEDOUT0;
        uint8_t regVal = 0b01  << ((LEDNo % 4) * 2);

        for (uint8_t i = 0; i < 4; i++)
        {
            uint8_t led = (LEDgroup * 4) + i;
            if (led != LEDNo)
            {
                if(ledStatus[led] == 0xFF) regVal |= 0b01 << (i * 2);
                else if(ledStatus[led] == 0xBB)  regVal |= 0b11 << (i * 2);
            }
        }

        status=LEDdriver::regwrite(regAdr, regVal);
        ledStatus[LEDNo] = 0xFF;
    }
    return status;
 }

 int LEDdriver::ledOff(uint8_t LEDNo)
{
    int status=XST_FAILURE;
    if (LEDNo < PCA9965_NUM_LEDS)
    {
        uint8_t LEDGroup = (LEDNo / 4);
        uint8_t regAdr = LEDGroup + LEDOUT0;

        // check other leds' status
        uint8_t regVal = 0;

        for (uint8_t i = 0; i < 4; i++)
        {
            uint8_t led = (LEDGroup * 4) + i;
            if (led != LEDNo){
                if(ledStatus[led] == 0xFF) regVal |= 0b01 << (i * 2);
                else if(ledStatus[led] == 0xBB)  regVal |= 0b11 << (i * 2);
            }
        }
        status=LEDdriver::regwrite(regAdr, regVal);
        ledStatus[LEDNo] = 0;
    }
    return status;
}

int LEDdriver::ledBlink(uint8_t LEDNo)
{
    int status=XST_FAILURE;
    if (LEDNo < PCA9965_NUM_LEDS)
    {
        uint8_t LEDgroup = uint8_t(LEDNo / 4);
        uint8_t regAdr = LEDgroup + LEDOUT0;
        uint8_t regVal = 0b11  << ((LEDNo % 4) * 2);

        for (uint8_t i = 0; i < 4; i++)
        {
            uint8_t led = (LEDgroup * 4) + i;
            if (led != LEDNo)
            {
                if(ledStatus[led] == 0xFF) regVal |= 0b01 << (i * 2);
                else if(ledStatus[led] == 0xBB)  regVal |= 0b11 << (i * 2);
            }
        }

        status=LEDdriver::regwrite(regAdr, regVal);
        ledStatus[LEDNo] = 0xBB;
    }
    return status;
}
int LEDdriver::ledSetBrightness(uint8_t LEDNo, uint8_t brightness){
    int status=XST_FAILURE;

    status=LEDdriver::regwrite(IREF0+LEDNo, brightness);
    return status;
}

void LEDdriver::allOn(void){
    for (int i=0; i<PCA9965_NUM_LEDS; i++) LEDdriver::ledOn(i);
}
void LEDdriver::allOff(void){
    for (int i=0; i<PCA9965_NUM_LEDS; i++) LEDdriver::ledOff(i);
}
void LEDdriver::allBlink(void){
    for (int i=0; i<PCA9965_NUM_LEDS; i++) LEDdriver::ledBlink(i);
}

int LEDdriver::setBlink(uint8_t freq)
{
    int status=XST_SUCCESS; //XST_SUCCESS=0, XST_FAILURE=1

    status|=LEDdriver::regwrite(PWMALL, 0xFF);
    status|=LEDdriver::regwrite(MODE2, MODE2_DMBLINK_BLINKING);
    status|=LEDdriver::regwrite(GRPFREQ, freq); // Group dimming frequency setting
    status|=LEDdriver::regwrite(GRPPWM, 0x80); // Group dimming duty setting: 0x80=50%

    return status;
}

void LEDdriver::saveState(uint8_t* savedState){
    for (int i=0; i<PCA9965_NUM_LEDS; i++) savedState[i]=ledStatus[i];
}

void LEDdriver::restoreState(uint8_t* savedState){
    for (int i=0; i<PCA9965_NUM_LEDS; i++) ledStatus[i]=savedState[i];

    for (int i=0; i<6;i++)
    {
    uint8_t LEDgroup = i;
    uint8_t regAdr = LEDgroup + LEDOUT0;
    uint8_t regVal = 0;
        for (uint8_t j = 0; j < 4; j++)
        {
            uint8_t led = (LEDgroup * 4) + j;
            if(ledStatus[led] == 0xFF) regVal |= 0b01 << (j * 2);
            else if(ledStatus[led] == 0xBB)  regVal |= 0b11 << (j * 2);
        }
    LEDdriver::regwrite(regAdr, regVal);
    }
}



int motherBoard::initializeUI(void)
{
    int status=XST_SUCCESS; //XST_SUCCESS=0, XST_FAILURE=1

    //Auxiliary LED
    status|=LEDdriver::ledOff(16);
    status|=LEDdriver::ledBlink(17);

    //Format LED
    //TODO: relier à la valeur TDM8/16 ou I2S
    status|=LEDdriver::ledOff(18);
    status|=LEDdriver::ledOn(19);

    //Sample Rate LED
    if((SYFALA_SAMPLE_RATE==384000) | (SYFALA_SAMPLE_RATE==768000))status|=LEDdriver::ledOn(20);
    if((SYFALA_SAMPLE_RATE==48000) | (SYFALA_SAMPLE_RATE==768000))status|=LEDdriver::ledOn(21);

    //Bit Width LED
    if((SYFALA_SAMPLE_WIDTH==24) | (SYFALA_SAMPLE_WIDTH==32))status|=LEDdriver::ledOn(22);
    if((SYFALA_SAMPLE_WIDTH==16) | (SYFALA_SAMPLE_WIDTH==32))status|=LEDdriver::ledOn(23);
    return status;
}

// Write 0x00 at each adress and see if a slave ack.
void motherBoard::searchIIC()
{
    uint8_t tx_data[1];
    tx_data[0] = 0x00;
    int status=XST_FAILURE;
    for (int i=0; i<255; i++){

        status = xiicps::master_send_polled(&x[IIC_MOTHERBOARD_BUS], tx_data, 1, i);
        if (status != XST_SUCCESS) { sy_debug("\033[2K[MotherBoard] No I2C at: 0x%02x \n\r", i); }
        else {sy_debug("\033[2K[MotherBoard] I2C found at: 0x%02x \n\r", i);}
        while (xiicps::bus_is_busy(&x[IIC_MOTHERBOARD_BUS])) {}
    }
}

//print a tab to indicate the adresses of the working ADAU1787
void motherBoard::printADAUTab(uint8_t *tab){
    sy_info("+-----------|-----------|-----------|-----------+");
    for (int i=0; i<4; i++){
    sy_info("|           |           |           |           |");
    sy_info("|     %d     |     %d     |     %d     |     %d     |",tab[i+12],tab[i+8],tab[i+4],tab[i]);
    sy_info("|           |           |           |           |");
    sy_info("|0x%02x chD   |0x%02x chC   |0x%02x chB   |0x%02x chA   |",IIC_ADAU1787_SLAVE_ADDR_0+i,IIC_ADAU1787_SLAVE_ADDR_0+i,IIC_ADAU1787_SLAVE_ADDR_0+i,IIC_ADAU1787_SLAVE_ADDR_0+i);
    sy_info("+-----------|-----------|-----------|-----------+");
    }
}

void motherBoard::ledCodecsAllOn(void){
    for (int i=0; i<16; i++) LEDdriver::ledOn(i);
}
void motherBoard::ledCodecsAllOff(void){
    for (int i=0; i<16; i++) LEDdriver::ledOff(i);
}
void motherBoard::ledCodecsAllBlink(void){
    for (int i=0; i<16; i++) LEDdriver::ledBlink(i);
}


