
#import <Foundation/Foundation.h>
#import "TTAudioHeader.h"
#include "IPCNetManagerInterface.h"

@class TTAudioPlayer;

typedef void (^TTAudioPlayerInputBlock)(AudioBufferList *bufferList);
typedef void (^TTAudioPlayerInputBlockFull)(TTAudioPlayer *player,
                                                AudioUnitRenderActionFlags *ioActionFlags,
                                                const AudioTimeStamp *inTimeStamp,
                                                UInt32 inBusNumber,
                                                UInt32 inNumberFrames,
                                                AudioBufferList *ioData);

@interface TTAudioPlayer : NSObject

{
    AudioUnit tt_audio_unit;
    pthread_mutex_t tt_audio_frame_packageList_Lock;
}

- (void)start;
- (void)stop;
//- (void)destroy;

- (instancetype)initWithRate:(TTAudioRate)rate bit:(TTAudioBit)bit channel:(TTAudioChannel)channel;
- (int)playThisAudioData:(uint8_t *)audioData audioSize:(int)audioSize frameType:(int)frameType timestamp:(long)timestamp;


@property (nonatomic,assign) IPCNET_AUDIO_ENCODE_TYPE_et audio_encode_Type;
@property (nonatomic,assign) NSString *sp_deviceID;



@end
