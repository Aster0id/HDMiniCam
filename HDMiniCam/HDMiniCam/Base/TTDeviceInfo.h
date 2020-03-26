//
//  TTDeviceInfo.h
//  SuperIPC
//
//  Created by kevin on 2020/2/18.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTDeviceInfo : NSObject

/// 设备id
@property (nonatomic, copy) NSString *deviceID;

/// 设备状态
// 0 在线 -6 离线 -26 密码错误 其余 连接中...
@property (nonatomic, copy) NSString *deviceStatus;

/// 设备密码
@property (nonatomic, copy) NSString *devicePassword;

/// 设备名称
@property (nonatomic, copy) NSString *deviceName;

/// 设备类型
@property (nonatomic, copy) NSString *deviceType;

/// 预留字段1
@property (nonatomic, copy) NSString *reserve1;

/// 预留字段2
@property (nonatomic, copy) NSString *reserve2;

/// 预留字段3
@property (nonatomic, copy) NSString *reserve3;

/// 预留字段4
@property (nonatomic, copy) NSString *reserve4;

/// 预留字段5
@property (nonatomic, copy) NSString *reserve5;

/// 预留字段6
@property (nonatomic, copy) NSString *reserve6;

/// 预留字段7
@property (nonatomic, copy) NSString *reserve7;

/// 预留字段8
@property (nonatomic, copy) NSString *reserve8;

/// 预留字段9
@property (nonatomic, copy) NSString *reserve9;

/// 预留字段10
@property (nonatomic, copy) NSString *reserve10;

/// 预留字段11
@property (nonatomic, copy) NSString *reserve11;

/// 预留字段12
@property (nonatomic, copy) NSString *reserve12;

/// 预留字段13
@property (nonatomic, copy) NSString *reserve13;

/// 预留字段14
@property (nonatomic, copy) NSString *reserve14;

/// 预留字段15
@property (nonatomic, copy) NSString *reserve15;

@end

NS_ASSUME_NONNULL_END
