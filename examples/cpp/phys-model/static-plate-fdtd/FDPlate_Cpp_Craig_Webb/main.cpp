#define ReaL double
#include "CJW_Audio.h"

#define maxp_ss 15000

#define outputfname "output_files/Plate_cpp_Craig.wav"

/*
 
 Basic Plate
 
 USES A ROW MAJOR DECOMPOSITION, Nx is numer of columns, Ny is number of rows.
 Y * (Nx+1) + X.  Memory goes in X direction, Y is +- wid
 
*/

int main()
{
    
    // ------------------------------------------------------------------------------
    // User Parameters
    int SR           = 48000;
    double K         = 0.6;          // Stiffness
    double ar        = 1.3;          // Aspect Ratio
    double low_T60   = 10.0;         // Low freq decay time
    double high_T60  = 8.0;          // Must be less than low_T60
    
    int Nf           = SR*3;
    double outposX   = 0.72;
    double outposY   = 0.41;
    double inposX    = 0.41;
    double inposY    = 0.55;
    
    // ------------------------------------------------------------------------------
    // Calculated parameters
    
    double srd       = static_cast<double>(SR);
    double k         = 1.0/srd;
    double zeta1     = 2.0 * M_PI * 100.0  / K;
    double zeta2     = 2.0 * M_PI * 1000.0 / K;
    double sig0p     = 6.0 * std::log(10.0)*(-zeta2/low_T60+zeta1/high_T60)/(zeta1-zeta2);
    double sig1p     = 6.0 * std::log(10.0)*(1.0/low_T60 -1.0/high_T60)/(zeta1-zeta2);
    
    double hp        = 2.0*std::sqrt( sig1p*sig1p + std::sqrt( sig1p*sig1p + K*K*k*k ));
    int Nx           = (int)std::floor(std::sqrt(ar)/hp);
    hp               = std::sqrt(ar)/Nx;
    int Ny           = (int)std::floor(1.0/(std::sqrt(ar)*hp));
    int ss           = (Nx+1)*(Ny+1);
    
    int wid          = Nx+1;
    int inint        = ((int)std::floor((Ny+1.0)*inposY))  * wid + (int)std::floor(wid*inposX);
    int outint       = ((int)std::floor((Ny+1.0)*outposY)) * wid + (int)std::floor(wid*outposX);
    
    // ------------------------------------------------------------------------------
    // Scheme coeffs
    double mu2       = K*K*k*k/(hp*hp*hp*hp);
    double sig0k     = 1.0 + sig0p*k;
    double sig1k     = (2.0*sig1p*k)/(hp*hp);
    
    double B1        = (-mu2*-8.0 + sig1k ) / sig0k;
    double B2        = -mu2 / sig0k;
    double B3        = (-mu2*2.0) / sig0k;
    double B4        = (-mu2*20.0 + 2.0 + sig1k*-4.0) / sig0k;
    
    double C1        = (-2.0*sig1p*k/(hp*hp) ) / (1.0 + sig0p*k);
    double C2        = ((sig1p*k-1.0) - (2.0*sig1p*k/(hp*hp) )*-4.0) / (1.0 + sig0p*k);
    
    // ---------------------------------------------------------
    // Memory pointers
    double *ptr;
    
    if (ss > maxp_ss)
    {
        printf("ss too large...\n");
        return 0;
    }
    
    alignas(32) double udata[maxp_ss];
    alignas(32) double u1data[maxp_ss];
    alignas(32) double u2data[maxp_ss];
    
    for (int i = 0; i < maxp_ss; ++i)
    {
        udata[i]  = 0.0;
        u1data[i] = 0.0;
        u2data[i] = 0.0;
    }
    
    double *u  = udata;
    double *u1 = u1data;
    double *u2 = u2data;
    
    double *out  = (double *)calloc(Nf,sizeof(double));
    
    // -------------------------------------------------------------------------------
    printf("--- Plate Test Craig Webb version --- \n\n");
    printf("Grid      : %d x %d = %d\n", Nx+1, Ny+1, ss);
    printf("Dur       : %d \n", Nf);
    printf("In_cell   : %d\n",inint);
    printf("Out_cell  : %d\n", outint);
    
    double start, end;
    int cp = 0; 
    timers(&start);
    
    // --------------------------------------------------------------
    // Time loop
    for(int n = 0; n < Nf; ++n)
    {
        // Interior update
        for(int Y = 2; Y < (Ny-1); ++Y)
        {
            for(int X = 2; X < (Nx-1); ++X)
            {
                
                cp = Y*wid+X;
                
                u[cp] = B1*(u1[cp-1]     + u1[cp+1]     + u1[cp-wid]   + u1[cp+wid]  )
                      + B2*(u1[cp-2]     + u1[cp+2]     + u1[cp-2*wid] + u1[cp+2*wid])
                      + B3*(u1[cp+wid-1] + u1[cp+wid+1] + u1[cp-wid-1] + u1[cp-wid+1])
                      + B4* u1[cp]       + C2*u2[cp]
                      + C1*(u2[cp-1]     + u2[cp+1]     + u2[cp-wid]   + u2[cp+wid]  );

            }
        }
        
        // Add impulse
        if (n == 1)
        {
            u[inint] += 1.0;
        }
        
        // read output
        out[n] = u[outint];

        // swap pointers
        ptr = u2;
        u2  = u1;
        u1  = u;
        u   = ptr;
        
    }
    
    timers(&end);
    printf("\nProcess time : %.6f seconds \n", (end-start));
    
    printLastSamples(out, Nf, 5);
    
    writeWav(out, out, outputfname, Nf, SR);
    
    // -------------------------------------------------------------------------------
    free(out);
    
    printf("\nComplete...\n");
    return 0;
}

