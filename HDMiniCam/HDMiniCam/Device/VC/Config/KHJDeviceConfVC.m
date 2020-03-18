//
//  KHJDeviceConfVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDeviceConfVC.h"
#import "KHJDeviceConfCell.h"
#import "KHJAlarmConfigVC.h"
#import "KHJWIFIConfigVC.h"
#import "KHJSDCardConfigVC.h"
#import "KHJlampConfigVC.h"
#import "KHJlampConfigVC.h"
#import "KHJTimeZoneConfigVC.h"
#import "KHJChangePasswordVC.h"

@interface KHJDeviceConfVC ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
    
    NSArray *iconArr;
    NSArray *titleArr;
}
@end

@implementation KHJDeviceConfVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deviceID = self.deviceInfo.deviceID;
    self.titleLab.text = KHJLocalizedString(@"highCfg_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    iconArr = @[KHJIMAGE(@"config_alarm"),
                KHJIMAGE(@"config_wifi"),
                KHJIMAGE(@"config_sd"),
//                KHJIMAGE(@"config_lamp"),
                KHJIMAGE(@"config_time"),
                KHJIMAGE(@"config_changepassword"),
                KHJIMAGE(@"config_restart"),
                KHJIMAGE(@"config_reboot")];
//                KHJIMAGE(@"config_app")];
    titleArr = @[KHJLocalizedString(@"alarCfg_", nil),
                 KHJLocalizedString(@"WiFiConectCfg_", nil),
                 KHJLocalizedString(@"SDCadCfg_", nil),
//                 KHJLocalizedString(@"杂项设置", nil),
                 KHJLocalizedString(@"timeCfg_", nil),
                 KHJLocalizedString(@"chagPwd_", nil),
                 KHJLocalizedString(@"restartDev_", nil),
                 KHJLocalizedString(@"rset_", nil)];
//                 KHJLocalizedString(@"APP密码", nil)];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 22)];
    head.backgroundColor = UIColorFromRGB(0xD5D5D5);
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 22)];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textColor = UIColor.whiteColor;
    lab.text = self.deviceID;
    [head addSubview:lab];
    return head;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return iconArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJDeviceConfCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJDeviceConfCell"];
    if (cell == nil) {
        cell = [[NSBundle  mainBundle] loadNibNamed:@"KHJDeviceConfCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    WeakSelf
    cell.block = ^(NSInteger row) {
        [weakSelf pushTo:row];
    };
    cell.lab.text = titleArr[indexPath.row];
    cell.imageview.image = iconArr[indexPath.row];
    return cell;
}

- (void)pushTo:(NSInteger)row
{
    if (row == 0) {
        KHJAlarmConfigVC *vc = [[KHJAlarmConfigVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 1) {
        KHJWIFIConfigVC *vc = [[KHJWIFIConfigVC alloc] init];
        vc.deviceInfo = self.deviceInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 2) {
        KHJSDCardConfigVC *vc = [[KHJSDCardConfigVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
//    else if (row == 3) {
//        KHJlampConfigVC *vc = [[KHJlampConfigVC alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    else if (row == 3){
        KHJTimeZoneConfigVC *vc = [[KHJTimeZoneConfigVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 4) {
        KHJChangePasswordVC *vc = [[KHJChangePasswordVC alloc] init];
        vc.isFinderPassword = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 5) {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:self.deviceInfo.deviceName message:KHJLocalizedString(@"surestart_", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertview addAction:delete];
        [alertview addAction:cancel];
        [self presentViewController:alertview animated:YES completion:nil];
    }
    else if (row == 6) {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:self.deviceInfo.deviceName message:KHJLocalizedString(@"sureSet_", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertview addAction:delete];
        [alertview addAction:cancel];
        [self presentViewController:alertview animated:YES completion:nil];
    }
//    else if (row == 7) {
//        KHJChangePasswordVC *vc = [[KHJChangePasswordVC alloc] init];
//        vc.isFinderPassword = NO;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}


@end
