#include "faust_v3.h"
#include <ap_int.h>
#include <stdio.h>
#include <iostream>
#include <fstream>

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif
#define FAUST_FLOAT_ZONE 8
static FAUSTFLOAT fzone[FAUST_FLOAT_ZONE];

//# define SIZE 4 //fzone size
# define INPUT 1 //input for tests

int main()
{
  ap_int<24> in_left, in_right;
  ap_int<24> out_left, out_right;
  std::ofstream debugfile;
  // init
  in_left = in_right = INPUT ;
  
  debugfile.open ("debug-faust.txt");
  // print input
  std::cout << " INPUT lEFT: " << in_left.to_string() << std::endl;
  std::cout << " INPUT RIGHT: " << in_right.to_string() << std::endl;
  
  out_left = out_right = 0 ;
  
  /**** TESTING FAUST_V3 FUNCTION *****/
  for (int i=0; i<108; i++)
    {
      faust_v3(in_left, in_right, &out_left, &out_right, fzone, false, false);
    
      // print output 
	std::cout << " OUTPUT LEFT: " << out_left.to_string() <<
	  "  ("  << out_left.to_int() << ")" << std::endl;
	std::cout << " OUTPUT RIGHT: " << out_right.to_string() <<
	  "  ("  << out_left.to_int() << ")" << std::endl;
	debugfile << " " << out_left.to_int()  << " " << std::endl;
    }
  /***** TESTING COMPUTEMYDSP FUNCTION ******/
  std::cout <<  "debug-faust.txt generated\n";
  debugfile.close();
  // reset variables
  in_left = in_right = INPUT ;
  out_left = out_right = 0;
  
}

