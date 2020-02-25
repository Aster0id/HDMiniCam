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
    [self addDeviceNoti];
    [self reloadNewDeviceList];
//    [[KHJDataBase sharedDataBase] removeAllDevice];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    CLog(@"info.deviceID = %@",info.deviceID);
    cell.idd.text = info.deviceID;
    cell.name.text = info.deviceName;
    if ([info.deviceStatus isEqualToString:@"0"]) {
        cell.status.text = @"在线";
    }
    else if ([info.deviceStatus isEqualToString:@"-6"]) {
        cell.status.text = @"离线";
    }
    else if ([info.deviceStatus isEqualToString:@"-26"]) {
        cell.status.text = @"密码错误";
    }
    else {
        cell.status.text = @"未连接";
    }
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    [self loginDevice_with_deviceInfo:info];
    return cell;
}

- (void)loginDevice_with_deviceInfo:(KHJDeviceInfo *)deviceInfo
{
    if (deviceInfo.deviceStatus != 0) {
        [[KHJDeviceManager sharedManager] connect_with_deviceID:deviceInfo.deviceID password:deviceInfo.devicePassword resultBlock:^(NSInteger code) {
            CLog(@"code = %ld",(long)code);
        }];
    }
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
    KHJVideoPlayer_sp_VC *vc = [[KHJVideoPlayer_sp_VC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.deviceID = info.deviceID;
    vc.password = info.devicePassword;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reConnectWithIndex:(NSInteger)index
{
    CLog(@"重连第 %ld 个",index);
}

#pragma mark - 添加设备通知

- (void)addDeviceNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDeviceStatus:) name:noti_onStatus_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewDeviceList) name:@"addNewDevice_NOTI" object:nil];
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
            [[KHJDataBase sharedDataBase] updateDeviceInfo_with_deviceInfo:info resultBlock:^(KHJDeviceInfo * _Nonnull info, int code) {
                if (code == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (KHJDeviceListCell *cell in [self->contentTBV visibleCells]) {
                            if ([cell.idd.text  isEqualToString:info.deviceID]) {
                                if ([info.deviceStatus isEqualToString:@"0"]) {
                                    cell.status.text = @"在线";
                                }
                                else if ([info.deviceStatus isEqualToString:@"-6"]) {
                                    cell.status.text = @"离线";
                                }
                                else if ([info.deviceStatus isEqualToString:@"-26"]) {
                                    cell.status.text = @"密码错误";
                                }
                                else {
                                    cell.status.text = @"密码错误";
                                }
                                break;
                            }
                        }
                    });
                }
            }];
            *stop = YES;
        }
    }];
}

- (void)reloadNewDeviceList
{
    [self.deviceList removeAllObjects];
    [self.deviceList addObjectsFromArray:[[KHJDataBase sharedDataBase] getAllDeviceInfo]];
    [contentTBV reloadData];
}

@end
