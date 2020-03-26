//
//  KHJRecordListVC_Three.h
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJRecordListVC_Three : KHJBaseVC

@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) KHJDeviceInfo *info;
@property (nonatomic, assign) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
