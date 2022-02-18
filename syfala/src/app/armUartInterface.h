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
    
    private:
        
        // TODO : add serial ports
        
    public:
        
        UartReceiverUI()
        {
        // WARNING!! It works well without this initialisation, I don't know if I have to do it...
			/*
			 * Initialize the UART driver so that it's ready to use
			 * Look up the configuration in the config table and then initialize it.
			 */
			 
			XUartPs_Config *Config;
			XUartPs Uart_Ps;        // The instance of the UART Driver 
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
    
		void readControlString(char* receivedString)
		{
			char RecvB;
			int idx  = 0;
			do     // as long as data is being receive
			{
				//while(XUartPs_IsReceiveData(STDIN_BASEADDRESS));
				RecvB = XUartPs_RecvByte(STDIN_BASEADDRESS);     // read the received byte and print it in hex
				//xil_printf("%X ",RecvB);
				if (RecvB != '\n') receivedString[idx++] = RecvB;
			} while(RecvB != '\n');
        }

		FAUSTFLOAT readControlValue()
		{
			FAUSTFLOAT controlValue;
			char* receivedString =(char*)&controlValue;
			char RecvB;
			int idx = 0;
			do     // as long as data is being receive
			{
				//while(XUartPs_IsReceiveData(STDIN_BASEADDRESS));
				RecvB = XUartPs_RecvByte(STDIN_BASEADDRESS);     // read the received byte and print it in hex
				//xil_printf("%X ",RecvB);
				receivedString[idx++]=RecvB;
			} while (idx < 4);

			//memcpy(&controlValue, &receivedString, sizeof(4));
			//printf("controlValue= %f \n",controlValue);
			return controlValue;
		}

        void send()
        {/*
            for (const auto& it : fPathZoneMap) {
                
                char* path = it.first.c_str();
                FAUSTFLOAT value = *it.second;
                
                // TODO
                // write 'path 'on serial port
                // write 'value 'on serial port
            }*/
        }
        
        // Function that reads the serial port
        void receive()
        {
            char path[512]={'\0'};
            readControlString(path);

            // Set value
            *fPathZoneMap[path] = readControlValue();
        }
    
        void update()
        {
            //send();
            receive();
        }
        
};
#endif // FAUST_UARTRECEIVERUI_H
/**************************  END  UartReceiverUI.h **************************/
