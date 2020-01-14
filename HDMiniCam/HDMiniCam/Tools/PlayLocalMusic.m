//
//  PlayLocalMusic.m
//  KHJCamera
//
//  Created by hezewen on 2018/5/23.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "PlayLocalMusic.h"
@implementation PlayLocalMusic

+(PlayLocalMusic *)shareInstance;

{
    static PlayLocalMusic *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [PlayLocalMusic shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [PlayLocalMusic shareInstance] ;
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






