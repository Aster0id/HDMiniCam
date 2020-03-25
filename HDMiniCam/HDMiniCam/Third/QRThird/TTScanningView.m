
#import "TTScanningView.h"

#define borderWidth 0.7 * self.frame.size.width
#define borderX 0.5 * (1 - 0.7) * self.frame.size.width
#define borderY 0.5 * (self.frame.size.height - borderWidth)

@interface TTScanningView ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *scanningline;
@end

@implementation TTScanningView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self INTINTINT];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self INTINTINT];
}

- (void)INTINTINT
{
    _scanningAnimationStyle = ScanningAnimationStyleDefault;
    _borderColor = [UIColor whiteColor];
    _cornerLocation = CornerLoactionDefault;
    _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _cornerWidth = 2.0;
    _backgroundAlpha = 0.5;
    _animationTimeInterval = 0.02;
    _scanningImageName = @"SGQRCode.bundle/QRCodeScanningLine";
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(borderX, borderY, borderWidth, borderWidth);
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGFloat borderW = borderWidth;
    CGFloat borderH = borderW;
    CGFloat borderLineW = 0.2;

    [[[UIColor blackColor] colorWithAlphaComponent:self.backgroundAlpha] setFill];
    UIRectFill(rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX + 0.5 * borderLineW, borderY + 0.5 *borderLineW, borderW - borderLineW, borderH - borderLineW)];
    [bezierPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX, borderY, borderW, borderH)];
    borderPath.lineCapStyle = kCGLineCapButt;
    borderPath.lineWidth = borderLineW;
    [self.borderColor set];
    [borderPath stroke];
    
    
    CGFloat cornerLenght = 20;
    UIBezierPath *leftTopPath = [UIBezierPath bezierPath];
    leftTopPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    CGFloat insideExcess = fabs(0.5 * (self.cornerWidth - borderLineW));
    CGFloat outsideExcess = 0.5 * (borderLineW + self.cornerWidth);
    if (self.cornerLocation == CornerLoactionInside) {
        [leftTopPath moveToPoint:CGPointMake(borderX + insideExcess, borderY + cornerLenght + insideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + insideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght + insideExcess, borderY + insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [leftTopPath moveToPoint:CGPointMake(borderX - outsideExcess, borderY + cornerLenght - outsideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY - outsideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght - outsideExcess, borderY - outsideExcess)];
    } else {
        [leftTopPath moveToPoint:CGPointMake(borderX, borderY + cornerLenght)];
        [leftTopPath addLineToPoint:CGPointMake(borderX, borderY)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght, borderY)];
    }

    [leftTopPath stroke];
    
    UIBezierPath *leftBottomPath = [UIBezierPath bezierPath];
    leftBottomPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside) {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght + insideExcess, borderY + borderH - insideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + borderH - insideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + borderH - cornerLenght - insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght - outsideExcess, borderY + borderH + outsideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY + borderH + outsideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY + borderH - cornerLenght + outsideExcess)];
    } else {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght, borderY + borderH)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX, borderY + borderH)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX, borderY + borderH - cornerLenght)];
    }

    [leftBottomPath stroke];
    
    UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
    rightTopPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside) {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght - insideExcess, borderY + insideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + insideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + cornerLenght + insideExcess)];
    }
    else if (self.cornerLocation == CornerLoactionOutside) {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght + outsideExcess, borderY - outsideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY - outsideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + cornerLenght - outsideExcess)];
    }
    else {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght, borderY)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW, borderY)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW, borderY + cornerLenght)];
    }

    [rightTopPath stroke];
    
    UIBezierPath *rightBottomPath = [UIBezierPath bezierPath];
    rightBottomPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside) {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + borderH - cornerLenght - insideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + borderH - insideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght - insideExcess, borderY + borderH - insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + borderH - cornerLenght + outsideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + borderH + outsideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght + outsideExcess, borderY + borderH + outsideExcess)];
    } else {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW, borderY + borderH - cornerLenght)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW, borderY + borderH)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght, borderY + borderH)];
    }

    [rightBottomPath stroke];
}

#pragma mark - - - 添加定时器

- (void)addTimer
{
    CGFloat scanninglineX = 0;
    CGFloat scanninglineY = 0;
    CGFloat scanninglineW = 0;
    CGFloat scanninglineH = 0;
    if (self.scanningAnimationStyle == ScanningAnimationStyleGrid) {
        [self addSubview:self.contentView];
        [_contentView addSubview:self.scanningline];
        scanninglineW = borderWidth;
        scanninglineH = borderWidth;
        scanninglineX = 0;
        scanninglineY = - borderWidth;
        _scanningline.frame = CGRectMake(scanninglineX, scanninglineY, scanninglineW, scanninglineH);

    } else {
        [self addSubview:self.scanningline];

        scanninglineW = borderWidth;
        scanninglineH = 12;
        scanninglineX = borderX;
        scanninglineY = borderY;
        _scanningline.frame = CGRectMake(scanninglineX, scanninglineY, scanninglineW, scanninglineH);
    }
    self.timer = [NSTimer timerWithTimeInterval:self.animationTimeInterval target:self selector:@selector(beginRefreshUI) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
#pragma mark - - - 移除定时器
- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self.scanningline removeFromSuperview];
    self.scanningline = nil;
}
#pragma mark - - - 执行定时器方法
- (void)beginRefreshUI {
    __block CGRect frame = _scanningline.frame;
    static BOOL flag = YES;

    if (self.scanningAnimationStyle == ScanningAnimationStyleGrid) {
        if (flag) {
            frame.origin.y = - borderWidth;
            flag = NO;
            [UIView animateWithDuration:self.animationTimeInterval animations:^{
                frame.origin.y += 2;
                _scanningline.frame = frame;
            } completion:nil];
        } else {
            if (_scanningline.frame.origin.y >= - borderWidth) {
                CGFloat scanContent_MaxY = - borderWidth + self.frame.size.width - 2 * borderX;
                if (_scanningline.frame.origin.y >= scanContent_MaxY) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        frame.origin.y = - borderWidth;
                        _scanningline.frame = frame;
                        flag = YES;
                    });
                } else {
                    [UIView animateWithDuration:self.animationTimeInterval animations:^{
                        frame.origin.y += 2;
                        _scanningline.frame = frame;
                    } completion:nil];
                }
            } else {
                flag = !flag;
            }
        }
    } else {
        if (flag) {
            frame.origin.y = borderY;
            flag = NO;
            [UIView animateWithDuration:self.animationTimeInterval animations:^{
                frame.origin.y += 2;
                _scanningline.frame = frame;
            } completion:nil];
        } else {
            if (_scanningline.frame.origin.y >= borderY) {
                CGFloat scanContent_MaxY = borderY + self.frame.size.width - 2 * borderX;
                if (_scanningline.frame.origin.y >= scanContent_MaxY - 10) {
                    frame.origin.y = borderY;
                    _scanningline.frame = frame;
                    flag = YES;
                } else {
                    [UIView animateWithDuration:self.animationTimeInterval animations:^{
                        frame.origin.y += 2;
                        _scanningline.frame = frame;
                    } completion:nil];
                }
            } else {
                flag = !flag;
            }
        }
    }
}

- (UIImageView *)scanningline {
    if (!_scanningline) {
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = [UIImage imageNamed:self.scanningImageName];
    }
    return _scanningline;
}

#pragma mark - - - set
- (void)setScanningAnimationStyle:(ScanningAnimationStyle)scanningAnimationStyle {
    _scanningAnimationStyle = scanningAnimationStyle;
}

- (void)setScanningImageName:(NSString *)scanningImageName {
    _scanningImageName = scanningImageName;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
}

- (void)setCornerLocation:(CornerLoaction)cornerLocation {
    _cornerLocation = cornerLocation;
}

- (void)setCornerColor:(UIColor *)cornerColor {
    _cornerColor = cornerColor;
}

- (void)setCornerWidth:(CGFloat)cornerWidth {
    _cornerWidth = cornerWidth;
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    _backgroundAlpha = backgroundAlpha;
}

- (void)setAnimationTimeInterval:(NSTimeInterval)animationTimeInterval {
    _animationTimeInterval = animationTimeInterval;
}


@end

