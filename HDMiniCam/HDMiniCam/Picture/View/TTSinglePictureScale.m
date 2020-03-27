
#import "TTSinglePictureScale.h"

@interface TTSinglePictureScale()

@end

@implementation TTSinglePictureScale

- (void)setOriginWidth:(CGFloat)originWidth
{
    _originWidth = originWidth;
    self.imageView.frame = CGRectMake(0, 0, _originWidth, _originWidth);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)setOriginHeight:(CGFloat)originHeight
{
    _originHeight = originHeight;
    self.imageView.frame = CGRectMake(0, 0, _originHeight, _originHeight);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces    = NO;
        self.delegate   = self;
        self.imageView      = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.userInteractionEnabled   = YES;
        self.imageView.clipsToBounds            = YES;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat X = 0;
    CGFloat Y = 0;

    X = floorf((self.imageView.frame.size.width - scrollView.zoomScale * _originWidth) / 2.0);
    // Y 大于等于0
    Y = floorf((self.frame.size.height - scrollView.zoomScale * _originHeight) / 2.0) > 0
    ? floorf((self.frame.size.height - scrollView.zoomScale * _originHeight) / 2.0)
    : 0;
    self.imageView.frame = CGRectMake(X,
                                      Y,
                                      scrollView.zoomScale * _originWidth,
                                      scrollView.zoomScale * _originHeight);
    self.contentSize = self.imageView.frame.size;
    if (scrollView.zoomScale < 1)
        self.imageView.center =  CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    TLog(@"Y = %f",Y);
    TLog(@"frame = %@",NSStringFromCGRect(self.frame));
    TLog(@"contentSize = %@",NSStringFromCGSize(self.contentSize));
    TLog(@"self.imageView.frame ================ %@",NSStringFromCGSize(self.imageView.frame.size));
}

- (void)photoBecomeZoomWithScale:(CGFloat)scale
{
    CGFloat X = 0;
    CGFloat Y = 0;
    self.contentSize = CGSizeMake(scale * _originWidth,
                                  scale * _originHeight);
    X = floorf((self.frame.size.width  - scale * _originWidth) / 2.0);
    Y = floorf((self.frame.size.height  - scale * _originHeight) / 2.0);
    self.imageView.frame = CGRectMake(X,
                                      Y,
                                      scale * _originWidth,
                                      scale * _originHeight);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.canScale == YES ? _imageView : nil;
}


@end

