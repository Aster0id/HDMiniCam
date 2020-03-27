//
//  TTDeviceAllDayVC.h
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTDeviceAllDayVC : TTBaseViewController

@property (nonatomic, strong) TTDeviceInfo *deviceInfo;
@property (nonatomic, assign) NSInteger isLiveOrRecordBack;

@end

NS_ASSUME_NONNULL_END
