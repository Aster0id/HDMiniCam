//
//  KHJUtility.h
//  KHJCamera
//
//  Created by khj888 on 2018/12/15.
//  Copyright © 2018 KHJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJUtility : NSObject

/* 主题色 */
+ (UIColor *)appMainColor;
/* 边框色 */
+ (void)setborderViewStyle:(UIView *)view;
/* Bugly KEY */
+ (NSString *)BuglyKey;
+ (UIColor *)ios13Color:(UIColor *)newColor ios12Coloer:(UIColor *)oldColor;

+ (NSDictionary *)cString_changto_ocStringWith:(const char *)cString;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;


@end
