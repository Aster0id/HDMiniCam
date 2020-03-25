//
//  KHJVideoPlayer_sp_VC.h
//  HDMiniCam
//
//  Created by kevin on 2020/2/12.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayerBaseVC.h"
#import "IPCNetManagerInterface.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "H26xHwDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJVideoPlayer_sp_VCDelegate <NSObject>

- (void)loadCellPic:(NSInteger)row;

@end

@interface KHJVideoPlayer_sp_VC : KHJVideoPlayerBaseVC

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) KHJDeviceInfo *deviceInfo;
@property (nonatomic, strong) id<KHJVideoPlayer_sp_VCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
