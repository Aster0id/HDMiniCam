//
//  TYCameraTimeLineScrollView.m
//  TYCameraBussinessLibrary
//
//  Created by 傅浪 on 2018/9/22.
//

#import "TYCameraTimeLineScrollView.h"

#define SECS_DAY 86400
#define SCALE_STEP 0.15
#define OriginHeight 20

@interface TYCameraTimeLineScrollView ()

{
    NSInteger longHeight;
    NSInteger shortHeight;
    NSDateFormatter *formatterShow;
}

@property (nonatomic, strong) UILabel *timeLab;

@property (nonatomic, strong) NSArray *timeUnits;

@property (nonatomic, assign) NSInteger secsPerUnit;

@end

@implementation TYCameraTimeLineScrollView

- (UILabel *)timeLab
{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - 50, 0, 100, OriginHeight)];
        _timeLab.font = [UIFont systemFontOfSize:14];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLab];
    }
    return _timeLab;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        formatterShow = [[NSDateFormatter alloc]init];
        [formatterShow setDateFormat:@"HH:mm:ss"];
        
        _displayLayer = [[TYAsyncDisplayLayer alloc] init];
        _displayLayer.displayDelegate = self;
        [self.layer addSublayer:_displayLayer];
        _secsPerUnit = 600;
        _markLineColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
        _viewWidth = CGRectGetWidth(frame);
        longHeight = 20;
        shortHeight = 12;
        _contentHeight = CGRectGetHeight(frame) - OriginHeight;
        _timeStringTop = _contentHeight/2.0 - 6 + OriginHeight;
        
        _gradientColors = @[(__bridge id)UIColor.lightGrayColor.CGColor];
        [self updateContentWidth];
        
        _timeBarHeight = 0;
        
        _measureLine = [[UIView alloc] initWithFrame:CGRectZero];
        _measureLine.backgroundColor = UIColor.redColor;
        
        [self addSubview:_measureLine];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [self addGestureRecognizer:pinchGesture];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _viewWidth = CGRectGetWidth(self.frame);
    _contentHeight = CGRectGetHeight(self.frame) - self.timeBarHeight;
    [self updateContentWidth];
    
    _displayLayer.bounds = self.bounds;
    _displayLayer.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2);
    [_displayLayer setNeedsDisplay];
    
    _measureLine.frame = CGRectMake(CGRectGetWidth(self.frame)/2 - 0.5, OriginHeight, 1, _contentHeight - OriginHeight);
}

- (void)asyncDisplayLayer:(TYAsyncDisplayLayer *)layer drawRect:(CGRect)rect inContext:(CGContextRef)ctx isCancelled:(BOOL (^)(void))isCancelled
{
    // 背景颜色
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *gradientColors = @[(__bridge id)UIColorFromRGB_alpha(0xffffff, 1).CGColor];
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, locations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, OriginHeight), CGPointMake(0, rect.size.height), 0);
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
            CGFloat width = (sourceModel.stopTimeIntervalSinceCurrentDay - sourceModel.startTimeIntervalSinceCurrentDay) / _secsPerUnit * _spacePerUnit;
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, rect.size.height - _contentHeight, width, _contentHeight)];
            CGPoint startPoint  = CGPointMake((x + width)/2, rect.size.height - _contentHeight + OriginHeight);
            CGPoint endPoint    = CGPointMake((x + width)/2, rect.size.height);
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
    CGFloat lineY = OriginHeight;
    while (lineX < _viewWidth) {
        CGContextMoveToPoint(ctx, lineX, lineY);
        CGContextAddLineToPoint(ctx, lineX, longHeight + lineY);
        NSTimeInterval timeInterval = numOfLine * _secsPerUnit;
        NSString *timeString = [self ty_timeString:timeInterval];
        [timeString drawAtPoint:CGPointMake(lineX - 12, _timeStringTop) withAttributes:self.timeStringAttributes];
        numOfLine ++;
        lineX += _spacePerUnit;
    }
    CGContextSetLineWidth(ctx, 1);
    [self.markLineColor setStroke];
    CGContextStrokePath(ctx);
    
    numOfLine = ceil((_offset - _viewWidth / 2) / _spacePerUnit);
    lineX = numOfLine * _spacePerUnit + _viewWidth / 2 - _offset;
    lineY = rect.size.height - longHeight;
    while (lineX < _viewWidth) {
        CGContextMoveToPoint(ctx, lineX, lineY);
        CGContextAddLineToPoint(ctx, lineX, rect.size.height);
        lineX += _spacePerUnit;
    }
    CGContextSetLineWidth(ctx, 1);
    [self.markLineColor setStroke];
    CGContextStrokePath(ctx);
    
    if (isCancelled() || !self.showShortLine) { return; }
    // 时间刻度，短刻度线
    CGFloat space = self.spacePerUnit / 5;
    lineX = ceil((_offset - _viewWidth / 2) / space) * space;
    lineY = OriginHeight;
    while (lineX < _viewWidth + _offset) {
        if ((int)round(lineX / space) % 5 != 0) {
            CGContextMoveToPoint(ctx, lineX - _offset + _viewWidth / 2, lineY);
            CGContextAddLineToPoint(ctx, lineX - _offset + _viewWidth / 2, shortHeight + lineY);
        }
        lineX += space;
    }
    CGContextStrokePath(ctx);
    
    // 时间刻度，短刻度线
    lineX = ceil((_offset - _viewWidth / 2) / space) * space;
    lineY = rect.size.height - shortHeight;
    while (lineX < _viewWidth + _offset) {
        if ((int)round(lineX / space) % 5 != 0) {
            CGContextMoveToPoint(ctx, lineX - _offset + _viewWidth / 2, lineY);
            CGContextAddLineToPoint(ctx, lineX - _offset + _viewWidth / 2, rect.size.height);
        }
        lineX += space;
    }
    CGContextStrokePath(ctx);
    
    // 时间刻度，短刻度线
    CGContextMoveToPoint(ctx, 0, OriginHeight);
    CGContextAddLineToPoint(ctx, _viewWidth, OriginHeight);
    CGContextStrokePath(ctx);
    CGContextMoveToPoint(ctx, 0, _contentHeight);
    CGContextAddLineToPoint(ctx, _viewWidth, _contentHeight);
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

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    TLog(@"currentTime ========= %f",currentTime);
    self.timeLab.text = [self showTimeWithInterval:currentTime + self.zeroTime];
    TLog(@"self.timeLab.text ========= %@",self.timeLab.text);
    _currentTime = currentTime;
    _offset = _currentTime / _secsPerUnit * _spacePerUnit;
    [_displayLayer setNeedsDisplay];
}

- (NSString *)showTimeWithInterval:(NSTimeInterval)interval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [formatterShow stringFromDate:date];
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
    NSTimeInterval min = (_offset - _viewWidth / 2) / _spacePerUnit * _secsPerUnit;
    NSTimeInterval max = (_offset + _viewWidth / 2) / _spacePerUnit * _secsPerUnit;
    NSInteger startIndex = -1;
    NSInteger endIndex = -1;
    
    for (NSInteger i = 0; i < self.sourceModels.count; i++) {
        id<TYCameraTimeLineViewSource> sourceModel = [self.sourceModels objectAtIndex:i];
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
            NSForegroundColorAttributeName: [UIColor blueColor]
//            NSForegroundColorAttributeName: UIColorFromRGB(0x99A0B4)
            };
    }
    return _timeStringAttributes;
}

@end
