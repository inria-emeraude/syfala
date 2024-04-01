from scipy import signal
import numpy as np

Fe = 48000  # Sampling frequency

# Define attack and release times (in seconds)
attack_time = 0.01  # 10 ms
release_time = 0.005  # 5 ms, shorter than the attack time

# Coefficients for the one-pole switching filter
attack_coeff = np.exp(-1.0 / (Fe * attack_time))
release_coeff = np.exp(-1.0 / (Fe * release_time))


M = 1 #subdivision of frequencies


note_frequencies = 440 * 2 ** (np.arange(-48, 40,1/M) / 12)
note_frequencies = note_frequencies[(note_frequencies >= 80) & (note_frequencies <= 12000)]

# Number of filters needed to cover the notes
num_bandpass_filters = len(note_frequencies) - 1  # One less than the number of notes
num_filters = num_bandpass_filters + 2  # Including one low-pass and one high-pass filter

A_ONE_COEF = 2
B_ONE_COEF = 3

As = np.zeros(A_ONE_COEF * num_filters)
Bs = np.zeros(B_ONE_COEF * num_filters)

# Create filters
for k in range(num_filters):
    if k == 0:  # Low-pass filter before the first note
        b, a = signal.iirfilter(2, (note_frequencies[0] / (Fe / 2)), btype='lowpass', ftype='butter')
    elif k == num_filters - 1:  # High-pass filter after the last note
        b, a = signal.iirfilter(2, (note_frequencies[-1] / (Fe / 2)), btype='highpass', ftype='butter')
    else:  # Bandpass filters for each note
        if k == 1:  # For the first bandpass filter, use the first note and the next for bandwidth calculation
            bandwidth = (note_frequencies[k] - note_frequencies[k - 1])
        elif k == num_filters - 2:  # For the last bandpass filter, consider the last note and the previous one
            bandwidth = (note_frequencies[k - 1] - note_frequencies[k - 2])
        else:  # For middle filters, calculate bandwidth as the distance to the midpoint between adjacent notes
            bandwidth_low = note_frequencies[k - 1] - note_frequencies[k - 2]
            bandwidth_high = note_frequencies[k] - note_frequencies[k - 1]
            bandwidth = (bandwidth_low + bandwidth_high) / 2  # Average the bandwidths

        center_freq = note_frequencies[k - 1]
        low_freq = center_freq - bandwidth / 2
        high_freq = center_freq + bandwidth / 2
        b, a = signal.iirfilter(1, [low_freq / (Fe / 2), high_freq / (Fe / 2)], btype='bandpass', ftype='butter')
    
    As[k * A_ONE_COEF:(k + 1) * A_ONE_COEF] = a[1:]
    Bs[k * B_ONE_COEF:(k + 1) * B_ONE_COEF] = b

header_file = ""
header_file += f"#define OPSF_ATK_COEF {attack_coeff} // OPSF = one-pole switching filter\n"
header_file += f"#define OPSF_REL_COEF {release_coeff} // OPSF = one-pole switching filter\n"
header_file += f"#define A_ONE_COEF {A_ONE_COEF}\n"
header_file += f"#define B_ONE_COEF {B_ONE_COEF}\n"
header_file += f"#define NUM_FILTERS {num_filters}\n"
header_file += f"#define A_SIZE {A_ONE_COEF * num_filters}\n"
header_file += f"#define B_SIZE {B_ONE_COEF * num_filters}\n"
header_file += "float b[B_SIZE] = {"
for i in range(B_ONE_COEF * num_filters-1):
    header_file += f"{Bs[i]}f,"
header_file += f"{Bs[-1]}f" + "};\n"
header_file += "float a[A_SIZE] = {"
for i in range(A_ONE_COEF * num_filters-1):
    header_file += f"{As[i]}f,"
header_file += f"{As[-1]}f" + "};"

with open("coefs.h", "w") as file:
    file.write(header_file)