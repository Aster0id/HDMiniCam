//
//  KHJDeviceListVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "AppDelegate.h"
#import "UIDevice+TFDevice.h"
#import "KHJDeviceListVC.h"
#import "KHJOnlineVC.h"
#import "KHJDeviceListCell.h"
#import "KHJWIFIConfigVC.h"
//
#import "TTFirmwareInterface_API.h"
//
#import "KHJDeviceInfo.h"
#import "KHJAddDeviceListVC.h"
#import "KHJSearchDeviceVC.h"
#import "KHJMutilScreenVC.h"
#import "KHJVideoPlayer_sp_VC.h"
#import "KHJDeviceConfVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>

NSString *wifiName;
typedef enum : NSUInteger {
    hotPointType_no = 0,
    hotPointType_once,
    hotPointType_more,
} hotPointType;

@interface KHJDeviceListVC ()<UITableViewDelegate, UITableViewDataSource, KHJDeviceListCellDelegate, KHJVideoPlayer_sp_VCDelegate>
{
    hotPointType hotPoint;
    __weak IBOutlet UITableView *contentTBV;
}

@property (nonatomic, strong) NSMutableDictionary *ensureDeviceBody;
@property (nonatomic, strong) NSMutableDictionary *offlinedDeviceBody;
@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation KHJDeviceListVC

- (NSMutableDictionary *)ensureDeviceBody
{
    if (!_ensureDeviceBody) {
        _ensureDeviceBody = [NSMutableDictionary dictionary];
    }
    return _ensureDeviceBody;
}

- (NSMutableDictionary *)offlinedDeviceBody
{
    if (!_offlinedDeviceBody) {
        _offlinedDeviceBody = [NSMutableDictionary dictionary];
    }
    return _offlinedDeviceBody;
}

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
    [self.deviceList addObjectsFromArray:[[KHJDataBase sharedDataBase] getAllDeviceInfo]];
    [self addDeviceNoti];
    [self reloadNewDeviceList];
    
    [[TTFirmwareInterface_API sharedManager] stopSearchDevice_with_reBlock:^(NSInteger code) {
        [[TTFirmwareInterface_API sharedManager] startSearchDevice_with_reBlock:^(NSInteger code) {}];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPhoneWifi];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)reloadNewDeviceList
{

    NSArray *subDeviceList = [self.deviceList copy];
    NSArray *array = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    TTWeakSelf
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
        __block BOOL isExit = NO;
        [subDeviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            KHJDeviceInfo *subInfo = (KHJDeviceInfo *)obj;
            if ([info.deviceID isEqualToString:subInfo.deviceID]) {
                isExit = YES;
                *stop = YES;
            }
        }];
        if (!isExit) {
            if (hotPoint != hotPointType_no) {
                if ([wifiName hasPrefix:info.deviceID]) {
                    TLog(@"wifiName = %@, info.deviceID = %@",wifiName,info.deviceID);
                    [weakSelf.deviceList addObject:info];
                    [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID
                                                                   password:info.devicePassword reBlock:^(NSInteger code) {}];
                }
                else {
                    TLog(@"非本机 ----------- info.deviceID = %@",info.deviceID);
                    [weakSelf.deviceList addObject:info];
                }
            }
            else {
                [weakSelf.deviceList addObject:info];
                [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID
                                                               password:info.devicePassword reBlock:^(NSInteger code) {}];
            }
        }
    }];
    [contentTBV reloadData];
}

- (IBAction)add:(id)sender
{
    KHJAddDeviceListVC *vc = [[KHJAddDeviceListVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)more:(id)sender
{
    
}

- (IBAction)search:(id)sender
{
    NSMutableArray *list = [NSMutableArray array];
    NSArray *passDeviceList = [self.deviceList copy];
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < passDeviceList.count; i++) {
            KHJDeviceInfo *info = passDeviceList[i];
            if ([info.deviceStatus isEqualToString:@"0"]) {
                [list addObject:info.deviceID];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            /* 显示多个视频 */
            AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.canLandscape   = YES;
            [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
            [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
            KHJMutilScreenVC *vc = [[KHJMutilScreenVC alloc] init];
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
    return self.deviceList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJDeviceListCell *cell = [contentTBV dequeueReusableCellWithIdentifier:@"KHJDeviceListCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJDeviceListCell" owner:nil options:nil][0];
    }
    KHJDeviceInfo *info = [[KHJDeviceInfo alloc] init];
    info = self.deviceList[indexPath.row];
    
    cell.deviceID = info.deviceID;
    cell.idd.text = info.deviceID;
    cell.name.text = info.deviceName;
    
    if ([info.deviceStatus isEqualToString:@"0"]) {
        cell.status.text = KHJLocalizedString(@"onLn_", nil);
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        cell.status.text = KHJLocalizedString(@"ofLn_", nil);
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        cell.status.text = KHJLocalizedString(@"pwdErr_", nil);
    }
    else {
        cell.status.text = KHJLocalizedString(@"cneting_", nil);
    }
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    return cell;
}

#pragma mark - KHJDeviceListCell

- (void)gotoSetupWithIndex:(NSString *)deviceID
{
    __block NSInteger index = 0;
    [self.deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *deviceInfo = (KHJDeviceInfo *)obj;
        if ([deviceID isEqualToString:deviceInfo.deviceID]) {
            index = idx;
            *stop = YES;
        }
    }];
    KHJDeviceInfo *deviceInfo = self.deviceList[index];
    [self showSetupWith:deviceInfo];
}

- (void)gotoVideoWithIndex:(NSInteger)index
{
    TLog(@"进入第 %ld 个视频播放界面",index);
    KHJDeviceInfo *info = self.deviceList[index];
    if ([info.deviceStatus isEqualToString:@"0"]) {
        KHJVideoPlayer_sp_VC *vc = [[KHJVideoPlayer_sp_VC alloc] init];
        vc.delegate     = self;
        vc.deviceInfo   = info;
        vc.row          = index;
        vc.deviceID     = info.deviceID;
        vc.password     = info.devicePassword;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        // 密码错误，请重新设置
        [self.view makeToast:KHJLocalizedString(@"pwdErSet_", nil)];
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        // 离线，重连
        [[TTFirmwareInterface_API sharedManager] disconnect_with_deviceID:info.deviceID reBlock:^(NSInteger code) {
            [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:info.deviceID password:info.devicePassword reBlock:^(NSInteger code) {}];
        }];
    }
    else {

    }
}

- (void)showSetupWith:(KHJDeviceInfo *)deviceInfo
{
    TTWeakSelf
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:deviceInfo.deviceName message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"chageDev_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJOnlineVC *vc = [[KHJOnlineVC alloc] init];
        vc.deviceInfo = deviceInfo;
        vc.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"dltDev_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[KHJDataBase sharedDataBase] deleteDeviceInfo_with_deviceInfo:deviceInfo reBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if ([weakSelf.deviceList containsObject:deviceInfo]) {
                NSInteger index = [weakSelf.deviceList indexOfObject:deviceInfo];
                [weakSelf.deviceList removeObject:deviceInfo];
                [self->contentTBV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.view makeToast:KHJLocalizedString(@"dltSuc_", nil)];
                
                
                NSString *path_document = NSHomeDirectory();
                NSString *pString = [NSString stringWithFormat:@"/Documents/%@.png",deviceInfo.deviceID];
                NSString *imagePath = [path_document stringByAppendingString:pString];
                NSString *screenShotPath = [[TTFileManager sharedModel] get_screenShot_DocPath_deviceID:deviceInfo.deviceID];
                NSString *recordScreenShotPath = [[TTFileManager sharedModel] get_recordVideo_screenShot_DocPath_with_deviceID:deviceInfo.deviceID];
                [[TTFileManager sharedModel] delete_videoFile_With_path:imagePath];
                [[TTFileManager sharedModel] delete_videoFile_With_path:screenShotPath];
                [[TTFileManager sharedModel] delete_videoFile_With_path:recordScreenShotPath];
            }
        }];
    }];
    
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"reCnctDev_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 离线，重连
        [[TTFirmwareInterface_API sharedManager] disconnect_with_deviceID:deviceInfo.deviceID reBlock:^(NSInteger code) {
            [[TTFirmwareInterface_API sharedManager] connect_with_deviceID:deviceInfo.deviceID password:deviceInfo.devicePassword reBlock:^(NSInteger code) {}];
        }];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"highCfg_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJDeviceConfVC *vc = [[KHJDeviceConfVC alloc] init];
        vc.deviceInfo = deviceInfo;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPhoneWifi) name: UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)netStateChange:(NSNotification *)noti
{
    [self.view makeToast:noti.object];
}

#pragma makr - 进入前台

- (void)getPhoneWifi
{
    TTWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *item in ifs) {
            NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
            wifiName = info[@"SSID"];
            if ([wifiName hasPrefix:@"IPC_"]) {
                TLog(@"wifiName ============ %@",wifiName);
//                if (self->hotPoint == hotPointType_no) {
//                    self->hotPoint = hotPointType_once;
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//                        KHJAddDeviceListVC *vc = [[KHJAddDeviceListVC alloc] init];
//                        vc.hidesBottomBarWhenPushed = YES;
//                        [weakSelf.navigationController pushViewController:vc animated:YES];
//                    });
//                }
//                else if (self->hotPoint == hotPointType_once) {
//                    self->hotPoint = hotPointType_more;
//                }
//                else {
            
                [weakSelf.view makeToast:KHJString(@"%@ %@ %@",KHJLocalizedString(@"phadCnet_", nil),wifiName,KHJLocalizedString(@"devHot_", nil))];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [weakSelf.view makeToast:KHJString(@"%@ %@ %@",KHJLocalizedString(@"请给", nil),wifiName,KHJLocalizedString(@"配置网络", nil))];
//                });
//                }
            }
            else {
                self->hotPoint = hotPointType_no;
            }
        }
    });
}

// 热点配网时，提示用户给设备进行网络配置
- (void)addNewDeviceTellUser:(NSNotification *)noti
{
    if ([wifiName hasPrefix:@"IPC"]) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)noti.object;
        UIAlertController *alertview = [UIAlertController alertControllerWithTitle:@"" message:KHJLocalizedString(@"tips_", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defult = [UIAlertAction actionWithTitle:KHJString(@"%@ \" %@ \" %@",KHJLocalizedString(@"toDev_", nil),info.deviceID,KHJLocalizedString(@"adNet_", nil))
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            KHJWIFIConfigVC *vc = [[KHJWIFIConfigVC alloc] init];
            vc.deviceInfo = info;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [alertview addAction:defult];
        [self presentViewController:alertview animated:YES completion:nil];
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

- (void)getDeviceStatus:(NSNotification *)noti
{
    NSDictionary *body = (NSDictionary *)noti.object;
    NSString *deviceID = KHJString(@"%@",body[@"deviceID"]);
    NSString *deviceStatus = KHJString(@"%@",body[@"deviceStatus"]);
    
    if ([wifiName hasPrefix:@"IPC"]) {
        TLog(@"当前连接的是热点");
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *item in ifs) {
            NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
            wifiName = info[@"SSID"];
            if (![wifiName hasPrefix:@"IPC"]) {
                TLog(@"wifiName ============ %@",wifiName);
                TLog(@"当前连接的是正常Wi-Fi");
                [self.deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
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
        [self.deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
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

- (UIViewController *)getCurrentUIVC
{
    UIViewController  *superVC = [self getCurrentVC];
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        
        if ([tabSelectVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }else
        if ([superVC isKindOfClass:[UINavigationController class]]) {
            
            return ((UINavigationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark - KHJVideoPlayer_sp_VCDelegate

- (void)loadCellPic:(NSInteger)row
{
    KHJDeviceListCell *cell = [contentTBV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    KHJDeviceInfo *info = self.deviceList[row];
    cell.deviceID = info.deviceID;
}

@end
