//
//  KHJPlayMusic.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface KHJPlayMusic : NSObject

@property(nonatomic, strong)AVAudioPlayer *hhAudioPlayer;
@property(nonatomic, strong)AVPlayer *myPlayer;

+(KHJPlayMusic *)shareInstance;
-(void)play:(NSURL *)url repeates:(NSInteger) number;
-(void)stopPlay;


@end
