//
//  KHJAlarmConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJAlarmConfigVC.h"
#import "KHJPicker.h"

@interface KHJAlarmConfigVC ()
{
    __weak IBOutlet UISwitch *alarmSwitchBtn;
    __weak IBOutlet UIView *alarmTimeView;
    __weak IBOutlet UISwitch *alarmTimeSwitchBtn;
    __weak IBOutlet NSLayoutConstraint *alarmTimeCH;
    __weak IBOutlet UISwitch *alarmPicSwitchBtn;
    __weak IBOutlet UISwitch *alarmVideoSwitchBTN;
    
    __weak IBOutlet UILabel *moveLab;
    __weak IBOutlet UILabel *startTimeLab;
    __weak IBOutlet UILabel *endTimeLab;
}
@end

@implementation KHJAlarmConfigVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerLJWKeyboardHandler];
    self.titleLab.text = KHJLocalizedString(@"alarSet_", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
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
        CLog(@"开始时间");
        KHJPicker *pick = [[KHJPicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-250+44, SCREEN_WIDTH, 324)];
        pick.tKind = 0;
        [pick initSubViews:nil];
        pick.confirmBlock = ^(NSString *strings) {
            self->startTimeLab.text = strings;
        };
    }
    else if (sender.tag == 30) {
        CLog(@"结束时间");
        KHJPicker *pick = [[KHJPicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-250+44, SCREEN_WIDTH, 324)];
        pick.tKind = 0;
        [pick initSubViews:nil];
        pick.confirmBlock = ^(NSString *strings) {
            self->endTimeLab.text = strings;
        };
    }
    else if (sender.tag == 40) {
        CLog(@"取消");
    }
    else if (sender.tag == 50) {
        CLog(@"取消");
    }
}

- (IBAction)alarmBtn:(UISwitch *)sender
{
    if (sender.tag == 10) {
        CLog(@"是否打开移动侦测");
    }
    else if (sender.tag == 20) {
        CLog(@"是否设置报警时间");
        if (sender.on) {
            alarmTimeCH.constant = 88;
            alarmTimeView.hidden = NO;
        }
        else {
            alarmTimeCH.constant = 0;
            alarmTimeView.hidden = YES;
        }
    }
    else if (sender.tag == 30) {
        CLog(@"是否打开报警抓拍");
    }
    else if (sender.tag == 40) {
        CLog(@"是否打开报警录像");
    }
}


- (void)moveAlarmType
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"high1_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:@"1"];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"high0_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:@"2"];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"normal_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:@"3"];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"low4_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:@"4"];
    }];
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"low5_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setAlarmTypeWith:@"5"];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:config3];
    [alertview addAction:config4];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setAlarmTypeWith:(NSString *)level
{
    moveLab.text = level;
}

@end

