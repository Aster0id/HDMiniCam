//
//  KHJOnlineVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJOnlineVC.h"
#import "KHJQRCodeScanVC.h"

@interface KHJOnlineVC ()
{
    __weak IBOutlet UITextField *name;
    __weak IBOutlet UIView *nameView;
    __weak IBOutlet UITextField *uid;
    __weak IBOutlet UIView *uidView;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UIView *passwordView;

    
}
@end

@implementation KHJOnlineVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addlayer];
    [self registerLJWKeyboardHandler];
    
    
    NSArray *deviceList = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    CLog(@"deviceList = %@",deviceList);
    
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchNet:(id)sender
{
    
}

- (IBAction)qr:(id)sender
{
    // 二维码扫描
    KHJQRCodeScanVC *vc = [[KHJQRCodeScanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sure:(id)sender
{
    if (name.text.length == 0) {
        [self.view makeToast:@"请输入设备名称"];
        return;
    }
    if (uid.text.length == 0) {
        [self.view makeToast:@"请输入设备id"];
        return;
    }
    if (password.text.length == 0) {
        [self.view makeToast:@"请输入设备密码"];
        return;
    }
    KHJDeviceInfo *deviceInfo = [[KHJDeviceInfo alloc] init];
    deviceInfo.deviceID = uid.text;
    deviceInfo.deviceName = name.text;
    deviceInfo.devicePassword = password.text;
    
    NSArray *deviceList = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    CLog(@"deviceList = %@",deviceList);
    
    __block BOOL exit = NO;
    [deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
        if ([info.deviceID isEqualToString:uid.text]) {
            exit = YES;
        }
    }];

    if (!exit) {
        [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewDevice_NOTI" object:nil];
                [self.view makeToast:KHJString(@"设备：\"%@\"，添加成功",deviceInfo.deviceID)];
            }
        }];
    }
    else {
        [[KHJDataBase sharedDataBase] updateDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewDevice_NOTI" object:nil];
                [self.view makeToast:KHJString(@"设备：\"%@\"，添加成功",deviceInfo.deviceID)];
            }
        }];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addlayer
{
    uidView.layer.borderWidth = 1;
    uidView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    nameView.layer.borderWidth = 1;
    nameView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    passwordView.layer.borderWidth = 1;
    passwordView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    self.titleLab.text = KHJLocalizedString(@"添加已联网设备", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

@end
