//
//  KHJVideoPlayer_sp_VC.h
//  SuperIPC
//
//  Created by kevin on 2020/2/12.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTPlayerBaseViewController.h"
#import "IPCNetManagerInterface.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "H264_H265_VideoDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJVideoPlayer_sp_VCDelegate <NSObject>

- (void)loadCellPic:(NSInteger)row;

@end

@interface KHJVideoPlayer_sp_VC : TTPlayerBaseViewController

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) TTDeviceInfo *deviceInfo;
@property (nonatomic, strong) id<KHJVideoPlayer_sp_VCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
