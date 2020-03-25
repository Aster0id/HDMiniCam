//
//  KHJAddDeviceListVC.m
//  HDMiniCam
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAddDeviceListVC.h"
#import "KHJAddDeviceListCell.h"
#import "KHJDeviceManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import "KHJOnlineVC.h"
#import "KHJQRCodeScanningVC.h"

extern NSString *wifiName;

@interface KHJAddDeviceListVC ()<UITableViewDataSource>
{
    BOOL isHotPoint;
    NSTimer *timer;
    __weak IBOutlet UITableView *contentTBV;
    BOOL isQRCode;
}

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) NSMutableArray *deviceList_old;

@end

@implementation KHJAddDeviceListVC

- (NSMutableArray *)deviceList
{
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

- (NSMutableArray *)deviceList_old
{
    if (!_deviceList_old) {
        _deviceList_old = [NSMutableArray array];
    }
    return _deviceList_old;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *hadArray = [NSArray arrayWithArray:[[KHJDataBase sharedDataBase] getAllDeviceInfo]];
    TTWeakSelf
    [hadArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
        [weakSelf.deviceList_old addObject:info.deviceID];
    }];
    
    [self addNoti];
    self.titleLab.text = KHJLocalizedString(@"adDev_", nil);
    [weakSelf fireRecordTimer];

    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchDeviceResult:) name:@"OnSearchDeviceResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getQRCode_noti:) name:@"getQRCode_noti" object:nil];
}

- (void)getSearchDeviceResult:(NSNotification *)noti
{
    __block BOOL exit = NO;
    NSArray *arr = [self.deviceList copy];
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary *body = (NSDictionary *)noti.object;
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dict = (NSDictionary *)obj;
            NSString *deviceID = KHJString(@"%@",body[@""]);
            NSString *deviceID2 = KHJString(@"%@",dict[@""]);
            if ([deviceID isEqualToString:deviceID2]) {
                exit = YES;
                *stop = YES;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!exit) {
                [weakSelf.deviceList addObject:body];
                [self->contentTBV reloadData];
            }
        });
    });
}

- (void)getQRCode_noti:(NSNotification *)noti
{
    isQRCode = YES;
    NSString *deviceID = (NSString *)noti.object;
    [self addDevice_with_deviceID:deviceID deviceName:@"IPC_QR" devicePassword:@"admin"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isHotPoint) {
        [self getPhoneWifi];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRecordTimer];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIAction

- (IBAction)hotPoint:(id)sender
{
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *item in ifs) {
            NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
            wifiName = info[@"SSID"];
            if ([wifiName hasPrefix:@"IPC_"]) {
                [self fireRecordTimer];
            }
            else {
                isHotPoint = YES;
                [self changeToDeviceHotpoint];
            }
        }
}

- (IBAction)QRCode:(id)sender
{
    isHotPoint = NO;
    KHJQRCodeScanningVC *vc = [[KHJQRCodeScanningVC alloc] init];
    [self QRCodeScanVC:vc];
}

- (void)QRCodeScanVC:(UIViewController *)scanVC
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.navigationController pushViewController:scanVC animated:YES];
                        });
                        NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
                    } else {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                [self.navigationController pushViewController:scanVC animated:YES];
                break;
            }
            case AVAuthorizationStatusDenied: {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil) message:KHJLocalizedString(@"cameraPrivacy", nil ) preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertC addAction:alertA];
                [self presentViewController:alertC animated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                NSLog(@"因为系统原因, 无法访问相册");
                break;
            }
            default:
                break;
        }
        return;
    }
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"温馨提示", nil)
                                                                    message:KHJLocalizedString(@"未检测到您的相机", nil)
                                                             preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"确定", nil)
                                                     style:(UIAlertActionStyleDefault)
                                                   handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}


- (IBAction)handAdd:(id)sender
{
    isHotPoint = NO;
    KHJOnlineVC *vc = [[KHJOnlineVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJAddDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJAddDeviceListCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJAddDeviceListCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    NSDictionary *body = self.deviceList[indexPath.row];
    cell.deviceIDLab.text = body[@"deviceIP"];
    cell.deviceNameLab.text = body[@"deviceID"];
    if ([self.deviceList_old containsObject:cell.deviceNameLab.text]) {
        cell.deviceStatusLab.text = KHJLocalizedString(@"摄像机已存在", nil);
    }
    else {
        cell.deviceStatusLab.text = KHJLocalizedString(@"摄像机已添加", nil);
        isQRCode = NO;
        [self addDevice_with_deviceID:body[@"deviceID"] deviceName:body[@"deviceName"] devicePassword:body[@"devicePassword"]];
    }
    return cell;
}

- (void)addDevice_with_deviceID:(NSString *)deviceID deviceName:(NSString *)deviceName devicePassword:(NSString *)devicePassword
{
    KHJDeviceInfo *deviceInfo = [[KHJDeviceInfo alloc] init];
    deviceInfo.deviceID = deviceID;
    deviceInfo.deviceName = deviceName;
    deviceInfo.devicePassword = devicePassword;
    NSArray *deviceList = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    __block BOOL exit = NO;
    [deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
        if ([info.deviceID isEqualToString:deviceInfo.deviceID]) {
            exit = YES;
        }
    }];
    if (!exit) {
        TTWeakSelf
        [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 通知刷新设备列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:noti_addDevice_KEY object:nil];
                });
                if (self->isQRCode) {
#pragma mark - 扫码连接
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:KHJLocalizedString(@"扫码添加成功", nil)];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            // 添加设备成功，发送通知到到设备列表，提示用户去连接可使用wifi
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewDevice_noti_key" object:deviceInfo];
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        });
                    });
                }
            }
        }];
    }
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterForeground) name: UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)EnterBackground
{
    [[KHJDeviceManager sharedManager] stopSearchDevice_with_resultBlock:^(NSInteger code) {}];
}

- (void)EnterForeground
{
    TTWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->isHotPoint) {
            [weakSelf getPhoneWifi];
        }
    });
}

- (void)getPhoneWifi
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *item in ifs) {
        NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
        wifiName = info[@"SSID"];
        
        if (![wifiName hasPrefix:@"IPC_"]) {
            
//            UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"setWF_", nil) message:@""
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel
//                                                           handler:nil];
//            TTWeakSelf
//            UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sbMit_", nil) style:UIAlertActionStyleDefault
//                                                           handler:^(UIAlertAction * _Nonnull action) {
//                [weakSelf changeToDeviceHotpoint];
//            }];
//            [alertview addAction:cancel];
//            [alertview addAction:defult];
//            [self presentViewController:alertview animated:YES completion:nil];
            
        }
        else {
            TLog(@"wifiName ============ %@",wifiName);
            [self.view makeToast:KHJLocalizedString(@"正在搜索设备..", nil)];
            [self fireRecordTimer];
        }
    }
}

- (void)changeToDeviceHotpoint
{
    NSURL *url = [self prefsUrlWithQuery:@{@"root": @"WIFI"}];
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (NSURL *)prefsUrlWithQuery:(NSDictionary *)query
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:@"QXBwLVByZWZz" options:0];
    NSString *scheme = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableString *url = [NSMutableString stringWithString:scheme];
    for (int i = 0; i < query.allKeys.count; i ++) {
        NSString *key = [query.allKeys objectAtIndex:i];
        NSString *value = [query valueForKey:key];
        [url appendFormat:@"%@%@=%@", (i == 0 ? @":" : @"?"), key, value];
    }
    return [NSURL URLWithString:url];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

/* 开启倒计时 */
- (void)fireRecordTimer
{
    [self stopRecordTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                   target:self
                                                 selector:@selector(timerAction)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
}

- (void)timerAction
{
    [[KHJDeviceManager sharedManager] stopSearchDevice_with_resultBlock:^(NSInteger code) {
        [[KHJDeviceManager sharedManager] startSearchDevice_with_resultBlock:^(NSInteger code) {}];
    }];
}

/* 停止倒计时 */
- (void)stopRecordTimer
{
    if ([timer isValid] || timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}

@end
