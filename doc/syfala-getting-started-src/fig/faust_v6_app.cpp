[...]
class mydsp : public one_sample_dsp_real<float> {
        
 private:
        
        int fSampleRate;
        float fConst0;
        FAUSTFLOAT fHslider0;
        int IOTA0;
        int iVec0[2];
        float fRec0[2];
        float fRec1[2];
        
 public:
[...]
        virtual void control(int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
                fControl[0] = fConst0 * float(fHslider0);
                fControl[1] = std::sin(fControl[0]);
                fControl[2] = std::cos(fControl[0]);
        }
  [...]
}
struct ARMController {
  // Control
  ARMControlUIBase* fControlUI;
  // DSP
  mydsp* fDSP;
  [...]
void sendControlToFPGA()
  {
    XSyfala_Write_ARM_fControl_Words(&xsyfala, 0,(u32*)fControl, FAUST_REAL_CONTROLS);
    XSyfala_Write_ARM_iControl_Words(&xsyfala, 0,(u32*)iControl, FAUST_INT_CONTROLS);
  }

  void controlFPGA()
  {
    // Compute iControl and fControl from controllers value
    fDSP->control(iControl, fControl, iZone, fZone);
    // send iControl and fControl to FPGA
    sendControlToFPGA();                              
  }
[...]
