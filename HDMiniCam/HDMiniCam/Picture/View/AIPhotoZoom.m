
#import "AIPhotoZoom.h"

@interface AIPhotoZoom()
{
    UIImageView *pImgView;
}
@end

@implementation AIPhotoZoom

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageNormalHeight = frame.size.height;
        _imageNormalWidth = frame.size.width;
        [self anisdnaisnia];
        
        [self panisdnaisndai:frame];
        [self panisdnaisndal:frame];
        
    }
    return self;
}

- (void)anisdnaisnia
{

    self.delegate = self;
    self.minimumZoomScale = 1.0f;
    self.maximumZoomScale = 3.0f;

}

- (void)panisdnaisndai:(CGRect)frame
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.imageView.userInteractionEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.imageView.clipsToBounds = YES;
    self.bounces = NO;
    [self addSubview:self.imageView];
}

- (void)panisdnaisndal:(CGRect)frame
{
    pImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    pImgView.image = KHJIMAGE(@"play_icon");

    [self addSubview:pImgView];
    pImgView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    pImgView.hidden = YES;
}

//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.needScale) {
        return self.imageView;
    }
    return nil;
}
#pragma mark -- Help Methods

- (void)pictureZoomWithScale:(CGFloat)zoomScale
{
    // 延中心点缩放
    CGFloat imageScaleWidth = zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = zoomScale * self.imageNormalHeight;
    self.contentSize = CGSizeMake( imageScaleWidth, imageScaleHeight);
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
}

#pragma mark -- Setter

- (void)setImageNormalWidth:(CGFloat)imageNormalWidth
{
    _imageNormalWidth = imageNormalWidth;
    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)setImageNormalHeight:(CGFloat)imageNormalHeight
{
    _imageNormalHeight = imageNormalHeight;
    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}



//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat imageScaleWidth = scrollView.zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = scrollView.zoomScale * (self.imageNormalHeight);
    
    self.contentSize = CGSizeMake( imageScaleWidth, imageScaleHeight+64*(scrollView.zoomScale-1)/2);
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    imageX = floorf((self.imageView.frame.size.width - imageScaleWidth) / 2.0);
    imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0 +(44)*(scrollView.zoomScale-1));
    
    self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    if (scrollView.zoomScale < 1) {
        self.imageView.center =  CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}



- (void)showCover
{
    pImgView.hidden = NO;
}

- (void)showNoCover
{
    pImgView.hidden = YES;
}


@end

