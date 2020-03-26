//
//  KHJAlarmPushSetupVC.m
//  SuperIPC
//
//  Created by kevin on 2020/3/24.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJAlarmPushSetupVC.h"

@interface KHJAlarmPushSetupVC ()
{
    __weak IBOutlet UISwitch *SDCardSBtn;
    __weak IBOutlet UISwitch *FTPPushSBtn;
    __weak IBOutlet UISwitch *MailSBtn;
    __weak IBOutlet UISwitch *APPSBtn;
}

@end

@implementation KHJAlarmPushSetupVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"报警推送设置", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchBtnAction:(UISwitch *)sender
{
    
}


@end
