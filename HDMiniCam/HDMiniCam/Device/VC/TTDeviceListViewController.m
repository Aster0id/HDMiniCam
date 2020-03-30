//
//  TTDeviceListViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "AppDelegate.h"
#import "TTDeviceListViewController.h"
#import "TTOnlineVC.h"
#import "TTDeviceListCell.h"
#import "TTWiFiConfigViewController.h"
//
#import "TTFirmwareInterface_API.h"
//
#import "TTDeviceInfo.h"
#import "TTAddTypeListVC.h"
#import "TTMutilPlayerViewController.h"
#import "TTLivePlayViewController.h"
#import "TTHighConfigViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

NSString *wifiName;

typedef enum : NSUInteger {
    TTHotPointAddDevice_no = 0,
    TTHotPointAddDevice_once,
    TTHotPointAddDevice_more,
} TTHotPointAddDevice;

@interface TTDeviceListViewController ()

<
UITableViewDelegate,
UITableViewDataSource,
TTDeviceListCellDelegate,
TTLivePlayViewControllerDelegate
>

{
    TTHotPointAddDevice hotPoint;
    NSMutableArray *dataArray;
    __weak IBOutlet UITableView *contentTBV;
}

@end

@implementation TTDeviceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)customizeDataSource
{
    dataArray = [NSMutableArray arrayWithArray:[[TTDataBase shareDB] getAllDeviceInfo]];
//    [[TTFirmwareInterface_API sharedManager] stopSearchDevice_with_reBlock:^(NSInteger code) {
//
//        TLog(@"停止嗖嗖");
//        [[TTFirmwareInterface_API sharedManager] startSearchDevice_with_reBlock:^(NSInteger code) {
//            TLog(@"开始搜索");
//        }];
//
//    }];
}

- (void)customizeAppearance
{
#pragma mark - 添加通知
    
    [self addDeviceNoti];
    
    [self reloadNewDeviceList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self enterForegroundNotification];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)add:(id)sender
{
    TTAddTypeListVC *vc = [[TTAddTypeListVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)more:(id)sender
{
    NSMutableArray *list = [NSMutableArray array];
    NSArray *passDeviceList = [dataArray copy];
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < passDeviceList.count; i++) {
            TTDeviceInfo *info = passDeviceList[i];
            if ([info.deviceStatus isEqualToString:@"0"]) {
                [list addObject:info.deviceID];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            /* 显示多个视频 */
            AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.canLandscape   = YES;
            [UIDevice TTurnAroundDirection:UIInterfaceOrientationLandscapeRight];
            [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
            TTMutilPlayerViewController *vc = [[TTMutilPlayerViewController alloc] init];
            vc.list = [list copy];
            vc.hidesBottomBarWhenPushed = YES;
            [UITabBar appearance].translucent = YES;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    });
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTDeviceListCell *cell = [contentTBV dequeueReusableCellWithIdentifier:@"TTDeviceListCell"];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TTDeviceListCell" owner:nil options:nil] firstObject];

    TTDeviceInfo *info = [[TTDeviceInfo alloc] init];
    
    info = dataArray[indexPath.row];
      
    cell.idd.text = info.deviceID;
    cell.name.text = info.deviceName;
    
    NSString *path_document = NSHomeDirectory();
    NSString *pString       = TTStr(@"/Documents/%@.png",info.deviceID);
    NSString *imagePath     = [path_document stringByAppendingString:pString];
    UIImage *image          = [UIImage imageWithContentsOfFile:imagePath];
    cell.bigIMGV.image      = image;
   
    if ([info.deviceStatus isEqualToString:@"0"])
        cell.status.text = TTLocalString(@"onLn_", nil);
    else if ([info.deviceStatus isEqualToString:@"-6"])
        cell.status.text = TTLocalString(@"ofLn_", nil);
    else if ([info.deviceStatus isEqualToString:@"-26"])
        cell.status.text = TTLocalString(@"pwdErr_", nil);
    else
        cell.status.text = TTLocalString(@"cneting_", nil);
    
    cell.delegate = self;
    
    cell.tag = indexPath.row + FLAG_TAG;
    
    return cell;
}

#pragma mark - TTDeviceListCellDelegate

- (void)gotoSetupWithIndex:(NSString *)deviceID
{
    __block NSInteger index = 0;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTDeviceInfo *deviceInfo = (TTDeviceInfo *)obj;
        if ([deviceID isEqualToString:deviceInfo.deviceID]) {
            index = idx;
            *stop = YES;
        }
    }];
    TTDeviceInfo *deviceInfo = dataArray[index];
    [self showSetupWith:deviceInfo];
}

- (void)gotoVideoWithIndex:(NSString *)deviceID
{
    __block NSInteger index = 0;
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTDeviceInfo *deviceInfo = (TTDeviceInfo *)obj;
        if ([deviceID isEqualToString:deviceInfo.deviceID]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    TTDeviceInfo *info = dataArray[index];
    if ([info.deviceStatus isEqualToString:@"0"]) {
        [self equal_0:index];
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        [self equal_26];
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        [self equal_6:index];
    }
}

#pragma mark - 前往设置界面

- (void)showSetupWith:(TTDeviceInfo *)info
{
    TTWeakSelf
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:info.deviceName
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config = [UIAlertAction actionWithTitle:TTLocalString(@"chageDev_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf addOnline:info];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:TTLocalString(@"dltDev_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteDevice:info];
    }];
    
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:TTLocalString(@"reCnctDev_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reconnect:info];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:TTLocalString(@"highCfg_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf togoHighSet:info];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:config3];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

#pragma mark - 添加设备通知

- (void)addDeviceNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStateChange:) name:@"netStateChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceStatus:) name:TT_onStatus_noti_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewDeviceList) name:TT_addDevice_noti_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDeviceTellUser:) name:@"addNewDevice_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name: UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - TTLivePlayViewControllerDelegate

- (void)loadCellPic:(NSInteger)row
{
    TTDeviceListCell *cell = [contentTBV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    TTDeviceInfo *info = dataArray[row];
    cell.deviceID = info.deviceID;
}

#pragma mark - 添加 @"netStateChange" 通知

- (void)netStateChange:(NSNotification *)noti
{
    [self.view makeToast:noti.object];
}

#pragma mark - 添加 TT_onStatus_noti_KEY 通知
#pragma mark - 收到通知时，更新 tableView 状态

- (void)getDeviceStatus:(NSNotification *)noti
{
    NSDictionary *body = (NSDictionary *)noti.object;
    NSString *deviceID = TTStr(@"%@",body[@"deviceID"]);
    NSString *deviceStatus = TTStr(@"%@",body[@"deviceStatus"]);
    
    if ([wifiName hasPrefix:@"IPC"]) {
        TLog(@"当前连接的是热点");
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *item in ifs) {
            NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
            wifiName = info[@"SSID"];
            if (![wifiName hasPrefix:@"IPC"]) {
                TLog(@"wifiName ============ %@",wifiName);
                TLog(@"当前连接的是正常Wi-Fi");
                [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    TTDeviceInfo *info = (TTDeviceInfo *)obj;
                    if ([info.deviceID isEqualToString:deviceID]) {
                        // 设备状态不保存在数据库，只临时赋值给对象
                        info.deviceStatus = deviceStatus;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]
                                                    withRowAnimation:UITableViewRowAnimationNone];
                        });
                        *stop = YES;
                    }
                }];
            }
        }
    }
    else {
        TLog(@"当前连接的是正常Wi-Fi");
        [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTDeviceInfo *info = (TTDeviceInfo *)obj;
            if ([info.deviceID isEqualToString:deviceID]) {
                // 设备状态不保存在数据库，只临时赋值给对象
                info.deviceStatus = deviceStatus;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]
                                            withRowAnimation:UITableViewRowAnimationNone];
                });
                *stop = YES;
            }
        }];
    }
}

#pragma mark - 添加 TT_addDevice_noti_KEY 通知

- (void)reloadNewDeviceList
{
    NSArray *array = [[TTDataBase shareDB] getAllDeviceInfo];
    TTWeakSelf
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTDeviceInfo *info = (TTDeviceInfo *)obj;
        [weakSelf reloadSubDeviceArr:info];
    }];
    [contentTBV reloadData];
}

- (void)reloadSubDeviceArr:(TTDeviceInfo *)info
{
    NSArray *subDeviceList = [dataArray copy];
    __block BOOL isExit = NO;
    [subDeviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTDeviceInfo *subInfo = (TTDeviceInfo *)obj;
        if ([info.deviceID isEqualToString:subInfo.deviceID]) {
            isExit = YES;
            *stop = YES;
        }
    }];
    if (!isExit) {
        if (hotPoint != TTHotPointAddDevice_no) {
            if ([wifiName hasPrefix:info.deviceID]) {
                TLog(@"wifiName = %@, info.deviceID = %@",wifiName,info.deviceID);
                [self->dataArray addObject:info];
                [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID
                                                               password:info.devicePassword reBlock:^(NSInteger code) {}];
            }
            else {
                TLog(@"非本机 ----------- info.deviceID = %@",info.deviceID);
                [self->dataArray addObject:info];
            }
        }
        else {
            [self->dataArray addObject:info];
            [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID
                                                           password:info.devicePassword reBlock:^(NSInteger code) {}];
        }
    }
}

#pragma mark - 添加 @"addNewDevice_noti_key" 通知
#pragma mark - 热点配网时，提示用户给设备进行网络配置
- (void)addNewDeviceTellUser:(NSNotification *)noti
{
    if ([wifiName hasPrefix:@"IPC"]) {
        TTDeviceInfo *info = (TTDeviceInfo *)noti.object;
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:@"" message:TTLocalString(@"tips_", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defult = [UIAlertAction actionWithTitle:TTStr(@"%@ \" %@ \" %@",TTLocalString(@"toDev_", nil),info.deviceID,TTLocalString(@"adNet_", nil))
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            TTWiFiConfigViewController *vc = [[TTWiFiConfigViewController alloc] init];
            vc.deviceInfo = info;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [alertview addAction:defult];
        [self presentViewController:alertview animated:YES completion:nil];
    }
}

#pragma mark - 进入前台
#pragma mark - 添加 UIApplicationWillEnterForegroundNotification 通知

- (void)enterForegroundNotification
{
    TTWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *item in ifs) {
            NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
            wifiName = info[@"SSID"];
            if ([wifiName hasPrefix:@"IPC_"]) {
                [weakSelf.view makeToast:TTStr(@"%@ %@ %@",
                                               TTLocalString(@"phadCnet_", nil),
                                               wifiName,
                                               TTLocalString(@"devHot_", nil))];

            }
            else {
                self->hotPoint = TTHotPointAddDevice_no;
            }
        }
    });
}


#pragma mark - 在线

- (void)addOnline:(TTDeviceInfo *)info
{
    TTOnlineVC *vc = [[TTOnlineVC alloc] init];
    vc.deviceInfo = info;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 删除设备

- (void)deleteDevice:(TTDeviceInfo *)info
{
    TTWeakSelf
    [[TTDataBase shareDB] deleteDeviceInfo_with_deviceInfo:info reBlock:^(TTDeviceInfo * _Nonnull info, int code) {
        if ([self->dataArray containsObject:info]) {
            NSInteger index = [self->dataArray indexOfObject:info];
            [self->dataArray removeObject:info];
            [self->contentTBV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.view makeToast:TTLocalString(@"dltSuc_", nil)];
            
            #pragma mark - 操作数据库
            [weakSelf handleTTFileManager:info];
        }
    }];
}

#pragma mark - 操作数据库

- (void)handleTTFileManager:(TTDeviceInfo *)info
{
    NSString *path_document = NSHomeDirectory();
    NSString *pString = [NSString stringWithFormat:@"/Documents/%@.png",info.deviceID];
    NSString *imagePath = [path_document stringByAppendingString:pString];
    NSString *screenShotPath = [[TTFileManager sharedModel] getScreenShotWithDeviceID:info.deviceID];
    NSString *recordScreenShotPath = [[TTFileManager sharedModel] getRecordScreenShotWithDeviceID:info.deviceID];
    [[TTFileManager sharedModel] deleteVideoFileWithFilePath:imagePath];
    [[TTFileManager sharedModel] deleteVideoFileWithFilePath:screenShotPath];
    [[TTFileManager sharedModel] deleteVideoFileWithFilePath:recordScreenShotPath];
}

#pragma mark - 高级配置

- (void)togoHighSet:(TTDeviceInfo *)info
{
    TTHighConfigViewController *vc = [[TTHighConfigViewController alloc] init];
    vc.deviceInfo = info;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 重连设备

- (void)reconnect:(TTDeviceInfo *)info
{
    // 离线，重连
    [[TTFirmwareInterface_API sharedManager] disconnect_with_deviceID:info.deviceID reBlock:^(NSInteger code) {
        TLog(@"断开连接....deviceID = %@",info.deviceID);
        [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID password:info.devicePassword reBlock:^(NSInteger code) {
            TLog(@"重新连接....deviceID = %@",info.deviceID);
        }];
    }];
}

#pragma mark - CellDelegate action

- (void)equal_0:(NSInteger)index
{
    TTDeviceInfo *info = dataArray[index];
    TTLivePlayViewController *vc = [[TTLivePlayViewController alloc] init];
    vc.delegate     = self;
    vc.deviceInfo   = info;
    vc.row          = index;
    vc.deviceID     = info.deviceID;
    vc.password     = info.devicePassword;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)equal_26
{
    // 密码错误，请重新设置
    [self.view makeToast:TTLocalString(@"pwdErSet_", nil)];
}

- (void)equal_6:(NSInteger)index
{
    TTDeviceInfo *info = dataArray[index];
    // 离线，重连
    [[TTFirmwareInterface_API sharedManager] disconnect_with_deviceID:info.deviceID reBlock:^(NSInteger code) {
        [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID password:info.devicePassword reBlock:^(NSInteger code) {}];
    }];
}


@end
