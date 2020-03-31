//
//  TTWiFiConfigViewController.m
//  SuperIPC
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "TTWiFiConfigViewController.h"
#import "TTWIFIConfigCell.h"
#import "ZQAlterField.h"
#import "TTFirmwareInterface_API.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface TTWiFiConfigViewController ()

<
UITableViewDelegate,
UITableViewDataSource,
TTWIFIConfigCellDelegate
>
{
    UILabel *wifiLab;
}

@property (weak, nonatomic) IBOutlet UIView *hadConnectView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hadConnectCH;
@property (weak, nonatomic) IBOutlet UITableView *ttableView;

@property (nonatomic, strong) NSMutableArray *wifiArray;

@end

@implementation TTWiFiConfigViewController

- (NSMutableArray *)wifiArray
{
    if (!_wifiArray) {
        _wifiArray = [NSMutableArray array];
    }
    return _wifiArray;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *item in ifs) {
        NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
        NSString *wifiName = info[@"SSID"];
        if ([wifiName hasPrefix:@"IPC_"]) {
            self.hadConnectCH.constant = 0;
            self.hadConnectView.hidden = YES;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getDeviceWiFi:)
                                                 name:TT_getDeviceWiFiCmdResult_noti_KEY
                                               object:nil];
}

#pragma mark - 获取到设备当前连接Wi-Fi的通知

- (void)getDeviceWiFi:(NSNotification *)noti
{
    NSDictionary *result = (NSDictionary *)noti.object;
    int ret = [result[@"ret"] intValue];
    NSDictionary *body = [NSDictionary dictionaryWithDictionary:result[@"NetWork.Wireless"]];
    if (ret == 0) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(searchDeviceWiFi:)
                                                     name:TT_getSearchDeviceWiFi_noti_KEY
                                                   object:nil];
        wifiLab.text = TTStr(@"%@  ",body[@"SSID"]);
        NSString *wifiName = self->wifiLab.text;
        TLog(@"wifiName ====== %@",[wifiName substringWithRange:NSMakeRange(0, wifiName.length - 2)]);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[TTFirmwareInterface_API sharedManager] searchDeviceWiFi_with_deviceID:self.deviceInfo.deviceID reBlock:^(NSInteger code) {}];
        });
    }
    else {
        
        
        [self.view makeToast:TTLocalString(@"getDevicWifFaile_", nil)];
    }
}

- (void)customizeDataSource
{
    [[TTFirmwareInterface_API sharedManager] getDeviceWiFi_with_deviceID:self.deviceInfo.deviceID reBlock:^(NSInteger code) {}];
}

- (void)customizeAppearance
{
    self.titleLab.text = TTLocalString(@"devicWif_", nil);
    [[TTHub shareHub] showText:@"" addToView:self.view type:0];
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - 搜索到Wi-Fi列表的通知

- (void)searchDeviceWiFi:(NSNotification *)noti
{
    [TTHub shareHub].hud.hidden = YES;

    NSDictionary *result = (NSDictionary *)noti.object;
    int ret = [result[@"ret"] intValue];
    if (ret == 0) {
        self.wifiArray = result[@"NetWork.WirelessSearch"][@"Aplist"];
        NSString *wifiName = self->wifiLab.text;
        // [wifiName substringWithRange:NSMakeRange(0, wifiName.length - 2)]
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.wifiArray];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *body = (NSDictionary *)obj;
            NSString *wifi = body[@"SSID"];
            if ([wifi isEqualToString:[wifiName substringWithRange:NSMakeRange(0, wifiName.length - 2)]]) {
                [array removeObject:body];
                *stop = YES;
            }
        }];
        self.wifiArray = [array mutableCopy];
        [self.ttableView reloadData];
    }
    else {
        [self.view makeToast:TTLocalString(@"getDevicWifFaile_", nil)];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.wifiArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    headView.backgroundColor = UIColorFromRGB(0xF5F5F5);
    
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 30)];
    lab1.text = TTLocalString(@"已连接Wi-Fi网络", nil);
    lab1.font = [UIFont systemFontOfSize:14];
    [headView addSubview:lab1];
    
    wifiLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 40)];
    wifiLab.font = [UIFont systemFontOfSize:14];
    wifiLab.textAlignment = NSTextAlignmentRight;
    [headView addSubview:wifiLab];
    
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(12, 70, SCREEN_WIDTH - 24, 30)];
    lab2.text = TTLocalString(@"选择需要连接的Wi-Fi网络", nil);
    lab2.font = [UIFont systemFontOfSize:14];
    [headView addSubview:lab2];
    
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TTWIFIConfigCell";
    TTWIFIConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];

    cell.delegate       = self;
    
    cell.tag            = indexPath.row + FLAG_TAG;
    
    NSDictionary *body  = self.wifiArray[indexPath.row];
    
    cell.first.text     = body[@"SSID"];
    
    cell.second.text    = TTStr(@"%@：%@",TTLocalString(@"safty_", nil),body[@"EncType"]);
    
    
    
    cell.third.text     = TTStr(@"%@：%@",TTLocalString(@"singleStrogly_", nil),body[@"RSSI"]);
    
    return cell;

}

#pragma mark - TTWIFIConfigCellDelegate

- (void)chooseWifiWith:(NSInteger)row
{
    [self changewifi:self.wifiArray[row]];
}

- (void)changewifi:(NSDictionary *)body
{
    ZQAlterField *alertView = [ZQAlterField alertView];
    alertView.Maxlength = 50;
    alertView.ensureBgColor = TTCommon.naviViewColor;
    alertView.placeholder = TTLocalString(@"inputWiFiPaswrd_", nil);
    alertView.title = TTStr(@"%@：%@",TTLocalString(@"chageWiFTo_", nil),body[@"SSID"]);
    TTWeakSelf
    [alertView ensureClickBlock:^(NSString *inputString) {
        
        [[TTFirmwareInterface_API sharedManager] setDeviceWiFi_with_deviceID:self.deviceInfo.deviceID
         
                                                                        ssid:body[@"SSID"]
         
                                                                    password:inputString
                                                                     encType:body[@"EncType"]
                                                                    
                                                                     reBlock:^(NSInteger code) {
            TLog(@"调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成");
            TLog(@"调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成");
            TLog(@"调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成");
            TLog(@"调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成调用成功成");
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:TTLocalString(@"chageWifing_waitReConect_", nil)];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
    [alertView show];
}

@end
