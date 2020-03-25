//
//  TTCommon.m
//  HDMiniCam
//
//  Created by kevin on 2020/3/25.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "TTCommon.h"
#import <AVFoundation/AVFoundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "KHJVideoModel.h"

@implementation TTCommon

/**
 主题色
 */
+ (UIColor *)appMainColor
{
    return UIColorFromRGB(0x0584e0);
}

+ (UIColor *)ios13_systemColor:(UIColor *)newColor earlier_systemColoer:(UIColor *)oldColor
{
    UIColor *returnColor = nil;
#pragma mark - 适配iOS13
    if (@available(iOS 13.0, *)) {
        returnColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return newColor;
            }
            else {
                return oldColor;
            }
        }];
    }
    else {
        returnColor = oldColor;
    }
    return returnColor;
}

+ (NSDictionary *)cString_changto_ocStringWith:(const char *)cString
{
    NSString *json      = [NSString stringWithUTF8String:cString];
    NSData *jsonData    = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *body  = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return body;
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }
    else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

#pragma mark - 计算方法

//计算数组去重个数
+ (NSMutableArray *)calCategoryArray:(NSArray *)arr
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray * marr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *s  in arr) {

        NSNumber *dd = [NSNumber numberWithInteger:[s integerValue]];
        [dict setObject:dd forKey:dd];
    }
    [marr addObjectsFromArray:[dict allValues]];
    marr = [self bubbleDescendingOrderSortWithArray:marr];
    return marr;
}

// 冒泡降序排序
+ (NSMutableArray *)bubbleDescendingOrderSortWithArray:(NSMutableArray *)descendingArr
{
    for (int i = 0; i < descendingArr.count; i++) {

        for (int j = 0; j < descendingArr.count - 1 - i; j++) {

            if ([descendingArr[j] longLongValue] < [descendingArr[j + 1] longLongValue]) {
                long long  tmp = [descendingArr[j] longLongValue];
                descendingArr[j] = descendingArr[j + 1];
                descendingArr[j + 1] = [NSNumber numberWithLongLong:tmp];
            }
        }
    }
    return descendingArr;
}

// 时间戳转字符串，获取、时、分、秒
+ (NSString *)getTimesFromUTC:(NSTimeInterval)timeInterval
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm:ss"];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}

// 时间戳转字符串，获取年、月、日
+ (NSString *)getYearFromUTC:(NSTimeInterval)timeInterval
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}


+ (NSString *)nextDay:(NSString *) dateString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd"];
    NSDate *date = [format dateFromString:dateString];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 24*3600)];

    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}

+ (NSString *)prevDay:(NSString *)dateString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy_MM_dd"];
    NSDate *date = [format dateFromString:dateString];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - 24*3600)];
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}

// 日期比较
+ (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate
{
    NSInteger aa = 0;;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy_MM_dd"];
    NSDate *dta = [[NSDate alloc] init];
    NSDate *dtb = [[NSDate alloc] init];

    dta = [dateformater dateFromString:aDate];
    dtb = [dateformater dateFromString:bDate];
    NSComparisonResult result = [dta compare:dtb];
    if (result == NSOrderedSame) {
        //        相等
        aa = 0;
    }
    else if (result == NSOrderedAscending) {
        //bDate比aDate大
        aa = 1;
    }
    else if (result == NSOrderedDescending) {
        //bDate比aDate小
        aa = -1;
    }
    return aa;
}
//
//获取当前的时间
+ (NSString*)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"yyyy_MM_dd"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
//    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

//2分查找
+ (NSInteger)binarySearch:(NSArray *)source target:(NSInteger)target
{
    if (source.count == 0) {
        return -1;
    }
    NSInteger start = 0;
    NSInteger end = source.count - 1;
    NSInteger mid = 0;
    while (start + 1 < end) {//判断在两个视频的中间

        mid = start + (end - start) / 2;
        KHJVideoModel *vModel = source[mid];
        if (vModel.startTime == target) { // 相邻就退出
            return mid;
        }
        else if (vModel.startTime < target) {//大于起始时间
            start = mid;
        }
        else {
            end = mid;
        }
    }
    KHJVideoModel *vModel = source[start];

    if ( vModel.startTime <= target && (vModel.startTime+vModel.durationTime) >= target) {
        return start;
    }
    vModel = source[end];
    if (vModel.startTime <= target && (vModel.startTime+vModel.durationTime) >= target) {
        return end;
    }
    return -1;
}
+ (NSInteger)binarySearchSDCardStart:(NSArray *)source target:(NSInteger)target
{
    if (source.count == 0) {
        return -1;
    }
    NSInteger start = 0;
    NSInteger end = source.count - 1;
    NSInteger mid = 0;
    while (start + 1 < end) {//判断在两个视频的中间

        mid = start + (end - start) / 2;
        KHJVideoModel *vModel = source[mid];
        if (vModel.startTime == target) { // 相邻就退出
            return mid;
        }
        else if (vModel.startTime < target) {//大于起始时间
            start = mid;
        }
        else {
            end = mid;
        }
    }
    KHJVideoModel *firstModel = source.firstObject;
    if (target < firstModel.startTime) {
        return -1;
    }
    KHJVideoModel *vModel = source[start];
    if ( vModel.startTime <= target && vModel.startTime + vModel.durationTime >= target) {
        return start;
    }
    KHJVideoModel *endModel = source[end];
    if (endModel.startTime <= target && endModel.startTime + endModel.durationTime >= target) {
        return end;
    }
    if (target > endModel.startTime + endModel.durationTime) {
        return -1;
    }
    if (endModel.startTime - (vModel.startTime + vModel.durationTime) > 0 &&
        endModel.startTime - (vModel.startTime + vModel.durationTime) <= 20 * 60) {
        return end;
    }
    return -1;
}

// 将当前时间字符串 转为 UTCDate
+ (NSTimeInterval )UTCDateFromLocalString2:(NSString *)localString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd"];
    NSDate *date = [dateFormatter dateFromString:localString];
    return [date timeIntervalSince1970];

}

+ (NSString *)valueImageSize:(NSString *)path
{
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    unsigned long long value = [TTCommon fileSizeAtPath:path];
    NSString *tString = [TTCommon imageSizeString:value];

    int index = 0;
    while (value > 1024) {
        value /= 1024.0;
        index ++;
    }
    NSString *str = [NSString stringWithFormat:@"%@%@",tString,typeArray[index]];
    return str;
}

// 文件大小
+ (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//单位转换
+ (NSString *)imageSizeString:(unsigned long long)size{

    if (size >= 1024*1024*1024) {
        return [NSString stringWithFormat:@"%.2f",size/(1024*1024*1024.0)];
    }
    else if (size >= 1024*1024) {
        return [NSString stringWithFormat:@"%.2f",size/(1024*1024.0)];
    }
    else if (size > 1024) {
        return [NSString stringWithFormat:@"%.2f",size/1024.0];
    }
    else {
        return @"";
    }
}

+ (NSString *)getDateFromTimes:(NSTimeInterval)timeInterval
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    NSString *currentDateString = [format stringFromDate:newDate];
    return currentDateString;
}

+ (CGSize)sizeWithText:(NSString *)text maxSize:(CGSize)maxSize;
{
    UIFont *font = [UIFont systemFontOfSize:12];
    NSDictionary *attrs = @{NSFontAttributeName: font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}


@end
