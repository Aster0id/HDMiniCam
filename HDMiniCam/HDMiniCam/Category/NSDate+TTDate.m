//
//  NSDate+TTDate.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "NSDate+TTDate.h"

@implementation NSDate (TTDate)

+ (NSTimeInterval)get_todayZeroInterverlWith:(NSTimeInterval)timeInterval
{
    NSDate *originalDate            = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFomater    = [[NSDateFormatter alloc]init];
    dateFomater.dateFormat  = @"yyyy_MM_dd";
    NSString *original      = [dateFomater stringFromDate:originalDate];
    NSDate *ZeroDate        = [dateFomater dateFromString:original];
    return [ZeroDate timeIntervalSince1970];
}


@end
