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
#import "KHJAddDeviceListVC.h"
#import "KHJSearchDeviceVC.h"
#import "KHJMutliScreenVC.h"
#import "KHJVideoPlayerVC.h"

@interface KHJDeviceListVC ()<UITableViewDelegate, UITableViewDataSource, KHJDeviceListCellDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
}
@end

@implementation KHJDeviceListVC

- (void)viewDidLoad{
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (IBAction)add:(id)sender {
    KHJAddDeviceListVC *vc = [[KHJAddDeviceListVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)more:(id)sender {
    KHJMutliScreenVC *vc = [[KHJMutliScreenVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)search:(id)sender {
    KHJSearchDeviceVC *vc = [[KHJSearchDeviceVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KHJDeviceListCell *cell = [contentTBV dequeueReusableCellWithIdentifier:@"KHJDeviceListCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJDeviceListCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    cell.delegate = self;
    return cell;
}

#pragma mark - KHJDeviceListCell

- (void)gotoSetupWithIndex:(NSInteger)index { 
    CLog(@"进入第 %ld 个设置界面",index);
}

- (void)gotoVideoWithIndex:(NSInteger)index { 
    CLog(@"进入第 %ld 个视频播放界面",index);
    KHJVideoPlayerVC *vc = [[KHJVideoPlayerVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reConnectWithIndex:(NSInteger)index { 
    CLog(@"重连第 %ld 个",index);
}


@end
