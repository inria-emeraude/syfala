// ----------------------------------------------------------------------
// Utility functions for working with audio streams
// Dr Craig J. Webb
// May 2016
//
// Dependencies: #define ReaL double/float before including this header
//
// ----------------------------------------------------------------------

#ifndef CJW_Audio_h
#define CJW_Audio_h

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <cmath>
#include <string.h>
#include <stdint.h>

// ----------------------------------------------------------------------
// Wav header struct
// ----------------------------------------------------------------------

typedef struct waveFormatHeader {
    char     ChunkId[4];
    uint32_t ChunkSize;
    char     Format[4];
    char     Subchunk1ID[4];
    uint32_t Subchunk1Size;
    uint16_t AudioFormat;
    uint16_t NumChannels;
    uint32_t SampleRate;
    uint32_t ByteRate;
    uint16_t BlockAlign;
    uint16_t BitsPerSample;
    char     SubChunk2ID[4];
    uint32_t Subchunk2Size;
} waveFormatHeader_t;


// ----------------------------------------------------------------------
// Function prototypes
// ----------------------------------------------------------------------

// Read in a Mono wav file
ReaL * readWav(const char *filename, int *length, int *sampleRate);

// Write two arrays of ReaLs to a 16bit stereo wav file. Can be same mono buffer.
void writeWav(ReaL *audioL, ReaL *audioR, const char outputFile[], int NumberOfSamples, int SampRate);

// Print last samples of mono data stream
void printLastSamples(ReaL *audio, int Nf, int N);

// CPU timer function
void timers(double *et);

// Normalise a stereo buffer
void normaliseStereoBuffer(ReaL *audioL, ReaL *audioR, int Nf);



// ----------------------------------------------------------------------
// Function Implementations
// ----------------------------------------------------------------------


// ----------------------------------------------------------------------
// readWav
// ----------------------------------------------------------------------

ReaL * readWav(const char *filename, int *length, int *sampleRate){
    
    FILE *f;
    waveFormatHeader_t hdr;
    ReaL *data;
    short *buf;
    int i;
    
    f = fopen(filename, "rb");
    if (!f) {
        return NULL;
    }
    fread(&hdr, 1, sizeof(hdr), f);
    /* quick sanity check */
    if ((strncmp(&hdr.ChunkId[0], "RIFF", 4))     || (strncmp(&hdr.Format[0], "WAVE", 4)) ||
        (strncmp(&hdr.Subchunk1ID[0], "fmt ", 4)) || (strncmp(&hdr.SubChunk2ID[0], "data", 4))) {
        fclose(f);
        return NULL;
    }
    
    /* check correct format */
    if ((hdr.BitsPerSample != 16) || (hdr.NumChannels != 1)) {
        fclose(f);
        return NULL;
    }
    
    *sampleRate = hdr.SampleRate;
    *length     = hdr.Subchunk2Size / 2;
    
    buf = (short *)malloc((*length)*sizeof(short));
    if (!buf) {
        fclose(f);
        return NULL;
    }
    fread(buf, (*length)*sizeof(short), 1, f);
    fclose(f);
    
    data = (ReaL *)malloc((*length)*sizeof(ReaL));
    if (!data) {
        free(buf);
        return NULL;
    }
    for (i = 0; i < (*length); i++) {
        data[i] = ((ReaL)buf[i]) / 32768.0;
    }
    
    printf("%d samples read from %s\n",*length,filename);
    
    free(buf);
    return data;
    
}

// ----------------------------------------------------------------------
// writeWav
// ----------------------------------------------------------------------

void writeWav(ReaL *audioL, ReaL *audioR, const char outputFile[], int NumberOfSamples, int SampRate){
    
    normaliseStereoBuffer(audioL, audioR, NumberOfSamples);
    
    FILE * file;
    file = fopen(outputFile, "w");
    
    waveFormatHeader_t * wh = (waveFormatHeader_t *)malloc(sizeof(waveFormatHeader_t));
    memcpy(wh->ChunkId, &"RIFF", 4);
    memcpy(wh->Format, &"WAVE", 4);
    memcpy(wh->Subchunk1ID, &"fmt ", 4); //notice the space at the end!
    wh -> Subchunk1Size = 16;
    wh->AudioFormat   = 1;
    wh->NumChannels   = 2;
    wh->SampleRate    = (uint32_t)SampRate;
    wh->BitsPerSample = 16;
    wh->ByteRate      = wh->NumChannels * wh -> SampleRate * wh -> BitsPerSample/8;
    wh->BlockAlign    = wh->NumChannels * wh -> BitsPerSample/8;
    memcpy(wh->SubChunk2ID, &"data", 4);
    wh -> Subchunk2Size = (uint32_t)NumberOfSamples * wh->NumChannels * wh->BitsPerSample/8;
    wh -> ChunkSize     = 36 + wh -> Subchunk2Size;
    
    fwrite(wh, sizeof(waveFormatHeader_t), 1, file);
    free(wh);
    
    int16_t sdata;
    ReaL amp = 32767.0;
    
    int i;
    for(i=0;i<NumberOfSamples;i++){
        sdata = (int16_t)(audioL[i]*amp);
        fwrite(&sdata, sizeof(int16_t), 1, file); //left channel
        sdata = (int16_t)(audioR[i]*amp);
        fwrite(&sdata, sizeof(int16_t), 1, file); //right channel
    }
    fclose(file);
    printf("%d samples written to %s\n", NumberOfSamples,outputFile);
    
}

// ----------------------------------------------------------------------
// printLastSamples
// ----------------------------------------------------------------------

void printLastSamples(ReaL *audio, int Nf, int N){
    
    int n;
    ReaL maxy;
    // Test that N > 0
    if(N<1){
        printf("Must display 1 or more samples...\n");
    }
    else{
        //print last N samples
        printf("\n");
        for(n=Nf-N;n<Nf;n++)
        {
            printf("Sample %d : %.15f\n",n,audio[n]);
        }
        
        // find max
        maxy = 0.0;
        for(n=0;n<Nf;n++)
        {
            if(fabs(audio[n])>maxy) maxy = fabs(audio[n]);
            
        }
        printf("\nMax sample   : %.15f\n",maxy);
    }
    
}

// ----------------------------------------------------------------------
// timers
// ----------------------------------------------------------------------

void timers(double *et){
    
    struct timeval t;
    gettimeofday( &t, (struct timezone *)0 );
    *et = t.tv_sec + t.tv_usec*1e-6;
}


// ----------------------------------------------------------------------
// normaliseStereoBuffer
// ----------------------------------------------------------------------

void normaliseStereoBuffer(ReaL *audioL, ReaL *audioR, int Nf)
{
    
    int n;
    
    // Find max abs sample
    ReaL maxy = 0.0;
    
    for(n=0;n<Nf;n++)
    {
        if(fabs(audioL[n])>maxy) maxy = fabs(audioL[n]);
        if(fabs(audioR[n])>maxy) maxy = fabs(audioR[n]);
        
    }
    
    // Check if both buffers the same !
    int stereo = 1;
    if (audioL==audioR) stereo = 0;
    
    // Normalise
    
    for(n=0;n<Nf;n++)
    {
        if (maxy > 0.000001)
            audioL[n] = audioL[n]/maxy;
        
        if (stereo)
        {
            if (maxy > 0.000001)
                audioR[n] = audioR[n]/maxy;
        }
    }
    
    
    // Smooth last 500 samples
    if(Nf>501){
        ReaL inc  = 1.0/500.0;
        ReaL ramp = 1.0;
        for(n=Nf-501;n<Nf;n++)
        {
            audioL[n] *= ramp;
            if (stereo) audioR[n] *= ramp;
            if(ramp>0) ramp-=inc;
        }
    }
    
}




// ----------------------------------------------------------------------

#endif /* CJW_Audio_h */




