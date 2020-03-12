//
//  KHJWIFIConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJWIFIConfigVC.h"
#import "KHJWIFIConfigCell.h"
#import "ZQAlterField.h"
#import "KHJDeviceManager.h"

@interface KHJWIFIConfigVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *wifiListArr;
    UIView *back_groundView;
    __weak IBOutlet UILabel *wifiName;
    __weak IBOutlet UITableView *contentTBV;
}

@end

@implementation KHJWIFIConfigVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"wifi设置", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [[KHJDeviceManager sharedManager] getDeviceWiFi_with_deviceID:self.deviceInfo.deviceID resultBlock:^(NSInteger code) {}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGetDeviceWiFi_CmdResult:) name:noti_OnGetDeviceWiFi_CmdResult_KEY object:nil];
}

- (void)OnGetDeviceWiFi_CmdResult:(NSNotification *)noti
{
    NSDictionary *result = (NSDictionary *)noti.object;
    int ret = [result[@"ret"] intValue];
    NSDictionary *body = [NSDictionary dictionaryWithDictionary:result[@"NetWork.Wireless"]];
    if (ret == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->wifiName.text = body[@"SSID"];
        });
        [[KHJDeviceManager sharedManager] searchDeviceWiFi_with_deviceID:self.deviceInfo.deviceID resultBlock:^(NSInteger code) {}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSearchDeviceWiFi_CmdResult:) name:noti_OnSearchDeviceWiFi_CmdResult_KEY object:nil];
    }
    else {
        [self.view makeToast:KHJLocalizedString(@"获取设备Wi-Fi失败！", nil)];
    }
}

- (void)OnSearchDeviceWiFi_CmdResult:(NSNotification *)noti
{
    NSDictionary *result = (NSDictionary *)noti.object;
    int ret = [result[@"ret"] intValue];
    if (ret == 0) {
        wifiListArr = result[@"NetWork.WirelessSearch"][@"Aplist"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *array = [NSMutableArray arrayWithArray:self->wifiListArr];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *body = (NSDictionary *)obj;
                NSString *wifi = body[@"SSID"];
                if ([wifi isEqualToString:self->wifiName.text]) {
                    [array removeObject:body];
                    *stop = YES;
                }
            }];
            self->wifiListArr = [array mutableCopy];
            [self->contentTBV reloadData];
        });
    }
    else {
        [self.view makeToast:KHJLocalizedString(@"获取设备Wi-Fi失败！", nil)];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return wifiListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJWIFIConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJWIFIConfigCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJWIFIConfigCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    WeakSelf
    NSDictionary *body = wifiListArr[indexPath.row];
    cell.block = ^(NSInteger row) {
        CLog(@"row = %ld",(long)row);
        [weakSelf changewifi:body];
    };
    cell.name.text = body[@"SSID"];
    cell.safeLab.text = KHJString(@"安全性：%@",body[@"EncType"]);
    cell.stronglyLab.text = KHJString(@"信号强度：%@",body[@"RSSI"]);
    return cell;
}

- (void)changewifi:(NSDictionary *)body
{
    WeakSelf
    ZQAlterField *alertView = [ZQAlterField alertView];
    alertView.title = KHJString(@"%@%@",KHJLocalizedString(@"更改 Wi-Fi 为：", nil),body[@"SSID"]);
    alertView.placeholder = KHJLocalizedString(@"请输入 Wi-Fi 密码", nil);
    alertView.Maxlength = 50;
    alertView.ensureBgColor = KHJUtility.appMainColor;
    [alertView ensureClickBlock:^(NSString *inputString, int type) {
        CLog(@"输入内容为%@",inputString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf changeConnectWifi:body password:inputString];
        });
    }];
    [alertView show];
}

- (void)changeConnectWifi:(NSDictionary *)body password:(NSString *)password
{
    [[KHJDeviceManager sharedManager] setDeviceWiFi_with_deviceID:self.deviceInfo.deviceID ssid:body[@"SSID"] password:password encType:body[@"EncType"] resultBlock:^(NSInteger code) {}];
    WeakSelf
    [self.view makeToast:KHJLocalizedString(@"正在切换Wi-Fi，请等待重连", nil)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    });
}

@end
