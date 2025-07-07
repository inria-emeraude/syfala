import numpy as np
import matplotlib.pyplot as plt

def load_data(file_path):
    """Loads a text file with one floating-point value per line."""
    return np.loadtxt(file_path)

def compute_metrics(sim_data, fpga_data):
    """Computes error metrics between simulation and FPGA outputs."""
    assert len(sim_data) == len(fpga_data), "Mismatch in file lengths!"

    absolute_errors = np.abs(sim_data - fpga_data)
    mae = np.mean(np.abs(sim_data - fpga_data))
    mse = np.mean((sim_data - fpga_data) ** 2)
    max_error = np.max(np.abs(sim_data - fpga_data))
    
    signal_power = np.sum(sim_data ** 2)
    error_power = np.sum((sim_data - fpga_data) ** 2)
    snr = 10 * np.log10(signal_power / error_power) if error_power > 0 else np.inf

    peak_signal = np.max(sim_data) ** 2
    psnr = 10 * np.log10(peak_signal / mse) if mse > 0 else np.inf
    
    epsilon = 1e-10
    relative_errors = absolute_errors / (np.abs(sim_data) + epsilon)

    
    # Compute maximum relative error
    max_rel_error = np.max(relative_errors)
    
    # Compute mean relative error
    mean_rel_error = np.mean(relative_errors)

    return mae, mse, max_error, snr, psnr, max_rel_error, mean_rel_error

def plot_results(sim_data, fpga_data):
    """Plots time-domain comparison and error distribution."""
    plt.figure(figsize=(10, 5))
    plt.plot(sim_data[:48000], label="Simulation", alpha=0.7)
    plt.plot(fpga_data[:48000], label="FPGA", alpha=0.7)
    plt.legend()
    plt.title("First 48000 Samples: Simulation vs. FPGA")
    plt.xlabel("Sample Index")
    plt.ylabel("Amplitude")
    plt.show()

    plt.figure(figsize=(10, 5))
    plt.plot(sim_data - fpga_data, label="Error Signal", color="red")
    plt.legend()
    plt.title("Difference Between Simulation and FPGA Output")
    plt.xlabel("Sample Index")
    plt.ylabel("Error")
    plt.show()

    plt.figure(figsize=(7, 5))
    plt.hist(sim_data - fpga_data, bins=50, color='gray', alpha=0.7)
    plt.title("Error Distribution Histogram")
    plt.xlabel("Error Value")
    plt.ylabel("Count")
    plt.show()

if __name__ == "__main__":
    # Update these file paths to your actual data files
    # simulation_file = "examples/cpp/phys-model/static-plate-full/maxi/csim-proof/output.txt"
    simulation_file = "cpu-mid.txt"
    fpga_file = "fpga-out-mid.txt"

    sim_data = load_data(simulation_file)
    fpga_data = load_data(fpga_file)

    mae, mse, max_error, snr, psnr, mxre, mnre = compute_metrics(sim_data, fpga_data)

    print(f"Mean Absolute Error (MAE): {mae:.6e}")
    print(f"Mean Squared Error (MSE): {mse:.6e}")
    print(f"Maximum Absolute Error: {max_error:.6e}")
    print(f"Signal-to-Noise Ratio (SNR): {snr:.2f} dB")
    print(f"Peak Signal-to-Noise Ratio (PSNR): {psnr:.2f} dB")
    print(f"Mean Relative Error: {mnre:.6e}")
    print(f"Maximum Relative Error: {mxre:.6e}")

    plot_results(sim_data, fpga_data)

