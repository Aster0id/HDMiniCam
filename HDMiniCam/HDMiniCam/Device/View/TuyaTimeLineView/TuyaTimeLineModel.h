//
//  TuyaTimeLineModel.h
//  SuperIPC
//
//  Created by kevin on 2020/2/13.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "TYCameraTimeLineViewSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface TuyaTimeLineModel : NSObject
// <TYCameraTimeLineViewSource>

@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;

/*
 视频类型
 0,1 全天录制           UIColor.lightGrayColor
 2   移动录制           UIColor.orangeColor
 4   声音录制           ssRGB(0x2a, 0xb9, 0xb7)
 6   移动 和 声音录制    UIColor.redColor
 */
@property (nonatomic, assign) int recType;

@end

NS_ASSUME_NONNULL_END
