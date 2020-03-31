//
//  TTDataBase.h
//  SuperIPC
//
//  Created by kevin on 2020/2/18.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTDataBase : NSObject

+ (instancetype)shareDB;

- (void)initDataBase;

// 获取所有设备
- (NSMutableArray *)getAllDeviceInfo;

// 移除所有设备
- (void)removeAllDevice;

// 添加设备
- (void)addDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock;

// 删除设备
- (void)deleteDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock;
- (void)deleteDeviceInfo_with_deviceID:(NSString *)deviceID reBlock:(void(^)(NSString *deviceID,int code))reBlock;

// 更新设备
- (void)updateDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock;

// 查找设备
- (void)selectDeviceInfo_with_deviceInfo:(TTDeviceInfo *)deviceInfo reBlock:(void(^)(TTDeviceInfo *info,int code))reBlock;


@end

NS_ASSUME_NONNULL_END
