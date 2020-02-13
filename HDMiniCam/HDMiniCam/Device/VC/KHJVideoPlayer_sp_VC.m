//
//  KHJVideoPlayer_sp_VC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/12.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayer_sp_VC.h"
#import "KHJVideoPlayer_hp_VC.h"
#import "KHJVideoPlayer_hf_VC.h"
#import "KHJMutliScreenVC.h"

@interface KHJVideoPlayer_sp_VC ()

{
    __weak IBOutlet UIView *playerView;
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIView *bottomView;
    
    __weak IBOutlet UIButton *recordBtn;
    __weak IBOutlet UIButton *qualityBtn;
    
    __weak IBOutlet UIImageView *oneImgView;
    __weak IBOutlet UILabel *oneLab;
    __weak IBOutlet UIImageView *twoImgView;
    __weak IBOutlet UILabel *twoLab;
    __weak IBOutlet UIImageView *threeImgView;
    __weak IBOutlet UILabel *threeLab;
    __weak IBOutlet UIImageView *fourImgView;
    __weak IBOutlet UILabel *fourLab;

    __weak IBOutlet UIImageView *fiveImgView;
    __weak IBOutlet UILabel *fiveLab;

    __weak IBOutlet UIImageView *sixImgView;
    __weak IBOutlet UILabel *sixLab;

    __weak IBOutlet UIImageView *sevenImgView;
    __weak IBOutlet UILabel *sevenLab;

    __weak IBOutlet UIImageView *eightImgView;
    __weak IBOutlet UILabel *eightLab;
}

@property(nonatomic,strong) UIActivityIndicatorView *activIndict;

@end

@implementation KHJVideoPlayer_sp_VC

- (UIActivityIndicatorView *)activIndict
{
    if (!_activIndict) {
        _activIndict = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _activIndict.center = CGPointMake(CGRectGetWidth(playerView.frame)/2.0, CGRectGetHeight(playerView.frame)/2.0);
        [_activIndict startAnimating];
    }
    return _activIndict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [playerView addSubview:self.activIndict];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.activIndict removeFromSuperview];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)topBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender.tag == 20) {
        // 上下控制
    }
    else if (sender.tag == 30) {
        // 左右控制
    }
    else if (sender.tag == 40) {
        // 多屏
        KHJMutliScreenVC *vc = [[KHJMutliScreenVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender.tag == 50) {
        // 预置点
        KHJVideoPlayer_hf_VC *vc = [[KHJVideoPlayer_hf_VC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)fourBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 翻转
        KHJVideoPlayer_hp_VC *vc = [[KHJVideoPlayer_hp_VC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender.tag == 20) {
        // 设置
    }
    else if (sender.tag == 30) {
        // 录像
    }
    else if (sender.tag == 40) {
        // 清晰度
    }
}

- (IBAction)eightBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 第一点
    }
    else if (sender.tag == 20) {
        // 第二点
    }
    else if (sender.tag == 30) {
        // 第三点
    }
    else if (sender.tag == 40) {
        // 第四点
    }
    else if (sender.tag == 50) {
        // 第五点
    }
    else if (sender.tag == 60) {
        // 第六点
    }
    else if (sender.tag == 70) {
        // 第七点
    }
    else if (sender.tag == 80) {
        // 第八点
    }
}

- (IBAction)threeBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 静音
        sender.selected = !sender.selected;
    }
    else if (sender.tag == 20) {
        // 发语音
    }
    else if (sender.tag == 30) {
        // 拍照
    }
}


@end
