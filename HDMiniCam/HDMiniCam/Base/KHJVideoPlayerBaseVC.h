//
//  KHJVideoPlayerBaseVC.h
//  HDMiniCam
//
//  Created by kevin on 2020/2/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>
// 监听/对讲
#import "XBAudioUnitPlayer.h"
#import "XBAudioUnitRecorder.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^onVideoImageBlock)(UIImage *image, CGSize imageSize);

@interface KHJVideoPlayerBaseVC : UIViewController

@property (nonatomic, copy) NSString *sp_deviceID;
- (void)sp_releaseDecoder;

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UILabel  *titleLab;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *right_leftBtn;
@property (nonatomic, strong) onVideoImageBlock imageBlock;

// 初始化多屏解码器
@property (nonatomic, assign) BOOL initMutliDecorder;

@end

NS_ASSUME_NONNULL_END
