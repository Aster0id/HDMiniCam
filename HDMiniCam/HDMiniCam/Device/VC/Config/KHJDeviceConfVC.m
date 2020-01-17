//
//  KHJDeviceConfVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDeviceConfVC.h"
#import "KHJDeviceConfCell.h"

@interface KHJDeviceConfVC ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
    
    NSArray *iconArr;
    NSArray *titleArr;
}
@end

@implementation KHJDeviceConfVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceID = @"IPC123123123xx";
    self.titleLab.text = KHJLocalizedString(@"高级配置", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    iconArr = @[KHJIMAGE(@"config_alarm"),
                KHJIMAGE(@"config_wifi"),
                KHJIMAGE(@"config_sd"),
                KHJIMAGE(@"config_lamp"),
                KHJIMAGE(@"config_time"),
                KHJIMAGE(@"config_changepassword"),
                KHJIMAGE(@"config_restart"),
                KHJIMAGE(@"config_reboot"),
                KHJIMAGE(@"config_app")];
    titleArr = @[@"报警配置",@"Wi-Fi连接配置",@"SD卡录像设置",@"杂项设置",@"时间设置",@"修改访问密码",@"重启设备",@"恢复出厂设置",@"APP密码"];
}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 22)];
    head.backgroundColor = UIColorFromRGB(0xD5D5D5);
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 22)];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textColor = UIColor.whiteColor;
    lab.text = self.deviceID;
    [head addSubview:lab];
    return head;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return iconArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJDeviceConfCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJDeviceConfCell"];
    if (cell == nil) {
        cell = [[NSBundle  mainBundle] loadNibNamed:@"KHJDeviceConfCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    cell.block = ^(NSInteger row) {
        CLog(@"row = %ld",row);
    };
    cell.lab.text = titleArr[indexPath.row];
    cell.imageview.image = iconArr[indexPath.row];
    return cell;
}

@end
