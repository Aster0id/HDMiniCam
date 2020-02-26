//
//  KHJVideoPlayerBaseVC.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^onVideoImageBlock)(UIImage *image, CGSize imageSize);

@interface KHJVideoPlayerBaseVC : UIViewController

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UILabel  *titleLab;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *right_leftBtn;
@property (nonatomic, strong) onVideoImageBlock imageBlock;

@end

NS_ASSUME_NONNULL_END
