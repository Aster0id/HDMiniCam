//
//  KHJNetWorkingManager.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJNetWorkingManager.h"

@interface KHJNetWorkingManager()

@end

@implementation KHJNetWorkingManager

+ (KHJNetWorkingManager *)sharedManager
{
    static KHJNetWorkingManager *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}




@end



















