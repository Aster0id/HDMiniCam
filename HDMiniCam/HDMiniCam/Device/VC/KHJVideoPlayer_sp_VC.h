//
//  KHJVideoPlayer_sp_VC.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/12.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayerBaseVC.h"
#import "IPCNetManagerInterface.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "H26xHwDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJVideoPlayer_sp_VC : KHJVideoPlayerBaseVC

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) KHJDeviceInfo *deviceInfo;

@end

NS_ASSUME_NONNULL_END
