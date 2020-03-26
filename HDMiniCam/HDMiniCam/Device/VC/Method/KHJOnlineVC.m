//
//  KHJOnlineVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJOnlineVC.h"
//#import "KHJQRCodeScanVC.h"
//#import "TTFirmwareInterface_API.h"

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
        [self.view makeToast:KHJLocalizedString(@"inputDevName_", nil)];
        return;
    }
    if (uid.text.length == 0) {
        [self.view makeToast:KHJLocalizedString(@"inputDevID_", nil)];
        return;
    }
    if (password.text.length == 0) {
        [self.view makeToast:KHJLocalizedString(@"inputDevPwd", nil)];
        return;
    }
    KHJDeviceInfo *deviceInfo = [[KHJDeviceInfo alloc] init];
    deviceInfo.deviceID = uid.text;
    deviceInfo.deviceName = name.text;
    deviceInfo.devicePassword = password.text;
    
    NSArray *deviceList = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    TLog(@"deviceList = %@",deviceList);
    
    __block BOOL exit = NO;
    [deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
        if ([info.deviceID isEqualToString:uid.text]) {
            exit = YES;
        }
    }];
    TTWeakSelf
    if (!exit) {
        // 未添加的设备：直接添加
        [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo reBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                [weakSelf.view makeToast:KHJString(@"%@：\"%@\"，%@",KHJLocalizedString(@"dev", nil),info.deviceID,KHJLocalizedString(@"addSuc_", nil))];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TT_addDevice_noti_KEY object:nil];
                });
            }
        }];
    }
    else {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips_", nil)
                                                                           message:KHJLocalizedString(@"reAdd_", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        TTWeakSelf
        UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 已添加的设备：先删除，再添加
            [[KHJDataBase sharedDataBase] deleteDeviceInfo_with_deviceInfo:deviceInfo reBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
                [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo reBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
                    if (code == 1) {
                        [weakSelf.view makeToast:KHJString(@"%@：\"%@\"，%@",KHJLocalizedString(@"dev", nil),info.deviceID,KHJLocalizedString(@"addSuc_", nil))];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                            [[NSNotificationCenter defaultCenter] postNotificationName:TT_addDevice_noti_KEY object:nil];
                        });
                    }
                }];
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
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
    self.titleLab.text = KHJLocalizedString(@"addHadAdd_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

@end
