//
//  KHJMutliScreenVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJMutliScreenVC.h"
#import "KHJVideoPlayer_hp_VC.h"
#import "KHJDeviceConfVC.h"



@interface KHJMutliScreenVC ()
{
    // 第一个
    __weak IBOutlet UIButton *oneAddBtn;
    __weak IBOutlet UIView *onePlayerView;
    // 第二个
    __weak IBOutlet UIButton *twoAddBtn;
    __weak IBOutlet UIView *twoPlayerView;
    // 第三个
    __weak IBOutlet UIButton *threeAddBtn;
    __weak IBOutlet UIView *threePlayerView;
    // 第四个
    __weak IBOutlet UIButton *fourAddBtn;
    __weak IBOutlet UIView *fourPlayerView;
}

@end

@implementation KHJMutliScreenVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"视频", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addDeviceBtnAction:(UIButton *)sender
{
    NSInteger index = sender.tag/10 - 1;
    CLog(@"点击添加第几个视频 = %ld",index);
}

- (IBAction)gotoVideoPlayer:(UIButton *)sender
{
    NSInteger index = sender.tag/10 - 1;
    CLog(@"index = %ld",index);
    KHJVideoPlayer_hp_VC *vc = [[KHJVideoPlayer_hp_VC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    if (index == 0) {
        // 第一个
    }
    else if (index == 1) {
        // 第二个
    }
    else if (index == 2) {
        // 第三个
    }
    else if (index == 3) {
        // 第四个
    }
}


/// 语音按钮
- (IBAction)voice:(UIButton *)sender
{
    NSInteger index = sender.tag/10 - 1;
    CLog(@"index = %ld",index);
    sender.selected = !sender.selected;
    if (index == 0) {
        // 第一个
    }
    else if (index == 1) {
        // 第二个
    }
    else if (index == 2) {
        // 第三个
    }
    else if (index == 3) {
        // 第四个
    }
}

- (IBAction)gotoSetup:(UIButton *)sender
{
    NSInteger index = sender.tag/10 - 1;
    CLog(@"index = %ld",index);
    
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"高级配置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJDeviceConfVC *vc = [[KHJDeviceConfVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:KHJLocalizedString(@"删除设备", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertview addAction:cancel];
    [alertview addAction:config];
    [alertview addAction:delete];
    [self presentViewController:alertview animated:YES completion:nil];
}


@end
