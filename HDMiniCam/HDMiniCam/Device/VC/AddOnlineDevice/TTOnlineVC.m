//
//  TTOnlineVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTOnlineVC.h"

@interface TTOnlineVC ()
{
    __weak IBOutlet UIView *nameView;
    __weak IBOutlet UIView *uidView;
    __weak IBOutlet UIView *passwordView;
}

@property (weak, nonatomic) IBOutlet UITextField *deviceTF;
@property (weak, nonatomic) IBOutlet UITextField *nickTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation TTOnlineVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    [self TT_register_kBoard_Handler];
}

- (void)customizeAppearance
{
    self.titleLab.text = TTLocalString(@"addHadAdd_", nil);
    nameView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    _deviceTF.text = self.deviceInfo.deviceID;
    _nickTF.text = self.deviceInfo.deviceName;
    _pwdTextField.text = self.deviceInfo.devicePassword;
    passwordView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
    [self.leftBtn addTarget:self action:@selector(baction) forControlEvents:UIControlEventTouchUpInside];
    uidView.layer.borderColor = UIColorFromRGB(0xF5F5F5).CGColor;
}

- (void)baction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sure:(id)sender
{
    [self checkParams];
    
    NSArray *allDeviceList = [[TTDataBase shareDB] getAllDeviceInfo];

    __block BOOL exit = NO;
    TTWeakSelf
    [allDeviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TTDeviceInfo *info1 = (TTDeviceInfo *)obj;
        
        if ([info1.deviceID isEqualToString:weakSelf.deviceTF.text]) {
            
            exit = YES;
        }
    }];
    
    TTDeviceInfo *info = [[TTDeviceInfo alloc] init];
    
    info.devicePassword = _pwdTextField.text;
    info.deviceName = _nickTF.text;
    info.deviceID = _deviceTF.text;
    
    if (!exit) {
        
        // 未添加的设备：直接添加
        [[TTDataBase shareDB] addDeviceInfo_with_deviceInfo:info reBlock:^(TTDeviceInfo * _Nonnull info, int code) {
            
            if (code == 1) {
                [weakSelf.view makeToast:TTStr(@"%@：\"%@\"，%@",TTLocalString(@"dev", nil),info.deviceID,TTLocalString(@"addSuc_", nil))];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TT_addDevice_noti_KEY object:nil];
                });
            }
        }];
    }
    else {
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:TTLocalString(@"tips_", nil)  message:TTLocalString(@"reAdd_", nil) preferredStyle:UIAlertControllerStyleAlert];
        TTWeakSelf
        UIAlertAction *config = [UIAlertAction actionWithTitle:TTLocalString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            // 已添加的设备：先删除，再添加
            [[TTDataBase shareDB] deleteDeviceInfo_with_deviceInfo:info reBlock:^(TTDeviceInfo * _Nonnull info, int code) {
                
                [[TTDataBase shareDB] addDeviceInfo_with_deviceInfo:info reBlock:^(TTDeviceInfo * _Nonnull info, int code) {
                    
                    if (code == 1) {
                        
                        [weakSelf.view makeToast:TTStr(@"%@：\"%@\"，%@",TTLocalString(@"dev", nil),info.deviceID,TTLocalString(@"addSuc_", nil))];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                            [[NSNotificationCenter defaultCenter] postNotificationName:TT_addDevice_noti_KEY object:nil];
                        });
                    }
                }];
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertview addAction:config];
        [alertview addAction:cancel];
        [self presentViewController:alertview animated:YES completion:nil];
    }
}

- (void)checkParams
{
    NSInteger get = FLAG_TAG;
    if (_pwdTextField.text.length == 0) {
        get = 0;
    }
    if (_deviceTF.text.length == 0) {
        get = 1;
    }
    if (_nickTF.text.length == 0) {
        get = 2;
    }
    if (get == 0) {
        [self.view makeToast:TTLocalString(@"inputDevPwd", nil)];
    }
    else if (get == 1) {
        [self.view makeToast:TTLocalString(@"inputDevID_", nil)];
    }
    else if (get == 2) {
        [self.view makeToast:TTLocalString(@"inputDevName_", nil)];
    }
    if (get != FLAG_TAG) {
        return;
    }
}

- (IBAction)cancel:(id)sender
{
    /////
    ///
    ///
    ///
    ///
    ///
    ///
    [self.navigationController popViewControllerAnimated:YES];
}


@end
