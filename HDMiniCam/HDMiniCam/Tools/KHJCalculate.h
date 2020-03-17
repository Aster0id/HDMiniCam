//
//  KHJCalculate.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface KHJCalculate : NSObject

////计算3个点的角度
//+ (CGFloat)getAnglesWithThreePoint:(CGPoint)pointA pointB:(CGPoint)pointB pointC:(CGPoint)pointC;
////判断在哪个部分
//+ (NSInteger)isBelongPart:(CGFloat)angle;
//计算数组去重个数,并且排序
+ (NSMutableArray *)calCategoryArray:(NSArray *)arr;
//数组排序
+ (NSMutableArray *)bubbleDescendingOrderSortWithArray:(NSMutableArray *)descendingArr;
////获取视频第一桢
//+ (UIImage *)getFristImageInmp4Video:(NSString *)filePath;
////
//+ (UIImage*)getCoverImage:(NSURL *)_outMovieURL;
//下一天日期
+ (NSString *)nextDay:(NSString *)dateString;
// 前一天日期
+ (NSString *)prevDay:(NSString *)dateString;
//// 字符串转时间戳
//+ (long)getTimeStrWithString:(NSString *)str;
///**
// 字符串转时间戳 如：2017年04月10日 17时15分
// */
//+ (long)getTimeStr_2WithString:(NSString *)str;
// 日期比较
+ (NSInteger)compareDate:(NSString *)aDate withDate:(NSString *)bDate;
// 获取当前时间
+ (NSString*)getCurrentTimes;
//// 根据返回的时间戳字符串，获取指定的格式的时间
//+ (NSString*)getTimeFormat:(NSString *)timeStampString;
//// 根据返回的时间戳字符串，获取指定的格式的时间
//+ (NSString*)formateTimeStamp:(NSString *)timeStampString;
//// 获取时间戳
//+ (NSInteger)getUTCTime:(NSString *)string;
// 时间戳转字符串，获取、时、分、秒
+ (NSString *)getTimesFromUTC:(NSTimeInterval)timeInterval;
// 时间戳转字符串，获取年、月、日
+ (NSString *)getYearFromUTC:(NSTimeInterval)timeInterval;
//// 邮箱验证
//+ (BOOL)isAvailableEmail:(NSString *)email;
//// 手机号验证
//+ (BOOL)valiMobile:(NSString *)mobile;
//// uicode转汉字
//+ (NSString *)replaceUnicode:(NSString *)unicodeStr;
//// 判断密码合法性
//+ (BOOL)validatePassword:(NSString *)passWord;
//// 获取网速
//+ (long long int)getInterfaceBytes;
//// 网速格式转换
//+ (NSString*)formatNetWork:(long long int)rate;
//// 设置锚点
//+ (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
//// json字符串 转 字典
//+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//// 根据返回的时间戳字符串，获取指定的格式的时间
//+(NSString*)getSureTimeFormat:(NSString *)timeStampString;
// 2分查找
+ (NSInteger)binarySearch:(NSArray *)source target:(NSInteger)target;
+ (NSInteger)binarySearchSDCardStart:(NSArray *)source target:(NSInteger)target;
//
//+ (NSInteger)binarySearchCloudStart:(NSArray *)source target:(NSInteger)target;
//+ (NSInteger)binarySearchCloudEnd:(NSArray *)source target:(NSInteger)target;
//// 通过时间戳，创建视频名称
//+ (NSString *)getVedioNameFromTimes:(NSTimeInterval)timeInterval;
// 将当前时间字符串 转为 UTCDate
+ (NSTimeInterval )UTCDateFromLocalString2:(NSString *)localString;
//// 文件大小
//+ (long long)fileSizeAtPath:(NSString*)filePath;
// 图片大小
+ (NSString *)valueImageSize:(NSString *)path;
//// YYYY_MM_dd HH:mm:ss 时间字符串 转 时间戳
//+ (NSTimeInterval)getUTCFromDateString:(NSString *)dateStr;
// 时间戳 转 yyyyMMdd 时间字符串
+ (NSString *)getDateFromTimes:(NSTimeInterval)timeInterval;
//// 时间戳 转 yyyy_MM_dd 时间字符串
//+ (NSString *)getDateFromTimes2:(NSTimeInterval)timeInterval;
//
//// 时间戳 转 HHmmss 时间字符串
//+ (NSString *)getTimewFromTimes:(NSTimeInterval)timeInterval;

// 根据文字 + 字体 + 最大size 计算label的宽高
//+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;
+ (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize;

////用户信息
//#pragma mark - 保存账户
//+ (void)saveAccount:(NSString *)accountText;//保存用户账户

@end






