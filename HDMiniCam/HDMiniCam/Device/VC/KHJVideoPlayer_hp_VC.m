//
//  KHJVideoPlayerVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayer_hp_VC.h"

@interface KHJVideoPlayer_hp_VC ()

@end

@implementation KHJVideoPlayer_hp_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"视频", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}
- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
