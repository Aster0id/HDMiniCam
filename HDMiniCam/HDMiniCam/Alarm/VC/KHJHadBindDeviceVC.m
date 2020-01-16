//
//  KHJHadBindDeviceVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJHadBindDeviceVC.h"
#import "KHJHadBindDeviceCell.h"

@interface KHJHadBindDeviceVC ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
    
}

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation KHJHadBindDeviceVC

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataSource addObject:@"<所有设备>"];
    [self.dataSource addObject:@"12312312312"];
    [self.dataSource addObject:@"12314141"];
    [self.dataSource addObject:@"12312312312"];
    [self.dataSource addObject:@"12314141"];
    self.titleLab.text = @"选择设备";
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [contentTBV reloadData];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJHadBindDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJHadBindDeviceCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJHadBindDeviceCell" owner:nil options:nil][0];
    }
    
    cell.tag = indexPath.row + FLAG_TAG;
    cell.block = ^(NSInteger row) {
        CLog(@"row = %ld",(long)row);
    };
    cell.lab.text = self.dataSource[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

@end
