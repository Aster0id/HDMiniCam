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

#import "KHJOnlineVC.h"
#import "KHJWiFiVC.h"

@interface KHJAddDeviceListVC ()<UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentTBV;
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
    [[KHJDeviceManager sharedManager] startSearchDevice_with_resultBlock:^(NSInteger code) {
        
    }];
    self.titleLab.text = KHJLocalizedString(@"添加设备", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)online:(id)sender {
    KHJOnlineVC *vc = [[KHJOnlineVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)wifi:(id)sender {
    KHJWiFiVC *vc = [[KHJWiFiVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
    cell.deviceNameLab.text = @"";
    cell.deviceIDLab.text = @"";
    return cell;
}

@end
