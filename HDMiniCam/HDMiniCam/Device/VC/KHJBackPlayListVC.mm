//
//  KHJBackPlayListVC.m
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJBackPlayListVC.h"
#import "KHJBackPlayListCell.h"
#import "TTFirmwareInterface_API.h"
#import "KHJBackPlayerList_playerVC.h"
//
#import "JSONStructProtocal.h"

extern IPCNetRecordCfg_st recordCfg;
extern const char *checkRemoteVideoList_Date;
extern RemoteDirInfo_t *remoteDirInfo;

@interface KHJBackPlayListVC ()<UITableViewDelegate,UITableViewDataSource,KHJBackPlayListCellDelegate>
{
    NSInteger deleteIndex;
    __weak IBOutlet UILabel *numLab;
    __weak IBOutlet UITableView *contentList;
    
    __weak IBOutlet UIView *fileView;
    __weak IBOutlet UILabel *fileNameLab;
    __weak IBOutlet UILabel *fileSizeLab;
    __weak IBOutlet UILabel *fileDurationLab;
    __weak IBOutlet UILabel *fileStartTimeLab;
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
    if (self.exitVideoList) {
        [self reloadTableView];
    }
    else {
        [self getVideoList];
    }
    self.titleLab.text = self.deviceID;
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)getVideoList
{
    [[TTFirmwareInterface_API sharedManager] getRecordConfig_with_deviceID:self.deviceID json:@"" reBlock:^(NSInteger code) {}];
    // 1、获取录像配置信息：获取文件路径
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1073_key:) name:noti_1073_KEY object:nil];
    // 2、结构体 remoteDirInfo 保存 列表成功，通知刷新列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1077_key:) name:noti_1077_KEY object:nil];
    // 删除回放视频通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_OnDeleteRemoteFileCmdResult_key:) name:noti_OnDeleteRemoteFileCmdResult_KEY object:nil];
}

- (void)noti_OnDeleteRemoteFileCmdResult_key:(NSNotification *)noti
{
    NSDictionary *body = self.listArr[deleteIndex];
    [self.listArr removeObjectAtIndex:deleteIndex];
    [contentList deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:deleteIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [contentList reloadData];
    [self.view makeToast:KHJString(@"%@,%@",body[@"name"],KHJLocalizedString(@"dltSuc_", nil))];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        TLog(@"刷新");
    }
    else if (sender.tag == 20) {
        TLog(@"返回");
    }
    else if (sender.tag == 30) {
        TLog(@"确定");
        [UIView animateWithDuration:0.25 animations:^{
            self->fileView.alpha = 0;
        }];
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
    cell.delegate = self;
    cell.tag = indexPath.row + FLAG_TAG;
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary *body = self.listArr[indexPath.row];
        NSInteger time = [body[@"end"] integerValue] - [body[@"start"] integerValue];
        int hour = (int)time / 3600;
        int min  = (int)(time - hour * 3600) / 60;
        int sec  = (int)(time - hour * 3600 - min * 60);
        NSString *times = KHJString(@"%02d:%02d:%02d", hour, min, sec);
        
        long size = [body[@"size"] longLongValue];
        NSString *sizeUnit = [self imageSizeString:size];

        dispatch_async(dispatch_get_main_queue(), ^{
            cell.nameLab.text = body[@"name"];
            cell.detailsLab.text = KHJString(@"%@-%@ (%@ %@M)",weakSelf.date,body[@"start"],times, sizeUnit);
        });
    });
    return cell;
}

#pragma mark - KHJBackPlayListCellDelegate

- (void)chooseItemWith:(NSInteger)index
{
    NSDictionary *body = self.listArr[index];
    NSInteger time = [body[@"end"] integerValue] - [body[@"start"] integerValue];
    int hour = (int)time / 3600;
    int min  = (int)(time - hour * 3600) / 60;
    int sec  = (int)(time - hour * 3600 - min * 60);
    NSString *times = KHJString(@"%02d:%02d:%02d", hour, min, sec);
    long size = [body[@"size"] longLongValue];
    NSString *sizeUnit = [self imageSizeString:size];
    
    TTWeakSelf
    UIAlertController *alertview    = [UIAlertController alertControllerWithTitle:body[@"name"] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config           = [UIAlertAction actionWithTitle:KHJLocalizedString(@"plyVideo_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KHJBackPlayerList_playerVC *vc = [[KHJBackPlayerList_playerVC alloc] init];
        vc.body = body;
        vc.deviceID = weakSelf.deviceID;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"deltVideo_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->deleteIndex = index;
        [[TTFirmwareInterface_API sharedManager] deleteRemoteFile_with_deviceID:self.deviceID path:body[@"videoPath"] reBlock:^(NSInteger code) {}];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"flDetaIf_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->fileNameLab.text = KHJString(@"%@：%@",KHJLocalizedString(@"flNm_", nil),body[@"name"]);
        self->fileSizeLab.text = KHJString(@"%@：%@M",KHJLocalizedString(@"flSiz_", nil),sizeUnit);
        if (min > 0) {
            self->fileDurationLab.text = KHJString(@"%@：%ld%@%ld%@",KHJLocalizedString(@"recdTms_", nil),(long)min,KHJLocalizedString(@"mins_", nil),(long)sec,KHJLocalizedString(@"secs_", nil));
        }
        else {
            self->fileDurationLab.text = KHJString(@"%@：%ld%@",KHJLocalizedString(@"recdTms_", nil),(long)sec,KHJLocalizedString(@"secs_", nil));
        }
        self->fileStartTimeLab.text = KHJString(@"%@-%@",weakSelf.date,times);
        [UIView animateWithDuration:0.25 animations:^{
            self->fileView.alpha = 1;
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
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

#pragma mark - 获取录像配置信息：获取文件路径

- (void)noti_1073_key:(NSNotification *)obj
{
    [self getBackPlayList];
}

- (void)getBackPlayList
{
    self.date = [self.date stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSString *one = [self.date substringWithRange:NSMakeRange(0, 6)];
    NSString *two = [self.date substringWithRange:NSMakeRange(6, 2)];
    NSString *date1 = KHJString(@"%@/%@",one,two);
    NSString *rootdir = KHJString(@"%@/%@",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],date1);
    checkRemoteVideoList_Date = date1.UTF8String;
    
    int vi = 0;
    // 0: 只扫描文件   1: 扫描目录和文件
    int mode = 1;
    // 文件开始时间
    int start = 0;
    // 文件结束时间
    int end = 240000;

    // 组织json字符串，lir是list remote简写，p为path简写，si是sensor index简写，m是mode简写，st是start time，e是end time
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:rootdir forKey:@"p"];
    [body setValue:@(vi) forKey:@"si"];
    [body setValue:@(mode) forKey:@"m"];
    [body setValue:@(start) forKey:@"st"];
    [body setValue:@(end) forKey:@"e"];
    [dict setValue:body forKey:@"lir"];
    // "{\"lir\":{\"p\":\"%s\",\"si\":%d,\"m\":%d,\"st\":%d,\"e\":%d}}"
//    TLog(@"dict = %@",dict);
    NSString *json = [TTCommon convertToJsonData:(NSDictionary *)dict];
    TLog(@"json = %@",json);
    [[TTFirmwareInterface_API sharedManager] getRemoteDirInfo_with_deviceID:self.deviceID json:json reBlock:^(NSInteger code) {}];
}

#pragma mark - 通过文件路径 + 文件数量 => 获取 回放视频列表 (存入)

- (void)noti_1077_key:(NSNotification *)obj
{
    [self reloadTableView];
}

- (void)reloadTableView
{
    [self.listArr removeAllObjects];
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (list<RemoteFileInfo_t*>::iterator i = remoteDirInfo->mRemoteFileInfoList.begin(); i != remoteDirInfo->mRemoteFileInfoList.end(); i++){
            
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
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(exitListData:)]) {
                if (weakSelf.listArr.count > 0) {
                    [weakSelf.delegate exitListData:YES];
                }
                else {
                    [weakSelf.delegate exitListData:NO];
                }
            }
            self->numLab.text = KHJString(@"%@%ld%@",KHJLocalizedString(@"ttl_", nil),weakSelf.listArr.count,KHJLocalizedString(@"unt_", nil));
            [self->contentList reloadData];
        });
    });
}

@end
