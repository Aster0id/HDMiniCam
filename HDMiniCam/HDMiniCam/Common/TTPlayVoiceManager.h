//
//  TTPlayVoiceManager.h
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TTPlayVoiceManager : NSObject

@property(nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (TTPlayVoiceManager *)shareInstance;
// 播放本地音频
- (void)playVoiceWithURL:(NSURL *)voiceURL;
// 停止播放本地音频
- (void)stopPlayVoice;


@end
