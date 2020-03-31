//
//  TTAddTypeListVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTAddTypeListVC.h"
#import "TTFirmwareInterface_API.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import "TTOnlineVC.h"
#import "TTScanningVC.h"

extern NSString *wifiName;

@interface TTAddTypeListVC ()<UITableViewDataSource>
{
    BOOL isHotPoint;
    BOOL isQRCode;
    NSTimer *timer;

    __weak IBOutlet UITableView *ttableView;
    __weak IBOutlet UIButton *hotPointBtn;
    __weak IBOutlet UIButton *handBtn;
    __weak IBOutlet UIButton *QRBtn;

    NSMutableArray *deviceArray;
    NSMutableArray *allDeviceIDArray;
}
@end

@implementation TTAddTypeListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
    [self addNotification];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getQRCode_noti" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSearchDeviceResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)customizeDataSource
{
    deviceArray         = [NSMutableArray array];
    allDeviceIDArray    = [NSMutableArray array];
    QRBtn.backgroundColor       = TTCommon.naviViewColor;
    handBtn.backgroundColor     = TTCommon.naviViewColor;
    hotPointBtn.backgroundColor = TTCommon.naviViewColor;
}

- (void)customizeAppearance
{
    [self fireRecordTimer];
    self.titleLab.text = TTLocalString(@"ad_Devic_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
//    NSArray *pass = [NSArray arrayWithArray:[[TTDataBase shareDB] getAllDeviceInfo]];
    [[[TTDataBase shareDB] getAllDeviceInfo] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTDeviceInfo *info = (TTDeviceInfo *)obj;
        [self->allDeviceIDArray addObject:info.deviceID];
    }];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchDeviceResult:) name:@"OnSearchDeviceResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getQRCode_noti:) name:@"getQRCode_noti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EnterForeground) name: UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)getSearchDeviceResult:(NSNotification *)noti
{
    __block BOOL exit = NO;
    NSArray *arr = [deviceArray copy];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *body = (NSDictionary *)noti.object;
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dict = (NSDictionary *)obj;
            NSString *deviceID = TTStr(@"%@",body[@""]);
            NSString *deviceID2 = TTStr(@"%@",dict[@""]);
            if ([deviceID isEqualToString:deviceID2]) {
                exit = YES;
                *stop = YES;
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!exit) {
                [self->deviceArray addObject:body];
                [self->ttableView reloadData];
            }
        });
    });
}

- (void)getQRCode_noti:(NSNotification *)noti
{
    isQRCode = YES;
    [self addDevice_with_deviceID:(NSString *)noti.object deviceName:@"IPC_QR" devicePassword:@"admin"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isHotPoint)
        [self getPhoneWifi];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRecordTimer];
}

- (void)backAction
{
    [self stopRecordTimer];
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
            [self.view makeToast:TTLocalString(@"正在搜索设备..", nil)];
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
    TTScanningVC *vc = [[TTScanningVC alloc] init];
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
                    }
                    else {
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
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:TTLocalString(@"tips", nil) message:TTLocalString(@"cameraPrivacy", nil ) preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *alertA = [UIAlertAction actionWithTitle:TTLocalString(@"commit", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    
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
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:TTLocalString(@"温馨提示", nil)
                                                                    message:TTLocalString(@"未检测到您的相机", nil)
                                                             preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:TTLocalString(@"确定", nil)
                                                     style:(UIAlertActionStyleDefault)
                                                   handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertC addAction:alertA];
    [self presentViewController:alertC animated:YES completion:nil];
}


- (IBAction)handAdd:(id)sender
{
    isHotPoint = NO;
    TTOnlineVC *vc = [[TTOnlineVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    NSDictionary *body = deviceArray[indexPath.row];
    cell.imageView.image = TTIMG(@"camera_black");
    cell.textLabel.text = body[@"deviceID"];
    cell.detailTextLabel.text = @"detailTextLabel";

    if ([allDeviceIDArray containsObject:cell.textLabel.text]) {
        cell.detailTextLabel.text = TTLocalString(@"摄像机已存在", nil);
    }
    else {
        cell.detailTextLabel.text = TTLocalString(@"摄像机已添加", nil);
        isQRCode = NO;
        [self addDevice_with_deviceID:body[@"deviceID"] deviceName:body[@"deviceName"] devicePassword:body[@"devicePassword"]];
    }
    return cell;
}

- (void)addDevice_with_deviceID:(NSString *)deviceID deviceName:(NSString *)deviceName devicePassword:(NSString *)devicePassword
{
    TTDeviceInfo *deviceInfo = [[TTDeviceInfo alloc] init];
    deviceInfo.deviceID = deviceID;
    deviceInfo.deviceName = deviceName;
    deviceInfo.devicePassword = devicePassword;
    NSArray *deviceList = [[TTDataBase shareDB] getAllDeviceInfo];
    __block BOOL exit = NO;
    [deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTDeviceInfo *info = (TTDeviceInfo *)obj;
        if ([info.deviceID isEqualToString:deviceInfo.deviceID]) {
            exit = YES;
        }
    }];
    if (!exit) {
        TTWeakSelf
        [[TTDataBase shareDB] addDeviceInfo_with_deviceInfo:deviceInfo reBlock:^(TTDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 通知刷新设备列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:TT_OnLine_AddDevice_noti_KEY object:deviceInfo];
                });
                if (self->isQRCode) {
#pragma mark - 扫码连接
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:TTLocalString(@"扫码添加成功", nil)];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            // 添加设备成功，发送通知到到设备列表，提示用户去连接可使用wifi
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"QRAddNewDevice_noti_key" object:deviceInfo];
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        });
                    });
                }
            }
        }];
    }
}


- (void)EnterBackground
{
    [[TTFirmwareInterface_API sharedManager] stopSearchDevice_with_reBlock:^(NSInteger code) {}];
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
        
        if ([wifiName hasPrefix:@"IPC_"]) {
            TLog(@"wifiName ============ %@",wifiName);
            [self.view makeToast:TTLocalString(@"正在搜索设备..", nil)];
            [self fireRecordTimer];
        }
    }
}

#pragma mark -

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

#pragma mark - Timer

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
    [[TTFirmwareInterface_API sharedManager] stopSearchDevice_with_reBlock:^(NSInteger code) {
        [[TTFirmwareInterface_API sharedManager] startSearchDevice_with_reBlock:^(NSInteger code) {}];
    }];
}

/* 停止倒计时 */
- (void)stopRecordTimer
{
    if ([timer isValid] || timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [[TTFirmwareInterface_API sharedManager] stopSearchDevice_with_reBlock:^(NSInteger code) {}];
}

@end
