#include <stdio.h>
#include "Heavy_heavy.hpp"
#include "Heavy_heavy.h"
#include "HvHeavy.h"
#include "HvSignalPhasor.h"
#include "HvSignalVar.h"
#include <syfala/utilities.hpp>
#include <xsyfala.h>

int main(int argc, const char *argv[]) {
  double sampleRate = 44100.0;

  HeavyContextInterface *context = hv_heavy_new(sampleRate);
  context.

  int numIterations = 10;
  int numOutputChannels = hv_getNumOutputChannels(context);
  int blockSize = 256; // should be a multiple of 8

  float **outBuffers = (float **) hv_malloc(numOutputChannels * sizeof(float *));
  for (int i = 0; i < numOutputChannels; ++i) {
    outBuffers[i] = (float *) hv_malloc(blockSize * sizeof(float));
  }

  // main processing loop
  for (int i = 0; i < numIterations; ++i) {
    hv_process(context, NULL, outBuffers, blockSize);
    for (int c = 0; c < numOutputChannels; ++c) {
      for (int s = 0; s < blockSize; ++s) {
        printf("%.3f ", outBuffers[c][s]);
      }
    }
  }
  hv_delete(context);
  return 0;
}
