//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Modal Plate Reverb
// C++ implementation by: Riccardo Russo, University of Bologna
//
// Date: 11-July-2023
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include <iostream>
#include "plateModalData.h"
#include "audio.h"
#include <chrono>

#define PI 3.141592653589793

int main(int argc, const char * argv[])
{
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
    //sets if to use the exact oscillator->no stability condition limiting the modes number
#define exactOsc true
    
//if nonzero limits the maximum frequency, useful to limit the number of modes to a specitic chosen value.
#define maxFreq 0
    
#define durSec 2  //duration in seconds of the simulation
#define baseSR 48000
    
    const unsigned int timeSamples = baseSR * durSec;
        
    float excit[timeSamples];

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
    double SR = baseSR;
    double k = 1.0 / SR;

    int modesNumber = 30000;

    if(maxFreq)
    {
        for(int i = 0; i < modesNumberFull; ++i)
        {
            if(eigenFreqs[i] > 2*PI*maxFreq)
            {
                modesNumber = i - 1;
                break;
            }
                
        }
    }
        
#if !exactOsc
    // STABILITY CONDITION FOR NON EXACT OSCILLATOR!!!
    for(int i = 0; i < modesNumberFull; ++i)
    {
        if(eigenFreqs[i] > 2/k)
        {
            modesNumber = i - 1;
            break;
        }
            
    }
#endif
    
    std::cout << "Number of Modes: " << modesNumber << '\n';
    
    //// Simulation
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
    /// Initializing vectors

    float output[timeSamples];

    float x[modesNumber];
    float xPrev[modesNumber];
    float xNext[modesNumber];
    
    float c1[modesNumber];
    float c2[modesNumber];
    float c3[modesNumber];

    for (int i = 0; i < timeSamples; ++i)
    {

        excit[i] = 0.f;
        output[i] = 0.f;
    }
    
    for (int i = 0; i < modesNumber; ++i)
    {
        x[i] = 0.f;
        xPrev[i] = 0.f;
        xNext[i] = 0.f;
        c1[i] = 2.f * exp(-dampCoeffs[i] * k)*cos(sqrt((eigenFreqs[i] * eigenFreqs[i]) - (dampCoeffs[i] * dampCoeffs[i])) * k);
        c2[i] = -exp(-2.f * dampCoeffs[i] * k);
        c3[i] = k * k * modesIn[i];
    }
    for (int n = 0; n < 10; ++n) {
        printf("n: %d, c1: %f, c2: %f, c3: %f\n",
           n, c1[n], c2[n], c3[n]
       );
    }

    excit[0] = 1.f;
    
    std::chrono::steady_clock::time_point tic = std::chrono::steady_clock::now();
    
    for (int n = 0;  n < timeSamples; ++n)
    {
        double exc = excit[n];
        for (int m = 0 ; m < modesNumber; ++m) {
            xNext[m] = c1[m] * x[m] + c2[m] * xPrev[m] + c3[m] * exc;
            xPrev[m] = x[m];
            x[m] = xNext[m];            
            output[n] += xNext[m] * modesOut[m];
        }
    }
    
    std::chrono::steady_clock::time_point toc  = std::chrono::steady_clock::now();
    double computeTime = std::chrono::duration<double >(std::chrono::duration_cast<std::chrono::nanoseconds>(toc - tic)).count();
    std::cout << "Compute Time: " << computeTime << '\n';
    
    //Debugging
    std::ofstream outFile;
    outFile.open("output.txt");

    if (!outFile.fail())
    {
        for (int n = 0; n < timeSamples; ++n)
        {
            outFile << output[n] * 100000 << '\n';
        }

        outFile.close();
    }

    audiowrite("plate", output, timeSamples, baseSR);

    return 0;
}
