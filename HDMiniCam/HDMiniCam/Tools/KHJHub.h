//
//  KHJHub.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
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
