//
//  KHJDeviceListVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDeviceListVC.h"
#import "KHJDeviceListCell.h"
//
#import "KHJDeviceManager.h"
//
#import "KHJDeviceInfo.h"
#import "KHJAddDeviceListVC.h"
#import "KHJSearchDeviceVC.h"
#import "KHJMutliScreenVC.h"
#import "KHJVideoPlayer_hp_VC.h"
#import "KHJVideoPlayer_sp_VC.h"
#import "KHJVideoPlayer_hf_VC.h"
#import "KHJOnlineVC.h"
#import "KHJDeviceConfVC.h"

@interface KHJDeviceListVC ()<UITableViewDelegate, UITableViewDataSource, KHJDeviceListCellDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
}

@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation KHJDeviceListVC

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
    CLog(@"11111111111")
    [self addDeviceNoti];
    [self reloadNewDeviceList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)reloadNewDeviceList
{
    [self.deviceList removeAllObjects];
    [self.deviceList addObjectsFromArray:[[KHJDataBase sharedDataBase] getAllDeviceInfo]];
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
    KHJMutliScreenVC *vc = [[KHJMutliScreenVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)search:(id)sender
{
    KHJSearchDeviceVC *vc = [[KHJSearchDeviceVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    cell.idd.text = info.deviceID;
    cell.name.text = info.deviceName;
    
    cell.smalIMGV.highlighted = NO;
    if ([info.deviceStatus isEqualToString:@"0"]) {
        cell.status.text = @"在线";
        cell.smalIMGV.highlighted = YES;
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        cell.status.text = @"离线";
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        cell.status.text = @"密码错误";
        cell.smalIMGV.highlighted = YES;
    }
    else {
        cell.status.text = @"连接中...";
    }
    
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    return cell;
}

#pragma mark - KHJDeviceListCell

- (void)gotoSetupWithIndex:(NSInteger)index
{
    CLog(@"进入第 %ld 个设置界面",index);
}

- (void)gotoVideoWithIndex:(NSInteger)index
{
    CLog(@"进入第 %ld 个视频播放界面",index);
    KHJDeviceInfo *info = self.deviceList[index];
    if ([info.deviceStatus isEqualToString:@"0"]) {
        KHJVideoPlayer_sp_VC *vc = [[KHJVideoPlayer_sp_VC alloc] init];
        vc.deviceInfo = info;
        vc.deviceID = info.deviceID;
        vc.password = info.devicePassword;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        // 密码错误，请重新设置
        [self.view makeToast:KHJLocalizedString(@"密码错误，请重新设置", nil)];
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        // 离线，重连
        [[KHJDeviceManager sharedManager] disconnect_with_deviceID:info.deviceID resultBlock:^(NSInteger code) {
            [[KHJDeviceManager sharedManager] connect_with_deviceID:info.deviceID password:info.devicePassword resultBlock:^(NSInteger code) {}];
        }];
    }
    else {

    }
}

- (void)reConnectWithIndex:(NSInteger)index
{
    KHJDeviceInfo *info = self.deviceList[index];
    if ([info.deviceStatus isEqualToString:@"0"]) {
        // 在线，弹出设置框
        [self showSetupWith:info];
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        // 离线，重连
        [[KHJDeviceManager sharedManager] disconnect_with_deviceID:info.deviceID resultBlock:^(NSInteger code) {
            [[KHJDeviceManager sharedManager] connect_with_deviceID:info.deviceID password:info.devicePassword resultBlock:^(NSInteger code) {}];
        }];
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        // 密码错误，弹出设置框
        [self showSetupWith:info];
    }
    else {
        // 连接中
    }
}

- (void)showSetupWith:(KHJDeviceInfo *)deviceInfo
{
    WeakSelf
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:deviceInfo.deviceName message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"修改设备", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJOnlineVC *vc = [[KHJOnlineVC alloc] init];
        vc.deviceInfo = deviceInfo;
        vc.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"删除设备", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[KHJDataBase sharedDataBase] deleteDeviceInfo_with_deviceInfo:deviceInfo resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
            if ([weakSelf.deviceList containsObject:deviceInfo]) {
                NSInteger index = [weakSelf.deviceList indexOfObject:deviceInfo];
                [weakSelf.deviceList removeObject:deviceInfo];
                [self->contentTBV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.view makeToast:KHJLocalizedString(@"设备删除成功", nil)];
            }
        }];
    }];
    
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"重连设备", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 离线，重连
        [[KHJDeviceManager sharedManager] disconnect_with_deviceID:deviceInfo.deviceID resultBlock:^(NSInteger code) {
            [[KHJDeviceManager sharedManager] connect_with_deviceID:deviceInfo.deviceID password:deviceInfo.devicePassword resultBlock:^(NSInteger code) {}];
        }];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"高级配置", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJDeviceConfVC *vc = [[KHJDeviceConfVC alloc] init];
        vc.deviceInfo = deviceInfo;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceStatus:) name:noti_onStatus_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewDeviceList) name:noti_addDevice_KEY object:nil];
}

- (void)getDeviceStatus:(NSNotification *)noti
{
    NSDictionary *body = (NSDictionary *)noti.object;
    NSString *deviceID = KHJString(@"%@",body[@"deviceID"]);
    NSString *deviceStatus = KHJString(@"%@",body[@"deviceStatus"]);
    
    [self.deviceList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KHJDeviceInfo *info = (KHJDeviceInfo *)obj;
        if ([info.deviceID isEqualToString:deviceID]) {
            // 设备状态不保存在数据库，只临时赋值给对象
            info.deviceStatus = deviceStatus;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
            *stop = YES;
        }
    }];
}

@end
