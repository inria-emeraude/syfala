using GLMakie
using WAV
using Chain

filename = "examples/cpp/phys-model/static-plate-fdtd/csim_signals/partitioned_output.txt"

function load_csim(filepath :: String) :: Vector

    file = open(filepath, "r")

    signal = @chain begin
        file 
        readlines 
        filter(!isempty, _)
        parse.(Float64, _)
    end

    return signal
end 

signal = load_csim(filename)

lines(signal)
wavwrite(signal, "examples/cpp/phys-model/static-plate-fdtd/output_files/Plate_csim_gcc.wav", Fs = 48000.0)