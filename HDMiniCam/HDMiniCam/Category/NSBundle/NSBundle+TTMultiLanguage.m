//
//  NSBundle+TTMultiLanguage.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "NSBundle+TTMultiLanguage.h"
#import <objc/runtime.h>

static const char _bundle = 0;

@interface subBundle : NSBundle

@end

@implementation subBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSBundle *bundle = objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation NSBundle (TTMultiLanguage)

+ (void)setAppNewLanguage:(NSString *)name
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [subBundle class]);
    });
    
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, name ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
