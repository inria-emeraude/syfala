using WAV

samplerate = 48000.0

length_s = 60.0
nchannels = 8
T = LinRange(0.0, length_s, Int(length_s*samplerate))

mutable struct Phasor
    state :: Float64
    increment :: Float64
end

freq = 150.0
phasor = Phasor(0.0, 0.0)
phasor.increment = 1.0/(1.0/freq * samplerate)

gain = 10.0^(-12.0/20.0)

function next_value(phasor :: Phasor)
    phasor.state += phasor.increment

    if phasor.state > 1.0
        phasor.state = 0.0
    end
    return phasor.state
end

sine_signal(freq, T) = sin.(2 * pi * freq * T);

saw(phasor :: Phasor) = next_value(phasor) * 2.0 - 1.0

rect(phasor :: Phasor) = next_value(phasor) > 0.5 ? 1.0 : -1.0

function triangle(phasor :: Phasor)
    phasor_value = next_value(phasor)

    value = phasor_value > 0.5 ? 1.0 - phasor_value : phasor_value

    return (value - 0.25) * 4.0
end




signal = zeros(length(T), nchannels)

audio_file_data, opeth_samplerate, _, _  = wavread("../Opeth - Windowpane (Audio).wav");

@show opeth_samplerate

for i in 1:length(T)
    # signal[i, 1] = triangle(phasor) * gain
    # signal[i, 1] = saw(phasor) * gain
    # signal[i, 1] = sin.(2 * pi * freq * T[i]);
    signal[i, 1] = audio_file_data[i, 1]
end

# square_signal = Int.(sine_signal .> 0)
# square_signal .*= 2.0
# square_signal .-= 1.0

# signal[:, 1] = sine_signal(220.0, T) .* gain
# signal[:, 2] = sine_signal(1000.0, T) .* gain

@show size(signal)
println("Taille mémoire du signal de test : $(length(signal) * 4 / 1000) kb")
wavwrite(signal, "test_signal.wav"; Fs=samplerate, nbits=16, compression=WAVE_FORMAT_PCM)