//
//  TTHighConfigViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTHighConfigViewController.h"
#import "TTHighConfigCell.h"
#import "TTWiFiConfigViewController.h"
#import "TTFirmwareInterface_API.h"

@interface TTHighConfigViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
TTHighConfigCellDelegate
>

{
    __weak IBOutlet UITableView *contentTBV;
}

@property (nonatomic, strong) NSMutableArray *icon;
@property (nonatomic, strong) NSMutableArray *name;

@end

@implementation TTHighConfigViewController

- (NSMutableArray *)icon
{
    if (!_icon) {
        _icon = [NSMutableArray array];
        [_icon addObject:@"config_wifi"];
        [_icon addObject:@"config_restart"];
        [_icon addObject:@"config_reboot"];
    }
    return _icon;
}

- (NSMutableArray *)name
{
    if (!_name) {
        _name = [NSMutableArray array];
        [_name addObject:TTLocalString(@"WiFConectConfg_", nil)];
        [_name addObject:TTLocalString(@"reStatDevic_", nil)];
        [_name addObject:TTLocalString(@"resetDevic_", nil)];
    }
    return _name;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeData];
    [self customizeAppearance];
}

- (void)customizeData
{
    self.deviceID = self.deviceInfo.deviceID;
}

- (void)customizeAppearance
{
    self.titleLab.text = TTLocalString(@"tallConfg_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.icon.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTHighConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TTHighConfigCell"];
    if (cell == nil) {
        cell = [[NSBundle  mainBundle] loadNibNamed:@"TTHighConfigCell" owner:nil options:nil][0];
    }
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    cell.lab.text = self.name[indexPath.row];
    cell.imageview.image = TTIMG(self.icon[indexPath.row]);
    return cell;
}

#pragma mark - TTHighConfigCellDelegate

- (void)clickWithCell:(NSInteger)row
{
    if (row == 0) {
        [self gotoWifiConfg];
    }
    else if (row == 1) {
        [self gotoRestartDevice];
    }
    else if (row == 2) {
        [self gotoResetDevice];
    }
}

#pragma mark - Wifi配置

- (void)gotoWifiConfg
{
    TTWiFiConfigViewController *vc = [[TTWiFiConfigViewController alloc] init];
    vc.deviceInfo = self.deviceInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 重启设备

- (void)gotoRestartDevice
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:self.deviceInfo.deviceName message:TTLocalString(@"canyousureRestartDevic_", nil) preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *delete = [UIAlertAction actionWithTitle:TTLocalString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf rebootDevice];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:delete];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)rebootDevice
{
    TTWeakSelf
    [[TTFirmwareInterface_API sharedManager] rebootDevice_with_deviceID:weakSelf.deviceInfo.deviceID reBlock:^(NSInteger code) {
        [weakSelf.view makeToast:TTLocalString(@"设备已重启", nil)];
    }];
}

#pragma mark - 恢复出厂设置

- (void)gotoResetDevice
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:self.deviceInfo.deviceName message:TTLocalString(@"canyousureSetDevic_", nil) preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *delete = [UIAlertAction actionWithTitle:TTLocalString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf resetDevice];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:delete];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)resetDevice
{
    TTWeakSelf
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
}

@end
