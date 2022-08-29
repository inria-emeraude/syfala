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

#ifndef FAUST_UARTUISENDER_H
#define FAUST_UARTUISENDER_H


#define SERIAL_PORT "/dev/ttyUSB1"


#include <string>
#include <stdio.h>
#include <unistd.h>
#include <iostream>
#include <thread>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <termios.h>
#include <time.h>

// File control definitions
#include <fcntl.h>
#include <sys/ioctl.h>

#include <syconfig.hpp>
#include "faust/gui/MapUI.h"

class UARTSenderUI : public MapUI
{

  private:
    int fd;
#ifdef LOG_UART
    int fdLog;
#endif
    // Update thread
    std::thread* fThread;
    bool fRunning;

    // Current values
    std::vector<FAUSTFLOAT> fValues;

    static void update_cb(UARTSenderUI* uart_ui)
    {
      while (uart_ui->fRunning) {
        uart_ui->update();
#ifdef LOG_UART
        // Wait 100 ms
       usleep(100000);
#else
        // Wait 20 ms. For now, bargraph aren't working at this speed...
        usleep(20000);
#endif

      }
    }

  public:

    UARTSenderUI():fThread(nullptr), fRunning(false)
    {
      /* Connection to serial port */
      // Structure with the device's options
      struct termios options;
      // Open device
      fd = open(SERIAL_PORT, O_RDWR | O_NOCTTY | O_NDELAY);
      // If the device is not open, return -1
      if (fd == -1) {
          printf("error %d opening /dev/ttyUSB1: %s\n", errno, strerror (errno));
          exit(1);
      }
      // Open the device in nonblocking mode
      fcntl(fd, F_SETFL, FNDELAY);

      // Get the current options of the port
      tcgetattr(fd, &options);
      // Clear all the options
      bzero(&options, sizeof(options));

      // Prepare speed (Bauds)
      speed_t Speed;
      Speed=B115200;

      // Set the baud rate
      cfsetispeed(&options, Speed);
      cfsetospeed(&options, Speed);
      // Configure the device : 8 bits, no parity, no control
      options.c_cflag |= ( CLOCAL | CREAD |  CS8);
      options.c_iflag |= ( IGNPAR | IGNBRK );
      // Timer unused
      options.c_cc[VTIME]=0;
      // At least on character before satisfy reading
      options.c_cc[VMIN]=0;
      // Activate the settings
      tcsetattr(fd, TCSANOW, &options);

#ifdef LOG_UART
      /*Log file */
      fdLog = open("./uart.log", O_CREAT | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR);
      if (fdLog == -1) printf("[ERROR] while opening the log file\n");
#endif
    }

    virtual ~UARTSenderUI()
    {
      // Close the serial device
      close (fd);
#ifdef LOG_UART
      close (fdLog);
#endif
      fRunning = false;
      fThread->join();
      delete fThread;
    }

    /* Read the serial while we don't have the requested byte numebr
    */
    int readUARTString(void* receivedString, int NumBytes)
    {
      int read_length = 0;
      while (read_length < NumBytes)
      {
        int delta = read(fd, receivedString + read_length, NumBytes - read_length);
        if (delta == -1) return -1;
        if (delta == 0) return 0; //We don't want to be blocked if the buffer is empty
        read_length += delta;
      }
      return (int)read_length;
    }

    /* Get the first 3 char of the string, corresponding to the size of the following path
    */
    int getstringSize()
    {
      char stringSize[4]={'\0'};
      if(readUARTString(stringSize,3)==0) // Nothing more to read in the serial buffer
      {
        return -1;
      }
      int size=atoi(stringSize);
      return size;
    }

    /* Send all controllers that have changed since the last send
    */
    void send()
    {
      int index = 0;
      char sendString[512]={'\0'};
      int newValue=0;
      for (const auto& it : fPathZoneMap)
      {
        FAUSTFLOAT value = *(it.second);
        // Only send when the value changes
        if (value != fValues[index])
        {
          newValue=1;
          // Update current value
          fValues[index] = value;
          sprintf(sendString,"%03d%s",(int)strlen(it.first.c_str()),it.first.c_str());
          write(fd, sendString, strlen(sendString));
          char *pt = (char *)&value;
          for(int i=0;i<4;i++){
             write(fd, pt++, 1);
          }
        }
        index++;
      }
      if(newValue==0)//if no new value is send, send a dummy char to unlock the receive fuction (ARM side)
      {
        char nullString[7]={'0'};
        write(fd, nullString, 7);
      }
    }

    /* Receive the bargraph.
    * Read the serial port while there is data in it.
    * Because the ARM wont send anything else than the state of each bargraph between two controller receptions,
    * we are sure to read all the bargraphs, and that there will be no queue.
    */
    void receive()
    {
      char path[512]={'\0'};
      FAUSTFLOAT value;
      char* valueStr =(char*)&value;
      int size=0;
      size=getstringSize();
      while(size!=-1) //Check if serial fill is not empty
      {
        readUARTString(path,size);
        readUARTString(valueStr,4);
        // Set value
        if (fPathZoneMap.find(path) != fPathZoneMap.end())
        {
          //printf( "path: |%s|\n", path);
          //printf( "val: |%f|\n", value);
          *fPathZoneMap[path] = value;
        }
        size=getstringSize();
      }
    }

#ifdef LOG_UART
    void writeLog(){
      time_t t = time(NULL);
      struct tm tm = *localtime(&t);
      char sendString[512]={'\0'};

      sprintf(sendString,"\n\r%d-%02d-%02d %02d:%02d:%02d\n", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec);
      write(fdLog, sendString, strlen(sendString));
      for (const auto& it : fPathZoneMap)
      {
        float value = *(it.second);
        const char* path = it.first.c_str();

        // Write current value
        sprintf(sendString,"%s: %f\n",path,value);
        write(fdLog, sendString, strlen(sendString));
      }
    }
#endif

    void update()
    {
      send();
     receive(); //DEBUG WARNING: don't open a terminal (putty/minicom/etc...) if you use this function (conflict)
#ifdef LOG_UART
      writeLog();
#endif
    }

    void start()
    {
      // Sample current values
      for (const auto& it : fPathZoneMap) {
          //fValues.push_back(*it.second);
          fValues.push_back(0); //set all to 0 to force to send all value at launch
      }
      fRunning = true;
      fThread = new std::thread(update_cb, this);
    }
};

#endif // FAUST_UARTUISENDER_H
/**************************  END  UartSenderUI.h **************************/
