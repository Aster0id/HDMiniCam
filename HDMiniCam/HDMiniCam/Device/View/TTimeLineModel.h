//
//  TTimeLineModel.h
//  SuperIPC
//
//  Created by kevin on 2020/2/13.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTimeLineModel : NSObject

#pragma mark - 开始时间戳
@property(nonatomic,assign) NSTimeInterval TT_startStamp;
#pragma mark - model 时长
@property(nonatomic,assign) int TT_durationStamp;
#pragma mark - 0 正常  2 移动  4 声音
@property(nonatomic,assign) int TT_dataType;

@end




























