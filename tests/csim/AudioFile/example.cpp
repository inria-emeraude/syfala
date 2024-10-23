#include "AudioFile.h"
// included here but the file is already included in csim_template_utilitites.hpp


const std::string filename = "test_filename.wav";

int main() {

    AudioFile<float> file;
    
    bool result = file.load(filename); // load the file, return false if the import failed, or if the file doesn't exist
    assert(result);
    
    // functions to retrieve information
    
	int sampleRate = audioFile.getSampleRate();
	int bitDepth = audioFile.getBitDepth();
	
	int numSamples = audioFile.getNumSamplesPerChannel();
	double lengthInSeconds = audioFile.getLengthInSeconds();
	
	int numChannels = audioFile.getNumChannels();
	bool isMono = audioFile.isMono();
	bool isStereo = audioFile.isStereo();
	
	// or, just use this quick shortcut to print a summary to the console
	audioFile.printSummary();
    
    // write or read to the file
    int channel_index = 0;
    int sample_index = 0;
    float sample = file.samples[channel_index][sample_index];
    file.samples[channel_index][sample_index] = 0.0f;
    
    file.save("path", AudioFileFormat::Wave);

    return 0;
}