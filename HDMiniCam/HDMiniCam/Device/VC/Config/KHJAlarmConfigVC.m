//
//  KHJAlarmConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJAlarmConfigVC.h"

@interface KHJAlarmConfigVC ()
{
    __weak IBOutlet UILabel *moveLab;
    __weak IBOutlet UISwitch *alarmDayliy;
    __weak IBOutlet UITextField *alarmTime;
    __weak IBOutlet UIView *alarmTimeView;
    __weak IBOutlet UILabel *alarmTime2;
    __weak IBOutlet UISwitch *alarmPush;
    __weak IBOutlet UISwitch *OSD;
    
}
@end

@implementation KHJAlarmConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerLJWKeyboardHandler];
    self.titleLab.text = KHJLocalizedString(@"报警设置", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    alarmTimeView.layer.borderWidth = 1;
    alarmTimeView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moveAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        CLog(@"移动侦测灵敏度");
        [self moveAlarmType];
    }
    else if (sender.tag == 20) {
        CLog(@"报警时间间隔");
    }
    else if (sender.tag == 30) {
        CLog(@"确定");
    }
    else if (sender.tag == 40) {
        CLog(@"取消");
    }
}

- (IBAction)alarmDayliy:(UIButton *)sender
{
    if (sender.tag == 10) {
        CLog(@"报警时间日程");
    }
    else if (sender.tag == 20) {
        CLog(@"报警推送消息");
    }
    else if (sender.tag == 30) {
        CLog(@"OSD显示");
    }
}

- (void)moveAlarmType
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"1-最高", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:1];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"2-高", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:3];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"3-普通", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:4];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"4-低", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:5];
    }];
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"5-最低", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:7];
    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"关闭移动侦测", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:FLAG_TAG];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:config3];
    [alertview addAction:config4];
    [alertview addAction:config5];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setAlarmTypeWith:(NSInteger)level
{
    if (level == FLAG_TAG) {
        CLog(@"关闭移动侦测");
    }
    else {
        CLog(@"选择级别");
    }
}

@end
