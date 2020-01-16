//
//  KHJUtility.m
//  KHJCamera
//
//  Created by khj888 on 2018/12/15.
//  Copyright © 2018 KHJ. All rights reserved.
//

#import "KHJUtility.h"

@implementation KHJUtility

/**
 主题色
 */
+ (UIColor *)appMainColor
{
    return UIColorFromRGB(0x0584e0);
}

/**
 边框色
 */
+ (void)setborderViewStyle:(UIView *)view
{
    view.layer.borderWidth      = 1;
    view.layer.borderColor      = KHJUtility.appMainColor.CGColor;
    view.layer.masksToBounds    = YES;
    view.layer.cornerRadius     = 5;
}

/**
 Bugly KEY
 */
+ (NSString *)BuglyKey
{
    return @"442deaba51";
}

+ (UIColor *)ios13Color:(UIColor *)newColor ios12Coloer:(UIColor *)oldColor
{
    UIColor *returnColor = nil;
#pragma mark - 适配iOS13
    if (@available(iOS 13.0, *)) {
//        returnColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
//            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
//                return newColor;
//            }
//            else {
//                return oldColor;
//            }
//        }];
    }
    else {
        returnColor = oldColor;
    }
    return returnColor;
}


@end
