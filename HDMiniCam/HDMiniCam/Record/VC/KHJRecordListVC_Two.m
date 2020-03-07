//
//  KHJRecordListVC_Two.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/4.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJRecordListVC_Two.h"
#import "KHJRecordListCell_Two.h"
#import "KHJRecordListVC_Three.h"

@interface KHJRecordListVC_Two ()<UITableViewDelegate, UITableViewDataSource, KHJRecordListCell_TwoDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
}

@property (nonatomic, strong) NSArray *videoList;
@property (nonatomic, strong) NSMutableArray *dateList;
@property (nonatomic, strong) NSMutableArray *dateList_num;

@end

@implementation KHJRecordListVC_Two

- (NSMutableArray *)dateList
{
    if (!_dateList) {
        _dateList = [NSMutableArray array];
    }
    return _dateList;
}

- (NSMutableArray *)dateList_num
{
    if (!_dateList_num) {
        _dateList_num = [NSMutableArray array];
    }
    return _dateList_num;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = self.info.deviceName;
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.videoList = [[[KHJHelpCameraData sharedModel] getmp4VideoArray_with_deviceID:self.info.deviceID] copy];
    [self.dateList removeAllObjects];
    [self.dateList_num removeAllObjects];
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [weakSelf.videoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *videoName = KHJString(@"%@",obj);
            NSString *date = [videoName componentsSeparatedByString:@"-"].firstObject;
            // 是否包含，包含的话，
            if ([weakSelf.dateList containsObject:date]) {
                NSInteger index = [weakSelf.dateList indexOfObject:date];
                NSInteger num = [weakSelf.dateList_num[index] integerValue];
                num ++;
                [weakSelf.dateList_num replaceObjectAtIndex:index withObject:@(num)];
            }
            else {
                // 保存日期
                [weakSelf.dateList addObject:date];
                [weakSelf.dateList_num addObject:@(1)];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->contentTBV reloadData];
        });
    });
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dateList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJRecordListCell_Two *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJRecordListCell_Two" owner:nil options:nil][0];
    }
    cell.delegate = self;
    cell.tag = FLAG_TAG + indexPath.row;
    cell.timeLab.text = KHJString(@"拍摄时间：%@",self.dateList[indexPath.row]);
    cell.numLab.text = KHJString(@"共 %@ 个",self.dateList_num[indexPath.row]);
    return cell;
}

#pragma MARK - KHJRecordListCell_TwoDelegate

- (void)chooseDateWith:(NSInteger)row
{
    KHJRecordListVC_Three *vc = [[KHJRecordListVC_Three alloc] init];
    vc.date = self.dateList[row];
    vc.info = self.info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
