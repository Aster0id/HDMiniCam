//
//  TYCameraTimeLineScrollView_old.h
//  TYCameraBussinessLibrary
//
//  Created by 傅浪 on 2018/9/22.
//

#import <UIKit/UIKit.h>
#import "TYCameraTimeLineViewSource.h"
#import "TYAsyncDisplayLayer.h"

@class TYCameraTimeLineScrollView_old, TYAsyncDisplayLayer;

@protocol TYCameraTimeLineScrollView_oldDelegate <NSObject>

@optional

- (void)timeLineViewWillBeginDraging:(TYCameraTimeLineScrollView_old *)timeLineView;

- (void)timeLineViewDidEndDraging:(TYCameraTimeLineScrollView_old *)timeLineView;

- (void)timeLineView:(TYCameraTimeLineScrollView_old *)timeLineView didEndScrollingAtTime:(NSTimeInterval)timeInterval inSource:(id<TYCameraTimeLineViewSource>)source;

- (void)timeLineViewNeedPreviousDaySources:(TYCameraTimeLineScrollView_old *)timeLineView;

- (void)timeLineViewNeedNextDaySources:(TYCameraTimeLineScrollView_old *)timeLineView;

@end

@interface TYCameraTimeLineScrollView_old : UIView <TYAsyncDisplayLayerDelegate> {
    @protected
    TYAsyncDisplayLayer *_displayLayer;
    CGFloat _contentWidth;
    CGFloat _contentHeight;
    CGFloat _viewWidth;
    CGFloat _offset;
    UIView *_measureLine;
}

@property (nonatomic, assign) CGFloat spacePerUnit;

@property (nonatomic, strong) UIColor *markLineColor;

@property (nonatomic, strong) NSArray *gradientColors;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) CGFloat timeBarHeight;

@property (nonatomic, assign) CGFloat timeStringTop;

@property (nonatomic, assign) BOOL prevDayLimit;

@property (nonatomic, assign) BOOL nextDayLimit;

@property (nonatomic, assign) BOOL showShortLine;

@property (nonatomic, strong) NSArray<id<TYCameraTimeLineViewSource>> *sourceModels;

@property (nonatomic, weak) id<TYCameraTimeLineScrollView_oldDelegate> delegate;

@property (nonatomic, strong) NSDictionary *timeStringAttributes;

- (void)scrollToTime:(NSTimeInterval)time animated:(BOOL)animated;

@end
