//
//  TuyaTimeLineModel.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/13.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "TuyaTimeLineModel.h"

@interface TuyaTimeLineModel ()

@property (nonatomic, assign) NSTimeInterval startTimeIntervalDay;
@property (nonatomic, assign) NSTimeInterval endTimeIntervalDay;

@end

@implementation TuyaTimeLineModel

- (void)setStartDate:(NSString *)startDate
{
    _startDate = startDate;
    NSString *time = KHJString(@"%@ 00:00:00",[_startDate substringWithRange:NSMakeRange(0, 10)]);
    NSDate *date = [self nsstringConversionNSDate:time];
    _startTimeIntervalDay = _startTime - [self dateConversionTimeStamp:date];
}

- (void)setEndDate:(NSString *)endDate
{
    _endDate = endDate;
    NSString *time = KHJString(@"%@ 00:00:00",[_endDate substringWithRange:NSMakeRange(0, 10)]);
    NSDate *date = [self nsstringConversionNSDate:time];
    _endTimeIntervalDay = _endTime - [self dateConversionTimeStamp:date];
}

- (NSTimeInterval)startTimeIntervalSinceCurrentDay
{
    return _startTimeIntervalDay;
}

- (NSTimeInterval)stopTimeIntervalSinceCurrentDay
{
    if (_endTimeIntervalDay == 0) {
        _endTimeIntervalDay = _endTime - _startTime + _startTimeIntervalDay;
    }
    return _endTimeIntervalDay;
}

- (NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}

- (NSInteger)dateConversionTimeStamp:(NSDate *)date
{
    NSInteger timeSp = [KHJString(@"%ld", (long)[date timeIntervalSince1970]) integerValue];
    return timeSp;
}



@end
