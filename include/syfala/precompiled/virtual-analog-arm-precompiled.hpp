/************************** BEGIN meta.h *******************************
 FAUST Architecture File
 Copyright (C) 2003-2022 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation; either version 2.1 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.
 ************************************************************************/

#ifndef __meta__
#define __meta__

/************************************************************************
 ************************************************************************
    FAUST compiler
    Copyright (C) 2003-2018 GRAME, Centre National de Creation Musicale
    ---------------------------------------------------------------------
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 ************************************************************************
 ************************************************************************/

#ifndef __export__
#define __export__

#define FAUSTVERSION "2.41.1"

// Use FAUST_API for code that is part of the external API but is also compiled in faust and libfaust
// Use LIBFAUST_API for code that is compiled in faust and libfaust

#ifdef _WIN32
    #pragma warning (disable: 4251)
    #ifdef FAUST_EXE
        #define FAUST_API
        #define LIBFAUST_API
    #elif FAUST_LIB
        #define FAUST_API __declspec(dllexport)
        #define LIBFAUST_API __declspec(dllexport)
    #else
        #define FAUST_API
        #define LIBFAUST_API
    #endif
#else
    #ifdef FAUST_EXE
        #define FAUST_API
        #define LIBFAUST_API
    #else
        #define FAUST_API __attribute__((visibility("default")))
        #define LIBFAUST_API __attribute__((visibility("default")))
    #endif
#endif

#endif

/**
 The base class of Meta handler to be used in dsp::metadata(Meta* m) method to retrieve (key, value) metadata.
 */
struct FAUST_API Meta {
    virtual ~Meta() {}
    virtual void declare(const char* key, const char* value) = 0;
};

#endif
/**************************  END  meta.h **************************/
/************************** BEGIN one-sample-dsp.h ************************
FAUST Architecture File
Copyright (C) 2003-2022 GRAME, Centre National de Creation Musicale
---------------------------------------------------------------------
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

EXCEPTION : As a special exception, you may create a larger work
that contains this FAUST architecture section and distribute
that work under terms of your choice, so long as this FAUST
architecture section is not modified.
***************************************************************************/

#ifndef __one_sample_dsp__
#define __one_sample_dsp__

#include <assert.h>
/************************** BEGIN dsp.h ********************************
 FAUST Architecture File
 Copyright (C) 2003-2022 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation; either version 2.1 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.
 ************************************************************************/

#ifndef __dsp__
#define __dsp__

#include <string>
#include <vector>


#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

struct FAUST_API UI;
struct FAUST_API Meta;

/**
 * DSP memory manager.
 */

struct FAUST_API dsp_memory_manager {

    virtual ~dsp_memory_manager() {}

    /**
     * Inform the Memory Manager with the number of expected memory zones.
     * @param count - the number of expected memory zones
     */
    virtual void begin(size_t count) {}

    /**
     * Give the Memory Manager information on a given memory zone.
     * @param size - the size in bytes of the memory zone
     * @param reads - the number of Read access to the zone used to compute one frame
     * @param writes - the number of Write access to the zone used to compute one frame
     */
    virtual void info(size_t size, size_t reads, size_t writes) {}

    /**
     * Inform the Memory Manager that all memory zones have been described,
     * to possibly start a 'compute the best allocation strategy' step.
     */
    virtual void end() {}

    /**
     * Allocate a memory zone.
     * @param size - the memory zone size in bytes
     */
    virtual void* allocate(size_t size) = 0;

    /**
     * Destroy a memory zone.
     * @param ptr - the memory zone pointer to be deallocated
     */
    virtual void destroy(void* ptr) = 0;

};

/**
* Signal processor definition.
*/

class FAUST_API dsp {

    public:

        dsp() {}
        virtual ~dsp() {}

        /* Return instance number of audio inputs */
        virtual int getNumInputs() = 0;

        /* Return instance number of audio outputs */
        virtual int getNumOutputs() = 0;

        /**
         * Trigger the ui_interface parameter with instance specific calls
         * to 'openTabBox', 'addButton', 'addVerticalSlider'... in order to build the UI.
         *
         * @param ui_interface - the user interface builder
         */
        virtual void buildUserInterface(UI* ui_interface) = 0;

        /* Return the sample rate currently used by the instance */
        virtual int getSampleRate() = 0;

        /**
         * Global init, calls the following methods:
         * - static class 'classInit': static tables initialization
         * - 'instanceInit': constants and instance state initialization
         *
         * @param sample_rate - the sampling rate in Hz
         */
        virtual void init(int sample_rate) = 0;

        /**
         * Init instance state
         *
         * @param sample_rate - the sampling rate in Hz
         */
        virtual void instanceInit(int sample_rate) = 0;

        /**
         * Init instance constant state
         *
         * @param sample_rate - the sampling rate in Hz
         */
        virtual void instanceConstants(int sample_rate) = 0;

        /* Init default control parameters values */
        virtual void instanceResetUserInterface() = 0;

        /* Init instance state (like delay lines...) but keep the control parameter values */
        virtual void instanceClear() = 0;

        /**
         * Return a clone of the instance.
         *
         * @return a copy of the instance on success, otherwise a null pointer.
         */
        virtual dsp* clone() = 0;

        /**
         * Trigger the Meta* parameter with instance specific calls to 'declare' (key, value) metadata.
         *
         * @param m - the Meta* meta user
         */
        virtual void metadata(Meta* m) = 0;

        /**
         * DSP instance computation, to be called with successive in/out audio buffers.
         *
         * @param count - the number of frames to compute
         * @param inputs - the input audio buffers as an array of non-interleaved FAUSTFLOAT samples (eiher float, double or quad)
         * @param outputs - the output audio buffers as an array of non-interleaved FAUSTFLOAT samples (eiher float, double or quad)
         *
         */
        virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) = 0;

        /**
         * DSP instance computation: alternative method to be used by subclasses.
         *
         * @param date_usec - the timestamp in microsec given by audio driver.
         * @param count - the number of frames to compute
         * @param inputs - the input audio buffers as an array of non-interleaved FAUSTFLOAT samples (either float, double or quad)
         * @param outputs - the output audio buffers as an array of non-interleaved FAUSTFLOAT samples (either float, double or quad)
         *
         */
        virtual void compute(double /*date_usec*/, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) { compute(count, inputs, outputs); }

};

/**
 * Generic DSP decorator.
 */

class FAUST_API decorator_dsp : public dsp {

    protected:

        dsp* fDSP;

    public:

        decorator_dsp(dsp* dsp = nullptr):fDSP(dsp) {}
        virtual ~decorator_dsp() { delete fDSP; }

        virtual int getNumInputs() { return fDSP->getNumInputs(); }
        virtual int getNumOutputs() { return fDSP->getNumOutputs(); }
        virtual void buildUserInterface(UI* ui_interface) { fDSP->buildUserInterface(ui_interface); }
        virtual int getSampleRate() { return fDSP->getSampleRate(); }
        virtual void init(int sample_rate) { fDSP->init(sample_rate); }
        virtual void instanceInit(int sample_rate) { fDSP->instanceInit(sample_rate); }
        virtual void instanceConstants(int sample_rate) { fDSP->instanceConstants(sample_rate); }
        virtual void instanceResetUserInterface() { fDSP->instanceResetUserInterface(); }
        virtual void instanceClear() { fDSP->instanceClear(); }
        virtual decorator_dsp* clone() { return new decorator_dsp(fDSP->clone()); }
        virtual void metadata(Meta* m) { fDSP->metadata(m); }
        // Beware: subclasses usually have to overload the two 'compute' methods
        virtual void compute(int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) { fDSP->compute(count, inputs, outputs); }
        virtual void compute(double date_usec, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) { fDSP->compute(date_usec, count, inputs, outputs); }

};

/**
 * DSP factory class, used with LLVM and Interpreter backends
 * to create DSP instances from a compiled DSP program.
 */

class FAUST_API dsp_factory {

    protected:

        // So that to force sub-classes to use deleteDSPFactory(dsp_factory* factory);
        virtual ~dsp_factory() {}

    public:

        virtual std::string getName() = 0;
        virtual std::string getSHAKey() = 0;
        virtual std::string getDSPCode() = 0;
        virtual std::string getCompileOptions() = 0;
        virtual std::vector<std::string> getLibraryList() = 0;
        virtual std::vector<std::string> getIncludePathnames() = 0;

        virtual dsp* createDSPInstance() = 0;

        virtual void setMemoryManager(dsp_memory_manager* manager) = 0;
        virtual dsp_memory_manager* getMemoryManager() = 0;

};

// Denormal handling

#if defined (__SSE__)
#include <xmmintrin.h>
#endif

class FAUST_API ScopedNoDenormals {

    private:

        intptr_t fpsr;

        void setFpStatusRegister(intptr_t fpsr_aux) noexcept
        {
        #if defined (__arm64__) || defined (__aarch64__)
           asm volatile("msr fpcr, %0" : : "ri" (fpsr_aux));
        #elif defined (__SSE__)
            _mm_setcsr(static_cast<uint32_t>(fpsr_aux));
        #endif
        }

        void getFpStatusRegister() noexcept
        {
        #if defined (__arm64__) || defined (__aarch64__)
            asm volatile("mrs %0, fpcr" : "=r" (fpsr));
        #elif defined ( __SSE__)
            fpsr = static_cast<intptr_t>(_mm_getcsr());
        #endif
        }

    public:

        ScopedNoDenormals() noexcept
        {
        #if defined (__arm64__) || defined (__aarch64__)
            intptr_t mask = (1 << 24 /* FZ */);
        #else
            #if defined(__SSE__)
            #if defined(__SSE2__)
                intptr_t mask = 0x8040;
            #else
                intptr_t mask = 0x8000;
            #endif
            #else
                intptr_t mask = 0x0000;
            #endif
        #endif
            getFpStatusRegister();
            setFpStatusRegister(fpsr | mask);
        }

        ~ScopedNoDenormals() noexcept
        {
            setFpStatusRegister(fpsr);
        }

};

#define AVOIDDENORMALS ScopedNoDenormals();

#endif

/************************** END dsp.h **************************/

class FAUST_API one_sample_dsp : public dsp {

    protected:

        FAUSTFLOAT* fInputs;
        FAUSTFLOAT* fOutputs;

        int* iControl;
        FAUSTFLOAT* fControl;

        bool fDelete;

        void checkAlloc()
        {
            // Allocated once (TODO : make this RT safe)
            if (!fInputs) {
                fInputs = new FAUSTFLOAT[getNumInputs() * 4096];
                fOutputs = new FAUSTFLOAT[getNumOutputs() * 4096];
            }
            if (!iControl) {
                iControl = new int[getNumIntControls()];
                fControl = new FAUSTFLOAT[getNumRealControls()];
            }
        }

    public:

        one_sample_dsp():fInputs(nullptr), fOutputs(nullptr), iControl(nullptr), fControl(nullptr), fDelete(true)
        {}

        one_sample_dsp(int* iControl, FAUSTFLOAT* fControl)
        :fInputs(nullptr), fOutputs(nullptr),
        iControl(iControl), fControl(fControl), fDelete(false)
        {}

        virtual ~one_sample_dsp()
        {
            delete [] fInputs;
            delete [] fOutputs;
            if (fDelete) {
                delete [] iControl;
                delete [] fControl;
            }
        }

        /**
         * Return the number of 'int' typed values necessary to compute the internal DSP state
         *
         * @return the number of 'int' typed values.
         */
        virtual int getNumIntControls() = 0;

        /**
         * Return the number of 'float, double or quad' typed values necessary to compute the DSP control state
         *
         * @return the number of 'float, double or quad' typed values.
         */
        virtual int getNumRealControls() = 0;

        /**
         * Update the DSP control state.
         *
         * @param iControl - an externally allocated array of 'int' typed values used to keep the DSP control state
         * @param fControl - an externally allocated array of 'float, double or quad' typed values used to keep the DSP control state
         */
        virtual void control(int* iControl, FAUSTFLOAT* fControl) = 0;

        // Alternative external version
        virtual void control()
        {
            checkAlloc();
            control(iControl, fControl);
        }

        /**
         * Compute one sample.
         *
         * @param inputs - the input audio buffers as an array of getNumInputs FAUSTFLOAT samples (either float, double or quad)
         * @param outputs - the output audio buffers as an array of getNumOutputs FAUSTFLOAT samples (either float, double or quad)
         * @param iControl - the externally allocated array of 'int' typed values used to keep the DSP control state
         * @param fControl - the externally allocated array of 'float, double or quad' typed values used to keep the DSP control state
         */
        virtual void compute(FAUSTFLOAT* inputs, FAUSTFLOAT* outputs, int* iControl, FAUSTFLOAT* fControl) = 0;

        // The standard 'compute' expressed using the control/compute (one sample) model
        virtual void compute(int count, FAUSTFLOAT** inputs_aux, FAUSTFLOAT** outputs_aux)
        {
            // Control
            control();

            // Compute
            int num_inputs = getNumInputs();
            int num_outputs = getNumOutputs();

            FAUSTFLOAT* inputs_ptr = &fInputs[0];
            FAUSTFLOAT* outputs_ptr = &fOutputs[0];

            for (int frame = 0; frame < count; frame++) {
                for (int chan = 0; chan < num_inputs; chan++) {
                    inputs_ptr[chan] = inputs_aux[chan][frame];
                }
                inputs_ptr += num_inputs;
            }

            inputs_ptr = &fInputs[0];
            for (int frame = 0; frame < count; frame++) {
                // One sample compute
                compute(inputs_ptr, outputs_ptr, iControl, fControl);
                inputs_ptr += num_inputs;
                outputs_ptr += num_outputs;
            }

            outputs_ptr = &fOutputs[0];
            for (int frame = 0; frame < count; frame++) {
                for (int chan = 0; chan < num_outputs; chan++) {
                    outputs_aux[chan][frame] = outputs_ptr[chan];
                }
                outputs_ptr += num_outputs;
            }
        }

        virtual void compute(double date_usec, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs)
        {
            compute(count, inputs, outputs);
        }

        int* getIControl() { return iControl; }
        FAUSTFLOAT* getFControl() { return fControl; }

};

// To be used with -os1 and -os2 mode

template <typename REAL>
class FAUST_API one_sample_dsp_real : public dsp {

    protected:

        FAUSTFLOAT* fInputs;
        FAUSTFLOAT* fOutputs;

        int* iControl;
        FAUSTFLOAT* fControl;

        int* iZone;
        REAL* fZone;

        bool fDelete;

        void checkAlloc()
        {
            // Allocated once (TODO : make this RT safe)
            if (!fInputs) {
                fInputs = new FAUSTFLOAT[getNumInputs() * 4096];
                fOutputs = new FAUSTFLOAT[getNumOutputs() * 4096];
            }
            if (!iControl) {
                iControl = new int[getNumIntControls()];
                fControl = new FAUSTFLOAT[getNumRealControls()];
                iZone = new int[getiZoneSize()];
                fZone = new REAL[getfZoneSize()];
            }
        }

    public:

        one_sample_dsp_real()
        :fInputs(nullptr), fOutputs(nullptr),
        iControl(nullptr), fControl(nullptr),
        iZone(nullptr), fZone(nullptr), fDelete(true)
        {}

        one_sample_dsp_real(int* iControl, FAUSTFLOAT* fControl, int* iZone, REAL* fZone)
        :fInputs(nullptr), fOutputs(nullptr),
        iControl(iControl), fControl(fControl),
        iZone(iZone), fZone(fZone), fDelete(false)
        {}

        virtual ~one_sample_dsp_real()
        {
            delete [] fInputs;
            delete [] fOutputs;
            if (fDelete) {
                delete [] iControl;
                delete [] fControl;
                delete [] iZone;
                delete [] fZone;
            }
        }

        virtual void init(int sample_rate)
        {
            checkAlloc();
            init(sample_rate, iZone, fZone);
        }

        virtual void init(int sample_rate, int* iZone, REAL* fZone) = 0;

        virtual void instanceInit(int sample_rate)
        {
            checkAlloc();
            instanceInit(sample_rate, iZone, fZone);
        }

        virtual void instanceInit(int sample_rate, int* iZone, REAL* fZone) = 0;

        virtual void instanceConstants(int sample_rate)
        {
            checkAlloc();
            instanceConstants(sample_rate, iZone, fZone);
        }

        virtual void instanceConstants(int sample_rate, int* iZone, REAL* fZone) = 0;

        virtual void instanceClear()
        {
            checkAlloc();
            instanceClear(iZone, fZone);
        }

        virtual void instanceClear(int* iZone, REAL* fZone) = 0;

        /**
         * Return the number of 'int' typed values necessary to compute the internal DSP state
         *
         * @return the number of 'int' typed values.
         */
        virtual int getNumIntControls() = 0;

        /**
         * Return the number of 'float, double or quad' typed values necessary to compute the DSP control state
         *
         * @return the number of 'float, double or quad' typed values.
         */
        virtual int getNumRealControls() = 0;

        /**
        * Return the size on 'float, double or quad' typed values necessary to compute the DSP state
        *
        * @return the number of 'float, double or quad' typed values.
        */
        virtual int getiZoneSize() = 0;

        /**
         * Return the size on 'int' typed values necessary to compute the DSP state
         *
         * @return the number of 'int' typed values.
         */
        virtual int getfZoneSize() = 0;

        /**
         * Update the DSP control state.
         *
         * @param iControl - an externally allocated array of 'int' typed values used to keep the DSP control state
         * @param fControl - an externally allocated array of 'float, double or quad' typed values used to keep the DSP control state
         * @param iZone - an externally allocated array of 'int' typed values used to keep the DSP state
         * @param fZone - an externally allocated array of 'float, double or quad' typed values used to keep the DSP state
         */
        virtual void control(int* iControl, FAUSTFLOAT* fControl, int* iZone, REAL* fZone) = 0;

        // Alternative external version
        virtual void control()
        {
            control(iControl, fControl, iZone, fZone);
        }

        /**
         * Compute one sample.
         *
         * @param inputs - the input audio buffers as an array of getNumInputs FAUSTFLOAT samples (either float, double or quad)
         * @param outputs - the output audio buffers as an array of getNumOutputs FAUSTFLOAT samples (either float, double or quad)
         * @param iControl - the externally allocated array of 'int' typed values used to keep the DSP control state
         * @param fControl - the externally allocated array of 'float, double or quad' typed values used to keep the DSP control state
         * @param iZone - an externally allocated array of 'int' typed values used to keep the DSP state
         * @param fZone - an externally allocated array of 'float, double or quad' typed values used to keep the DSP state
         */
        virtual void compute(FAUSTFLOAT* inputs, FAUSTFLOAT* outputs,
                             int* iControl, FAUSTFLOAT* fControl,
                             int* iZone, REAL* fZone) = 0;

        // The standard 'compute' expressed using the control/compute (one sample) model
        virtual void compute(int count, FAUSTFLOAT** inputs_aux, FAUSTFLOAT** outputs_aux)
        {
            assert(fInputs);

            // Control
            control();

            // Compute
            int num_inputs = getNumInputs();
            int num_outputs = getNumOutputs();

            FAUSTFLOAT* inputs_ptr = &fInputs[0];
            FAUSTFLOAT* outputs_ptr = &fOutputs[0];

            for (int frame = 0; frame < count; frame++) {
                for (int chan = 0; chan < num_inputs; chan++) {
                    inputs_ptr[chan] = inputs_aux[chan][frame];
                }
                inputs_ptr += num_inputs;
            }

            inputs_ptr = &fInputs[0];
            for (int frame = 0; frame < count; frame++) {
                // One sample compute
                compute(inputs_ptr, outputs_ptr, iControl, fControl, iZone, fZone);
                inputs_ptr += num_inputs;
                outputs_ptr += num_outputs;
            }

            outputs_ptr = &fOutputs[0];
            for (int frame = 0; frame < count; frame++) {
                for (int chan = 0; chan < num_outputs; chan++) {
                    outputs_aux[chan][frame] = outputs_ptr[chan];
                }
                outputs_ptr += num_outputs;
            }
        }

        virtual void compute(double date_usec, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs)
        {
            compute(count, inputs, outputs);
        }

        int* getIControl() { return iControl; }
        FAUSTFLOAT* getFControl() { return fControl; }

        int* getIZone() { return iZone; }
        REAL* getFZone() { return fZone; }

};

// To be used with -os3 mode

template <typename REAL>
class FAUST_API one_sample_dsp_real1 : public dsp {

    protected:

        FAUSTFLOAT* fInputs;
        FAUSTFLOAT* fOutputs;

    public:

        one_sample_dsp_real1():fInputs(nullptr), fOutputs(nullptr)
        {}

        virtual ~one_sample_dsp_real1()
        {
            delete [] fInputs;
            delete [] fOutputs;
        }

        /**
         * Return the number of 'int' typed values necessary to compute the internal DSP state
         *
         * @return the number of 'int' typed values.
         */
        virtual int getNumIntControls() = 0;

        /**
         * Return the number of 'float, double or quad' typed values necessary to compute the DSP control state
         *
         * @return the number of 'float, double or quad' typed values.
         */
        virtual int getNumRealControls() = 0;

        /**
         * Return the size on 'float, double or quad' typed values necessary to compute the DSP state
         *
         * @return the number of 'float, double or quad' typed values.
         */
        virtual int getiZoneSize() = 0;

        /**
         * Return the size on 'int' typed values necessary to compute the DSP state
         *
         * @return the number of 'int' typed values.
         */
        virtual int getfZoneSize() = 0;

        /**
         * Update the DSP control state.
         */
        virtual void control() = 0;

        /**
         * Compute one sample.
         *
         * @param inputs - the input audio buffers as an array of getNumInputs FAUSTFLOAT samples (either float, double or quad)
         * @param outputs - the output audio buffers as an array of getNumOutputs FAUSTFLOAT samples (either float, double or quad)
         */
        virtual void compute(FAUSTFLOAT* inputs, FAUSTFLOAT* outputs) = 0;

        // The standard 'compute' expressed using the control/compute (one sample) model
        virtual void compute(int count, FAUSTFLOAT** inputs_aux, FAUSTFLOAT** outputs_aux)
        {
            // TODO : not RT safe
            if (!fInputs) {
                fInputs = new FAUSTFLOAT[getNumInputs() * 4096];
                fOutputs = new FAUSTFLOAT[getNumOutputs() * 4096];
            }

            // Control
            control();

            // Compute
            int num_inputs = getNumInputs();
            int num_outputs = getNumOutputs();

            FAUSTFLOAT* inputs_ptr = &fInputs[0];
            FAUSTFLOAT* outputs_ptr = &fOutputs[0];

            for (int frame = 0; frame < count; frame++) {
                for (int chan = 0; chan < num_inputs; chan++) {
                    inputs_ptr[chan] = inputs_aux[chan][frame];
                }
                inputs_ptr += num_inputs;
            }

            inputs_ptr = &fInputs[0];
            for (int frame = 0; frame < count; frame++) {
                // One sample compute
                compute(inputs_ptr, outputs_ptr);
                inputs_ptr += num_inputs;
                outputs_ptr += num_outputs;
            }

            outputs_ptr = &fOutputs[0];
            for (int frame = 0; frame < count; frame++) {
                for (int chan = 0; chan < num_outputs; chan++) {
                    outputs_aux[chan][frame] = outputs_ptr[chan];
                }
                outputs_ptr += num_outputs;
            }
        }

        virtual void compute(double date_usec, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs)
        {
            compute(count, inputs, outputs);
        }

};

#endif
/************************** END one-sample-dsp.h **************************/
/************************** BEGIN DecoratorUI.h **************************
 FAUST Architecture File
Copyright (C) 2003-2022 GRAME, Centre National de Creation Musicale
---------------------------------------------------------------------
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

EXCEPTION : As a special exception, you may create a larger work
that contains this FAUST architecture section and distribute
that work under terms of your choice, so long as this FAUST
architecture section is not modified.
*************************************************************************/

#ifndef Decorator_UI_H
#define Decorator_UI_H

/************************** BEGIN UI.h *****************************
 FAUST Architecture File
 Copyright (C) 2003-2022 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation; either version 2.1 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.
 ********************************************************************/

#ifndef __UI_H__
#define __UI_H__


#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

/*******************************************************************************
 * UI : Faust DSP User Interface
 * User Interface as expected by the buildUserInterface() method of a DSP.
 * This abstract class contains only the method that the Faust compiler can
 * generate to describe a DSP user interface.
 ******************************************************************************/

struct Soundfile;

template <typename REAL>
struct FAUST_API UIReal {

    UIReal() {}
    virtual ~UIReal() {}

    // -- widget's layouts

    virtual void openTabBox(const char* label) = 0;
    virtual void openHorizontalBox(const char* label) = 0;
    virtual void openVerticalBox(const char* label) = 0;
    virtual void closeBox() = 0;

    // -- active widgets

    virtual void addButton(const char* label, REAL* zone) = 0;
    virtual void addCheckButton(const char* label, REAL* zone) = 0;
    virtual void addVerticalSlider(const char* label, REAL* zone, REAL init, REAL min, REAL max, REAL step) = 0;
    virtual void addHorizontalSlider(const char* label, REAL* zone, REAL init, REAL min, REAL max, REAL step) = 0;
    virtual void addNumEntry(const char* label, REAL* zone, REAL init, REAL min, REAL max, REAL step) = 0;

    // -- passive widgets

    virtual void addHorizontalBargraph(const char* label, REAL* zone, REAL min, REAL max) = 0;
    virtual void addVerticalBargraph(const char* label, REAL* zone, REAL min, REAL max) = 0;

    // -- soundfiles

    virtual void addSoundfile(const char* label, const char* filename, Soundfile** sf_zone) = 0;

    // -- metadata declarations

    virtual void declare(REAL* zone, const char* key, const char* val) {}

    // To be used by LLVM client
    virtual int sizeOfFAUSTFLOAT() { return sizeof(FAUSTFLOAT); }
};

struct FAUST_API UI : public UIReal<FAUSTFLOAT> {
    UI() {}
    virtual ~UI() {}
};

#endif
/**************************  END  UI.h **************************/

//----------------------------------------------------------------
//  Generic UI empty implementation
//----------------------------------------------------------------

class FAUST_API GenericUI : public UI
{

    public:

        GenericUI() {}
        virtual ~GenericUI() {}

        // -- widget's layouts
        virtual void openTabBox(const char* label) {}
        virtual void openHorizontalBox(const char* label) {}
        virtual void openVerticalBox(const char* label) {}
        virtual void closeBox() {}

        // -- active widgets
        virtual void addButton(const char* label, FAUSTFLOAT* zone) {}
        virtual void addCheckButton(const char* label, FAUSTFLOAT* zone) {}
        virtual void addVerticalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) {}
        virtual void addHorizontalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) {}
        virtual void addNumEntry(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) {}

        // -- passive widgets
        virtual void addHorizontalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) {}
        virtual void addVerticalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max) {}

        // -- soundfiles
        virtual void addSoundfile(const char* label, const char* soundpath, Soundfile** sf_zone) {}

        virtual void declare(FAUSTFLOAT* zone, const char* key, const char* val) {}

};

//----------------------------------------------------------------
//  Generic UI decorator
//----------------------------------------------------------------

class FAUST_API DecoratorUI : public UI
{

    protected:

        UI* fUI;

    public:

        DecoratorUI(UI* ui = 0):fUI(ui) {}
        virtual ~DecoratorUI() { delete fUI; }

        // -- widget's layouts
        virtual void openTabBox(const char* label)          { fUI->openTabBox(label); }
        virtual void openHorizontalBox(const char* label)   { fUI->openHorizontalBox(label); }
        virtual void openVerticalBox(const char* label)     { fUI->openVerticalBox(label); }
        virtual void closeBox()                             { fUI->closeBox(); }

        // -- active widgets
        virtual void addButton(const char* label, FAUSTFLOAT* zone)         { fUI->addButton(label, zone); }
        virtual void addCheckButton(const char* label, FAUSTFLOAT* zone)    { fUI->addCheckButton(label, zone); }
        virtual void addVerticalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
        { fUI->addVerticalSlider(label, zone, init, min, max, step); }
        virtual void addHorizontalSlider(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
        { fUI->addHorizontalSlider(label, zone, init, min, max, step); }
        virtual void addNumEntry(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
        { fUI->addNumEntry(label, zone, init, min, max, step); }

        // -- passive widgets
        virtual void addHorizontalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max)
        { fUI->addHorizontalBargraph(label, zone, min, max); }
        virtual void addVerticalBargraph(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max)
        { fUI->addVerticalBargraph(label, zone, min, max); }

        // -- soundfiles
        virtual void addSoundfile(const char* label, const char* filename, Soundfile** sf_zone) { fUI->addSoundfile(label, filename, sf_zone); }

        virtual void declare(FAUSTFLOAT* zone, const char* key, const char* val) { fUI->declare(zone, key, val); }

};

// Defined here to simplify header #include inclusion
class FAUST_API SoundUIInterface : public GenericUI {};

#endif
/**************************  END  DecoratorUI.h **************************/

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <math.h>

static float mydsp_faustpower2_f(float value) {
    return value * value;
}

#ifndef FAUSTCLASS
#define FAUSTCLASS mydsp
#endif

#ifdef __APPLE__
#define exp10f __exp10f
#define exp10 __exp10
#endif

#if defined(_WIN32)
#define RESTRICT __restrict
#else
#define RESTRICT __restrict__
#endif

class mydsp : public one_sample_dsp_real<float> {

 public:

    FAUSTFLOAT fHslider0;
    int fSampleRate;
    float fConst0;
    float fConst1;
    FAUSTFLOAT fHslider1;
    float fConst2;
    int IOTA0;
    int iVec0[2];
    float fRec0[2];
    FAUSTFLOAT fButton0;
    float fConst4;
    float fConst5;
    float fRec2[2];
    float fRec3[2];
    float fConst6;
    FAUSTFLOAT fHslider2;
    float fRec4[2];
    FAUSTFLOAT fButton1;
    FAUSTFLOAT fHslider3;
    int iRec6[2];
    float fConst7;
    FAUSTFLOAT fHslider4;
    float fRec7[2];
    FAUSTFLOAT fHslider5;
    float fRec8[2];
    float fRec1[4];

 public:
    mydsp() {}
    mydsp(int* icontrol, float* fcontrol, int* izone, float* fzone):one_sample_dsp_real(icontrol, fcontrol, izone, fzone) {}

    void metadata(Meta* m) {
        m->declare("compile_options", "-a /home/pierre/Repositories/syfala-v7/source/faust/architecture/arm.cpp -lang cpp -i -os2 -es 1 -mcd 0 -uim -single -ftz 0");
        m->declare("filename", "virtualAnalog.dsp");
        m->declare("filters.lib/fir:author", "Julius O. Smith III");
        m->declare("filters.lib/fir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/fir:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/iir:author", "Julius O. Smith III");
        m->declare("filters.lib/iir:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/iir:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/lowpass0_highpass1", "MIT-style STK-4.3 license");
        m->declare("filters.lib/name", "Faust Filters Library");
        m->declare("filters.lib/nlf2:author", "Julius O. Smith III");
        m->declare("filters.lib/nlf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/nlf2:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/resonlp:author", "Julius O. Smith III");
        m->declare("filters.lib/resonlp:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/resonlp:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/tf2:author", "Julius O. Smith III");
        m->declare("filters.lib/tf2:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/tf2:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/tf2s:author", "Julius O. Smith III");
        m->declare("filters.lib/tf2s:copyright", "Copyright (C) 2003-2019 by Julius O. Smith III <jos@ccrma.stanford.edu>");
        m->declare("filters.lib/tf2s:license", "MIT-style STK-4.3 license");
        m->declare("filters.lib/version", "0.3");
        m->declare("maths.lib/author", "GRAME");
        m->declare("maths.lib/copyright", "GRAME");
        m->declare("maths.lib/license", "LGPL with exception");
        m->declare("maths.lib/name", "Faust Math Library");
        m->declare("maths.lib/version", "2.5");
        m->declare("name", "virtualAnalog");
        m->declare("noises.lib/name", "Faust Noise Generator Library");
        m->declare("noises.lib/version", "0.4");
        m->declare("oscillators.lib/lf_sawpos:author", "Bart Brouns, revised by Stéphane Letz");
        m->declare("oscillators.lib/lf_sawpos:licence", "STK-4.3");
        m->declare("oscillators.lib/lf_triangle:author", "Bart Brouns");
        m->declare("oscillators.lib/lf_triangle:licence", "STK-4.3");
        m->declare("oscillators.lib/name", "Faust Oscillator Library");
        m->declare("oscillators.lib/saw1:author", "Bart Brouns");
        m->declare("oscillators.lib/saw1:licence", "STK-4.3");
        m->declare("oscillators.lib/version", "0.3");
        m->declare("platform.lib/name", "Generic Platform Library");
        m->declare("platform.lib/version", "0.2");
        m->declare("signals.lib/name", "Faust Signal Routing Library");
        m->declare("signals.lib/version", "0.3");
    }

    virtual int getNumInputs() {
        return 0;
    }
    virtual int getNumOutputs() {
        return 2;
    }

    static void classInit(int sample_rate) {}

    void staticInit(int sample_rate, int* iZone, float* fZone) {
    }

    virtual void instanceConstants(int sample_rate, int* iZone, float* fZone) {
        fSampleRate = sample_rate;
        fConst0 = std::min<float>(192000.0f, std::max<float>(1.0f, float(fSampleRate)));
        fConst1 = 44.0999985f / fConst0;
        fConst2 = 1.0f - fConst1;
        float fConst3 = 2764.60156f / fConst0;
        fConst4 = std::sin(fConst3);
        fConst5 = std::cos(fConst3);
        fConst6 = 1.0f / fConst0;
        fConst7 = 3.14159274f / fConst0;
    }

    virtual void instanceConstantsFromMem(int sample_rate, int* iZone, float* fZone) {
        fSampleRate = sample_rate;
        fConst0 = fZone[0];
        fConst1 = fZone[1];
        fConst2 = fZone[2];
        fConst4 = fZone[3];
        fConst5 = fZone[4];
        fConst6 = fZone[5];
        fConst7 = fZone[6];
    }

    virtual void instanceConstantsToMem(int sample_rate, int* iZone, float* fZone) {
        fSampleRate = sample_rate;
        fZone[0] = fConst0;
        fZone[1] = fConst1;
        fZone[2] = fConst2;
        fZone[3] = fConst4;
        fZone[4] = fConst5;
        fZone[5] = fConst6;
        fZone[6] = fConst7;
    }

    virtual void instanceResetUserInterface() {
        fHslider0 = FAUSTFLOAT(0.80000000000000004f);
        fHslider1 = FAUSTFLOAT(0.5f);
        fButton0 = FAUSTFLOAT(0.0f);
        fHslider2 = FAUSTFLOAT(80.0f);
        fButton1 = FAUSTFLOAT(0.0f);
        fHslider3 = FAUSTFLOAT(0.0f);
        fHslider4 = FAUSTFLOAT(1000.0f);
        fHslider5 = FAUSTFLOAT(1.0f);
    }

    virtual void instanceClear(int* iZone, float* fZone) {
        IOTA0 = 0;
        for (int l0 = 0; l0 < 2; l0 = l0 + 1) {
            iVec0[l0] = 0;
        }
        for (int l1 = 0; l1 < 2; l1 = l1 + 1) {
            fRec0[l1] = 0.0f;
        }
        for (int l2 = 0; l2 < 2; l2 = l2 + 1) {
            fRec2[l2] = 0.0f;
        }
        for (int l3 = 0; l3 < 2; l3 = l3 + 1) {
            fRec3[l3] = 0.0f;
        }
        for (int l4 = 0; l4 < 2; l4 = l4 + 1) {
            fRec4[l4] = 0.0f;
        }
        for (int l5 = 0; l5 < 2; l5 = l5 + 1) {
            iRec6[l5] = 0;
        }
        for (int l6 = 0; l6 < 2; l6 = l6 + 1) {
            fRec7[l6] = 0.0f;
        }
        for (int l7 = 0; l7 < 2; l7 = l7 + 1) {
            fRec8[l7] = 0.0f;
        }
        for (int l8 = 0; l8 < 4; l8 = l8 + 1) {
            fRec1[l8] = 0.0f;
        }
    }

    virtual void init(int sample_rate, int* iZone, float* fZone) {
        instanceInit(sample_rate, iZone, fZone);
    }

    virtual void instanceInit(int sample_rate, int* iZone, float* fZone) {
        staticInit(sample_rate, iZone, fZone);
        instanceConstants(sample_rate, iZone, fZone);
        instanceConstantsToMem(sample_rate, iZone, fZone);
        instanceResetUserInterface();
        instanceClear(iZone, fZone);
    }

    virtual mydsp* clone() {
        return new mydsp();
    }

    virtual int getSampleRate() {
        return fSampleRate;
    }

    virtual void buildUserInterface(UI* ui_interface) {
        ui_interface->openVerticalBox("virtualAnalog");
        ui_interface->declare(&fButton1, "switch", "6");
        ui_interface->addButton("activateNoise", &fButton1);
        ui_interface->declare(&fButton0, "switch", "5");
        ui_interface->addButton("killSwitch", &fButton0);
        ui_interface->declare(&fHslider5, "knob", "2");
        ui_interface->addHorizontalSlider("lfoFreq", &fHslider5, FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f), FAUSTFLOAT(8.0f), FAUSTFLOAT(0.00999999978f));
        ui_interface->declare(&fHslider4, "knob", "3");
        ui_interface->addHorizontalSlider("lfoRange", &fHslider4, FAUSTFLOAT(1000.0f), FAUSTFLOAT(10.0f), FAUSTFLOAT(5000.0f), FAUSTFLOAT(0.00999999978f));
        ui_interface->declare(&fHslider0, "slider", "8");
        ui_interface->addHorizontalSlider("masterVol", &fHslider0, FAUSTFLOAT(0.800000012f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f));
        ui_interface->declare(&fHslider3, "slider", "7");
        ui_interface->addHorizontalSlider("noiseGain", &fHslider3, FAUSTFLOAT(0.0f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f));
        ui_interface->declare(&fHslider2, "knob", "1");
        ui_interface->addHorizontalSlider("oscFreq", &fHslider2, FAUSTFLOAT(80.0f), FAUSTFLOAT(50.0f), FAUSTFLOAT(500.0f), FAUSTFLOAT(0.00999999978f));
        ui_interface->declare(&fHslider1, "knob", "4");
        ui_interface->addHorizontalSlider("pan", &fHslider1, FAUSTFLOAT(0.5f), FAUSTFLOAT(0.0f), FAUSTFLOAT(1.0f), FAUSTFLOAT(0.00999999978f));
        ui_interface->closeBox();
    }

    virtual void control(int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
        fControl[0] = mydsp_faustpower2_f(float(fHslider0));
        fControl[1] = fConst1 * float(fHslider1);
        fControl[2] = 0.25f * (1.0f - float(fButton0));
        fControl[3] = std::max<float>(1.1920929e-07f, std::fabs(float(fHslider2)));
        fControl[4] = fConst6 * fControl[3];
        fControl[5] = 1.0f - fConst0 / fControl[3];
        fControl[6] = 4.65661287e-10f * float(fButton1) * mydsp_faustpower2_f(float(fHslider3));
        fControl[7] = fConst1 * float(fHslider4);
        fControl[8] = fConst6 * float(fHslider5);
    }

    virtual int getNumIntControls() { return 0; }
    virtual int getNumRealControls() { return 9; }

    virtual int getiZoneSize() { return 0; }
    virtual int getfZoneSize() { return 7; }

    virtual void compute(float* RESTRICT inputs, float* RESTRICT outputs, int* RESTRICT iControl, float* RESTRICT fControl, int* RESTRICT iZone, float* RESTRICT fZone) {
        iVec0[IOTA0 & 1] = 1;
        fRec0[IOTA0 & 1] = fControl[1] + fConst2 * fRec0[(IOTA0 - 1) & 1];
        float fTemp0 = fRec0[IOTA0 & 1];
        float fTemp1 = fRec3[(IOTA0 - 1) & 1];
        float fTemp2 = fRec2[(IOTA0 - 1) & 1];
        fRec2[IOTA0 & 1] = fConst4 * fTemp1 + fConst5 * fTemp2;
        fRec3[IOTA0 & 1] = (float(1 - iVec0[(IOTA0 - 1) & 1]) + fConst5 * fTemp1) - fConst4 * fTemp2;
        float fTemp3 = fRec4[(IOTA0 - 1) & 1];
        float fTemp4 = fControl[4] + fTemp3 + -1.0f;
        int iTemp5 = fTemp4 < 0.0f;
        float fTemp6 = fControl[4] + fTemp3;
        fRec4[IOTA0 & 1] = ((iTemp5) ? fTemp6 : fTemp4);
        float fThen1 = fControl[4] + fTemp3 + fControl[5] * fTemp4;
        float fRec5 = ((iTemp5) ? fTemp6 : fThen1);
        iRec6[IOTA0 & 1] = 1103515245 * iRec6[(IOTA0 - 1) & 1] + 12345;
        float fTemp7 = fRec1[(IOTA0 - 2) & 3];
        fRec7[IOTA0 & 1] = fControl[7] + fConst2 * fRec7[(IOTA0 - 1) & 1];
        float fTemp8 = fRec8[(IOTA0 - 1) & 1];
        fRec8[IOTA0 & 1] = fControl[8] + fTemp8 - std::floor(fControl[8] + fTemp8);
        float fTemp9 = std::tan(fConst7 * (0.5f * fRec7[IOTA0 & 1] * (2.0f * (1.0f - std::fabs(2.0f * fRec8[IOTA0 & 1] + -1.0f)) + -1.0f + 1.0f) + 50.0f));
        float fTemp10 = 1.0f / fTemp9;
        float fTemp11 = fRec1[(IOTA0 - 1) & 3];
        float fTemp12 = (fTemp10 + 0.200000003f) / fTemp9 + 1.0f;
        fRec1[IOTA0 & 3] = (fControl[2] * fRec3[IOTA0 & 1] * (2.0f * fRec5 + -1.0f) + fControl[6] * float(iRec6[IOTA0 & 1])) - (fTemp7 * ((fTemp10 + -0.200000003f) / fTemp9 + 1.0f) + 2.0f * fTemp11 * (1.0f - 1.0f / mydsp_faustpower2_f(fTemp9))) / fTemp12;
        float fTemp13 = fTemp7 + fRec1[IOTA0 & 3] + 2.0f * fTemp11;
        outputs[0] = FAUSTFLOAT(fControl[0] * ((1.0f - fTemp0) * fTemp13) / fTemp12);
        outputs[1] = FAUSTFLOAT(fControl[0] * (fTemp0 * fTemp13) / fTemp12);
        IOTA0 = IOTA0 + 1;
    }

};

#define FAUST_INT_CONTROLS 0
#define FAUST_REAL_CONTROLS 9

#define FAUST_INT_ZONE 0
#define FAUST_FLOAT_ZONE 7

#ifdef FAUST_UIMACROS

    #define FAUST_FILE_NAME "virtualAnalog.dsp"
    #define FAUST_CLASS_NAME "mydsp"
    #define FAUST_COMPILATION_OPIONS "-a /home/pierre/Repositories/syfala-v7/source/faust/architecture/arm.cpp -lang cpp -i -os2 -es 1 -mcd 0 -uim -single -ftz 0"
    #define FAUST_INPUTS 0
    #define FAUST_OUTPUTS 2
    #define FAUST_ACTIVES 8
    #define FAUST_PASSIVES 0

    FAUST_ADDBUTTON("activateNoise", fButton1);
    FAUST_ADDBUTTON("killSwitch", fButton0);
    FAUST_ADDHORIZONTALSLIDER("lfoFreq", fHslider5, 1.0f, 0.01f, 8.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("lfoRange", fHslider4, 1000.0f, 10.0f, 5000.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("masterVol", fHslider0, 0.80000000000000004f, 0.0f, 1.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("noiseGain", fHslider3, 0.0f, 0.0f, 1.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("oscFreq", fHslider2, 80.0f, 50.0f, 500.0f, 0.01f);
    FAUST_ADDHORIZONTALSLIDER("pan", fHslider1, 0.5f, 0.0f, 1.0f, 0.01f);

    #define FAUST_LIST_ACTIVES(p) \
        p(BUTTON, activateNoise, "activateNoise", fButton1, 0.0f, 0.0f, 1.0f, 1.0f) \
        p(BUTTON, killSwitch, "killSwitch", fButton0, 0.0f, 0.0f, 1.0f, 1.0f) \
        p(HORIZONTALSLIDER, lfoFreq, "lfoFreq", fHslider5, 1.0f, 0.01f, 8.0f, 0.01f) \
        p(HORIZONTALSLIDER, lfoRange, "lfoRange", fHslider4, 1000.0f, 10.0f, 5000.0f, 0.01f) \
        p(HORIZONTALSLIDER, masterVol, "masterVol", fHslider0, 0.80000000000000004f, 0.0f, 1.0f, 0.01f) \
        p(HORIZONTALSLIDER, noiseGain, "noiseGain", fHslider3, 0.0f, 0.0f, 1.0f, 0.01f) \
        p(HORIZONTALSLIDER, oscFreq, "oscFreq", fHslider2, 80.0f, 50.0f, 500.0f, 0.01f) \
        p(HORIZONTALSLIDER, pan, "pan", fHslider1, 0.5f, 0.0f, 1.0f, 0.01f) \

    #define FAUST_LIST_PASSIVES(p) \

#endif
