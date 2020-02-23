
#import <UIKit/UIKit.h>

@interface AIPhotoZoom : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView * imageView;

//默认是屏幕的宽和高
@property (assign, nonatomic) CGFloat imageNormalWidth; // 图片未缩放时宽度
@property (assign, nonatomic) CGFloat imageNormalHeight; // 图片未缩放时高度
@property (assign, nonatomic) BOOL needScale; // 图片未缩放时高度

- (void)showCover;
- (void)showNoCover;
//缩放方法，共外界调用
- (void)pictureZoomWithScale:(CGFloat)zoomScale;

@end
