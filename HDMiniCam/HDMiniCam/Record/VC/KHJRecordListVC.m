//
//  KHJRecordListVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJRecordListVC.h"
#import "KHJRecordListCell.h"

@interface KHJRecordListVC ()<UITableViewDelegate, UITableViewDataSource, KHJRecordListCellDelegate>

{
    __weak IBOutlet UITableView *contentTBV;
    
    ///
    __weak IBOutlet UIButton *leftNavi;
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
}

@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation KHJRecordListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deviceID = @"IPC123123131231";
    [self addLayer];
    [self changeCurrentSatus:naviOne imageView:naviOneIMGV];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)btn:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 编辑、完成编辑
        _isEdit = !_isEdit;
        if (_isEdit){
            [leftNavi setTitle:@"完成" forState:UIControlStateNormal];
        }
        else{
            [leftNavi setTitle:@"编辑" forState:UIControlStateNormal];
        }
        [contentTBV reloadData];
    }
    else if (sender.tag == 20) {
        // 查看手机录制的视频列表
        [self changeCurrentSatus:naviOne imageView:naviOneIMGV];
    }
    else if (sender.tag == 30) {
        // 查看摄像头录制的视频列表
        [self changeCurrentSatus:naviTwo imageView:naviTwoIMGV];
    }
    else if (sender.tag == 40) {
        // 查看正在下载的视频列表
        [self changeCurrentSatus:naviThree imageView:naviThreeIMGV];
    }
    else if (sender.tag == 50) {
        // 查看已下载的视频列表
        [self changeCurrentSatus:naviFour imageView:naviFourIMGV];
    }
    else if (sender.tag == 60) {
        // 查看设备列表

    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    head.backgroundColor = UIColorFromRGB(0x8a8a8a);
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 30)];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textColor = UIColor.whiteColor;
    lab.text = self.deviceID;
    [head addSubview:lab];
    return head;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJRecordListCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJRecordListCell" owner:nil options:nil][0];
    }
    if (_isEdit){
        cell.btn.enabled = NO;
        cell.leftContraint.constant = 60;
    }
    else{
        cell.btn.enabled = YES;
        cell.leftContraint.constant = 0;
    }
    cell.delegate = self;
    cell.tag = FLAG_TAG + indexPath.row;
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

- (void)contentWith:(NSInteger)row{
    CLog(@"contentWith Row = %ld",(long)row);
}

- (void)deleteWith:(NSInteger)row {
    CLog(@"deleteWith Row = %ld",(long)row);
}


@end
