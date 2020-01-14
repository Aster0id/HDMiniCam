//
//  PlayLocalMusic.h
//  KHJCamera
//
//  Created by hezewen on 2018/5/23.
//  Copyright © 2018年 khj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayLocalMusic : NSObject

@property(nonatomic, strong)AVAudioPlayer *hhAudioPlayer;
@property(nonatomic, strong)AVPlayer *myPlayer;

+(PlayLocalMusic *)shareInstance;
-(void)play:(NSURL *)url repeates:(NSInteger) number;
-(void)stopPlay;


@end
