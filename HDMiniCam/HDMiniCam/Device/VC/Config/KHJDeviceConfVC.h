//
//  KHJDeviceConfVC.h
//  SuperIPC
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJDeviceConfVC : TTBaseViewController

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, strong) TTDeviceInfo *deviceInfo;

@end

NS_ASSUME_NONNULL_END
