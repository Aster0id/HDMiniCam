//
//  KHJRecordListVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJRecordListVC.h"
#import "KHJRecordListCell.h"
#import "KHJRecordListVC_Two.h"
#import "KHJVideoPlayer_hf_VC.h"

@interface KHJRecordListVC ()<UITableViewDelegate, UITableViewDataSource, KHJRecordListCellDelegate>

{
    __weak IBOutlet UITableView *contentTBV;
    
    ///
    __weak IBOutlet UIView *contentNavi;
    __weak IBOutlet UIView *naviOne;
    __weak IBOutlet UIImageView *naviOneIMGV;
    __weak IBOutlet UIView *naviTwo;
    __weak IBOutlet UIImageView *naviTwoIMGV;
    __weak IBOutlet UIView *naviThree;
    __weak IBOutlet UIImageView *naviThreeIMGV;
    __weak IBOutlet UIView *naviFour;
    __weak IBOutlet UIImageView *naviFourIMGV;
    UIView *currentView;
    UIImageView *currentIMGV;
    ///
    
    NSInteger currentIndex;
}

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation KHJRecordListVC

- (NSMutableArray *)videoList
{
    if (!_videoList) {
        _videoList = [NSMutableArray array];
    }
    return _videoList;
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
    [self addLayer];
    [self changeCurrentSatus:naviOne imageView:naviOneIMGV];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.deviceList = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    [contentTBV reloadData];
}

- (IBAction)btn:(UIButton *)sender
{
    if (sender.tag == 20) {
        // 查看手机录制的视频列表
        currentIndex = 0;
        [self changeCurrentSatus:naviOne imageView:naviOneIMGV];
    }
    else if (sender.tag == 30) {
        // 查看摄像头录制的视频列表
        currentIndex = 1;
        [self changeCurrentSatus:naviTwo imageView:naviTwoIMGV];
    }
    else if (sender.tag == 40) {
        // 查看正在下载的视频列表
        currentIndex = 2;
        [self changeCurrentSatus:naviThree imageView:naviThreeIMGV];
    }
    else if (sender.tag == 50) {
        // 查看已下载的视频列表
        currentIndex = 3;
        [self changeCurrentSatus:naviFour imageView:naviFourIMGV];
    }
    [contentTBV reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJRecordListCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJRecordListCell" owner:nil options:nil][0];
    }
    cell.delegate = self;
    cell.tag = FLAG_TAG + indexPath.row;
    KHJDeviceInfo *info = self.deviceList[indexPath.row];
    cell.idLab.text = info.deviceName;
    cell.nameLab.text = info.deviceID;
    if (currentIndex == 0) {
        NSArray *list = [[TTFileManager sharedModel] get_live_record_VideoArray_with_deviceID:info.deviceID];
        cell.numberLab.text = KHJString(@"%@ %d %@",KHJLocalizedString(@"共", nil),(int)list.count,KHJLocalizedString(@"个", nil));
    }
    else if (currentIndex == 1) {
        cell.numberLab.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [contentTBV deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (void)addLayer
{
    contentNavi.layer.cornerRadius = 5;
    contentNavi.layer.masksToBounds = YES;
    contentNavi.layer.borderWidth = 1;
    contentNavi.layer.borderColor = UIColorFromRGB(0x0584E0).CGColor;
    naviTwo.layer.borderWidth = 1;
    naviTwo.layer.borderColor = UIColorFromRGB(0x0584E0).CGColor;
    naviThree.layer.borderWidth = 1;
    naviThree.layer.borderColor = UIColorFromRGB(0x0584E0).CGColor;
}

- (void)changeCurrentSatus:(UIView *)view imageView:(UIImageView *)imageView
{
    if (currentView && currentIMGV) {
        currentView.backgroundColor = UIColor.clearColor;
        currentIMGV.highlighted = NO;
        currentView = view;
        currentIMGV = imageView;
        currentView.backgroundColor = UIColorFromRGB(0x0584E0);
        currentIMGV.highlighted = YES;
    }
    else {
        currentView = view;
        currentIMGV = imageView;
        currentView.backgroundColor = UIColorFromRGB(0x0584E0);
        currentIMGV.highlighted = YES;
    }
}

- (void)contentWith:(NSInteger)row
{
    TLog(@"contentWith Row = %ld",(long)row);
    KHJDeviceInfo *info = self.deviceList[row];
    if (currentIndex == 0) {
        KHJRecordListVC_Two *vc = [[KHJRecordListVC_Two alloc] init];
        vc.info = info;
        vc.currentIndex = currentIndex;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (currentIndex == 1) {
        // 预置点
        KHJVideoPlayer_hf_VC *vc = [[KHJVideoPlayer_hf_VC alloc] init];
        vc.deviceID = info.deviceID;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
