//
//  ZFTimeLine.h
//  TimeLineView
//
//  Created by hezewen on 2018/9/3.
//  Copyright © 2018年 zengjia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ScaleTypeBig,           //大
    ScaleTypeSmall          //小
}ScaleType;                 //时间轴模式

@class ZFTimeLine;

@protocol ZFTimeLineDelegate <NSObject>

- (void)timeLine:(ZFTimeLine *)timeLine moveToDate:(NSTimeInterval)date;

- (void)LineBeginMove;

@end

@interface ZFTimeLine : UIView

@property (nonatomic, assign) id<ZFTimeLineDelegate> delegate;
@property (nonatomic,copy) NSMutableArray *timesArr;
@property (nonatomic,assign) BOOL isSDDataSource;

#pragma mark --- 获取时间轴指向的时间
- (void)updateTime:(NSTimeInterval)time;
//更新时间轴
- (void)updateCurrentInterval:(NSTimeInterval)tTime;
//横竖屏切换
- (void)refreshTimeLabelFrame;

@end






