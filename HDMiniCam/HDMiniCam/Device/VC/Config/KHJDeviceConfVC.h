//
//  KHJDeviceConfVC.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJDeviceConfVC : KHJBaseVC

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, strong) KHJDeviceInfo *deviceInfo;

@end

NS_ASSUME_NONNULL_END
