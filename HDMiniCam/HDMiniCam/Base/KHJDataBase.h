//
//  KHJDataBase.h
//  HDMiniCam
//
//  Created by kevin on 2020/2/18.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface KHJDataBase : NSObject

+ (instancetype)sharedDataBase;

- (void)initDataBase;

// 获取所有设备
- (NSMutableArray *)getAllDeviceInfo;

// 移除所有设备
- (void)removeAllDevice;

// 添加设备
- (void)addDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo resultBlock:(void(^)(KHJDeviceInfo *info,int code))resultBlock;

// 删除设备
- (void)deleteDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo resultBlock:(void(^)(KHJDeviceInfo *info,int code))resultBlock;

// 更新设备
- (void)updateDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo resultBlock:(void(^)(KHJDeviceInfo *info,int code))resultBlock;

// 查找设备
- (void)selectDeviceInfo_with_deviceInfo:(KHJDeviceInfo *)deviceInfo resultBlock:(void(^)(KHJDeviceInfo *info,int code))resultBlock;


@end

NS_ASSUME_NONNULL_END
