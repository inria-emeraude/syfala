/************************** BEGIN UartUI.h **************************/
/************************************************************************
 FAUST Architecture File
 Copyright (C) 2003-2017 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This Architecture section is free software; you can redistribute it
 and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3 of
 the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; If not, see <http://www.gnu.org/licenses/>.

 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.
 ************************************************************************/

#ifndef FAUST_UARTRECEIVERUI_H
#define FAUST_UARTRECEIVERUI_H

#include "faust/gui/MapUI.h"

class UartReceiverUI : public MapUI
{

  protected:

    // TODO : add serial ports

    std::map<std::string, FAUSTFLOAT*> fBargraphZoneMap;

    // -- passive widgets
    void addHorizontalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT fmin, FAUSTFLOAT fmax)
    {
      fBargraphZoneMap[buildPath(label)] = zone;
    }
    void addVerticalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT fmin, FAUSTFLOAT fmax)
    {
      fBargraphZoneMap[buildPath(label)] = zone;
    }
    XUartPs Uart_Ps;        // The instance of the UART Driver


  public:
    UartReceiverUI()
    {
    // WARNING!! It works well without this initialisation, I don't know if I have to do it...
   /*
   * Initialize the UART driver so that it's ready to use
   * Look up the configuration in the config table and then initialize it.
   */
      XUartPs_Config *Config;

      Config = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
      if (NULL == Config) {
        printf("Error while XUartPs_LookupConfig\n");
      }
      int Status = XUartPs_CfgInitialize(&Uart_Ps, Config, XPAR_PS7_UART_1_BASEADDR);
      if (Status != XST_SUCCESS) {
        printf("Error while XUartPs_CfgInitialize\n");
      } else {
        printf("UART OK\n");
      }
      //XUartPs_SetBaudRate(&Uart_Ps, 115200);
    }

    virtual ~UartReceiverUI()
    {}

    /* Read NumBytes on the serial port.
    * This is an alternativ to:
    * while (!XUartPs_IsReceiveData(STDIN_BASEADDRESS)) {;}
    * XUartPs_Recv(&Uart_Ps, (u8*)stringSize,NumBytes);
    * But we don't use it because we are not assured that we get NumBytes char (see XUartPs_Recv description). You need to check the number of received char and do a
    * while function. So it's simplier to use the XUartPs_RecvByte function
    */
    void readUARTString(char* receivedString, int NumBytes)
    {
      for (int receivedChar=0; receivedChar<NumBytes; receivedChar++)
      {
        receivedString[receivedChar]=(char)XUartPs_RecvByte(STDIN_BASEADDRESS); //Read byte to byte in blocking mode, we can't miss a byte.
      }
    }

    int getstringSize()
    {
      char stringSize[3]={'\0'};
      readUARTString(stringSize,3);
      int size=atoi(stringSize);
      //printf("Size:%s\n",stringSize);
      return size;
    }

    /* Send bargraph through serial port.
    * We don't use printf to send the value because we want to send the float value on 4 bytes, it's easier to decode than to print the decimal representation because we don't
    * know how many digit there will be in the decimal representation.
    * But if we use printf to send 4 char (bytes), there will be a null char send when char=0. So we use the XUartPs_Send.
    * Then, we have to use XUartPs_SendByte for the path because it won't works if the two string aren't send with the same method.
    */
    void send()
    {
      for (const auto& it : fBargraphZoneMap) {
        char sendString[512]={'\0'};
        const char* path = it.first.c_str();
        //float value = *(it.second);
        sprintf(sendString,"%03d%s",(int)strlen(path),path);
        while (XUartPs_IsTransmitFull(STDIN_BASEADDRESS)) {;}
        XUartPs_Send(&Uart_Ps,(u8*)sendString,strlen(sendString));
        char *pt = (char *)(it.second);
        for(int i=0;i<4;i++){
          XUartPs_SendByte(STDIN_BASEADDRESS,(u8)*pt++);
        }
        /*sprintf(sendString,"\r\n");
        while (XUartPs_IsTransmitFull(STDIN_BASEADDRESS)) {;}
        XUartPs_Send(&Uart_Ps,(u8*)sendString,strlen(sendString));*/
      }
    }

    /* Function that reads the serial port
    * We only read one controller per call of this function.
    * But there is no need to read more because the user can't move more than 1 controller at a time
    */
    void receive()
    {
      char path[512]={'\0'};
      FAUSTFLOAT value;
      char* valueStr =(char*)&value;
      readUARTString(path,getstringSize());
      readUARTString(valueStr,4);
      // Set value
      if (fPathZoneMap.find(path) != fPathZoneMap.end())
      {
        //printf("Path:|%s|\nValue:|%f|\n",path,value);
         *fPathZoneMap[path] = value;
      }
    }

    void update()
    {
      send();
      receive();
    }
};
#endif // FAUST_UARTRECEIVERUI_H
/**************************  END  UartReceiverUI.h **************************/
