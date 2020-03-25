//
//  KHJAlarmListVC.m
//  HDMiniCam
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAlarmListVC.h"
#import "KHJAlarmListCell.h"
#import "KHJHadBindDeviceVC.h"
@interface KHJAlarmListVC ()<UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentTBV;
}

@end

@implementation KHJAlarmListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)chooseDevice:(id)sender
{
    KHJHadBindDeviceVC *vc = [[KHJHadBindDeviceVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJAlarmListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJAlarmListCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmListCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    cell.block = ^(NSInteger row) {
        TLog(@"点了一下 row = %ld",row);
    };
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}




@end
