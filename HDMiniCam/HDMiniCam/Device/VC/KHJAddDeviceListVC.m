//
//  KHJAddDeviceListVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAddDeviceListVC.h"
#import "KHJAddDeviceListCell.h"
#import "KHJDeviceManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import "KHJOnlineVC.h"
#import "KHJWiFiVC.h"

extern NSString *wifiName;

@interface KHJAddDeviceListVC ()<UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentTBV;
    __weak IBOutlet UIStackView *stackView;
    __weak IBOutlet NSLayoutConstraint *stackViewCH;
}

@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation KHJAddDeviceListVC

- (NSMutableArray *)deviceList
{
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNoti];
    self.titleLab.text = KHJLocalizedString(@"adDev_", nil);
    [[KHJDeviceManager sharedManager] startSearchDevice_with_resultBlock:^(NSInteger code) {}];
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchDeviceResult:) name:@"OnSearchDeviceResult_noti_key" object:nil];
    if (self.isSameRouter) {
        stackView.hidden = YES;
        stackViewCH.constant = 0;
    }
}

- (void)getSearchDeviceResult:(NSNotification *)noti
{
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *body = (NSDictionary *)noti.object;
        if (![weakSelf.deviceList containsObject:body]) {
            [weakSelf.deviceList addObject:(NSDictionary *)noti.object];
            [self->contentTBV reloadData];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPhoneWifi];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)online:(id)sender
{
    KHJOnlineVC *vc = [[KHJOnlineVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)wifi:(id)sender
{
    KHJWiFiVC *vc = [[KHJWiFiVC alloc] init];
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
    cell.deviceNameLab.text = body[@"deviceName"];
    cell.deviceIDLab.text = body[@"deviceID"];
    WeakSelf
    cell.block = ^(NSInteger row) {
        [weakSelf addDevice_with_deviceID:body[@"deviceID"] deviceName:body[@"deviceName"] devicePassword:body[@"devicePassword"]];
    };
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
        WeakSelf
        [[KHJDataBase sharedDataBase] addDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if (code == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:noti_addDevice_KEY object:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 添加设备成功，发送通知到到设备列表，提示用户去连接可使用wifi
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewDevice_noti_key" object:deviceInfo];
                    });
                });
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
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf getPhoneWifi];
    });
}

- (void)getPhoneWifi
{
    if (self.isSameRouter) {
        [[KHJDeviceManager sharedManager] stopSearchDevice_with_resultBlock:^(NSInteger code) {
            [[KHJDeviceManager sharedManager] startSearchDevice_with_resultBlock:^(NSInteger code) {}];
        }];
        return;
    }
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *item in ifs) {
        NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
        wifiName = info[@"SSID"];
        if (![wifiName hasPrefix:@"IPC_"]) {
            
            UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"setWF_", nil) message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel
                                                           handler:nil];
            WeakSelf
            UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sbMit_", nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf changeToDeviceHotpoint];
            }];
            [alertview addAction:cancel];
            [alertview addAction:defult];
            [self presentViewController:alertview animated:YES completion:nil];
            
        }
        else {
            CLog(@"wifiName ============ %@",wifiName);
            [[KHJDeviceManager sharedManager] stopSearchDevice_with_resultBlock:^(NSInteger code) {
                [[KHJDeviceManager sharedManager] startSearchDevice_with_resultBlock:^(NSInteger code) {}];
            }];
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

@end
