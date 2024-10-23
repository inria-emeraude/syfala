// TEST IN A MAIN :
#include <iostream>
#include<random>


// LMS identification function
void NLMSSystemIdentificationStep(float system_input_sample, float system_output_sample, float *filter_coefs, float *input_buffer,  int FILTER_ORDER, float STEP_SIZE) {
    // Shift the input buffer
    for (int i = FILTER_ORDER - 1; i > 0; i--) {
        input_buffer[i] = input_buffer[i - 1];
    }
    // Welcome the new input sample
    input_buffer[0] = system_input_sample;

    // Compute the estimated output 
    // ! heavy computations here ! 
    // (compute an FIR Filter step)
    float estimated_output = 0;
    for (int j = 0; j < FILTER_ORDER; j++) {
        estimated_output += filter_coefs[j] * input_buffer[j];
    }
    // Compute the error
    float error = system_output_sample - estimated_output;
    // std::cout << error << "   ";
    printf("%.6f\n", error);

    // Compute norm of inputBuffer for Normalized LMS
    // ! More heavy computations here !
    // (would not be required for non-normalized LMS)
    float BufferSquaredNorm(0.);
    for (int j = 0; j < FILTER_ORDER; j++) {
        BufferSquaredNorm += input_buffer[j]*input_buffer[j];
    }
    // Defuine a regularization value to avoid dividing by 0 if norm of Input buffer is 0
    float regularization_parameter = 0.001;

    // Update the filter coefficients with the nLMS algo
    for (int j = 0; j < FILTER_ORDER; j++) {
        filter_coefs[j] += STEP_SIZE * error * input_buffer[j]/(BufferSquaredNorm + regularization_parameter);
    }
}

#define SYFALA_BLOCK_NSAMPLES 1
void computemydsp(float inputs[SYFALA_BLOCK_NSAMPLES][2], float outputs[SYFALA_BLOCK_NSAMPLES][2]) {
  for (int s = 0; s < SYFALA_BLOCK_NSAMPLES; ++s) {
    /* compute one sample */
    // Input 1 is a copy of the noise signal that is drving the system to identify's input,
    // Input 2 is the system's to identify's response to that noise singal,
    // Output 1 is sending the identified FIR coefficients in a loop, to be visialized on an oscilloscope,
    // Output 2 is unused.

    // Algorithm parameters :
    static const int FILTER_ORDER = 1024;
    static const float STEP_SIZE = 0.01;

    // Variables needed from one call to another :
    static int FIRScopeCounter;
    static float filter_coefs[FILTER_ORDER];
    static float input_buffer[FILTER_ORDER];

    // Identification Algo :
    float system_input_sample = inputs[s][0];
    float system_output_sample = inputs[s][1];
    NLMSSystemIdentificationStep(system_input_sample, system_output_sample, filter_coefs, input_buffer, FILTER_ORDER, STEP_SIZE);  

    // Output the filter coefs in a loop (for vizualisation with an oscilloscope) :
    outputs[s][0] = filter_coefs[FIRScopeCounter];
    FIRScopeCounter = FIRScopeCounter+1 % FILTER_ORDER;
    outputs[s][1] = 0.;
  }
}


//// added ///
#include <fstream>
std::ofstream output_stream("outputs/nils_outputs.txt");

//////


float noise(0.);
const int TrainingDataLegth = 2048;
std::random_device rd; // Obtain a random number from hardware
std::mt19937 gen(rd()); // Seed the generator
std::uniform_real_distribution<float> dis(-1.0, 1.0); // Define the range
int main(){
    float inputs[SYFALA_BLOCK_NSAMPLES][2];
    float outputs[SYFALA_BLOCK_NSAMPLES][2];

    for(int i=1; i<TrainingDataLegth; i++){
        noise = dis(gen);
        // ONLY FOR SYFALA_BLOCK_NSAMPLES=1 :
        inputs[SYFALA_BLOCK_NSAMPLES][0] = noise;
        inputs[SYFALA_BLOCK_NSAMPLES][1] = noise;
        computemydsp(inputs, outputs);
        // std::cout << outputs[SYFALA_BLOCK_NSAMPLES][0] << "  " ;
        // output_stream << outputs[SYFALA_BLOCK_NSAMPLES][0] << "\n";
        
    }
    return 0;
}