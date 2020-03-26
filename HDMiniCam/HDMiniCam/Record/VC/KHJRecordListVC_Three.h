//
//  KHJRecordListVC_Three.h
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJRecordListVC_Three : TTBaseViewController

@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) TTDeviceInfo *info;
@property (nonatomic, assign) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
