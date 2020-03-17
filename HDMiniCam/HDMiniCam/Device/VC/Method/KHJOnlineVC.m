//
//  KHJOnlineVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJOnlineVC.h"
//#import "KHJQRCodeScanVC.h"
//#import "KHJDeviceManager.h"

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
    
    if (_deviceInfo) {
        uid.text = _deviceInfo.deviceID;
        name.text = _deviceInfo.deviceName;
        password.text = _deviceInfo.devicePassword;
    }
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
//    KHJQRCodeScanVC *vc = [[KHJQRCodeScanVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sure:(id)sender
{
    if (name.text.length == 0) {
        [self.view makeToast:KHJLocalizedString(@"请输入设备名称", nil)];
        return;
    }
    if (uid.text.length == 0) {
        [self.view makeToast:KHJLocalizedString(@"请输入设备id", nil)];
        return;
    }
    if (password.text.length == 0) {
        [self.view makeToast:KHJLocalizedString(@"请输入设备密码", nil)];
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
    WeakSelf
    if (!exit) {
        // 未添加的设备：直接添加
        [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                [weakSelf.view makeToast:KHJString(@"%@：\"%@\"，%@",KHJLocalizedString(@"设备", nil),info.deviceID,KHJLocalizedString(@"添加成功", nil))];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:noti_addDevice_KEY object:nil];
                });
            }
        }];
    }
    else {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"提示", nil)
                                                                           message:KHJLocalizedString(@"该设备已经被添加，请问是否再次添加？", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        WeakSelf
        UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 已添加的设备：先删除，再添加
            [[KHJDataBase sharedDataBase] deleteDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
                [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
                    if (code == 1) {
                        [weakSelf.view makeToast:KHJString(@"%@：\"%@\"，%@",KHJLocalizedString(@"设备", nil),info.deviceID,KHJLocalizedString(@"添加成功", nil))];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                            [[NSNotificationCenter defaultCenter] postNotificationName:noti_addDevice_KEY object:nil];
                        });
                    }
                }];
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertview addAction:config];
        [alertview addAction:cancel];
        [self presentViewController:alertview animated:YES completion:nil];
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
