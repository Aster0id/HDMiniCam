//
//  TTAllDeviceVC.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTAllDeviceVC.h"
#import "TTAllDeviceCell.h"
#import "TTDeviceAllDayVC.h"
#import "TTRebackPlayViewController.h"

@interface TTAllDeviceVC ()
<
TTAllDeviceCellDelegate,
UITableViewDelegate,
UITableViewDataSource
>

{
    //  segement
    __weak IBOutlet UIView *segmentView;
    
    // 手机内存
    __weak IBOutlet UIView *phoneView;
    __weak IBOutlet UIImageView *phoneImgView;
    
    // sd卡内存
    __weak IBOutlet UIView *sdCardView;
    __weak IBOutlet UIImageView *sdCardImgView;
    
    
    // tableview
    
    __weak IBOutlet UITableView *TTableView;
}

@property (nonatomic, strong) UIView *pView;
@property (nonatomic, assign) NSInteger pIndex;
@property (nonatomic, strong) UIImageView *pImgView;

@property (nonatomic, strong) NSMutableArray *deviceDataSArray;
@property (nonatomic, strong) NSMutableArray *videoDataSourceArr;

@end

@implementation TTAllDeviceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeAppearance];
    [self switchSegment:phoneView imageView:phoneImgView];
}

- (void)customizeAppearance
{
    segmentView.layer.borderColor = UIColorFromRGB(0x0584E0).CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.deviceDataSArray = [[TTDataBase shareDB] getAllDeviceInfo];
    [TTableView reloadData];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceDataSArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TTAllDeviceCell";
    TTAllDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];

    TTDeviceInfo *deviceInfoo = _deviceDataSArray[indexPath.row];

    cell.delegate = self;
    cell.tag = FLAG_TAG + indexPath.row;
    cell.deviceID.text = deviceInfoo.deviceName;
    cell.deviceName.text = deviceInfoo.deviceID;
    
    if (self.pIndex == 0)
        [self phone:deviceInfoo cell:cell];
    else if (self.pIndex == 1)
        [self sdCard:cell];
    return cell;
}


#pragma mark - 查看手机录制的视频列表
- (IBAction)phoneBtnAction:(UIButton *)sender
{
    self.pIndex = 0;
    
    // 切换至手机
    
    [self switchSegment:phoneView imageView:phoneImgView];
}
#pragma mark - 查看摄像头录制的视频列表
- (IBAction)sdCardBtnAction:(UIButton *)sender
{
    self.pIndex = 1;
    
    // 切换至sd卡
    
    
    [self switchSegment:sdCardView imageView:sdCardImgView];
}

#pragma mark -

- (void)switchSegment:(UIView *)view imageView:(UIImageView *)imageView
{
    if (_pImgView) {
        _pImgView.highlighted = NO;
        _pImgView = imageView;
        _pImgView.highlighted = YES;
    }
    else {
        _pImgView = imageView;
        _pImgView.highlighted = YES;
    }
    if (self.pView) {
        self.pView.backgroundColor = UIColor.clearColor;
        self.pView = view;
        self.pView.backgroundColor = UIColorFromRGB(0x0584E0);
    }
    else {
        self.pView = view;
        self.pView.backgroundColor = UIColorFromRGB(0x0584E0);
    }
    [TTableView reloadData];
}

- (void)chooseDeviceWithRow:(NSInteger)row
{
    TTDeviceInfo *deviceInfoooo = _deviceDataSArray[row];
    TTRebackPlayViewController *backVC = [[TTRebackPlayViewController alloc] init];
    TTDeviceAllDayVC *allDayVC = [[TTDeviceAllDayVC alloc] init];
    backVC.hidesBottomBarWhenPushed = YES;
    allDayVC.hidesBottomBarWhenPushed = YES;

    switch (_pIndex) {
        case 0:
        {
            // 回放或直播视频
            allDayVC.deviceInfo = deviceInfoooo;
            allDayVC.isLiveOrRecordBack = self.pIndex;
            [self.navigationController pushViewController:allDayVC animated:YES];
        }
            break;
        case 1:
        {
            backVC.info = deviceInfoooo;
            [self.navigationController pushViewController:backVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark -

- (NSMutableArray *)videoDataSourceArr
{
    if (!_videoDataSourceArr) {
        _videoDataSourceArr = [NSMutableArray array];
    }
    return _videoDataSourceArr;
}

- (NSMutableArray *)deviceDataSArray
{
    if (!_deviceDataSArray) {
        _deviceDataSArray = [NSMutableArray array];
    }
    return _deviceDataSArray;
}

- (void)phone:(TTDeviceInfo *)deviceInfo cell:(TTAllDeviceCell *)cell
{
    NSArray *arr = [[TTFileManager sharedModel] getLiveRecordVideoArrayWithDeviceID:deviceInfo.deviceID];
    cell.dayTotal.text = TTStr(@"%d %@",(int)arr.count,TTLocalString(@"天", nil));
}

- (void)sdCard:(TTAllDeviceCell *)cell
{
    cell.dayTotal.text = @"";
}


@end
