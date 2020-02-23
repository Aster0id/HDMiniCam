//
//  KHJVideoPlayer_sp_VC.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/12.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseVC.h"

#import "IPCNetManagerInterface.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "H264HwDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJVideoPlayer_sp_VC : KHJBaseVC

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *password;

@end

NS_ASSUME_NONNULL_END
