
#import <Foundation/Foundation.h>
#import "TTAudioHeader.h"
#include "IPCNetManagerInterface.h"

@class TTAudioRecorder;


@interface TTAudioRecorder : NSObject




@property (nonatomic,readonly,assign) BOOL isRecording;



@property (nonatomic,assign) char *mUUID;

@property (nonatomic,assign) IPCNET_AUDIO_ENCODE_TYPE_et codeType;




- (instancetype)initWithRate:(TTAudioRate)rate bit:(TTAudioBit)bit channel:(TTAudioChannel)channel;
- (void)start;

- (void)stop;


- (AudioStreamBasicDescription)getOutputFormat;

@end
