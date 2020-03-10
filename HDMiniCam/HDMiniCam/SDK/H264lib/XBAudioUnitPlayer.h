//
//  XBAudioUnitPlayer.h
//  XBVoiceTool
//
//  Created by xxb on 2018/6/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Header_audio.h"
#include "IPCNetManagerInterface.h"

@class XBAudioUnitPlayer;

typedef void (^XBAudioUnitPlayerInputBlock)(AudioBufferList *bufferList);
typedef void (^XBAudioUnitPlayerInputBlockFull)(XBAudioUnitPlayer *player,
                                                AudioUnitRenderActionFlags *ioActionFlags,
                                                const AudioTimeStamp *inTimeStamp,
                                                UInt32 inBusNumber,
                                                UInt32 inNumberFrames,
                                                AudioBufferList *ioData);

@interface XBAudioUnitPlayer : NSObject
@property (nonatomic,assign) NSString *mUUID;
@property (nonatomic,assign) IPCNET_AUDIO_ENCODE_TYPE_et codeType;
//@property (nonatomic,copy) XBAudioUnitPlayerInputBlock bl_input;
//@property (nonatomic,copy) XBAudioUnitPlayerInputBlockFull bl_inputFull;
- (instancetype)initWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel;
- (void)start;
- (void)stop;
- (void)destroy;
- (int)playThisAudioData:(uint8_t *)audioData audioSize:(int)audioSize frameType:(int)frameType timestamp:(long)timestamp;

@end
