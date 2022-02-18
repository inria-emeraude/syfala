// ==============================================================

#ifndef FAUST_V6_APP_H
#define FAUST_V6_APP_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

void setParamFPGA(const char *name, FAUSTFLOAT value);
void setParamWithController(const char *name, FAUSTFLOAT value);
void autoMapController(int* tab_value, int number);
float getParamFPGA(XFaust_v6 *InstancePtr,const char *name);
int user_faust_ctrl(XFaust_v6 *faust_v6, u32 *ddr_ptr);
void printListParamFPGA(void );
void controlmyfpga(XFaust_v6 *InstancePtr);
#ifdef __cplusplus
}
#endif

#endif
