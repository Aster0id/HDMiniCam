//
//  TTPlayVoiceManager.h
//  HDMiniCam
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "TTPlayVoiceManager.h"
@implementation TTPlayVoiceManager

static TTPlayVoiceManager *playVoice = nil;

+ (TTPlayVoiceManager *)shareInstance;
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        playVoice = [[TTPlayVoiceManager alloc] init] ;
    }) ;
    return playVoice;
}

// 播放本地音频
- (void)playVoiceWithURL:(NSURL *)voiceURL
{
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:voiceURL error:nil];
    [self.audioPlayer setVolume:1];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

// 停止播放本地音频
- (void)stopPlayVoice
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

@end






