using WAV
using Chain
using GLMakie
import GLMakie: closeall
using FFTW
using DSP
closeall()

function write_to_csim(filepath :: String, signal :: Vector) :: Nothing

    io = open(filepath, "w")

    for element in signal
        write(io, string(element) * "\n")
    end

    println("Properly written to file")
    close(io)
    return nothing
end 

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

function wav_to_csim(wav_filepath:: String, csim_filepath :: String) :: Nothing

    signal, samplerate, _, _ = wavread(wav_filepath)

    if ndims(signal) > 1
        signal = signal[:, 1]
    end 

    write_to_csim(csim_filepath, signal)

    return nothing
end 

function csim_to_wav(wav_filepath :: String, csim_filepath :: String) :: Nothing 

    signal = load_csim(csim_filepath)
    wavwrite(signal, wav_filepath; Fs = 48000.0, nbits = 24)
    return nothing
end 

function plot_time(signal :: Vector, samplerate :: Number, title :: String) :: Nothing

    T = LinRange(0, length(signal)/samplerate, length(signal))

    fig = Figure()
    ax1 = Axis(fig[1, 1], title = title)
    lines!(ax1, T, signal)

    display(GLMakie.Screen(), fig)

    return nothing
end 

function pad(signal :: Vector, length_to_match :: Integer) :: Vector
    if length(signal) >= length_to_match
        return signal
    else 
        return [signal; zeros(length_to_match - length(signal))]
    end
end 
    

function plot_spectrum(signal :: Vector, samplerate :: Number, title :: String) :: Nothing
    
    nfft = 8192

    padded_signal = pad(signal, nfft)

    spectrum = 20*log10.(abs.(rfft(padded_signal)))
    freqs = rfftfreq(nfft, samplerate) .+ 0.01    
    
    fig = Figure(size = (1000, 600))
    axspectrum = Axis(fig[1, 1], 
                      xscale = log10, 
                      xminorticksvisible = true, 
                      xminorgridvisible = true, 
                      xminorticks = IntervalsBetween(9), 
                      title = title)

    lines!(axspectrum, freqs, spectrum)
    xlims!(axspectrum, 20, 20000)
    
    display(GLMakie.Screen(), fig)  
    
    return nothing
end 


function plot_spectrogram(signal :: Vector, samplerate :: Number, title :: String) :: Nothing
    
    nfft = 16384
    window_size = 1024

    spectro = DSP.spectrogram(signal, window_size; nfft=nfft, fs=samplerate, window=DSP.Windows.hanning)

    fig = Figure()
    ax = Axis(fig[1, 1], yscale = log10, title = title)
    ylims!(ax, 10, 20000)
    hm = heatmap!(ax, spectro.time, spectro.freq .+ 10, 20 * log10.(abs.(spectro.power |> transpose)))
    Colorbar(fig[:, end+1], hm)
    display(GLMakie.Screen(), fig)
    return nothing
end 


mutable struct Biquad
    b0 :: Float64
    b1 :: Float64
    b2 :: Float64
    a1 :: Float64
    a2 :: Float64
    
    w1 :: Float64
    w2 :: Float64
    
    Biquad() = new(0.0, 0.0, 0.0, 0.0, 0.0)
end 

getCoeffTuple(f :: Biquad) = ([f.b0, f.b1, f.b2], [f.a1, f.a2])

function Biquad(response :: Symbol, freq :: Number, Q :: Number, gain :: Number, samplerate :: Number)

    filter = Biquad()
    
    A = 10^(gain/40)
    w0 = 2* freq/samplerate
    
    cosw0 = cospi(w0)
    sinw0 = sinpi(w0)
    
    alpha = sinw0/(2 * Q)
    beta = sqrt(A)/Q
    
    if response == :lowpass

        a0inv = 1/(1 + alpha);
        
        filter.b0 = ((1 - cosw0)/2) * a0inv
        filter.b1 = (1 - cosw0) * a0inv
        filter.b2 = ((1 - cosw0)/2) * a0inv
        filter.a1 = (-2*cosw0) * a0inv
        filter.a2 = (1 - alpha) * a0inv
    
    elseif response == :highshelf

        a0inv = 1/(1 + alpha)
        
        filter.b0 = ((1 + cosw0)/2) * a0inv
        filter.b1 = (-(1 + cosw0)) * a0inv
        filter.b2 = ((1 + cosw0)/2) * a0inv
        filter.a1 = (-2*cosw0) * a0inv
        filter.a2 = (1 - alpha) * a0inv
    
    elseif response == :peak
        
        a0 = 1 + alpha/A
        
        filter.b0 = ( 1 + alpha*A)/a0
        filter.b1 = (-2*cosw0)/a0
        filter.b2 = ( 1 - alpha*A)/a0
        filter.a1 = (-2*cosw0)/a0
        filter.a2 = ( 1 - alpha/A)/a0
        
    elseif response == :lowshelf
        a0 = (A+1) + (A-1)*cosw0 + beta*sinw0
        
        filter.b0 = (A*((A+1) - (A-1)*cosw0 + beta*sinw0))/a0
        filter.b1 = (2*A*((A-1) - (A+1)*cosw0))/a0
        filter.b2 = (A*((A+1) - (A-1)*cosw0 - beta*sinw0))/a0
        filter.a1 = (-2*((A-1) + (A+1)*cosw0))/a0
        filter.a2 = ((A+1) + (A-1)*cosw0 - beta*sinw0)/a0
    end
    
    
    return filter 
end

function process(input_signal :: Vector, f :: Biquad) :: Vector
    output_signal = copy(input_signal)

    f.w1 = 0.0
    f.w2 = 0.0
    
    for i in 1:length(input_signal)
        W = input_signal[i] - f.a1*f.w1 - f.a2*f.w2
        output_sample = f.b0*W + f.b1*f.w1 + f.b2*f.w2
        
        f.w2 = f.w1
        f.w1 = W
        output_signal[i] = output_sample
    end 
    return output_signal
end 


const samplerate :: Float32 = 48000.0

function generate_inputs() :: Nothing 

    noise = rand(floor(Int, samplerate * 5)) * 2 .- 1
    
    filter1 = Biquad(:lowpass, 1500, 1.5, 0.0, samplerate)    
    filter2 = Biquad(:lowpass, 5000, 2.0, 0.0, samplerate)    
    filtered_noise1 = process(noise, filter1)
    filtered_noise2 = process(noise, filter2)

    result_noise = 0.5 * (filtered_noise1 .+ filtered_noise2)

    write_to_csim("examples/cpp/NLMS/csim_signals/input_noise.txt", noise)
    write_to_csim("examples/cpp/NLMS/csim_signals/system_output_noise.txt", result_noise)

    return nothing 
end 

function read_inputs() :: Nothing

    input_noise :: Vector    = load_csim("examples/cpp/NLMS/csim_signals/input_noise.txt")    
    filtered_noise :: Vector = load_csim("examples/cpp/NLMS/csim_signals/system_output_noise.txt")    

    # plot_spectrogram(input_noise, samplerate, "input noise to the unknown system")
    # plot_spectrogram(filtered_noise, samplerate, "unknown system output filtered noise")
    plot_time(input_noise, samplerate, "input noise time domain")
    plot_time(filtered_noise, samplerate, "system output time domain")

    return nothing
end 

function read_outputs_std() :: Nothing
    
    filter_output_std :: Vector = load_csim("examples/cpp/NLMS/csim_signals/estimated_output_std.txt")    
    error_std :: Vector         = load_csim("examples/cpp/NLMS/csim_signals/error_std.txt")    
    filter_coeffs_std :: Vector = load_csim("examples/cpp/NLMS/csim_signals/filter_coeffs_std.txt")

    
    # plot_spectrogram(filter_output_std, samplerate, "standalone : NLMS estimated output filtered noise")
    plot_time(error_std, samplerate, "standalone : NLMS error")
    # plot_time(filter_output_std, samplerate, "standalone : NLMS output time domain")
    plot_spectrum(filter_coeffs_std, samplerate, "standalone : DFT of the filter coefficients")
        
    return nothing 
end 

function read_outputs_HLS() :: Nothing
    filter_output_HLS  :: Vector = load_csim("examples/cpp/NLMS/csim_signals/estimated_output_HLS.txt")    
    error_HLS :: Vector          = load_csim("examples/cpp/NLMS/csim_signals/error_HLS.txt")    
    filter_coeffs_HLS :: Vector  = load_csim("examples/cpp/NLMS/csim_signals/filter_coeffs_HLS.txt")

    # plot_spectrogram(filter_output_HLS, samplerate, "HLS : NLMS estimated output filtered noise")
    plot_time(error_HLS, samplerate, "HLS : NLMS error")
    plot_time(filter_output_HLS, samplerate, "HLS : NLMS output time domain")
    println("spectrum size : $(length(filter_coeffs_HLS))")
    plot_spectrum(filter_coeffs_HLS, samplerate, "HLS : DFT of the filter coefficients")
    return nothing
end 

# read_outputs_HLS()