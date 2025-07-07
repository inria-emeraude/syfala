/*
 MattsAudioHeader.h
 A single header #include to start experimenting with audio output in C++
 
 Current Functionality
 
 - Sample rate fixed at 44100
 - bit depth fixed at 16-bit
 - Channel config fixed to mono
 */

#pragma once

//------------------------------------------------------------------------------
#include <iostream>
#include <fstream>
#include <string>
#include <cstddef>
#include <cstdlib>
#include <cmath>
#include <cstdint>
#include "Filter.hpp"
#include <assert.h>
#include <cstring>

#if defined _WIN32 || defined _WIN64
#pragma comment(lib, "Winmm")
#include <windows.h>
#endif
//------------------------------------------------------------------------------
/// Header for a WAVE format file. defaults to 16-bit, 44100 Hz Mono
struct WaveHeader
{
    /** waveFormatHeader: The first 4 bytes of a wav file should be the characters "RIFF" */
    char chunkID[4] = { 'R', 'I', 'F', 'F' };
    /** waveFormatHeader: This is the size of the entire file in bytes minus 8 bytes */
    uint32_t chunkSize;
    /** waveFormatHeader" The should be characters "WAVE" */
    char format[4] = { 'W', 'A', 'V', 'E' };
    /** waveFormatHeader" This should be the letters "fmt ", note the space character */
    char subChunk1ID[4] = { 'f', 'm', 't', ' ' };
    /** waveFormatHeader: For PCM == 16, since audioFormat == uint16_t */
    uint32_t subChunk1Size = 16;
    /** waveFormatHeader: For PCM this is 1, other values indicate compression */
    uint16_t audioFormat = 1;
    /** waveFormatHeader: Mono = 1, Stereo = 2, etc. */
    uint16_t numChannels = 1;
    /** waveFormatHeader: Sample Rate of file */
    uint32_t sampleRate = 44100;
    /** waveFormatHeader: SampleRate * NumChannels * BitsPerSample/8 */
    uint32_t byteRate = 44100 * 2;
    /** waveFormatHeader: The number of bytes for one sample including all channels */
    uint16_t blockAlign = 2;
    /** waveFormatHeader: 8 bits = 8, 16 bits = 16 */
    uint16_t bitsPerSample = 16;
    /** waveFormatHeader: Contains the letters "data" */
    char subChunk2ID[4] = { 'd', 'a', 't', 'a' };
    /** waveFormatHeader: == NumberOfFrames * NumChannels * BitsPerSample/8
     This is the number of bytes in the data.
     */
    uint32_t subChunk2Size;
    
    WaveHeader(uint32_t samplingFrequency = 44100, uint16_t bitDepth = 16, uint16_t numberOfChannels = 1)
    {
        numChannels = numberOfChannels;
        sampleRate = samplingFrequency;
        bitsPerSample = bitDepth;
        
        byteRate = sampleRate * numChannels * bitsPerSample / 8;
        blockAlign = numChannels * bitsPerSample / 8;
    };
    
    /// sets the fields that refer to how large the wave file is
    /// @warning This MUST be set before writing a file, or the file will be unplayable.
    /// @param numberOfFrames total number of audio frames. i.e. total number of samples / number of channels
    void setFileSize(uint32_t numberOfFrames)
    {
        subChunk2Size = numberOfFrames * numChannels * bitsPerSample / 8;
        chunkSize = 36 + subChunk2Size;
    }
    
    uint32_t getNumFrames()
    {
        return subChunk2Size / (numChannels * bitsPerSample / 8);
    }
    
    void assertWavFile()
    {
        char riff[4] = { 'R', 'I', 'F', 'F' };
        char wave[4] = { 'W', 'A', 'V', 'E' };
        char fmt [4] = { 'f', 'm', 't', ' ' };
        char data[4] = { 'd', 'a', 't', 'a' };
        
        // The first 4 bytes of a WAV should be RIFF, this doesn't look like a wav file
        assert(memcmp(chunkID, riff, 4) == 0); // ^ read this
        
        // The format should be WAVE: this seems to be some kind of non-standard wav file
        assert(memcmp(format, wave, 4) == 0); // ^ read this
        
        // subChunk1ID should be 'fmt ', if this is bext then this wav is a brodcast extension format and probably
        // came from a DAW export. Try importing into AUDACITY and rexporting
        assert(memcmp(subChunk1ID, fmt, 4) == 0); // ^ read this
        
        // subChunk2ID should be 'data', if it is 'fact' then you've got a floating point format wav and
        // I was to lazy to parse those. Try exportin in another format.
        assert(memcmp(subChunk2ID, data, 4) == 0); // ^ read this
    }
    
    void print()
    {
        
        auto leftpad = [](std::string text) {
            return std::string(17 - text.length(), ' ');
        };
        
        std::cout << leftpad("chunkID:") <<  "chunkID:\t";
        
        for (int i = 0; i < 4; i++)
            std::cout << chunkID[i];
        
        std::cout << '\n';
        
        std::cout <<  leftpad("chunkSize:") <<   "chunkSize:\t"  <<     chunkSize    << '\n';
        
        std::cout << leftpad("format:") <<   "format:\t";
        
        for (int i = 0; i < 4; i++)
            std::cout << format[i];
        
        std::cout << '\n';
        
        std::cout << leftpad("subChunk1ID:") <<    "subChunk1ID:\t";
        for (int i = 0; i < 4; i++)
            std::cout << subChunk1ID[i];
        std::cout << '\n';
        
        std::cout << leftpad("subChunk1Size:")  << "subChunk1Size:\t" <<  subChunk1Size   << '\n';
        std::cout << leftpad("audioFormat:")    << "audioFormat:\t"  <<   audioFormat    << '\n';
        std::cout << leftpad("numChannels:")    << "numChannels:\t"  <<   numChannels    << '\n';
        std::cout << leftpad("sampleRate:")     << "sampleRate:\t"   <<   sampleRate     << '\n';
        std::cout << leftpad("byteRate:")       << "byteRate:\t"   <<     byteRate     << '\n';
        std::cout << leftpad("blockAlign:")     << "blockAlign:\t"  <<    blockAlign    << '\n';
        std::cout << leftpad("bitsPerSample:")  << "bitsPerSample:\t" <<  bitsPerSample   << '\n';
        std::cout << leftpad("subChunk2ID:")    << "subChunk2ID:\t";
        
        for (int i = 0; i < 4; i++)
            std::cout << subChunk2ID[i];
        std::cout << '\n';
        
        std::cout << leftpad("subChunk2Size:") << "subChunk2Size:\t" <<  subChunk2Size   << '\n';
        
        std::cout << "Number of Frames:\t" <<  getNumFrames() << '\n' ;
    }
    
};

//------------------------------------------------------------------------------

void printHeaderFromFile(std::string filepath)
{
    std::ifstream wavFile {filepath, std::fstream::in | std::ios::binary};
    WaveHeader wavHeader;
    wavFile.read((char*)&wavHeader, sizeof(WaveHeader));
    wavHeader.print();
    wavHeader.assertWavFile();
}

//------------------------------------------------------------------------------

/// write an array of float data to a 16-bit, 44100 Hz Mono wav file
/// @param audio audio samples, assumed to be 44100 Hz sampling rate
/// @param numberOfSamples total number of samples in audio
/// @param filename filename, should end in .wav and will be written to your Desktop
void writeToWav(float* audio,
                uint32_t numberOfSamples,
                const char* filename,
                uint32_t sampleRate = 44100u,
                const bool toDesktop = true,
                const char* path = "",
                const bool shouldPlay = false)
{
    std::ofstream fs;
    
#if defined _WIN32 || defined _WIN64
    char* buf = nullptr;
    size_t sz = 0;
    _dupenv_s(&buf, &sz, "USERPROFILE"); // or HOMEDRIVE or HOMEPATH
    std::string desktop = std::string(buf) + std::string(R"(\Desktop\)");
#else
    std::string desktop = std::string(getenv("HOME")) + std::string("/Desktop/");
#endif
    
    std::string filepath = ((toDesktop) ? desktop : std::string(path)) + std::string(filename);
    
    if (filepath.substr(filepath.size() - 4, 4) != std::string(".wav"))
        filepath += std::string(".wav");
    
    fs.open(filepath, std::fstream::out | std::ios::binary);
    
    WaveHeader* header = new WaveHeader{sampleRate};
    header->setFileSize(numberOfSamples);
    
    fs.write((char*)header, sizeof(WaveHeader));
    
    int16_t* audioData = new int16_t[numberOfSamples];
    static constexpr float max16BitValue = 32768.0f;
    
    for (int i = 0; i < numberOfSamples; ++i)
    {
        int pcm = int(audio[i] * (max16BitValue));
        
        if (pcm >= max16BitValue)
            pcm = max16BitValue - 1;
        else if (pcm < -max16BitValue)
            pcm = -max16BitValue;
        
        audioData[i] = int16_t(pcm);
    }
    
    fs.write((char*)audioData, header->subChunk2Size);
    
    fs.close();
    std::cout << filename << " written to:\n" << filepath << std::endl;
    
    if (shouldPlay)
    {
#if defined _WIN32 || defined _WIN64
        // don't forget to add Add 'Winmm.lib' in Properties > Linker > Input > Additional Dependencies
        PlaySound(std::wstring(filepath.begin(), filepath.end()).c_str(), NULL, SND_FILENAME);
#elif __linux__
        std::system((std::string("aplay ") + filepath).c_str());
#elif __APPLE__
        std::system((std::string("afplay ") + filepath).c_str());
#endif
    }
}

//------------------------------------------------------------------------------

/// Load sample data from a wav file in mono floating point format
/// Multi-channel audio is collapsed to mono.
///
/// @param numberOfFrames variable that will be populated with the number of samples in the audio.
/// @param filepath file path to wav file
///
///  @returns Float pointer to mono  audio sample data.
///           This pointer is dynamically allocated and it is up to the user to delete it
float* loadWav(uint32_t &numberOfFrames, std::string filepath)
{
    std::ifstream wavFile {filepath, std::fstream::in | std::ios::binary};
    
    // If you're reading this, there was a problem reading the file
    // check the file path is correct and make sure the file is in the right place
    //
    // Windows Users: You might need to type the path as a raw string
    // e.g. R"(C:\Path\To\Your\File)"
    assert (wavFile.good());
    
    WaveHeader wavHeader;
    wavFile.read((char*)&wavHeader, sizeof(WaveHeader));
    wavHeader.assertWavFile();
    numberOfFrames  = wavHeader.getNumFrames();
    
    char * bytes = nullptr;
    
    uint32_t byteDepth = wavHeader.bitsPerSample / 8;
    
    switch (byteDepth)
    {
        case 1:
        case 2:
            bytes = new char[byteDepth];
            break;
        case 3:
        case 4:
            bytes = new char[4];
            break;
        default:
            assert(false); // Bit depth is not a value that is dealt with.
            break;
    }
    
    std::fill(bytes, bytes + byteDepth, 0);
    
    float* audio = new float[wavHeader.getNumFrames()];
    
    for (uint32_t i = 0; i < numberOfFrames; i++)
    {
        audio[i] = 0.0f;
        for (uint16_t channel = 0; channel < wavHeader.numChannels; channel++)
        {
            wavFile.read(bytes, byteDepth);
            
            switch (byteDepth)
            {
                case 1:
                    audio[i] += (float(*((uint8_t*)(bytes))) - 127.0f) / 127.0f;
                    break;
                case 2:
                    audio[i] += float(*((int16_t*)(bytes))) / 32768.0f;
                    break;
                case 3:
                    for (uint8_t j = 3; j > 0; j--)
                        bytes[j] = bytes[j-1];
                    bytes[0] = 0;
                case 4:
                    audio[i] += float(*((int32_t*)(bytes))) / 2147483648.0f;
                    break;
            }
        }
    }
    
    delete [] bytes;
    
    return audio;
}

double getSplineOut(double n0, double n1, double n2, double alpha)
{
    const double a = n1;
    const double c = ((3 * (n2 - n1)) -  (3 * (n1 - n0))) * 0.25;
    const double b = (n2 - n1) - (2 * c * 0.33333);
    const double d = (-c) * 0.33333;
    return a + (b * alpha) + (c * alpha * alpha) + (d * alpha * alpha * alpha);
}


void normalise(float* audio, uint32_t numberOfSamples)
{
    float normalisation = 0.0;
    for (int i = 0; i < numberOfSamples; ++i)
    {
        float absoluteSampleValue = std::abs(audio[i]);
        normalisation = (absoluteSampleValue > normalisation) ? absoluteSampleValue : normalisation;
    }
    
    normalisation = 1.0 / normalisation;
    
    for (int i = 0; i < numberOfSamples; ++i)
        audio[i] *= normalisation;
    
    std::cout << "Audio Normalised by " << normalisation << '\n';
}

enum class InterpolationType {Decimate, Linear, Cubic, Lagrange};

float* resample(float* upsampledAudio, double targetSampleRate, double currentSampleRate, uint32_t& numberOfSamples)
{
    // step 1. Brick wall filter
    Filter lowpass;
    
    float sampleRateRatio = targetSampleRate / currentSampleRate;
    double normalisedCutoffFrequency = (2.0 * sampleRateRatio) - 0.01;
    lowpass.setButterworthCoefficients(4, normalisedCutoffFrequency);

    for (int i = 0; i < numberOfSamples; i++)
    {
        upsampledAudio[i] = lowpass.process(upsampledAudio[i]);
    }
        
    // step 2. Interpolate filtered audio
    float stepSize = 1.0 / sampleRateRatio;
    int targetNumSamples = int(sampleRateRatio * float(numberOfSamples));
    float* resampledAudio = new float[targetNumSamples];
    
    InterpolationType interpolationType = InterpolationType::Linear;
    
    switch (interpolationType)
    {
        case InterpolationType::Decimate:
        {
            // Decimate
            for (int i = 0; i < targetNumSamples; i++)
            {
                int j = int (float(i) * stepSize);
                resampledAudio[i] = upsampledAudio[j];
            }
            break;
        }
        case InterpolationType::Linear:
        {
            // Linear
            for (int i = 0; i < targetNumSamples; i++)
            {
                double floatIndex = float(i) * stepSize;
                double floorIndex = int(float(i) * stepSize);
                double alpha = floatIndex - floorIndex;
                int j = int (floorIndex);

                if ((j + 1) >= numberOfSamples)
                    resampledAudio[i] = 0.5 * (upsampledAudio[j] * (1.0 - alpha));
                else if (j >= numberOfSamples)
                    resampledAudio[i] = 0.0;
                else
                    resampledAudio[i] = 0.5 * (upsampledAudio[j] * (1.0 - alpha) + (upsampledAudio[j+1] * alpha));

            }
            break;
        }
        case InterpolationType::Cubic:
        {}
            break;
        case InterpolationType::Lagrange:
        {}
            break;
    }

    numberOfSamples = targetNumSamples;
    
    return resampledAudio;
}

float* resample(double* upsampledAudio, double targetSampleRate, double currentSampleRate, uint32_t& numberOfSamples)
{
    // step 1. Brick wall filter
    Filter lowpass;
    
    float sampleRateRatio = targetSampleRate / currentSampleRate;
    double normalisedCutoffFrequency = (2.0 * sampleRateRatio) - 0.01;
    lowpass.setButterworthCoefficients(4, normalisedCutoffFrequency);

    for (int i = 0; i < numberOfSamples; i++)
    {
        upsampledAudio[i] = lowpass.process(upsampledAudio[i]);
    }
        
    // step 2. Interpolate filtered audio
    float stepSize = 1.0 / sampleRateRatio;
    int targetNumSamples = int(sampleRateRatio * float(numberOfSamples));
    float* resampledAudio = new float[targetNumSamples];
    
    InterpolationType interpolationType = InterpolationType::Linear;
    
    switch (interpolationType)
    {
        case InterpolationType::Decimate:
        {
            // Decimate
            for (int i = 0; i < targetNumSamples; i++)
            {
                int j = int (float(i) * stepSize);
                resampledAudio[i] = upsampledAudio[j];
            }
            break;
        }
        case InterpolationType::Linear:
        {
            // Linear
            for (int i = 0; i < targetNumSamples; i++)
            {
                double floatIndex = float(i) * stepSize;
                double floorIndex = int(float(i) * stepSize);
                double alpha = floatIndex - floorIndex;
                int j = int (floorIndex);

                if ((j + 1) >= numberOfSamples)
                    resampledAudio[i] = 0.5 * (upsampledAudio[j] * (1.0 - alpha));
                else if (j >= numberOfSamples)
                    resampledAudio[i] = 0.0;
                else
                    resampledAudio[i] = 0.5 * (upsampledAudio[j] * (1.0 - alpha) + (upsampledAudio[j+1] * alpha));

            }
            break;
        }
        case InterpolationType::Cubic:
        {}
            break;
        case InterpolationType::Lagrange:
        {}
            break;
    }

    numberOfSamples = targetNumSamples;
    
    return resampledAudio;
}



void diff(float* audio, uint32_t numberOfSamples)
{
    audio[0] = 0.0;
    for (int i = 1; i < numberOfSamples - 1; i++)
    {
        audio[i] = audio[i+1] - audio[i];
    }
    audio[numberOfSamples - 1] = 0.0f;
}

void fade(float* audio, uint32_t numberOfSamples)
{
    static constexpr int fadeSize = 50;
    for (int i = 0; i < fadeSize - 1; i++)
        audio[i] *= float(i) / float(fadeSize);
}

void audiowrite(const char* filename, float* audio, uint32_t numberOfSamples, uint32_t sampleRate)
{
    fade(audio, numberOfSamples);
    normalise(audio, numberOfSamples);
    writeToWav(audio,
               numberOfSamples,
               filename,
               sampleRate);
}
