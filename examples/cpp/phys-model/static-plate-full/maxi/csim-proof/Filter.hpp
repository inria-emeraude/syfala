#ifndef FilterEffectBase_hpp
#define FilterEffectBase_hpp

#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cmath>
#include "nemus_constants.h"

/// Simple DSP Filter
class Filter
{
public:        // methods
    //==========================================================================
    /** Constructor. */
    Filter();
    /** Destructor. */
    ~Filter();
    //==========================================================================
    /** with the current filter coefficients this method filters a
     sample then stores it the sample Buffer and increments the index
     
     @param sampVal is the sample to be processed
     
     @returns filtered audio sample
     */
    double process(double sampVal);
    //==========================================================================
    ///
    void printBuffers();
    ///
    void printCoefs();
    /// set filter coefficients to a butterworth low pass filter
    /// @param order filter order
    /// @param normalisedCutoffFreq cutoff frequency normalise between 0.0 < W < 1.0
    bool setButterworthCoefficients(int order, double normalisedCutoffFreq);
 //==========================================================================
private:    // methods
    //==========================================================================
    /** increment the buffer index and wrap it to the filter order*/
    void incBufferIndex();
    
    //==========================================================================
    /** checks internal memory storage of filter coeffcients and deletes if
     required
     */
    void clearMemory();
    
    /** will allocate memory to a buffer given the current filter order and set
     all values == 0.00
     */
    void allocateBufferMemory();

public:     // variables
    //==========================================================================
protected:  // variables
    //==========================================================================
private:    // variables
    //==========================================================================
    ///
    static const unsigned int maxOrder = 22;
    ///
    double a[maxOrder] = {0.0};
    ///
    double b[maxOrder] = {0.0};
    ///
    double firBuffer [maxOrder] = {0.0};
    /// buffer to hold backward delay sample data
    double iirBuffer [maxOrder] = {0.0};
    /// current buffer index
    int bufferIndex = 0;
    /// current filter order
    int filterOrder = 0;
};
#endif
