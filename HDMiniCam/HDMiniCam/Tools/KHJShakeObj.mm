//
//  KHJShakeObj.m
//  KHJCamera
//
//  Created by hezewen on 2018/7/18.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "KHJShakeObj.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define KHJNeedShakeKey    @"isNeedShake"

@interface KHJShakeObj ()
{
//    SystemSoundID sound;
    NSTimer *shakeTimer;
    SystemSoundID soundID;
    BOOL isNeedShake;
    NSArray *mArray;
}

@end

@implementation KHJShakeObj

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KHJNeedShakeKey];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flushSoundID) name:flushSoundID_Noti object:nil];
//        mArray = [NSArray arrayWithObjects:@"classical",@"alarmbell",@"moming", nil];
//        [self flushSoundID];
    }
    return self;
}

- (void)flushSoundID
{
//    NSInteger kind      = [[NSUserDefaults standardUserDefaults] integerForKey:KHJPhoneAlarmSoundCateKey];
//    NSString *sName     = [mArray objectAtIndex:kind];//音频文件名称
//    NSString *sstime    = [[NSUserDefaults standardUserDefaults] objectForKey:KHJPhoneAlarmSoundTimeKey];
//    if ([sstime isEqualToString:@"30s"] || [sstime isEqualToString:@"30秒"]) {
//        sName = KHJString(@"%@_30",sName);
//    }
//    CLog(@"铃声类型 == %@",sName);
//    NSString *filePath  = [[NSBundle mainBundle] pathForResource:sName ofType:@"mp3"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], &soundID);
}
- (void)onlyShark
{
    NSLog(@"仅报警");
    isNeedShake =  [[NSUserDefaults standardUserDefaults] boolForKey:KHJNeedShakeKey];
    if (!isNeedShake) {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, soundCompleteCallback1, NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [[NSUserDefaults standardUserDefaults] boolForKey:KHJNeedShakeKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KHJNeedShakeKey];
    }
}

- (void)stopOnlyShark
{
    NSLog(@"停止震动");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KHJNeedShakeKey];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    });
}

- (void)sharkAndPlaySound
{
    NSLog(@"报警 + 响铃");
    isNeedShake =  [[NSUserDefaults standardUserDefaults] boolForKey:KHJNeedShakeKey];
    if (!isNeedShake) {
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, soundCompleteCallback1, NULL);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlayAlertSound(soundID);
        [[NSUserDefaults standardUserDefaults] boolForKey:KHJNeedShakeKey];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KHJNeedShakeKey];
    }
}

- (void)stopSharkAndPlaySound
{
    NSLog(@"停止震动和响铃");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KHJNeedShakeKey];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AudioServicesDisposeSystemSoundID(self->soundID);
        AudioServicesRemoveSystemSoundCompletion(self->soundID);
    });
}

void soundCompleteCallback1(SystemSoundID sound,void * clientData) {
    
    BOOL isStop     =  [[NSUserDefaults standardUserDefaults] boolForKey:KHJNeedShakeKey];
    BOOL isLogin    =  [SaveManager.isLogined boolValue];
    if (isStop && isLogin) {
        AudioServicesPlayAlertSound(sound);
    }
    else {
        AudioServicesDisposeSystemSoundID(sound);
        AudioServicesRemoveSystemSoundCompletion(sound);
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
    }
}

extern OSStatus
AudioServicesAddSystemSoundCompletion(SystemSoundID                        inSystemSoundID,
                                      CFRunLoopRef                         inRunLoop,
                                      CFStringRef                          inRunLoopMode,
                                      AudioServicesSystemSoundCompletionProc  inCompletionRoutine,
                                      void*                                inClientData)
__OSX_AVAILABLE_STARTING(__MAC_10_5,__IPHONE_2_0);

@end
