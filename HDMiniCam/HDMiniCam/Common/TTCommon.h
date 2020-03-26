//
//  TTCommon.h
//  SuperIPC
//
//  Created by kevin on 2020/3/25.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTCommon : NSObject

+ (UIColor *)appMainColor;
+ (UIColor *)ios13_systemColor:(UIColor *)newColor earlier_systemColoer:(UIColor *)oldColor;
+ (NSDictionary *)cString_changto_ocStringWith:(const char *)cString;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

#pragma mark - 计算方法

/// 计算数组去重个数,并且排序
+ (NSMutableArray *)calCategoryArray:(NSArray *)arr;
/// 数组排序
+ (NSMutableArray *)bubbleDescendingOrderSortWithArray:(NSMutableArray *)descendingArr;
/// 下一天日期
+ (NSString *)nextDay:(NSString *)dateString;
/// 前一天日期
+ (NSString *)prevDay:(NSString *)dateString;
/// 日期比较
+ (NSInteger)compareDate:(NSString *)aDate withDate:(NSString *)bDate;
/// 获取当前时间
+ (NSString*)getCurrentTimes;
/// 时间戳转字符串，获取、时、分、秒
+ (NSString *)getTimesFromUTC:(NSTimeInterval)timeInterval;
/// 时间戳转字符串，获取年、月、日
+ (NSString *)getYearFromUTC:(NSTimeInterval)timeInterval;
/// 2分查找
+ (NSInteger)binarySearch:(NSArray *)source target:(NSInteger)target;
+ (NSInteger)binarySearchSDCardStart:(NSArray *)source target:(NSInteger)target;
/// 将当前时间字符串 转为 UTCDate
+ (NSTimeInterval )UTCDateFromLocalString2:(NSString *)localString;
/// 图片大小
+ (NSString *)valueImageSize:(NSString *)path;
/// 时间戳 转 yyyyMMdd 时间字符串
+ (NSString *)getDateFromTimes:(NSTimeInterval)timeInterval;
/// 根据文字 + 字体 + 最大size 计算label的宽高
+ (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize;



@end

NS_ASSUME_NONNULL_END
