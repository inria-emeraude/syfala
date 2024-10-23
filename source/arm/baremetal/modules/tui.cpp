/************************************************************************
 *
 *	SyFala: Terminal Line Interface
 *
 *
 *****************************************************************************/


#include <syfala/arm/tui.hpp>
#include <syfala/arm/gpio.hpp>
#include <syfala/arm/audio.hpp>
#include <syfala/arm/codecs/ADAU17xx.hpp>
#include <syfala/arm/codecs/SSM2603.hpp>
#include <syfala/config_arm.hpp>
#include <syfala/config_common.hpp>
#include <xil_io.h>
#include <syfala/utilities.hpp>
#include <sleep.h>
#include <cstdlib>

using namespace Syfala::ARM;

int isTUI;

static uint8_t selectedMenu=0;
static uint8_t oldBtnVector=0;

const char *entryTab[MAX_ENTRY];
void (*functionTab[MAX_ENTRY]) (void);


void TUI::initialize() {
    info("[tui] Initialize Terminal User Interface");
    selectedMenu=1;
    TUI::createEntry("Show info",1,true,show_info);
    TUI::createEntry("Print test",2, true,functionTest);
    TUI::createEntry("GPIO test",3,true, GPIOtest);
    TUI::createEntry("Reconfig audio",4,true, Audio::initialize);
    TUI::createEntry("Write on I2C bus",5,true, TUI::writeIIC);
    //TUI::createEntry("Hidden menu",5,false,functionTest);
    TUI::createEntry(" ",7,SYFALA_ADAU_MOTHERBOARD,trivialFunction);
    TUI::drawMenu();
}
void TUI::drawMenu() {
    TUIprint("+------------------------------------------------------------------+\r\n");
    TUIprint("|                                                                  |\r\n");
    for (int i=1; i<=MAX_ENTRY; i++){
        if(functionTab[i-1]) TUIprint("| %s %d - %-59s %s|\r\n",SEL_(i,selectedMenu),i,entryTab[i-1],LINEFORMAT_RESET);
        else if(entryTab[i-1]) TUIprint("| %s %d - %s (unavailable)%-49s|\r\n",LINEFORMAT_RESET,i,entryTab[i-1],LINEFORMAT_RESET);
        else TUIprint("|  %d -                                                             |\r\n",i);
    }
    TUIprint("|                                                                  |\r\n");
    TUIprint("+------------------------------------------------------------------+\r\033[%dA",MAX_ENTRY+3);
}

void TUI::update(int lineToUpdate) {
    TUIprint("\r\033[%dB",lineToUpdate+1);//go to the righ line from the bottom of the menu
    TUIprint("| %s %i - %-59s %s",SEL_(lineToUpdate,selectedMenu),lineToUpdate,entryTab[lineToUpdate-1],LINEFORMAT_RESET);
    TUIprint("\r\033[%dA",lineToUpdate+1);//go on the top of the menu to correctly print futur functions
}

//index between 1 and MAX_ENTRY
int TUI::createEntry(const char* name,int index,int condition,void (*function)(void)){
    int status = XST_FAILURE;

    if(index>MAX_ENTRY){
        info("[tui] Could not add entry \"%s\", index out of bound(%d).",name,index);
        return XST_FAILURE;
    }
    if(!condition){
        info("[tui] Condition not met for entry \"%s\".",name);
    }
    else {functionTab[index-1]=function;}

    entryTab[index-1]=name;

return status;
}

void TUI::updateUserInput(){
    if(!isTUI)TUI::drawMenu(); //Redraw menu if something else was print since last draw.
    //WARNING, if the menu is not rebuilded, it's because printf is called instaed of println. I didn't change it in the linux files for now.
    u32 btnVector=GPIO::read_btn();
    if(!(btnVector == oldBtnVector || btnVector==0)) //wait for button release between two command
    {
        uint8_t oldSelectedMenu;
        switch (btnVector) {
        case BTN_LEFT:
            ;
            break;
        case BTN_RIGHT:
            functionTab[selectedMenu-1]();
            break;
        case BTN_UP:
            oldSelectedMenu=selectedMenu;
            do{
                selectedMenu-=1;
                if (selectedMenu <=0)selectedMenu=MAX_ENTRY;
            }while(!functionTab[selectedMenu-1]);
            TUI::update(oldSelectedMenu);
            TUI::update(selectedMenu);
            break;
        case BTN_DOWN:
            oldSelectedMenu=selectedMenu;
            do{
                selectedMenu+=1;
                if (selectedMenu>MAX_ENTRY)selectedMenu=1;
            }while(!functionTab[selectedMenu-1]);
            TUI::update(oldSelectedMenu);
            TUI::update(selectedMenu);
            break;
        case BTN_CENTER:
            functionTab[selectedMenu-1]();
            break;
        }
    }
    oldBtnVector=btnVector;
}


void TUI::writeIIC(){

    info("[tui] Entering I2C write");
    cleanMenu();

    const char *type[] = {"CUSTOM (1Byte value)","SSM (8bit addr)","ADAU1777 (2Byte addr)","ADAU1787 (2Byte addr)","ADAU1761 (2Byte addr)"};
    uint16_t valueTab[7]={0};
    uint16_t oldValueTab;
    uint16_t maxTab[7]={IIC_NUM_INSTANCES-1,4,0xFF,0xFFFF,0xFF,1,1}; //from datasheet, not header!
    uint16_t minTab[7]={0,0,0x00,0x0000,0x00,1,1};
    int place=0;
    uint8_t exit=0;
    u32 btnVector=0;
    while(GPIO::read_btn()==BTN_RIGHT); //Avoid taking into account the right click to enter the menu.
    do{

        switch (btnVector) {
            case BTN_CENTER: //Genesys only
                if (place==6) exit=1;
                if (place==5)  sendIIC(valueTab);
                break;
            case BTN_LEFT:
                place--;
                if(place<=-1)place=6;
                break;
            case BTN_RIGHT:
                place++;
                if(place>=7)place=0;
                break;
            case BTN_UP:
                if (place==6) exit=1;
                if (place==5)  sendIIC(valueTab);
                if(valueTab[place]>=maxTab[place])valueTab[place]=minTab[place];
                else valueTab[place]++;
                break;
            case BTN_DOWN:
                if (place==6) exit=1;
                if (place==5)  sendIIC(valueTab);
                if(valueTab[place]<=minTab[place])valueTab[place]=maxTab[place];
                else valueTab[place]--;
                break;
        }
        if(valueTab[1]!=oldValueTab){
            switch (valueTab[1]) {
                case 1: //SSM
                    maxTab[4]=0x1FF;
                    maxTab[3]=0x15;
                    minTab[3]=0x00;
                    valueTab[2]=IIC_SSM_SLAVE_ADDR;
                    break;
                case 2: // ADAU1777
                    maxTab[3]=0x54;
                    minTab[3]=0x00;
                    valueTab[2]=IIC_ADAU1777_SLAVE_ADDR_0;
                    break;
                case 3: // ADAU1787
                    maxTab[3]=0xC0E1;
                    minTab[3]=0xC000;
                    valueTab[2]=IIC_ADAU1787_SLAVE_ADDR_0;
                    break;
                case 4: // ADAU1761
                    maxTab[3]=0x40FA;
                    minTab[3]=0x4000;
                    valueTab[2]=IIC_ADAU1761_SLAVE_ADDR_0;
                    break;
                case 0: //CUSTOM
                    maxTab[3]=0xFF;
                    minTab[3]=0x00;
                    valueTab[2]=0x00;
                    break;
            }
            valueTab[3]=minTab[3];
            valueTab[4]=0;
        }
        oldValueTab=valueTab[1];
        if(!isTUI){ //Redraw menu if something else was print since last draw.
            TUIprint("+----------------------------- I2C REGISTER WRITE -----------------------+                 \r\n");//space at the end to erase "send" and "exit"
            TUIprint("|  %sBUS%s  |           %sTYPE%s          |  %sI2C ADDR%s  |  %sREG ADDR%s  |  %sREG VALUE%s |  >%sSEND%s\n\033[6D >%sEXIT%s\r",SEL_(place,0),_SEL,SEL_(place,1),_SEL,SEL_(place,2),_SEL,SEL_(place,3),_SEL,SEL_(place,4),_SEL,SEL_(place,5),_SEL,SEL_(place,6),_SEL);
            TUIprint("|   %d   | %-23s |    0x%02x    |   0x%04x   |     0x%02x   |\r\n",valueTab[0],type[valueTab[1]],valueTab[2],valueTab[3],valueTab[4]);
            TUIprint("+------------------------------------------------------------------------+\r\033[3A");
        }
        TUIprint("\n|  %sBUS%s  |           %sTYPE%s          |  %sI2C ADDR%s  |  %sREG ADDR%s  |  %sREG VALUE%s |  >%sSEND%s\n\033[6D >%sEXIT%s\r",SEL_(place,0),_SEL,SEL_(place,1),_SEL,SEL_(place,2),_SEL,SEL_(place,3),_SEL,SEL_(place,4),_SEL,SEL_(place,5),_SEL,SEL_(place,6),_SEL);
        TUIprint("|   %d   | %-23s |    0x%02x    |   0x%04x   |     0x%02x   |\r\033[2A",valueTab[0],type[valueTab[1]],valueTab[2],valueTab[3],valueTab[4]);//go on the bottom of the menu at the end to correctly print futur functions

        do{
            oldBtnVector=btnVector;
            btnVector=GPIO::read_btn(); //wait for button release between two command
        }while(((btnVector == oldBtnVector) || (btnVector==0)) && !exit);
    }while (!exit);
    TUIprint("\r\033[4B");
    isTUI=0; //To rebuild the menu
    debug("\033[2K[tui] Exiting I2C write \n\r");
}

void sendIIC(uint16_t* values){
    uint8_t value[1];
    uint8_t regAddr[2];
    int sizeRegAddr=0;
    switch (values[1]) {
        case 1: //SSM
            sizeRegAddr=1;
            regAddr[0]  = (values[3] << 1) | ((values[4] >> 8) & 0b1);
            regAddr[1]=0x00; //for clean printf
            break;
        case 2:
        case 3:
        case 4: // ADAU17xx
            sizeRegAddr=2;
            regAddr[0] = (values[3] >> 8) & 0xff;
            regAddr[1] = values[3] & 0xff;
            break;

        case 0: //CUSTOM
        default:
            sizeRegAddr=1;
            regAddr[0] = values[3] & 0xff;
            regAddr[1]=0x00; //for clean printf
            break;
    }

    value[0] = values[4] & 0xFF;
    println("Sending 0x%02x to register 0x%04x at I2C address 0x%02x on bus %d",values[4],values[3],values[2],values[0]);
    Audio::regwrite(regAddr,sizeRegAddr,value,sizeof(value),values[2],values[0]);
}

void cleanMenu(){
    for (int i=0; i<MAX_ENTRY+3;i++) println("");//cleaning TUI
    println("\033[%dA",MAX_ENTRY+4);
}
void functionTest(){
        println("[tui] Hello world");
}

void show_info(){
        println("----- GENERAL -----");
        println("SYFALA_BOARD: %d",SYFALA_BOARD);
        println("SYFALA_MEMORY_USE_DDR: %d",SYFALA_MEMORY_USE_DDR);
        println("SYFALA_ADAU_EXTERN: %d",SYFALA_ADAU_EXTERN);
        println("SYFALA_ADAU_MOTHERBOARD: %d",SYFALA_ADAU_MOTHERBOARD);
        println("SYFALA_VERBOSE: %d",SYFALA_VERBOSE);
        println("SYFALA_CONTROLLER_TYPE: %d",SYFALA_CONTROLLER_TYPE);
        println("SYFALA_UART_BAUD_RATE: %d",SYFALA_UART_BAUD_RATE);

        println("----- I2C -----");
        println("IIC_SCLK_RATE: %d",IIC_SCLK_RATE);
#if (SYFALA_ADAU_MOTHERBOARD) // --
        println("IIC_MOTHERBOARD_BUS: %d",IIC_MOTHERBOARD_BUS);
        println("IIC_MOTHERBOARD_TCA9548A_ADDR: 0x%02x",IIC_MOTHERBOARD_TCA9548A_ADDR);
        println("IIC_MOTHERBOARD_TCA9548A_BUS: 0x%02x",IIC_MOTHERBOARD_TCA9548A_BUS);
        println("IIC_MOTHERBOARD_PCA9956_ADDR: 0x%02x",IIC_MOTHERBOARD_PCA9956_ADDR);
        println("IIC_MOTHERBOARD_PCA9956_BUS: 0x%02x",IIC_MOTHERBOARD_PCA9956_BUS);
#endif // -------------------

        println("----- AUDIO -----");
        println("SYFALA_SAMPLE_WIDTH: %d",SYFALA_SAMPLE_WIDTH);
        println("SYFALA_SAMPLE_RATE: %d",SYFALA_SAMPLE_RATE);
        println("SYFALA_SSM_VOLUME: 0x%02x",SYFALA_SSM_VOLUME);
        println("SYFALA_SSM_SPEED: 0x%02x",SYFALA_SSM_SPEED);

        println("----- OTHER -----");
        println("SYFALA_ARM_BENCHMARK: %d",SYFALA_ARM_BENCHMARK);
        println("SYFALA_FAUST_TARGET: %d",SYFALA_FAUST_TARGET);
        println("SYFALA_CONTROL_MIDI: %d",SYFALA_CONTROL_MIDI);
        println("SYFALA_CONTROL_OSC: %d",SYFALA_CONTROL_OSC);
        println("SYFALA_CONTROL_HTTP: %d",SYFALA_CONTROL_HTTP);
        println("SYFALA_REAL_FIXED_POINT: %d",SYFALA_REAL_FIXED_POINT);
        println("SYFALA_CONTROL_BLOCK: %d",SYFALA_CONTROL_BLOCK);
        println("SYFALA_CONTROL_BLOCK_FPGA: %d",SYFALA_CONTROL_BLOCK_FPGA);
        println("SYFALA_CONTROL_BLOCK_HOST: %d",SYFALA_CONTROL_BLOCK_HOST);
        println("SYFALA_CONTROL_RELEASE: %d",SYFALA_CONTROL_RELEASE);
        println("SYFALA_DEBUG_AUDIO: %d",SYFALA_DEBUG_AUDIO);
        println("SYFALA_BLOCK_NSAMPLES: %d",SYFALA_BLOCK_NSAMPLES);
        println("SYFALA_CSIM_NUM_ITER: %d",SYFALA_CSIM_NUM_ITER);
        println("SYFALA_CSIM_INPUT_DIR: %d",SYFALA_CSIM_INPUT_DIR);

}

void GPIOtest(){
    cleanMenu();
    info("[tui] Entering GPIO test");
    println("---------- GPIO TEST ----------");
    println("Press UP and DOWN simultaneously to quit");
#if (SYFALA_BOARD_GENESYS) // --
    TUIprint("+-------------------------------------------------------------------------+\r\n");
    TUIprint("| UP (B12)  |  DOWN (J12)  |  LEFT (F12)  |  RIGHT (A12)  |  CENTER (H12) |\r\n");
    TUIprint("|           |              |              |               |               |\r\n");
    TUIprint("+-------------------------------------------------------------------------+\r\n");
    TUIprint("|    SW3 (AB14)    |    SW2 (Y13)    |    SW1 (W12)    |    SW0 (AB15)    |\r\n");
    TUIprint("|                  |                 |                 |                  |\r\n");
    TUIprint("+-------------------------------------------------------------------------+\r");
#elif (SYFALA_BOARD_ZYBO)  // --
    TUIprint("+---------------------------------------------------------------------------------+\r\n");
    TUIprint("| BTN3[UP] (Y16)  |  BTN2[DOWN] (K19)  |  BTN1[LEFT] (P16)  |  BTN0[RIGHT] (K18)  |\r\n");
    TUIprint("|                 |                    |                    |                     |\r\n");
    TUIprint("+---------------------------------------------------------------------------------+\r\n");
    TUIprint("|      SW3 (T16)     |     SW2 (W13)     |     SW1 (P15)     |      SW0 (G15)     |\r\n");
    TUIprint("|                    |                   |                   |                    |\r\n");
    TUIprint("+---------------------------------------------------------------------------------+\r");
#endif // ----------------------
    u32 btnVector=0,oldbtnVector=0;
    u32 swVector=0,oldswVector=0;
    do{
    while(oldbtnVector==btnVector && oldswVector==swVector){
        btnVector=GPIO::read_btn();
        swVector=GPIO::read_sw(3)<<3 | GPIO::read_sw(2)<<2 | GPIO::read_sw(1)<<1 | GPIO::read_sw(0);
    }
#if (SYFALA_BOARD_GENESYS) // --
    TUIprint("\033[4A|     %d     |       %d      |       %d      |       %d       |       %d       |\r\033[3B",(btnVector & BTN_UP)>>4,(btnVector & BTN_DOWN)>>2,(btnVector & BTN_LEFT)>>1,(btnVector & BTN_RIGHT),(btnVector & BTN_CENTER)>>3);
    TUIprint("|        %d         |        %d        |        %d        |         %d        |\r\n",GPIO::read_sw(3),GPIO::read_sw(2),GPIO::read_sw(1),GPIO::read_sw(0));
#elif (SYFALA_BOARD_ZYBO)  // --
    TUIprint("\033[4A|        %d        |          %d         |          %d         |           %d         |\r\033[3B",(btnVector & BTN_UP)>>4,(btnVector & BTN_DOWN)>>2,(btnVector & BTN_LEFT)>>1,(btnVector & BTN_RIGHT));
    TUIprint("|         %d          |         %d         |         %d         |          %d         |\r\n",GPIO::read_sw(3),GPIO::read_sw(2),GPIO::read_sw(1),GPIO::read_sw(0));
#endif // -------------------

    oldbtnVector=btnVector;
    oldswVector=swVector;
    }while (!(((btnVector & BTN_UP)>>4)&((btnVector & BTN_DOWN)>>2)));
    TUIprint("\r\033[2B");
    debug("\033[2K[tui] Exiting GPIO test \n\r");
    isTUI=0; //To rebuild the menu

}
/*------------------------------------------------------------------------------------------*
 *                              Just some trivial functions
 *------------------------------------------------------------------------------------------*/

const int width = 4;
const int height = 4;

static int x, y;
static int targetCordX, targetCordY;

static int tailX[16], tailY[16];
static int tailLen;
enum ekansDirection { STOP=0, LEFT, RIGHT, UP, DOWN };
static ekansDirection sDir;
int targetNb;
static bool isEkansOver;
static uint8_t savedLedStatus[PCA9965_NUM_LEDS];

void EkansInit()
{
    info("[tui] Just a trivial function, nothing to see here.");
    isEkansOver = false;
    tailLen = 0;
    sDir = STOP;
    targetNb=0;
    x = width / 2;
    y = height / 2;
    targetCordX = rand() % width;
    targetCordY = rand() % height;
    LEDdriver::saveState(savedLedStatus);
    LEDdriver::allOff();
    motherBoard::ledCodecsAllBlink();
    sleep(1);
    LEDdriver::allOff();
    LEDdriver::setBlink(0x07);
}

void EkansRender(void)
{
    for (int i = 0; i < height; i++) {
        for (int j = 0; j <= width; j++) {
            int ledCoord=15-i-(4*j);

            if (i == y && j == x){//Snake's head
              LEDdriver::ledSetBrightness(ledCoord, CODEC_LED_BRIGHTNESS_LEVEL*5);
              LEDdriver::ledOn(ledCoord);
            }
            else if (i == targetCordY && j == targetCordX){//Snake's food
                LEDdriver::ledSetBrightness(ledCoord, CODEC_LED_BRIGHTNESS_LEVEL*2);
                LEDdriver::ledBlink(ledCoord);
            }

            else { // Snake's Tail
                bool prTail = false;
                for (int k = 0; k < tailLen; k++) {
                    if (tailX[k] == j
                        && tailY[k] == i) {
                        LEDdriver::ledSetBrightness(ledCoord, CODEC_LED_BRIGHTNESS_LEVEL);
                        LEDdriver::ledOn(ledCoord);
                        prTail = true;
                    }
                }
                if (!prTail)
                    LEDdriver::ledOff(ledCoord);
            }
        }
    }
}



void EkansUpdate()
{
    int prevX = tailX[0];
    int prevY = tailY[0];
    int prev2X, prev2Y;
    tailX[0] = x;
    tailY[0] = y;

    for (int i = 1; i < tailLen; i++) {
        prev2X = tailX[i];
        prev2Y = tailY[i];
        tailX[i] = prevX;
        tailY[i] = prevY;
        prevX = prev2X;
        prevY = prev2Y;
    }

    switch (sDir) {
    case LEFT:
        x--;
        if (x < 0)x=width-1;
        break;
    case RIGHT:
        x++;
        if (x >= width)x=0;
        break;
    case UP:
        y++;
        if (y >= height)y=0;
        break;
    case DOWN:
        y--;
        if (y < 0)y=height-1;
        break;
    case STOP:
        break;
    }
    // Checks for collision with the tail
    for (int i = 0; i < tailLen; i++) {
        if (tailX[i] == x && tailY[i] == y)
            isEkansOver = true;
    }

    // Checks for collision with the target
    if (x == targetCordX && y == targetCordY) {
        targetCordX = rand() % width;
        targetCordY = rand() % height;
        tailLen++;
        targetNb += 1;
    }
}

void EkansUserInput()
{
    u32 btnVector=GPIO::read_btn();
    switch (btnVector) {
    case BTN_LEFT:
        sDir = LEFT;
        break;
    case BTN_RIGHT:
        sDir = RIGHT;
        break;
    case BTN_UP:
        sDir = UP;
        break;
    case BTN_DOWN:
        sDir = DOWN;
        break;
    case BTN_CENTER:
        sDir = STOP;
        isEkansOver = true;
        break;
    }
}

void trivialFunction()
{
    int speed=6;
    EkansInit();
    while (!isEkansOver) {
        EkansRender();
        for (int i=0; i<speed*100000; i++) EkansUserInput();
        EkansUpdate();
    }
    info("[tui] %d/16 at speed %d!",targetNb,speed);
    motherBoard::ledCodecsAllBlink();
    sleep(2);
    motherBoard::ledCodecsAllOff();
    LEDdriver::initialize();
    LEDdriver::restoreState(savedLedStatus);
    //return 0;
}



