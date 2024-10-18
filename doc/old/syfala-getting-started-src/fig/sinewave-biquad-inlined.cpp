[...]
typedef struct {
        int fSampleRate;
        float fConst0;
        FAUSTFLOAT fHslider0;
        int IOTA0;
        int iVec0[2];
        float fRec0[2];
        float fRec1[2];
} mydsp;
[....]
void instanceConstantsFromMemmydsp(mydsp* dsp, int sample_rate, int* iZone, float* fZone) {
        dsp->fSampleRate = sample_rate;
        dsp->fConst0 = fZone[0];
}
[....]
void computemydsp(mydsp* dsp, FAUSTFLOAT* inputs, 
        FAUSTFLOAT* outputs, int* iControl, float* fControl, 
        int* iZone, float* fZone) {
    dsp->iVec0[(dsp->IOTA0 & 1)] = 1;
    float fTemp0 = dsp->fRec1[((dsp->IOTA0 - 1) & 1)];
    float fTemp1 = dsp->fRec0[((dsp->IOTA0 - 1) & 1)];
    dsp->fRec0[(dsp->IOTA0 & 1)] = ((fControl[1]*fTemp0) + 
        (fControl[2] * fTemp1));
    dsp->fRec1[(dsp->IOTA0 & 1)] = (((float)(1 - 
        dsp->iVec0[((dsp->IOTA0 - 1) & 1)]) + (fControl[2] * 
        fTemp0)) - (fControl[1] * fTemp1));
    float fTemp2 = dsp->fRec1[((dsp->IOTA0 - 0) & 1)];
    outputs[0] = (FAUSTFLOAT)fTemp2;
    outputs[1] = (FAUSTFLOAT)fTemp2;
    dsp->IOTA0 = (dsp->IOTA0 + 1);
}
[....]
/* body of syfala() function */
if (enable_RAM_access) {
    if (cpt==0) {
      /* first iteration: constant initialization */
      cpt++:
      instanceConstantsFromMemmydsp(&DSP,SAMPLE_RATE,I_ZONE,F_ZONE);
    }
    else
      {
        /* all other iterations: compute one sample */

       computemydsp(&DSP, inputs, outputs, icontrol, fcontrol, I_ZONE, F_ZONE);
        
      }
  }
[...]
