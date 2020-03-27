
#import <UIKit/UIKit.h>

@interface TTSinglePictureScale : UIScrollView <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL canScale;


@property (nonatomic, strong) UIImageView * imageView;

@property (assign, nonatomic) CGFloat originWidth;
@property (assign, nonatomic) CGFloat originHeight;

- (void)photoBecomeZoomWithScale:(CGFloat)scale;

@end
