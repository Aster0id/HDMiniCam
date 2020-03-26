
#ifndef TTAudioHeader_h
#define TTAudioHeader_h

#define kInputBus (1)
#define kOutputBus (0)

#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "TTAudioHeader.h"
#import <assert.h>

typedef enum : NSUInteger
{
    
    
    TTAudioFormatFlags_Float = kAudioFormatFlagIsFloat,
    
    
    TTAudioFormatFlags_Packed = kAudioFormatFlagIsPacked,
    
    TTAudioFormatFlags_BigEndian = kAudioFormatFlagIsBigEndian,
    
    TTAudioFormatFlags_NonMixable = kAudioFormatFlagIsNonMixable,
    
    TTAudioFormatFlags_AreAllClear = kAudioFormatFlagsAreAllClear,
    
    TTAudioFormatFlags_AlignedHigh = kAudioFormatFlagIsAlignedHigh,
    
    TTAudioFormatFlags_SignedInteger = kAudioFormatFlagIsSignedInteger,
    
    
    TTAudioFormatFlags_NonInterleaved = kAudioFormatFlagIsNonInterleaved,


} TTAudioFormatFlags;


typedef enum : NSUInteger
{
    TTAudioChannel_2 = 2,
    TTAudioChannel_1 = 1,
} TTAudioChannel;



typedef enum : NSUInteger
{
    TTAudioFormatID_PCM = kAudioFormatLinearPCM,
} TTAudioFormatID;

typedef enum : NSUInteger
{
    
    
    TTAudioUnitPropertyID_StreamFormat = kAudioUnitProperty_StreamFormat,
    
    TTAudioUnitPropertyID_ElementCount = kAudioUnitProperty_ElementCount,
    
    TTAudioUnitPropertyID_callback_input = kAudioUnitProperty_SetRenderCallback,
    
    
    TTAudioUnitPropertyID_callback_output = kAudioOutputUnitProperty_SetInputCallback,

} TTAudioUnitPropertyID;


typedef enum : NSUInteger
{
    TTAudioBit_32 = 32,
    TTAudioBit_16 = 16,
    TTAudioBit_8 = 8,
} TTAudioBit;


static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char errorString[20];
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
    
        
        isprint(errorString[3]) && isprint(errorString[4])) {
        
        
        errorString[0] = errorString[5] = '\'';
        
        
        errorString[6] = '\0';
    }
    
    else {
        
        
        sprintf(errorString, "%d", (int)error);
    }
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}



typedef enum : NSUInteger
{
    
    
    TTAudioRate_96k = 96000,
    
    TTAudioRate_48k = 48000,
    
    TTAudioRate_44k = 44100,
    
    TTAudioRate_20k = 20000,
    
    TTAudioRate_16k = 16000,
    
    TTAudioRate_8k = 8000,

} TTAudioRate;

#endif /* TTAudioHeader_h */
