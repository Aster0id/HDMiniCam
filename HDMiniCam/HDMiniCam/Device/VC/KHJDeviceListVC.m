//
//  KHJDeviceListVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDeviceListVC.h"
#import "KHJDeviceListCellTableViewCell.h"
//
#import "KHJAddDeviceListVC.h"

@interface KHJDeviceListVC ()<UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentTBV;
    
}
@end

@implementation KHJDeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (IBAction)add:(id)sender {
    KHJAddDeviceListVC *vc = [[KHJAddDeviceListVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)more:(id)sender {
}
- (IBAction)search:(id)sender {
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KHJDeviceListCellTableViewCell *cell = [contentTBV dequeueReusableCellWithIdentifier:@"KHJDeviceListCellTableViewCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJDeviceListCellTableViewCell" owner:nil options:nil][0];
    }
    
    return cell;
}

@end
