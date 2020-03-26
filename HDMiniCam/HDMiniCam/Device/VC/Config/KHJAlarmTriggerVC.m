//
//  KHJAlarmTriggerVC.m
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJAlarmTriggerVC.h"

@interface KHJAlarmTriggerVC ()

{
    // 报警抓拍
    __weak IBOutlet UISwitch *alarmOpenSB;              // 报警抓拍
    __weak IBOutlet UILabel *zpNumberLab;               // 抓拍数量
    __weak IBOutlet UIStackView *alarmStackView;
    __weak IBOutlet NSLayoutConstraint *alarmStackViewCH;
    // 报警录像
    __weak IBOutlet UISwitch *alarmRecordSB;            // 报警录像开关
    __weak IBOutlet UILabel *alarmDurationLab;          // 报警录像时长
    __weak IBOutlet UIView *alarmDurationView;          // 报警时长View
    __weak IBOutlet NSLayoutConstraint *alarmDurationViewCH;
    __weak IBOutlet UISwitch *alarmPreRecordSB;         // 报警预录像开关
    __weak IBOutlet UIView *alarmPreRecordView;         // 预录像时长View
    __weak IBOutlet UILabel *alarmPreRecordDurationLab; // 报警预录像时长
    __weak IBOutlet NSLayoutConstraint *alarmPreRecordViewCH;
    // 文字推送
    __weak IBOutlet UISwitch *wordPushSB;               // 文字推送
}

@end

@implementation KHJAlarmTriggerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    wordPushSB.transform = CGAffineTransformMakeScale(0.8, 0.8);
    alarmOpenSB.transform = CGAffineTransformMakeScale(0.8, 0.8);
    alarmRecordSB.transform = CGAffineTransformMakeScale(0.8, 0.8);
    alarmPreRecordSB.transform = CGAffineTransformMakeScale(0.8, 0.8);

    self.titleLab.text = KHJLocalizedString(@"报警触发设置", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchBtnAction:(UISwitch *)sender
{
    if (sender.tag == 10) {
        // 报警抓拍
        if (sender.on) {
            alarmStackViewCH.constant = 80;
            alarmStackView.hidden = NO;
        }
        else {
            alarmStackViewCH.constant = 0;
            alarmStackView.hidden = YES;
        }
    }
    else if (sender.tag == 20) {
        // 报警录像
        if (sender.on) {
            alarmDurationViewCH.constant = 40;
            alarmDurationView.hidden = NO;
        }
        else {
            alarmDurationViewCH.constant = 0;
            alarmDurationView.hidden = YES;
        }
    }
    else if (sender.tag == 30) {
        // 报警预录
        if (sender.on) {
            alarmPreRecordViewCH.constant = 40;
            alarmPreRecordView.hidden = NO;
        }
        else {
            alarmPreRecordViewCH.constant = 0;
            alarmPreRecordView.hidden = YES;
        }
    }
    else if (sender.tag == 40) {
        // app 文字推送
    }
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 确定
    }
    else if (sender.tag == 20) {
        // 取消
    }
    else if (sender.tag == 101) {
        // 抓拍数量
    }
    else if (sender.tag == 102) {
        // 推送设置
    }
    else if (sender.tag == 103) {
        // 报警时长
    }
    else if (sender.tag == 104) {
        // 预录像时长
    }
    else if (sender.tag == 105) {
        // 推送设置
    }
}

@end
