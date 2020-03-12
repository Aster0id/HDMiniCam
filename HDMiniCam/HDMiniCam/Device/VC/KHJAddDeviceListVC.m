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

@interface KHJAddDeviceListVC ()<UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentTBV;
    NSString *wifiName;
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
    WeakSelf
    [[KHJDeviceManager sharedManager] startSearchDevice_with_resultBlock:^(NSInteger code) {
        NSMutableDictionary *body = [NSMutableDictionary dictionary];
        [body setValue:@"deviceName" forKey:@"deviceName"];
        [body setValue:@"deviceID" forKey:@"deviceID"];
        [body setValue:@"devicePassword" forKey:@"devicePassword"];
        [weakSelf.deviceList addObject:body];
        [self->contentTBV reloadData];
    }];
    self.titleLab.text = KHJLocalizedString(@"添加设备", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchSSIDInfo];
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
    [self fetchSSIDInfo];
}

- (void)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *item in ifs) {
        NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
        wifiName = info[@"SSID"];
        if (![wifiName hasPrefix:@"IPC_"]) {

            UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"请前往手机设置界面,设置手机连接的wifi", nil) message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel
                                                           handler:nil];
            WeakSelf
            UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJLocalizedString(@"提交", nil) style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf changeToDeviceHotpoint];
            }];
            [alertview addAction:cancel];
            [alertview addAction:defult];
            [self presentViewController:alertview animated:YES completion:nil];
            
        }
        CLog(@"wifiName ============ %@",wifiName);
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
