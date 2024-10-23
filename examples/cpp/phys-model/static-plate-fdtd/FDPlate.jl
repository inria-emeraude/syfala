using WAV
using TickTock
using GLMakie

const maxp_ss :: Int = 15000

const outputfname :: String = "output_files/Plate_jl.wav"

#=
 
 Basic Plate
 
 USES A ROW MAJOR DECOMPOSITION, Nx is numer of columns, Ny is number of rows.
 Y * (Nx+1) + X.  Memory goes in X direction, Y is +- wid
 
=#

function printLastSamples(audio :: Vector, Nf :: Integer, N :: Integer) :: Nothing
    
    # Test that N > 0
    if N<1
        print("Must display 1 or more samples...\n");
    
    else
        #print last N samples
        print("\n");
        for n in (Nf-N):Nf
        
            print("Sample $(n) : $(audio[n])\n");
        end 
        
        # find max
        maxy = 0.0;
        for n in 1:Nf
        
            (abs(audio[n])>maxy) && (maxy = abs(audio[n]));
            
        end 
        print("\nMax sample   : $(maxy)\n");
    end 
    
end 


function main() :: Nothing
    
    # ------------------------------------------------------------------------------
    # User Parameters
    # SR        = 48000;
    # K         = 0.6;          # Stiffness
    # ar        = 1.3;          # Aspect Ratio
    # low_T60   = 10.0;         # Low freq decay time
    # high_T60  = 8.0;          # Must be less than low_T60
    
    # Nf        = SR*3;
    # outposX   = 0.72;
    # outposY   = 0.41;
    # inposX    = 0.41;
    # inposY    = 0.55;
    
    # ------------------------------------------------------------------------------
    # Calculated parameters
    
    # srd       = Float64(SR);
    # k         = 1.0/srd;
    # zeta1     = 2.0 * π * 100.0  / K;
    # zeta2     = 2.0 * π * 1000.0 / K;
    # sig0p     = 6.0 * log(10.0)*(-zeta2/low_T60+zeta1/high_T60)/(zeta1-zeta2);
    # sig1p     = 6.0 * log(10.0)*(1.0/low_T60 -1.0/high_T60)/(zeta1-zeta2);
    
    # hp        = 2.0*sqrt( sig1p*sig1p + sqrt( sig1p*sig1p + K*K*k*k ));
    # Nx        = floor(Int, sqrt(ar)/hp);
    # hp        = sqrt(ar)/Nx;
    # Ny        = floor(Int, 1.0/(sqrt(ar)*hp));
    # ss        = (Nx+1)*(Ny+1);
    
    # wid       = Nx+1;
    # inint     = (floor(Int, (Ny + 1)*inposY))  * wid + floor(Int, wid*inposX) + 1;
    # outint    = (floor(Int, (Ny + 1)*outposY)) * wid + floor(Int, wid*outposX) + 1;

    # # ------------------------------------------------------------------------------
    # # Scheme coeffs
    # mu2       = K*K*k*k/(hp*hp*hp*hp);
    # sig0k     = 1.0 + sig0p*k;
    # sig1k     = (2.0*sig1p*k)/(hp*hp);
    
    # B1        = (-mu2*-8.0 + sig1k ) / sig0k;
    # B2        = -mu2 / sig0k;
    # B3        = (-mu2*2.0) / sig0k;
    # B4        = (-mu2*20.0 + 2.0 + sig1k*-4.0) / sig0k;
    
    # C1        = (-2.0*sig1p*k/(hp*hp) ) / (1.0 + sig0p*k);
    # C2        = ((sig1p*k-1.0) - (2.0*sig1p*k/(hp*hp) )*-4.0) / (1.0 + sig0p*k);
    
    SR = 48000
    K = 0.6
    ar = 1.3
    low_T60 = 10.0
    high_T60 = 8.0
    Nf = 144000
    outposX = 0.72
    outposY = 0.41
    inposX = 0.41
    inposY = 0.55
    srd = 48000.0
    k = 2.0833333333333333e-5
    zeta1 = 1047.1975511965977
    zeta2 = 10471.975511965977
    sig0p = 1.34317463757986
    sig1p = 3.664677994397138e-5
    # Nx = 91
    # Ny = 70
    Nx = 84
    Ny = 100
    hp = 0.012529400275814704
    ss = 6532
    wid = 92
    inint = 3626
    outint = 2735
    mu2 = 0.006340140624999996
    sig0k = 1.0000279828049496
    sig1k = 9.726666176795735e-6
    B1 = 0.050729432114372704
    B2 = -0.006339963215045962
    B3 = -0.012679926430091923
    B4 = 1.8731058660791926
    C1 = -9.72639400500943e-6
    C2 = -0.9999331116385926

    # ---------------------------------------------------------
    # Memory pointers
    if (ss > maxp_ss)
        print("ss too large...\n");
        
        return nothing
    end
    
    udata = zeros(Float64, maxp_ss)
    u1data = zeros(Float64, maxp_ss)
    u2data = zeros(Float64, maxp_ss)

    u  = udata;
    u1 = u1data;
    u2 = u2data;
    
    out = zeros(Float64, Nf)

    # --------------------------------------------------------------------------------
    print("--- Plate Test --- \n\n")
    print("Grid      : $(Nx+1) x $(Ny+1) = $(ss)\n")
    print("Dur       : $(Nf) \n")
    print("In_cell   : $(inint)\n")
    print("Out_cell  : $(outint)\n")
    
    println("")
    tick()

    cp = 0

    # --------------------------------------------------------------------------------
    # Time loop
    for n in 1:Nf
        # Interior update
        for Y in 2:(Ny-1)
            for X in 2:(Nx-1)
                
                cp = (Y)*wid+X + 1;
                
                u[cp] = (B1*(u1[cp-1]     + u1[cp+1]     + u1[cp-wid]   + u1[cp+wid] )
                      + B2*(u1[cp-2]     + u1[cp+2]     + u1[cp-2*wid] + u1[cp+2*wid])
                      + B3*(u1[cp+wid-1] + u1[cp+wid+1] + u1[cp-wid-1] + u1[cp-wid+1])
                      + B4* u1[cp]       + C2*u2[cp]
                      + C1*(u2[cp-1]     + u2[cp+1]     + u2[cp-wid]   + u2[cp+wid] ))

                if X == 3 && Y == 3 && n == 1
                    println("première valeur de cp : $(cp)")
                end
            end
        end
        
        # Add impulse
        if (n == 2)
            u[inint] += 1.0;
        end 

        # read output
        out[n] = u[outint];


        # swap pointers
        ptr = u2;
        u2  = u1;
        u1  = u;
        u   = ptr;
        
    end

    tock()

    printLastSamples(out, Nf, 5)
    
    @assert maximum(abs.(out)) <= 1.

    GLMakie.closeall()

    fig, ax, plt, = lines(out)
    # display(fig)


    # wavwrite(out, outputfname, Fs=SR)
    # --------------------------------------------------------------------------------
    gain = 10^(-6.0/20.0)
    # wavplay(out * gain, SR)

    print("\nComplete...\n");
    
    return nothing
end

DEBUG :: Bool = false
# DEBUG && @run main()
DEBUG ||      main()
