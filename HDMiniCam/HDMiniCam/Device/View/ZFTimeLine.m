//
//  ZFTimeLine.m
//  TimeLineView
//
//  Created by hezewen on 2018/9/3.
//  Copyright © 2018年 zengjia. All rights reserved.
//

#import "ZFTimeLine.h"
#import "KHJVideoModel.h"
#import "NSDate+TTDate.h"

//
#import "TuyaTimeLineModel.h"

@interface ZFTimeLine(){
    float intervalValue;                        //小刻度宽度 默认10
    
    NSDateFormatter *formatterScale;            //时间格式化 用于获取时刻表文字
    NSDateFormatter *formatterProject;          //时间格式化 用于项目同于时间格式转化
    NSDateFormatter *formatterShow;             //时间格式化 用于显示当前时间点

    ScaleType scaleType;                        //时间轴模式
    NSTimeInterval currentInterval;             //中间时刻对应的时间戳
    
    CGPoint moveStart;                          //移动的开始点
    float scaleValue;                           //缩放时记录开始的间距
    
    BOOL onTouch;                               //是否在触摸状态
    UILabel *timeLab;//当前的时间点
    NSTimer *panTimer;
}
@end

@implementation ZFTimeLine

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.alpha = 0.8;
        intervalValue = 20;
        formatterScale = [[NSDateFormatter alloc]init];
        [formatterScale setDateFormat:@"HH:mm"];
        
        formatterProject = [[NSDateFormatter alloc]init];
        [formatterProject setDateFormat:@"yyyyMMddHHmmss"];
        
        formatterShow = [[NSDateFormatter alloc]init];
        [formatterShow setDateFormat:@"HH:mm:ss"];
        
        _timesArr = [NSMutableArray array];
        [self setTimeLab:frame];
        scaleType = ScaleTypeBig;
        currentInterval = [[NSDate date] timeIntervalSince1970];
        self.multipleTouchEnabled = YES;
        onTouch = NO;
        // 缩放手势
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        [self addGestureRecognizer:pinchGestureRecognizer];
//        // 移动手势
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)setTimeLab:(CGRect)frame
{
    timeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 14)];
    timeLab.textColor = [UIColor blackColor];
    timeLab.font = [UIFont systemFontOfSize:14];
    timeLab.textAlignment = NSTextAlignmentCenter;
    timeLab.text = [self getZFCurrentTimes];
    [self addSubview:timeLab];
}

- (void)refreshTimeLabelFrame
{
    timeLab.frame = CGRectMake(0, 0, self.frame.size.width, 14);
}

#pragma mark - 获取当前的时间

- (NSString *)getZFCurrentTimes
{
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatterShow stringFromDate:datenow];
    return currentTimeString;
}

- (void)layoutSubviews
{
    [self setNeedsDisplay];
}

// 处理拖拉手势
- (void)panView:(UIPanGestureRecognizer *)panGest
{
    if (!self.userInteractionEnabled) {
        TLog(@"touchesBegan") ;
        return;
    }
    if (panGest.state == UIGestureRecognizerStateBegan){
       
        if (self.delegate && [self.delegate respondsToSelector:@selector(LineBeginMove)]) {
            [self.delegate LineBeginMove];
        }
        onTouch = YES;
        moveStart =  [panGest locationInView:self];
    }
    else if (panGest.state == UIGestureRecognizerStateChanged ){
       
        CGPoint point = [panGest locationInView:self];
        float x = point.x - moveStart.x;
        if (x > -1 && x < 1) {//d
            return ;
        }
        // 左右临界点判断
        NSTimeInterval ddInt = [NSDate get_todayZeroInterverlWith:currentInterval];
        NSTimeInterval eeInt = [NSDate get_todayZeroInterverlWith:currentInterval]+24*60*60-1;
        
        currentInterval = currentInterval - [self secondsOfIntervalValue] * x;
        moveStart = point;
        NSTimeInterval ccInt = [[NSDate date] timeIntervalSince1970];
        if (currentInterval >= ccInt) {
            // 如果中间位置是当前时间，则禁止继续向后拖动
            currentInterval = [[NSDate date] timeIntervalSince1970];
        }
        
        if (currentInterval <= ddInt) {
            currentInterval = ddInt;
            [self setNeedsDisplay];
            return;
        }
        
        if ((int)currentInterval>=(int)eeInt) {
            currentInterval = eeInt;
            [self setNeedsDisplay];
            return;
        }
        
        float centerX = self.frame.size.width/2.0;
        NSTimeInterval leftInterval = currentInterval - centerX * [self secondsOfIntervalValue];
        NSTimeInterval rightInterval = currentInterval + centerX * [self secondsOfIntervalValue];
        if (leftInterval >= rightInterval) {
            return;
        }
        [self setNeedsDisplay];
    }
    else if (panGest.state == UIGestureRecognizerStateEnded ){
        
        if (!self.userInteractionEnabled) {
            return;
        }
        //延时处理
        if (panTimer) {
            [panTimer invalidate];
            panTimer = nil;
        }
        panTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(upDateVideo) userInfo:nil repeats:NO];
        onTouch = NO;
    }
    NSString *timeStr = [self currentShowTimeStr];
    timeLab.text = timeStr;
}

- (void)upDateVideo
{
    TLog(@"upDateVideo");
    if (!onTouch) {
        NSLog(@"[self currentTimeStr] = %@",[self currentTimeStr]);
        if (self.delegate && [self.delegate respondsToSelector:@selector(timeLine:moveToDate:)]) {
            [self.delegate timeLine:self moveToDate:currentInterval];
        }
    }
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGest
{
    if (!self.userInteractionEnabled) {
        TLog(@"touchesBegan");
        return;
    }
    
    if (pinchGest.state == UIGestureRecognizerStateBegan){
        onTouch = YES;
        scaleValue =  pinchGest.scale* SCREEN_WIDTH/2;
    }
    else if(pinchGest.state == UIGestureRecognizerStateChanged){
        
        float value = pinchGest.scale* SCREEN_WIDTH/2;;//变化位置
        
        intervalValue = intervalValue + (value - scaleValue)/100;
        intervalValue = round(intervalValue);
//        TLog(@"intervalValue = %f",intervalValue);
        if (scaleType == ScaleTypeBig) {
            
            if (scaleValue - value < 0) {//变大
                if (intervalValue >= 40) {
                    scaleType = ScaleTypeSmall;
                    intervalValue = 40;
                }
            }
            else {
                //缩小
//                intervalValue = intervalValue + (value - scaleValue)/100;
                if (intervalValue < 20) {
                    intervalValue = 20;
                }
            }
        }
        else {
//            intervalValue = intervalValue + (value - scaleValue)/100;
            if (scaleValue - value < 0) {//变大
                if (intervalValue >= 40) {
                    intervalValue = 40;
                }
            }
            else {//缩小
//                intervalValue = intervalValue + (value - scaleValue)/100;
                if (intervalValue < 20) {
                    scaleType = ScaleTypeBig;
                    intervalValue = 20;
                }
            }
        }
        [self setNeedsDisplay];
    }
    else if(pinchGest.state == UIGestureRecognizerStateEnded) {
        if (!self.userInteractionEnabled) {
            return;
        }
        onTouch = NO;
    }
}

// 刷新,但不改变时间
- (void)refresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

#pragma mark --- 移动到某时间
// date数据格式举例 20170814121020

- (void)moveToDate:(NSString *)date
{
    if (onTouch || !self.userInteractionEnabled) {
        return;
    }
    currentInterval = [self intervalWithTime:date];
    TLog(@"moveToDate:%@",date);
    [self setNeedsDisplay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeLine:moveToDate:)]) {
        [self.delegate timeLine:self moveToDate:currentInterval];
    }
}

#pragma mark --- 获取时间轴指向的时间

- (NSString *)currentTimeStr
{
    return [self projectTimeWithInterval:currentInterval];
}

- (NSString *)currentShowTimeStr
{
    return [self showTimeWithInterval:currentInterval];
}

// 宽度1所代表的秒数
- (float)secondsOfIntervalValue
{
    if (scaleType == ScaleTypeBig)
        return 6.0*60.0/intervalValue;
    else if (scaleType == ScaleTypeSmall)
        return 60.0/intervalValue;
    return 6.0*60.0/intervalValue;
}

- (float)getIntervalForPoint:(NSTimeInterval)inter
{
    if (scaleType == ScaleTypeBig)
       return  (inter * intervalValue)/(6 * 60.0);
    else if (scaleType == ScaleTypeSmall)
        return (inter * intervalValue)/60.0;
    return  (inter * intervalValue)/(6 * 60.0);
}

- (void)updateTime:(NSTimeInterval)time
{
    currentInterval = time;
    timeLab.text = [self currentShowTimeStr];
}

//更新时间轴
- (void)updateCurrentInterval:(NSTimeInterval)tTime
{
    currentInterval = tTime;
    [self refresh];
}

//绘图
- (void)drawRect:(CGRect)rect
{
    //计算 x = 0时对应的时间戳
    float centerX = rect.size.width/2.0;
    /* 屏幕显示区域，最小的时间戳 */
    NSTimeInterval leftInterval = self->currentInterval - centerX * [self secondsOfIntervalValue];
    /* 屏幕显示区域，最大的世界戳 */
    NSTimeInterval rightInterval = self->currentInterval + centerX * [self secondsOfIntervalValue];
    if (leftInterval >= rightInterval) {
        return;
    }
    CGContextRef contex = UIGraphicsGetCurrentContext();
    if (self.timesArr.count != 0) {
        //数组很大的时候，需要2分查找
        for (KHJVideoModel *tInfo in self.timesArr) {

            NSTimeInterval start = tInfo.startTime;
            NSTimeInterval end = tInfo.startTime + tInfo.durationTime;

            if ((start > leftInterval && start < rightInterval) ||
                (end > leftInterval && end < rightInterval ) ||
                (start < leftInterval && end > rightInterval) ) {
                //计算起始位置对应的x值
                float startX = (start-leftInterval)/[self secondsOfIntervalValue];
                //计算时间长度对应的宽度
                float length = (end - start)/[self secondsOfIntervalValue] + 0.5;
                if (tInfo.recType == 0 || tInfo.recType == 1) {//灰色
                    [self drawColorRect:startX Context:contex length:length withColor:UIColor.lightGrayColor];
                }
                else if(tInfo.recType == 2) {//2移动侦测
                    [self drawColorRect:startX Context:contex length:length withColor:UIColor.orangeColor];
                }
                else if(tInfo.recType == 4) {
                    //4是声音侦测
                    [self drawColorRect:startX Context:contex length:length withColor:TTRGB(0x2a, 0xb9, 0xb7)];
                }
                else if(tInfo.recType ==6 ){
                    //6移动和声音
                    [self drawColorRect:startX Context:contex length:length withColor:UIColor.redColor];
                }
                else {
                    // 人脸人形检测（默认的报警类型）
                    [self drawColorRect:startX Context:contex length:length withColor:UIColor.orangeColor];
                }
            }
            else {
//                TLog(@"时间区域显示不正常！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！");
            }
        }
    }

    //左边第一个刻度对应的x值和时间戳
    float x;
    NSTimeInterval interval;
    if (self->scaleType == ScaleTypeBig) {
        float a = leftInterval/(60.0*6.0);
        interval = (((int)a) + 1) * (60.0 * 6.0);
        x = (interval - leftInterval) / [self secondsOfIntervalValue];
    }
    else {
        float a = leftInterval/(60.0);
        interval = (((int)a) + 1) * (60.0);
        x = (interval - leftInterval) / [self secondsOfIntervalValue];
    }

    //画线
    while (x >= 0 && x <= rect.size.width) {
        int b;
        if (self->scaleType == ScaleTypeBig) {
            b = 60 * 6;
        }
        else {
            b = 60;
        }
        int rem = ((int)interval) % (b * 5);
        if (rem != 0) {//小刻度
            [self drawUpSmallScale:x context:contex height:rect.size.height];
            [self drawDownSmallScale:x context:contex height:rect.size.height];
        }
        else {//大刻度
            [self drawUpBigScale:x context:contex height:rect.size.height];
            [self drawDownBigScale:x context:contex height:rect.size.height];
            [self drawText:x interval:interval context:contex height:rect.size.height];
        }
        x = x + self->intervalValue;
        interval = interval + b;
    }

    [self drawCenterLine:rect.size.width/2 context:contex height:rect.size.height];
    [self drawBottomLine:rect.size.height context:contex width:rect.size.width];
    [self drawTopLine:rect.size.height context:contex width:rect.size.width];

//    NSString *timeStr = [self currentShowTimeStr];
//    self->timeLab.text = timeStr;

//    TTWeakSelf
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        //计算 x = 0时对应的时间戳
//        float centerX = rect.size.width/2.0;
//        /* 屏幕显示区域，最小的时间戳 */
//        NSTimeInterval leftInterval = self->currentInterval - centerX * [weakSelf secondsOfIntervalValue];
//        /* 屏幕显示区域，最大的世界戳 */
//        NSTimeInterval rightInterval = self->currentInterval + centerX * [weakSelf secondsOfIntervalValue];
//        if (leftInterval >= rightInterval) {
//            return;
//        }
//        CGContextRef contex = UIGraphicsGetCurrentContext();
//        if (weakSelf.timesArr.count != 0) {
//            //数组很大的时候，需要2分查找
//            for (KHJVideoModel *tInfo in weakSelf.timesArr) {
//
//                NSTimeInterval start = tInfo.startTime;
//                NSTimeInterval end = tInfo.startTime + tInfo.durationTime;
//
//                if ((start > leftInterval && start < rightInterval) ||
//                    (end > leftInterval && end < rightInterval ) ||
//                    (start < leftInterval && end > rightInterval) ) {
//                    //计算起始位置对应的x值
//                    float startX = (start - leftInterval)/[weakSelf secondsOfIntervalValue];
//                    //计算时间长度对应的宽度
//                    float length = (end - start)/[weakSelf secondsOfIntervalValue] + 0.5;
//                    if (tInfo.recType == 0 || tInfo.recType == 1) {//灰色
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf drawColorRect:startX Context:contex length:length withColor:UIColor.lightGrayColor];
//                        });
//                    }
//                    else if(tInfo.recType == 2) {//2移动侦测
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf drawColorRect:startX Context:contex length:length withColor:UIColor.orangeColor];
//                        });
//                    }
//                    else if(tInfo.recType == 4) {
//                        //4是声音侦测
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf drawColorRect:startX Context:contex length:length withColor:TTRGB(0x2a, 0xb9, 0xb7)];
//                        });
//                    }
//                    else if(tInfo.recType ==6 ){
//                        //6移动和声音
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf drawColorRect:startX Context:contex length:length withColor:UIColor.redColor];
//                        });
//                    }
//                    else {
//                        // 人脸人形检测（默认的报警类型）
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf drawColorRect:startX Context:contex length:length withColor:UIColor.orangeColor];
//                        });
//                    }
//                }
//                else {
//    //                TLog(@"时间区域显示不正常！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！");
//                }
//            }
//        }
//
//        //左边第一个刻度对应的x值和时间戳
//        float x;
//        NSTimeInterval interval;
//        if (self->scaleType == ScaleTypeBig) {
//            float a = leftInterval/(60.0*6.0);
//            interval = (((int)a) + 1) * (60.0 * 6.0);
//            x = (interval - leftInterval) / [self secondsOfIntervalValue];
//        }
//        else {
//            float a = leftInterval/(60.0);
//            interval = (((int)a) + 1) * (60.0);
//            x = (interval - leftInterval) / [self secondsOfIntervalValue];
//        }
//
//        //画线
//        while (x >= 0 && x <= rect.size.width) {
//            int b;
//            if (self->scaleType == ScaleTypeBig) {
//                b = 60 * 6;
//            }
//            else {
//                b = 60;
//            }
//            int rem = ((int)interval) % (b * 5);
//            if (rem != 0) {//小刻度
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf drawUpSmallScale:x context:contex height:rect.size.height];
//                    [weakSelf drawDownSmallScale:x context:contex height:rect.size.height];
//                });
//            }
//            else {//大刻度
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf drawUpBigScale:x context:contex height:rect.size.height];
//                    [weakSelf drawDownBigScale:x context:contex height:rect.size.height];
//                    [weakSelf drawText:x interval:interval context:contex height:rect.size.height];
//                });
//            }
//            x = x + self->intervalValue;
//            interval = interval + b;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf drawCenterLine:rect.size.width/2 context:contex height:rect.size.height];
//            [weakSelf drawBottomLine:rect.size.height context:contex width:rect.size.width];
//            [weakSelf drawTopLine:rect.size.height context:contex width:rect.size.width];
//        });
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString *timeStr = [self currentShowTimeStr];
//            self->timeLab.text = timeStr;
//        });
//    });
}

#pragma mark - 计算0点所在屏幕的位置

- (int)getLeftPointFromZero
{
    float centerX = self.frame.size.width/2.0;
    NSTimeInterval leftInterval = currentInterval - centerX * [self secondsOfIntervalValue];
    NSTimeInterval ddInt2 = [NSDate get_todayZeroInterverlWith:currentInterval];//当前0点时间戳
    
    int bb = 0;
    if (scaleType == ScaleTypeBig) {
        bb = 60 * 6;
    }
    else {
        bb = 60;
    }
    int mm = intervalValue *(ddInt2-leftInterval)/bb;
    return mm;
}

#pragma mark --- 画小刻度

- (void)drawUpSmallScale:(float)x context:(CGContextRef)context height:(float)height
{
    int mm      = [self getLeftPointFromZero];
    CGFloat ff  = [self getNeedWidth];
    
    if (x < mm || (int)x >= (int)ff) {
        return;
    }
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x-0.5, 17);
    CGContextAddLineToPoint(context, x-0.5, 27);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextStrokePath(context);
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int mm = [weakSelf getLeftPointFromZero];
//        CGFloat ff = [weakSelf getNeedWidth];
//
//        if (x < mm || (int)x >= (int)ff) {
//            return;
//        }
//
//        CGContextBeginPath(context);
//        CGContextMoveToPoint(context, x-0.5, 17);
//        CGContextAddLineToPoint(context, x-0.5, 27);
//        CGContextSetLineWidth(context, 1.0);
//        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
//        CGContextStrokePath(context);
//    });
}

- (void)drawDownSmallScale:(float)x context:(CGContextRef)context height:(float)height
{
    int mm = [self getLeftPointFromZero];
    CGFloat ff = [self getNeedWidth];

    if (x < mm || (int)x >= (int)ff) {
        return;
    }
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x-0.5, CGRectGetHeight(self.frame) - 0.9);
    CGContextAddLineToPoint(context, x-0.5, CGRectGetHeight(self.frame) - 10.9);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextStrokePath(context);
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int mm = [weakSelf getLeftPointFromZero];
//        CGFloat ff = [weakSelf getNeedWidth];
//
//        if (x < mm || (int)x >= (int)ff) {
//            return;
//        }
//        CGContextBeginPath(context);
//        CGContextMoveToPoint(context, x-0.5, CGRectGetHeight(self.frame) - 0.9);
//        CGContextAddLineToPoint(context, x-0.5, CGRectGetHeight(self.frame) - 10.9);
//        CGContextSetLineWidth(context, 1.0);
//        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
//        CGContextStrokePath(context);
//    });
}

#pragma mark --- 画大刻度

- (void)drawUpBigScale:(float)x context:(CGContextRef)ctx height:(float)height
{
    int mm = [self getLeftPointFromZero];
    CGFloat ff = [self getNeedWidth];

    if (x < mm || (int)x > (int)ff) {
        return;
    }
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x - 0.5, 17);
    CGContextAddLineToPoint(ctx, x - 0.5, 35);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokePath(ctx);
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int mm = [weakSelf getLeftPointFromZero];
//        CGFloat ff = [weakSelf getNeedWidth];
//
//        if (x < mm || (int)x > (int)ff) {
//            return;
//        }
//        CGContextBeginPath(ctx);
//        CGContextMoveToPoint(ctx, x-0.5, 17);
//        CGContextAddLineToPoint(ctx, x-0.5, 35);
//        CGContextSetLineWidth(ctx, 1.0);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
//        CGContextStrokePath(ctx);
//    });
}

- (void)drawDownBigScale:(float)x context:(CGContextRef)ctx height:(float)height
{
    int mm = [self getLeftPointFromZero];
    CGFloat ff = [self getNeedWidth];
    
    if (x < mm || (int)x > (int)ff) {
        return;
    }
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x-0.5, height - 0.9 - 18);
    CGContextAddLineToPoint(ctx, x-0.5, height - 0.9);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokePath(ctx);
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int mm = [weakSelf getLeftPointFromZero];
//        CGFloat ff = [weakSelf getNeedWidth];
//
//        if (x < mm || (int)x > (int)ff) {
//            return;
//        }
//
//        CGContextBeginPath(ctx);
//        CGContextMoveToPoint(ctx, x-0.5, height - 0.9 - 18);
//        CGContextAddLineToPoint(ctx, x-0.5, height - 0.9);
//        CGContextSetLineWidth(ctx, 1.0);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
//        CGContextStrokePath(ctx);
//    });
}

#pragma mark --- 画中间线

- (void)drawCenterLine:(float)x context:(CGContextRef)ctx height:(float)height
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, x - 0.5, 17);
        CGContextAddLineToPoint(ctx, x - 0.5, height - 0.9);
        CGContextSetLineWidth(ctx, 1.0);
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextStrokePath(ctx);

        CGContextRef upContext = UIGraphicsGetCurrentContext();
        CGPoint sPoints[3];
        sPoints[0] = CGPointMake(x - 5.0 - 0.5, 17);
        sPoints[1] = CGPointMake(x + 5.0 - 0.5, 17);
        sPoints[2] = CGPointMake(x - 0.5, 17 + 5.0);
        
        CGContextSetFillColorWithColor(upContext, [UIColor redColor].CGColor);
        CGContextAddLines(upContext, sPoints, 3);
        CGContextClosePath(upContext);
        CGContextDrawPath(upContext, kCGPathFill);
        
        CGContextRef downContext = UIGraphicsGetCurrentContext();
        CGPoint downPoints[3];
        downPoints[0] = CGPointMake(x - 5.0 - 0.5, height - 0.9);
        downPoints[1] = CGPointMake(x + 5.0 - 0.5, height - 0.9);
        downPoints[2] = CGPointMake(x - 0.5, height - 0.9 - 5.0);
        
        CGContextSetFillColorWithColor(downContext, [UIColor redColor].CGColor);
        CGContextAddLines(downContext, downPoints, 3);
        CGContextClosePath(downContext);
        CGContextDrawPath(downContext, kCGPathFill);
//    });
    
}

#pragma mark - 计算24点所在屏幕的位置

- (int)getRightPointFrom24
{
    float centerX = self.frame.size.width/2;
    //这个1/2屏幕所占的时间戳+当前时间搓 = 右边的时间搓
    NSTimeInterval rightInterval = centerX * [self secondsOfIntervalValue]+currentInterval;
    NSTimeInterval interVal24 = [NSDate get_todayZeroInterverlWith:currentInterval]+24*60*60;
    int bb = 0;
    if (scaleType == ScaleTypeBig) {
        bb = 60 * 6;
    }
    else {
        bb = 60;
    }
    int mm = intervalValue * (interVal24-rightInterval)/bb;
    return mm;
}

- (CGFloat)getNeedWidth
{
    float centerX = self.frame.size.width/2.0;
    NSTimeInterval leftInterval = currentInterval - centerX * [self secondsOfIntervalValue];
    NSTimeInterval interVal24 = [NSDate get_todayZeroInterverlWith:currentInterval]+24*60*60;
    CGFloat ff = [self getIntervalForPoint:(interVal24 -leftInterval)];
    return ff;
}

#pragma mark --- 画底部横线
- (void)drawBottomLine:(float)y context:(CGContextRef)ctx width:(float)width
{
    int nn = [self getRightPointFrom24];
    int mm = [self getLeftPointFromZero];

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, mm, CGRectGetHeight(self.frame) - 0.9);
    if(nn >= 0) {
        CGContextAddLineToPoint(ctx, width, CGRectGetHeight(self.frame) - 0.9);
    }
    else {
        CGFloat ff = [self getNeedWidth];
        CGContextAddLineToPoint(ctx, ff, CGRectGetHeight(self.frame) - 0.9);
    }
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokePath(ctx);
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int nn = [weakSelf getRightPointFrom24];
//        int mm = [weakSelf getLeftPointFromZero];
//
//        CGContextBeginPath(ctx);
//        CGContextMoveToPoint(ctx, mm, CGRectGetHeight(weakSelf.frame) - 0.9);
//        if(nn >= 0) {
//            CGContextAddLineToPoint(ctx, width, CGRectGetHeight(weakSelf.frame) - 0.9);
//        }
//        else {
//            CGFloat ff = [weakSelf getNeedWidth];
//            CGContextAddLineToPoint(ctx, ff, CGRectGetHeight(weakSelf.frame) - 0.9);
//        }
//        CGContextSetLineWidth(ctx, 1.0);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
//        CGContextStrokePath(ctx);
//    });
}

#pragma mark --- 画顶部横线
- (void)drawTopLine:(float)y context:(CGContextRef)ctx width:(float)width
{
    int nn = [self getRightPointFrom24];
    int mm = [self getLeftPointFromZero];
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, mm, 17);
    if (nn >= 0) {
        CGContextAddLineToPoint(ctx, width, 17);
    }
    else {
        CGFloat ff = [self getNeedWidth];
        CGContextAddLineToPoint(ctx, ff, 17);
    }
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokePath(ctx);
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int nn = [weakSelf getRightPointFrom24];
//        int mm = [weakSelf getLeftPointFromZero];
//
//        CGContextBeginPath(ctx);
//        CGContextMoveToPoint(ctx, mm, 17);
//        if (nn >= 0) {
//            CGContextAddLineToPoint(ctx, width, 17);
//        }
//        else {
//            CGFloat ff = [weakSelf getNeedWidth];
//            CGContextAddLineToPoint(ctx, ff, 17);
//        }
//        CGContextSetLineWidth(ctx, 1.0);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
//        CGContextStrokePath(ctx);
//    });
}

#pragma mark --> 在刻度上标记文本

- (void)drawText:(float)x interval:(NSTimeInterval)interval context:(CGContextRef)ctx height:(float)height
{
    int mm      = [self getLeftPointFromZero];
    CGFloat ff  = [self getNeedWidth];

    if (x < mm || (int)x > (int)ff) {
        return;
    }
    NSString *text = nil;
    if ((int)x == (int)ff){
        text = @"23:59";
    }
    else {
        text = [self timeWithInterval:interval];
    }
    CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:12.f];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.alignment = NSTextAlignmentCenter;
    [text drawInRect:CGRectMake(x - 17, height/2.0, 34, 12)
      withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor blueColor],NSParagraphStyleAttributeName:paragraph}];
//    TTWeakSelf
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int mm = [weakSelf getLeftPointFromZero];
//        CGFloat ff = [weakSelf getNeedWidth];
//
//        if (x < mm || (int)x > (int)ff) {
//            return;
//        }
//        NSString *text = nil;
//        if ((int)x == (int)ff){
//            text = @"23:59";
//        }
//        else {
//            text = [weakSelf timeWithInterval:interval];
//        }
//        CGContextSetRGBFillColor(ctx, 1, 0, 0, 1);
//        UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:12.f];
//        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
//        paragraph.alignment = NSTextAlignmentCenter;
//        [text drawInRect:CGRectMake(x - 17, height/2.0, 34, 12)
//          withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor blueColor],NSParagraphStyleAttributeName:paragraph}];
//    });
}

#pragma mark --- 时间戳转 显示的时刻文字
- (NSString *)timeWithInterval:(NSTimeInterval)interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [formatterScale stringFromDate:date];
}

#pragma mark --- 文字转时间戳
- (NSTimeInterval)intervalWithTime:(NSString *)time
{
    NSDate *date = [formatterProject dateFromString:time];
    return [date timeIntervalSince1970];
}

#pragma mark --- 时间戳转 当前的时间 格式举例: 2080814122034
- (NSString *)projectTimeWithInterval:(NSTimeInterval)interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [formatterProject stringFromDate:date];
}

#pragma mark --- 时间戳转 当前的时间 格式举例:12:20:34
- (NSString *)showTimeWithInterval:(NSTimeInterval)interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [formatterShow stringFromDate:date];
}

#pragma mark --- 绿色色块
- (void)drawColorRect:(float)x Context:(CGContextRef)ctx length:(float)length withColor:(UIColor *)mColor
{
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x, 17);
    CGContextAddLineToPoint(ctx, x+length, 17);
    CGContextAddLineToPoint(ctx, x+length,CGRectGetHeight(self.frame) - 0.9);
    CGContextAddLineToPoint(ctx, x, CGRectGetHeight(self.frame) - 0.9);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, mColor.CGColor);
    CGContextFillPath(ctx);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CGContextBeginPath(ctx);
//        CGContextMoveToPoint(ctx, x, 17);
//        CGContextAddLineToPoint(ctx, x+length, 17);
//        CGContextAddLineToPoint(ctx, x+length,CGRectGetHeight(self.frame) - 0.9);
//        CGContextAddLineToPoint(ctx, x, CGRectGetHeight(self.frame) - 0.9);
//        CGContextClosePath(ctx);
//        CGContextSetFillColorWithColor(ctx, mColor.CGColor);
//        CGContextFillPath(ctx);
//    });
}

#pragma mark --- 红色色块
- (void)drawRedRect:(float)x Context:(CGContextRef)ctx length:(float)length
{
    CGContextBeginPath(ctx);
    CGFloat y = self.frame.size.height;
    CGContextMoveToPoint(ctx, x, 16);
    CGContextAddLineToPoint(ctx, x+length, 16);
    CGContextAddLineToPoint(ctx, x+length,y- 27.0);
    CGContextAddLineToPoint(ctx, x, y -27.0);
    CGContextClosePath(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:233.0/255.0 green:64.0/255.0 blue:73.0/255.0 alpha:1.0].CGColor);
    CGContextFillPath(ctx);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CGContextBeginPath(ctx);
//        CGFloat y = self.frame.size.height;
//        CGContextMoveToPoint(ctx, x, 16);
//        CGContextAddLineToPoint(ctx, x+length, 16);
//        CGContextAddLineToPoint(ctx, x+length,y- 27.0);
//        CGContextAddLineToPoint(ctx, x, y -27.0);
//        CGContextClosePath(ctx);
//        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:233.0/255.0 green:64.0/255.0 blue:73.0/255.0 alpha:1.0].CGColor);
//        CGContextFillPath(ctx);
//    });
}

@end













