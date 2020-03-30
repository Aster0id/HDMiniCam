//
//  UIDevice+TTDevice.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "UIDevice+TTDevice.h"

@implementation UIDevice (TTDevice)

+ (void)TTurnAroundDirection:(UIInterfaceOrientation)interfaceOrientation
{
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:interfaceOrientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

@end
