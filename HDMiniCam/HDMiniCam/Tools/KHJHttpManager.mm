//
//  KHJHttpManager.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJHttpManager.h"

@interface KHJHttpManager()

@end

@implementation KHJHttpManager

+ (KHJHttpManager *)sharedManager
{
    static KHJHttpManager *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return instanceManager ;
}




@end



















