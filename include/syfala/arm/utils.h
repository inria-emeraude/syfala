/******************************************************************************
* @file utils.h
* Utils file for ARM
* @authors M.POPOFF
*
* @date 10/17/2022
*
*****************************************************************************/

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __UTILS_H
#define __UTILS_H


#define get_max(x,y) (((x) >= (y)) ? (x) : (y))

 /* 0: no print, 1= INFO only, 2= DEBUG (all) */
#define VERBOSE_LEVEL 2

/* WARNING: no ';' at the end to prevent double coma if you call " PRINT_INFO("x");" which can be a problem in a non-bracketized if for example */
#define PRINT_DEBUG(...)    do{ if(VERBOSE_LEVEL>=2) {xil_printf(__VA_ARGS__); } }while(0)
#define PRINT_INFO(...)    do{ if(VERBOSE_LEVEL>=1) { xil_printf(__VA_ARGS__); } }while(0)



/* tiré de util_console.h (projet STM32), peut être utile...
#define PRINTNOW()      do{                                                           \
                          SysTime_t stime  =SysTimeGetMcuTime();                      \
                          TraceSend("%3ds%03d: ",stime.Seconds, stime.SubSeconds); \
                         }while(0)

#define PPRINTF(...)     do{ } while( 0!= TraceSend(__VA_ARGS__) ) //Polling Mode
*/

#endif /*__UTILS_H */
