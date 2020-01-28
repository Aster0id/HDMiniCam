//
//  KHJSDCardConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJSDCardConfigVC.h"

@interface KHJSDCardConfigVC ()
{
    __weak IBOutlet UILabel *sdCard;
    __weak IBOutlet UILabel *fenBianLv;
    __weak IBOutlet UITextField *fileSize;
    __weak IBOutlet UISwitch *recordSBtn;
    __weak IBOutlet UIView *timeView;
    
}
@end

@implementation KHJSDCardConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerLJWKeyboardHandler];
    timeView.layer.borderWidth = 1;
    timeView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    self.titleLab.text = KHJLocalizedString(@"录像设置", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn:(UIButton *)sender
{
    if (sender.tag == 10) {
        CLog(@"分辨率");
        [self addFenBianLv];
    }
    else if (sender.tag == 20) {
        CLog(@"确定");
    }
    else if (sender.tag == 30) {
        CLog(@"取消");
    }
    else if (sender.tag == 40) {
        CLog(@"格式化");
    }
}

- (void)addFenBianLv
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"title", nil)
                                                                       message:KHJLocalizedString(@"分辨率", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"1080P", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:1];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"720P", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:2];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setAlarmTypeWith:(NSInteger)tag
{
    if (tag == 1) {
        CLog(@"1080P");
    }
    else if (tag == 2) {
        CLog(@"720P");
    }
}

- (IBAction)sbtn:(id)sender
{
    CLog(@"循环录像");
}

@end
