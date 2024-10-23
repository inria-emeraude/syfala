# ------------------------------------------------------------------------------
# User Parameters
samplerate = 48000.0;
K         = 0.6;          # Stiffness
ar        = 1.0;          # Aspect Ratio
low_T60   = 5.0;          # Low freq decay time
high_T60  = 4.0;          # Must be less than low_T60

Nf        = trunc(Int, samplerate*3);
outposX   = 0.72;
outposY   = 0.41;
inposX    = 0.41;
inposY    = 0.55;

# ------------------------------------------------------------------------------
# Calculated parameters

k           = 1.0/samplerate;
zeta1       = 2.0 * π * 100.0  / K;
zeta2       = 2.0 * π * 1000.0 / K;
sig0p       = 6.0 * log(10.0)*(-zeta2/low_T60+zeta1/high_T60)/(zeta1-zeta2);
sig1p       = 6.0 * log(10.0)*(1.0/low_T60 -1.0/high_T60)/(zeta1-zeta2);

hp          = 2.0*sqrt( sig1p*sig1p + sqrt( sig1p*sig1p + K*K*k*k ));
grid_width  = floor(Int, sqrt(ar)/hp);
hp          = sqrt(ar)/grid_width;
grid_height = floor(Int, 1.0/(sqrt(ar)*hp));
ss          = (grid_width+1)*(grid_height+1);

wid         = grid_width+1;
inint       = (floor(Int, (grid_height + 1)*inposY))  * wid + floor(Int, wid*inposX) + 1;
outint      = (floor(Int, (grid_height + 1)*outposY)) * wid + floor(Int, wid*outposX) + 1;

# ------------------------------------------------------------------------------
# Scheme coeffs
mu2         = K*K*k*k/(hp*hp*hp*hp);
sig0k       = 1.0 + sig0p*k;
sig1k       = (2.0*sig1p*k)/(hp*hp);

B1          = (-mu2*-8.0 + sig1k ) / sig0k;
B2          = -mu2 / sig0k;
B3          = (-mu2*2.0) / sig0k;
B4          = (-mu2*20.0 + 2.0 + sig1k*-4.0) / sig0k;

C1          = (-2.0*sig1p*k/(hp*hp) ) / (1.0 + sig0p*k);
C2          = ((sig1p*k-1.0) - (2.0*sig1p*k/(hp*hp) )*-4.0) / (1.0 + sig0p*k);


run(`clear`)

println("Not important constants")
@show K
@show ar
@show low_T60
@show high_T60
@show outposX
@show outposY
@show inposX
@show inposY
@show k
@show zeta1
@show zeta2
@show sig0p
@show sig1p
@show hp
@show ss
@show mu2
@show sig0k
@show sig1k


print("\n")
println("Important constants")
@show samplerate
@show Nf
@show grid_height
@show grid_width
@show wid
@show inint
@show outint

@show B1
@show B2
@show B3
@show B4

@show C1
@show C2

open("examples/cpp/phys-model/static-plate-fdtd/constants.h", "w") do file 
    write(file, "#ifndef HLS_CONSTANTS_H\n")
    write(file, "#define HLS_CONSTANTS_H\n")
    write(file, "constexpr f32 B1 = $(B1);\n")
    write(file, "constexpr f32 B2 = $(B2);\n")
    write(file, "constexpr f32 B3 = $(B3);\n")
    write(file, "constexpr f32 B4 = $(B4);\n")
    write(file, "constexpr f32 C1 = $(C1);\n")
    write(file, "constexpr f32 C2 = $(C2);\n")
    write(file, "#endif // HLS_CONSTANTS_H\n")
end 


