//
//  FilterEffectBase.cpp
//  AudioEffectsSuite
//
//  Created by admin on 05/01/2018.
//  Copyright © 2018 AudioEffectsSuiteTeam. All rights reserved.
//
#ifndef FilterEffectBase_hpp
#include "Filter.hpp"

Filter::Filter(){}
Filter::~Filter(){}

//==============================================================================
double Filter::process(double sampVal)
{
    
    firBuffer[bufferIndex] = sampVal;
    
    for(int j = 0; j < filterOrder; j++)
    {
        int i = ((bufferIndex - j) + filterOrder);
        while (i >= filterOrder) i -= filterOrder;
        iirBuffer[bufferIndex] += (b[j] * firBuffer[i]) - (a[j] * iirBuffer[i]);
    }
    
    double outSample = iirBuffer[bufferIndex];
    
    incBufferIndex();
    iirBuffer[bufferIndex] = 0.0;
    
    return outSample;
}

//==============================================================================

inline void Filter::incBufferIndex()
{
    bufferIndex++;
    if(bufferIndex >= filterOrder )
        bufferIndex -= filterOrder;
}

//==============================================================================

bool Filter::setButterworthCoefficients(int order, double normalisedCutoffFreq)
{
    // parameters    
    filterOrder = order + 1;
    double n = double(order);
    double cutoff = -(normalisedCutoffFreq * 0.5) * (2.0 * nemus::pi);
    
    if(normalisedCutoffFreq >= 1.0) return false;
    
    // calculate coefficients
    double a1[maxOrder];
    
    a[0]  = 1.0;
    a1[0] = 0.0;
    b[0]  = 1.0;
    
    double scale = 1.0;
    double invert = 1.0;
    
    for (int i = 1; i <= n; ++i)
    {
        double id = double(i);
        double angle = (id - 0.5) / n * nemus::pi;
        double sinsin = 1.0 - std::sin(cutoff) * std::sin(angle);
        double rcof0 = -std::cos(cutoff) / sinsin;
        double rcof1 =  std::sin(cutoff) * std::cos(angle) / sinsin;
        a[i] = 0;
        a1[i] = 0;
        for (int j = i; j > 0; --j)
        {
            a[j]  += rcof0 * a [j-1] + rcof1 * a1[j-1];
            a1[j] += rcof0 * a1[j-1] - rcof1 * a [j-1];
        }
        scale *= sinsin * 2.0 / (1-std::cos(cutoff)*invert);
        b[i] = b[i-1] * invert * (n - id + 1.0) / id;
    }
    scale = std::sqrt(scale);
    
    for (int i = 0; i <= n; ++i)
        b[i] /= scale;
    
    return true;
}

//==============================================================================

void Filter::clearMemory()
{
    std::fill(firBuffer, firBuffer + maxOrder, 0);
    std::fill(iirBuffer, iirBuffer + maxOrder, 0);
    std::fill(b, b + maxOrder, 0);
    std::fill(a, a + maxOrder, 0);
}

//==============================================================================

void Filter::allocateBufferMemory()
{
    
}
//==============================================================================

void Filter::printBuffers()
{
    printf("FIRb\t\tIIRb\n");
    
    for (int i = 0; i < filterOrder; i++)
    {
        int j = (bufferIndex - i);
        if (j < 0) j += filterOrder;
        printf("%.4f\t%.4f\n", firBuffer[j], iirBuffer[j]);
    }
    
    printf("\n");
}

void Filter::printCoefs()
{
    printf(" A\t\t\t\tB\n");
    
    for (int i = 0; i < filterOrder; i++)
    {
        printf("%s%1.9f\t%1.9f\n", ((a[i] < 0.0)? "":" "), a[i], b[i]);
    }
    
    printf("\n");
}



#endif /* FilterEffectBase_hpp */
