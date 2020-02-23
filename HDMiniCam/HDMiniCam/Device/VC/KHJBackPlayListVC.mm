//
//  KHJBackPlayListVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBackPlayListVC.h"
#import "KHJBackPlayListCell.h"

//
#import "JSONStructProtocal.h"

extern RemoteDirInfo_t *mCurRemoteDirInfo;

@interface KHJBackPlayListVC ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentList;
    __weak IBOutlet UILabel *numLab;
}

@property (nonatomic, strong) NSMutableArray *listArr;

@end

@implementation KHJBackPlayListVC

- (NSMutableArray *)listArr
{
    if (!_listArr) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getLIET];
    self.titleLab.text = self.deviceID;
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getLIET
{
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (list<RemoteFileInfo_t*>::iterator i= mCurRemoteDirInfo->mRemoteFileInfoList.begin(); i != mCurRemoteDirInfo->mRemoteFileInfoList.end(); i++){
            RemoteFileInfo_t *rfi = *i;
            NSMutableDictionary *body = [NSMutableDictionary dictionary];
            NSString *name = [NSString stringWithUTF8String:rfi->name.c_str()];
            NSArray *timeArr1 = [name componentsSeparatedByString:@"."];
            NSArray *timeArr2 = [timeArr1.firstObject componentsSeparatedByString:@"-"];
            NSString *start = timeArr2.firstObject;
            NSString *end = timeArr2.lastObject;
            [body setValue:[NSString stringWithUTF8String:rfi->name.c_str()] forKey:@"name"];
            [body setValue:[NSString stringWithUTF8String:rfi->path.c_str()] forKey:@"videoPath"];
            [body setValue:@(rfi->size) forKey:@"size"];
            [body setValue:start forKey:@"start"];
            [body setValue:end forKey:@"end"];
            [weakSelf.listArr addObject:body];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->contentList reloadData];
        });
    });
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        CLog(@"刷新");
    }
    else if (sender.tag == 20) {
        CLog(@"返回");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJBackPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJBackPlayListCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJBackPlayListCell" owner:nil options:nil][0];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary *body = self.listArr[indexPath.row];
        NSString *date  = @"2020/02/23";
        NSInteger time = [body[@"end"] integerValue] - [body[@"start"] integerValue];
        int hour = (int)time / 3600;
        int min  = (int)(time - hour * 3600) / 60;
        int sec  = (int)(time - hour * 3600 - min * 60);
        NSString *times = KHJString(@"%02d:%02d:%02d", hour, min, sec);
        
        long size = [body[@"size"] longLongValue];
        NSString *sizeUnit = [self imageSizeString:size];

        dispatch_async(dispatch_get_main_queue(), ^{
            cell.nameLab.text = body[@"name"];
            cell.detailsLab.text = KHJString(@"%@-%@ (%@ %@M)",date,body[@"start"],times, sizeUnit);
        });
    });
    return cell;
}

//单位转换
- (NSString *)imageSizeString:(unsigned long long)size
{
    if (size >= 1024*1024) {
        return [NSString stringWithFormat:@"%.2f",size/(1024*1024.0)];
    }
    else if (size > 1024) {
        return [NSString stringWithFormat:@"%.2f",size/1024.0];
    }
    else {
        return @"";
    }
}


@end
