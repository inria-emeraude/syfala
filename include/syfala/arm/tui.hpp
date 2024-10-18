#pragma once

#include <stdint.h>

namespace Syfala::ARM::TUI {
/**
 * @brief Initialize the TUI.
 */
extern void initialize();
extern void drawMenu();
extern void update(int);
extern int createEntry(const char* name,int index,int condition,void (*function)(void));
extern void updateUserInput();
extern void writeIIC(void);

}
#define BTN_LEFT    0b00000010
#define BTN_RIGHT   0b00000001
#define BTN_UP      0b00010000
#define BTN_DOWN    0b00000100
#define BTN_CENTER  0b00001000

#define LINEFORMAT_RESET        "\033[0m"
#define LINEFORMAT_SELECTED     "\033[7m"
#define LINEFORMAT_AVAILABLE    "\033[1m"
#define SEL_(_i,_s) _i==_s?LINEFORMAT_SELECTED:LINEFORMAT_AVAILABLE
#define _SEL LINEFORMAT_RESET

#define MAX_ENTRY 9

void cleanMenu(void);
void sendIIC(uint16_t*);
void functionTest(void);
void trivialFunction(void);
void show_info(void);
void GPIOtest(void);
