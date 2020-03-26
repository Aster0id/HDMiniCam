//
//  TTDeviceInfo.m
//  SuperIPC
//
//  Created by kevin on 2020/2/18.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDeviceInfo.h"

@implementation TTDeviceInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceID       = [[NSString alloc] init];
        _deviceName     = [[NSString alloc] init];
        _deviceType     = [[NSString alloc] init];
        _deviceStatus   = [[NSString alloc] init];
        _devicePassword = [[NSString alloc] init];
        _reserve1   = [[NSString alloc] init];
        _reserve2   = [[NSString alloc] init];
        _reserve3   = [[NSString alloc] init];
        _reserve4   = [[NSString alloc] init];
        _reserve5   = [[NSString alloc] init];
        _reserve6   = [[NSString alloc] init];
        _reserve7   = [[NSString alloc] init];
        _reserve8   = [[NSString alloc] init];
        _reserve9   = [[NSString alloc] init];
        _reserve10  = [[NSString alloc] init];
        _reserve11  = [[NSString alloc] init];
        _reserve12  = [[NSString alloc] init];
        _reserve13  = [[NSString alloc] init];
        _reserve14  = [[NSString alloc] init];
        _reserve15  = [[NSString alloc] init];
    }
    return self;
}

@end
