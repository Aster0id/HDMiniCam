//
//  KHJDeviceConfVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJDeviceConfVC.h"
#import "KHJDeviceConfCell.h"
#import "KHJAlarmConfVC_2.h"
#import "KHJWIFIConfigVC.h"
#import "KHJSDCardConfigVC.h"
#import "KHJlampConfigVC.h"
#import "KHJlampConfigVC.h"
#import "KHJTimeZoneConfigVC.h"
#import "KHJChangePasswordVC.h"
#import "TTFirmwareInterface_API.h"

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
    self.titleLab.text = TTLocalString(@"highCfg_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    iconArr = @[TTIMG(@"config_alarm"),
                TTIMG(@"config_wifi"),
                TTIMG(@"config_sd"),
//                TTIMG(@"config_lamp"),
                TTIMG(@"config_time"),
                TTIMG(@"config_changepassword"),
                TTIMG(@"config_restart"),
                TTIMG(@"config_reboot")];
//                TTIMG(@"config_app")];
    titleArr = @[TTLocalString(@"alarCfg_", nil),
                 TTLocalString(@"WiFiConectCfg_", nil),
                 TTLocalString(@"SDCadCfg_", nil),
//                 TTLocalString(@"杂项设置", nil),
                 TTLocalString(@"timeCfg_", nil),
                 TTLocalString(@"chagPwd_", nil),
                 TTLocalString(@"restartDev_", nil),
                 TTLocalString(@"rset_", nil)];
//                 TTLocalString(@"APP密码", nil)];
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
    TTWeakSelf
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
        KHJAlarmConfVC_2 *vc = [[KHJAlarmConfVC_2 alloc] init];
//        vc.deviceInfo = self.deviceInfo;
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
    else if (row == 3) {
        KHJTimeZoneConfigVC *vc = [[KHJTimeZoneConfigVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 4) {
        KHJChangePasswordVC *vc = [[KHJChangePasswordVC alloc] init];
        vc.isFinderPassword = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 5) {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:self.deviceInfo.deviceName message:TTLocalString(@"surestart_", nil) preferredStyle:UIAlertControllerStyleAlert];
        TTWeakSelf
        UIAlertAction *delete = [UIAlertAction actionWithTitle:TTLocalString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TTFirmwareInterface_API sharedManager] rebootDevice_with_deviceID:weakSelf.deviceInfo.deviceID reBlock:^(NSInteger code) {
                [weakSelf.view makeToast:TTLocalString(@"设备已重启", nil)];
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertview addAction:delete];
        [alertview addAction:cancel];
        [self presentViewController:alertview animated:YES completion:nil];
    }
    else if (row == 6) {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:self.deviceInfo.deviceName message:TTLocalString(@"sureSet_", nil) preferredStyle:UIAlertControllerStyleAlert];
        TTWeakSelf
        UIAlertAction *delete = [UIAlertAction actionWithTitle:TTLocalString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TTFirmwareInterface_API sharedManager] resetDevice_with_deviceID:weakSelf.deviceInfo.deviceID reBlock:^(NSInteger code) {
                if (code >= 0) {
                    [weakSelf.view makeToast:TTLocalString(@"正在恢复出厂设置，3秒后将返回设备列表", nil)];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                }
                else {
                    [weakSelf.view makeToast:TTLocalString(@"恢复出厂设置失败", nil)];
                }
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
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
