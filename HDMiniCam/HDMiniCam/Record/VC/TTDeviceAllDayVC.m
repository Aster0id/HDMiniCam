//
//  TTDeviceAllDayVC.m
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDeviceAllDayVC.h"
#import "TTDeviceAllDayCell.h"
#import "TTDeviceSingleDayVC.h"

@interface TTDeviceAllDayVC ()<UITableViewDelegate, UITableViewDataSource, TTDeviceAllDayCellDelegate>
{
    NSArray *videoList;
    NSMutableArray *dateList;
    NSMutableArray *dateList_num;
    __weak IBOutlet UITableView *contentTBV;
}

@end

@implementation TTDeviceAllDayVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeAppearance];
    [self customizeDataSource];
}

- (void)customizeAppearance
{
    dateList = [NSMutableArray array];
    dateList_num = [NSMutableArray array];
}

- (void)customizeDataSource
{
    self.titleLab.text = _deviceInfo.deviceName;
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isLiveOrRecordBack == 0)
        videoList = [[[TTFileManager sharedModel] getLiveRecordVideoArrayWithDeviceID:_deviceInfo.deviceID] copy];

    else if (_isLiveOrRecordBack == 1)
        videoList = [[[TTFileManager sharedModel] getRebackRecordVideoArrayWithDeviceID:_deviceInfo.deviceID] copy];

    [dateList removeAllObjects];
    [dateList_num removeAllObjects];
    
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        
        for (int i = 0; i < self->videoList.count; i++) {
        
            NSString *name = self->videoList[i];
            NSString *video_Date = [name componentsSeparatedByString:@"-"].firstObject;
            
            
            if ([self->dateList containsObject:video_Date]) {
            
                NSInteger index = [self->dateList indexOfObject:video_Date];
                
                NSString *numString = self->dateList_num[index];
                
                int numValie = [numString intValue];
                
                numValie ++;
                
                [self->dateList_num replaceObjectAtIndex:index withObject:@(numValie)];
            }
            else {
                
                // 保存日期
                
                [self->dateList addObject:video_Date];
                [self->dateList_num addObject:@(1)];
           
            }
            
        }
        

        //        [weakSelf.videoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        //            NSString *videoName = TTStr(@"%@",obj);

        //            NSString *date = [videoName componentsSeparatedByString:@"-"].firstObject;
        
        
        //            // 是否包含，包含的话，
        
        
        //            if ([weakSelf.dateList containsObject:date]) {
        
        //                NSInteger index = [weakSelf.dateList indexOfObject:date];
        //                NSInteger num = [weakSelf.dateList_num[index] integerValue];
        
        
        //                num ++;
        //                [weakSelf.dateList_num replaceObjectAtIndex:index withObject:@(num)];
        
        //            }
        
        
        //            else {
        
        //                // 保存日期
        
        //                [weakSelf.dateList addObject:date];
        
        //                [weakSelf.dateList_num addObject:@(1)];
        
        //            }
        
        //        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->contentTBV reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dateList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TTDeviceAllDayCell";
    TTDeviceAllDayCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    
    cell.delegate = self;
    
    cell.tag = FLAG_TAG + indexPath.row;
    cell.date = dateList[indexPath.row];
    cell.deviceID = _deviceInfo.deviceID;
    
    
    cell.timeLab.text = TTStr(@"%@：%@", TTLocalString(@"camerTimKe_", nil), dateList[indexPath.row]);
    
    cell.numLab.text =
    TTStr(@"%@ %@ %@", TTLocalString(@"ttl_", nil),dateList_num[indexPath.row],TTLocalString(@"unt_", nil));
    
    return cell;
}

#pragma MARK - TTDeviceAllDayCellDelegate

- (void)chooseDateWith:(NSInteger)row
{
    TTDeviceSingleDayVC *DeviceSingleDayVC = [[TTDeviceSingleDayVC alloc] init];
    DeviceSingleDayVC.date = dateList[row];
    DeviceSingleDayVC.info = _deviceInfo;
    DeviceSingleDayVC.currentIndex = _isLiveOrRecordBack;
    [self.navigationController pushViewController:DeviceSingleDayVC animated:YES];
}

#pragma mark -

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
