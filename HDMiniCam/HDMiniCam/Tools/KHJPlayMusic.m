//
//  KHJPlayMusic.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJPlayMusic.h"
@implementation KHJPlayMusic

+(KHJPlayMusic *)shareInstance;

{
    static KHJPlayMusic *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [KHJPlayMusic shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [KHJPlayMusic shareInstance] ;
}

-(void)play:(NSURL *)url repeates:(NSInteger) number
{
    //创建音乐播放器
;
    if(url){
        NSError *error ;
        _hhAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if(error){
            NSLog(@"audioPlayer init error:%@",[error localizedDescription]);
        }
        [_hhAudioPlayer setVolume:1];
        [_hhAudioPlayer prepareToPlay];
        [_hhAudioPlayer play];
    }
}
-(void)stopPlay
{
    [_hhAudioPlayer stop];
    _hhAudioPlayer = nil;
    
}

@end






