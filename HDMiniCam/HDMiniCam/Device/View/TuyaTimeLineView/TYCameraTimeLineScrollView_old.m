//
//  TYCameraTimeLineScrollView_old.m
//  TYCameraBussinessLibrary
//
//  Created by 傅浪 on 2018/9/22.
//

#import "TYCameraTimeLineScrollView_old.h"

#define SECS_DAY 86400
#define SCALE_STEP 0.15

@interface TYCameraTimeLineScrollView_old ()

@property (nonatomic, strong) NSArray *timeUnits;

@property (nonatomic, assign) NSInteger secsPerUnit;

@end

@implementation TYCameraTimeLineScrollView_old

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _displayLayer = [[TYAsyncDisplayLayer alloc] init];
        _displayLayer.displayDelegate = self;
        [self.layer addSublayer:_displayLayer];
        _secsPerUnit = 600;
        _markLineColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _viewWidth = CGRectGetWidth(frame);
        _contentHeight = CGRectGetHeight(frame);
        _timeStringTop = _contentHeight - 12;
        
        _gradientColors = @[(__bridge id)UIColorFromRGB_alpha(0x4F67EE, 0.3).CGColor, (__bridge id)UIColorFromRGB_alpha(0x4D68FF, 0.04).CGColor];
        [self updateContentWidth];
        
        _measureLine = [[UIView alloc] initWithFrame:CGRectZero];
        _measureLine.backgroundColor = UIColorFromRGB(0x516AEE);
        
        [self addSubview:_measureLine];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [self addGestureRecognizer:pinchGesture];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _viewWidth = CGRectGetWidth(self.frame);
    _contentHeight = CGRectGetHeight(self.frame) - self.timeBarHeight;
    [self updateContentWidth];
    
    _displayLayer.bounds = self.bounds;
    _displayLayer.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
    [_displayLayer setNeedsDisplay];
    
    _measureLine.frame = CGRectMake(CGRectGetWidth(self.frame)/2-0.5, self.timeBarHeight, 1, _contentHeight);
}

- (void)asyncDisplayLayer:(TYAsyncDisplayLayer *)layer drawRect:(CGRect)rect inContext:(CGContextRef)ctx isCancelled:(BOOL (^)(void))isCancelled
{
    // 背景颜色
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *gradientColors = @[(__bridge id)UIColorFromRGB(0x1D1D1D).CGColor, (__bridge id)UIColorFromRGB(0x000000).CGColor];
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, locations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    if (isCancelled()) { return; }
    // 时间片段
    NSRange showRange = [self rangeOfDisplayedSources];
    if (showRange.length > 0) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = {0.0, 1.0};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)self.gradientColors, locations);
        for (NSInteger i = showRange.location; i < showRange.location + showRange.length; i++) {
            if (isCancelled()) { return; }
            id<TYCameraTimeLineViewSource> sourceModel = self.sourceModels[i];
            CGFloat x = sourceModel.startTimeIntervalSinceCurrentDay / _secsPerUnit * _spacePerUnit + _viewWidth / 2 - _offset;
//            CLog(@"++++++++++++++++++++++++++++++   x = %f",x);
            CGFloat width = (sourceModel.stopTimeIntervalSinceCurrentDay - sourceModel.startTimeIntervalSinceCurrentDay) / _secsPerUnit * _spacePerUnit;
//            CLog(@"++++++++++++++++++++++++++++++   sourceModel.stopTimeIntervalSinceCurrentDay = %f",sourceModel.stopTimeIntervalSinceCurrentDay);
//            CLog(@"++++++++++++++++++++++++++++++   sourceModel.startTimeIntervalSinceCurrentDay = %f",sourceModel.startTimeIntervalSinceCurrentDay);
//            CLog(@"++++++++++++++++++++++++++++++   _secsPerUnit = %ld",(long)_secsPerUnit);
//            CLog(@"++++++++++++++++++++++++++++++   _spacePerUnit = %f",_spacePerUnit);
//            CLog(@"++++++++++++++++++++++++++++++   width = %f",width);
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, rect.size.height - _contentHeight, width, _contentHeight)];
            CGPoint startPoint = CGPointMake((x+width)/2, rect.size.height - _contentHeight);
//            CLog(@"++++++++++++++++++++++++++++++   startPoint.x = %f, startPoint.y = %f",startPoint.x,startPoint.y);
            CGPoint endPoint = CGPointMake((x+width)/2, rect.size.height);
//            CLog(@"++++++++++++++++++++++++++++++   endPoint.x = %f, endPoint.y = %f",endPoint.x,endPoint.y);
            CGContextSaveGState(ctx); {
                CGContextAddPath(ctx, bezierPath.CGPath);
                CGContextClip(ctx);
                CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
            } CGContextRestoreGState(ctx);
        }
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
    }
    if (isCancelled()) { return; }
    // 时间刻度，长刻度线
    CGFloat numOfLine = ceil((_offset - _viewWidth / 2) / _spacePerUnit);
    CGFloat lineX = numOfLine * _spacePerUnit + _viewWidth / 2 - _offset;
    CGFloat lineY = rect.size.height - _contentHeight;
    while (lineX < _viewWidth) {
        CGContextMoveToPoint(ctx, lineX, lineY);
        CGContextAddLineToPoint(ctx, lineX, rect.size.height);
        NSTimeInterval timeInterval = numOfLine * _secsPerUnit;
        NSString *timeString = [self ty_timeString:timeInterval];
        [timeString drawAtPoint:CGPointMake(lineX-12, _timeStringTop) withAttributes:self.timeStringAttributes];
        numOfLine ++;
        lineX += _spacePerUnit;
    }
    CGContextSetLineWidth(ctx, 1);
    [self.markLineColor setStroke];
    CGContextStrokePath(ctx);
    
    if (isCancelled() || !self.showShortLine) { return; }
    // 时间刻度，短刻度线
    CGFloat space = self.spacePerUnit / 5;
    lineX = ceil((_offset - _viewWidth / 2) / space) * space;
    lineY = _contentHeight / 4 + _timeBarHeight;
    while (lineX < _viewWidth + _offset) {
        if ((int)round(lineX / space) % 5 != 0) {
            CGContextMoveToPoint(ctx, lineX-_offset+_viewWidth / 2, lineY);
            CGContextAddLineToPoint(ctx, lineX-_offset+_viewWidth / 2, rect.size.height - _contentHeight / 4);
        }
        lineX += space;
    }
    CGContextStrokePath(ctx);
}

#pragma mark - Public

- (void)setSecsPerUnit:(NSInteger)secsPerUnit {
    _secsPerUnit = secsPerUnit;
    [self updateContentWidth];
    [_displayLayer setNeedsDisplay];
}

- (void)setSpacePerUnit:(CGFloat)spacePerUnit {
    _spacePerUnit = spacePerUnit;
    [self updateContentWidth];
    [_displayLayer setNeedsDisplay];
}

- (void)setGradientColors:(NSArray *)gradientColors {
    _gradientColors = gradientColors;
    [_displayLayer setNeedsDisplay];
}

- (void)setSourceModels:(NSArray<id<TYCameraTimeLineViewSource>> *)sourceModels {
    _sourceModels = sourceModels;
    [_displayLayer setNeedsDisplay];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    _offset = _currentTime / _secsPerUnit * _spacePerUnit;
    [_displayLayer setNeedsDisplay];
}

- (void)scrollToTime:(NSTimeInterval)time animated:(BOOL)animated {
    _currentTime = time;
    [_displayLayer setNeedsDisplay];
}

#pragma mark - getsture action

- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer
{
    static BOOL couldChange = YES;
    if (recognizer.state != UIGestureRecognizerStateBegan && recognizer.state != UIGestureRecognizerStateChanged) {
        couldChange = YES;
        return;
    }
    
    if (!couldChange) { return; }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        couldChange = NO;
    }
    
    if (recognizer.scale < 1) {
        if (_secsPerUnit == 60) {
            _secsPerUnit = 600;
        }else if (_secsPerUnit == 600) {
            _secsPerUnit = 3600;
        }else if (_secsPerUnit == 3600) {
            return;
        }
    }
    if (recognizer.scale > 1) {
        if (_secsPerUnit == 3600) {
            _secsPerUnit = 600;
        }else if (_secsPerUnit == 600) {
            _secsPerUnit = 60;
        }else if (_secsPerUnit == 60) {
            return;
        }
    }
    [self updateContentWidth];
    [self setCurrentTime:self.currentTime];
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onScrollEnd) object:nil];
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.delegate respondsToSelector:@selector(timeLineViewWillBeginDraging:)]) {
                [self.delegate timeLineViewWillBeginDraging:self];
            }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            if ([self.delegate respondsToSelector:@selector(timeLineViewDidEndDraging:)]) {
                [self.delegate timeLineViewDidEndDraging:self];
            }
        default:
            break;
    }
    CGPoint translation = [recognizer translationInView:self];
    [recognizer setTranslation:CGPointZero inView:self];
    
    CGFloat offset = _offset-translation.x;
    
    if (offset < 0) {
        if (self.prevDayLimit) {
            offset = 0;
        }else {
            self.offset = _contentWidth;
            if ([self.delegate respondsToSelector:@selector(timeLineViewNeedPreviousDaySources:)]) {
                [self.delegate timeLineViewNeedPreviousDaySources:self];
            }
            return;
        }
    }else if (_offset > _contentWidth) {
        if (self.nextDayLimit) {
            offset = _contentWidth;
        }else {
            self.offset = 0;
            if ([self.delegate respondsToSelector:@selector(timeLineViewNeedNextDaySources:)]) {
                [self.delegate timeLineViewNeedNextDaySources:self];
            }
            return;
        }
    }
    
    [self setOffset:offset];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(onScrollEnd) withObject:nil afterDelay:1];
    }
}

- (void)onScrollEnd {
    if ([self.delegate respondsToSelector:@selector(timeLineView:didEndScrollingAtTime:inSource:)]) {
        BOOL isFind = NO;
        NSInteger index = [self indexForSelectedSourceModeFromIndex:0 to:self.sourceModels.count - 1 isFind:&isFind];
        if (isFind) {
            [self.delegate timeLineView:self
                  didEndScrollingAtTime:_currentTime
                               inSource:self.sourceModels[index]];
        }else if (index >= 0 && index < self.sourceModels.count) {
            id<TYCameraTimeLineViewSource> source = self.sourceModels[index];
            [self.delegate timeLineView:self didEndScrollingAtTime:source.startTimeIntervalSinceCurrentDay inSource:source];
        } else {
            [self.delegate timeLineView:self didEndScrollingAtTime:_currentTime inSource:nil];
        }
    }
}

#pragma mark - Private

- (NSString *)ty_timeString:(NSTimeInterval)timeInterval {
    int time = (int)timeInterval % SECS_DAY;
    if (time < 0) {
        time = SECS_DAY + time;
    }
    int hour = time / 3600;
    int minu = time / 60 % 60;
    return [NSString stringWithFormat:@"%02d:%02d", hour, minu];
}

#pragma mark - search

- (NSRange)rangeOfDisplayedSources
{
    CLog(@"___rangeOfDisplayedSources___");
    NSTimeInterval min = (_offset - _viewWidth / 2) / _spacePerUnit * _secsPerUnit;
    NSTimeInterval max = (_offset + _viewWidth / 2) / _spacePerUnit * _secsPerUnit;
    NSInteger startIndex = -1;
    NSInteger endIndex = -1;
    
    for (NSInteger i = 0; i < self.sourceModels.count; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CLog(@"self.sourceModels.count = %lu",(unsigned long)self.sourceModels.count);
        });
        id<TYCameraTimeLineViewSource> sourceModel = [self.sourceModels objectAtIndex:i];
//        CLog(@"min = %f",min);
//        CLog(@"max = %f",max);
//        CLog(@"sourceModel.stopTimeIntervalSinceCurrentDay = %f",sourceModel.stopTimeIntervalSinceCurrentDay);
        CLog(@"sourceModel.startTimeIntervalSinceCurrentDay = %f",sourceModel.startTimeIntervalSinceCurrentDay);
        if (sourceModel.stopTimeIntervalSinceCurrentDay > min && sourceModel.startTimeIntervalSinceCurrentDay < max) {
            startIndex = i;
            break;
        }
        if (sourceModel.startTimeIntervalSinceCurrentDay > max) {
            break;
        }
    }
    if (startIndex == -1) {
        return NSMakeRange(0, 0);
    }
    for (NSInteger i = startIndex+1; i < self.sourceModels.count; i++) {
        id<TYCameraTimeLineViewSource> sourceModel = [self.sourceModels objectAtIndex:i];
        if (sourceModel.startTimeIntervalSinceCurrentDay > max) {
            endIndex = i;
            break;
        }
    }
    if (endIndex == -1) {
        endIndex = self.sourceModels.count;
    }
    return NSMakeRange(startIndex, endIndex - startIndex);
    
}

- (NSInteger)indexForSelectedSourceModeFromIndex:(NSInteger)from to:(NSInteger)to isFind:(BOOL *)isFind{
    if (to < from) {
        *isFind = NO;
        return from;
    }
    NSInteger target = (from + to) / 2;
    id<TYCameraTimeLineViewSource> sourceModel = [self.sourceModels objectAtIndex:target];
    if (sourceModel.startTimeIntervalSinceCurrentDay > _currentTime) {
        return [self indexForSelectedSourceModeFromIndex:from to:target - 1 isFind:isFind];
    }else if (sourceModel.stopTimeIntervalSinceCurrentDay < _currentTime) {
        return [self indexForSelectedSourceModeFromIndex:target + 1 to:to isFind:isFind];
    }else {
        *isFind = YES;
        return target;
    }
}

- (BOOL)shouldShowSource:(id<TYCameraTimeLineViewSource>)source {
    CGFloat startX = source.startTimeIntervalSinceCurrentDay / _secsPerUnit * _spacePerUnit;
    CGFloat stopX = source.stopTimeIntervalSinceCurrentDay / _secsPerUnit * _spacePerUnit;
    if (stopX <= _offset) {
        return NO;
    }
    if (startX >= _offset+_viewWidth) {
        return NO;
    }
    return YES;
}

#pragma mark - Accessor

- (NSArray *)timeUnits {
    return @[@(60), @(600), @(3600)];
}

- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    _currentTime = _offset / _spacePerUnit * _secsPerUnit;
    [_displayLayer setNeedsDisplay];
}

- (void)updateContentWidth {
    _contentWidth = (SECS_DAY / _secsPerUnit) * _spacePerUnit;
}

- (NSDictionary *)timeStringAttributes {
    if (!_timeStringAttributes) {
        _timeStringAttributes = @{
            NSFontAttributeName: [UIFont systemFontOfSize:9],
            NSForegroundColorAttributeName: UIColorFromRGB(0x99A0B4)
            };
    }
    return _timeStringAttributes;
}

@end
