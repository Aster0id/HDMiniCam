//
//  KHJHub.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

typedef enum : NSUInteger {
    _default,
    _lightGray,
} KHJHubType;

@interface KHJHub : NSObject

@property (nonatomic,strong) MBProgressHUD *hud;

+ (KHJHub *)shareHub;
- (void)showText:(NSString *)string addToView:(UIView *)view;
- (void)showText:(NSString *)string addToView:(UIView *)view andColor:(int)kind;
- (void)showText:(NSString *)string addToView:(UIView *)view type:(KHJHubType)type;

@end
