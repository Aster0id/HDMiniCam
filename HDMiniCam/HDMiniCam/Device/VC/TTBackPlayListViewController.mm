//
//  TTBackPlayListViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBackPlayListViewController.h"
#import "KHJBackPlayListCell.h"
#import "TTFirmwareInterface_API.h"
#import "TTSingleBackPlayViewController.h"
#import "JSONStructProtocal.h"

#pragma mark - 用于获取sd卡视频存放路径    recordCfg.DiskInfo->Path.c_str()
extern IPCNetRecordCfg_st recordCfg;
#pragma mark - 查询回放列表的日期
extern const char *seekBackPlayList_Date;
#pragma mark - 远程目录信息
extern RemoteDirInfo_t *remoteDirInfo;

@interface TTBackPlayListViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
KHJBackPlayListCellDelegate
>
{
    NSInteger deleteItemWithIndex;
    __weak IBOutlet UILabel *numLab;
    __weak IBOutlet UITableView *ttableView;
    
    __weak IBOutlet UIView  *fileView;
    __weak IBOutlet UILabel *fileNameLab;
    __weak IBOutlet UILabel *fileSizeLab;
    __weak IBOutlet UILabel *fileDurationLab;
    __weak IBOutlet UILabel *fileStartTimeLab;
}

@property (nonatomic, strong) NSMutableArray *listArr;

@end

@implementation TTBackPlayListViewController

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
    [self customizeDataSource];
    [self custmoizeAppearance];
}

- (void)customizeDataSource
{
#pragma mark - 存在数据，不需要重复请求
    if (self.haveBackPlayData_now)
        [self reloadTableView];
#pragma mark - 不存在数据，需要先请求数据
    else
        [self getVideoList];
}

- (void)custmoizeAppearance
{
    self.titleLab.text = _did;
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getVideoList
{
    [[TTFirmwareInterface_API sharedManager] getRecordConfig_with_deviceID:_did json:@"" reBlock:^(NSInteger code) {}];
#pragma mark - 1、获取录像配置信息：获取文件路径
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRecordConf:) name:TT_getRecordConf_noti_KEY object:nil];
#pragma mark - 2、结构体 remoteDirInfo 保存 列表成功，通知刷新列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getListRemotePageFile:) name:TT_getListRemotePageFile_noti_KEY object:nil];
#pragma mark - 删除回放视频通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteRemoteFile:) name:TT_deleteRemoteFile_noti_KEY object:nil];
}

#pragma mark - 删除回放视频通知

- (void)deleteRemoteFile:(NSNotification *)noti
{
    NSDictionary *body = self.listArr[deleteItemWithIndex];
    [self.listArr removeObjectAtIndex:deleteItemWithIndex];
    [ttableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:deleteItemWithIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [ttableView reloadData];
    [self.view makeToast:TTStr(@"%@,%@",body[@"name"],TTLocalString(@"dltSuc_", nil))];
}

#pragma makr - Action

- (IBAction)sureAction:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        self->fileView.alpha = 0;
    }];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

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
        [weakSelf ff:indexPath.row cell:cell];
    });
    return cell;
}

- (void)ff:(NSInteger)row cell:(KHJBackPlayListCell *)cell
{
    NSDictionary *body = self.listArr[row];
    NSInteger time = [body[@"end"] integerValue] - [body[@"start"] integerValue];
    int hour = (int)time / 3600;
    int min  = (int)(time - hour * 3600) / 60;
    int sec  = (int)(time - hour * 3600 - min * 60);
    long size = [body[@"size"] longLongValue];
    
    NSString *times = TTStr(@"%02d:%02d:%02d", hour, min, sec);
    NSString *sizeUnit = [self imageSizeString:size];

    TTWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf gg:cell body:body times:times sizeUnit:sizeUnit];
    });
}

- (void)gg:(KHJBackPlayListCell *)cell body:(NSDictionary *)body times:(NSString *)times sizeUnit:(NSString *)sizeUnit
{
    cell.firstLab.text = body[@"name"];
    cell.secondLab.text = TTStr(@"%@-%@ (%@ %@M)",self.seekList_currentDate,body[@"start"],times, sizeUnit);
}

#pragma mark - KHJBackPlayListCellDelegate

- (void)chooseItemWith:(NSInteger)index
{
    NSDictionary *body = self.listArr[index];
    NSInteger time = [body[@"end"] integerValue] - [body[@"start"] integerValue];
    int hour = (int)time / 3600;
    int min  = (int)(time - hour * 3600) / 60;
    int sec  = (int)(time - hour * 3600 - min * 60);
    NSString *times = TTStr(@"%02d:%02d:%02d", hour, min, sec);
    long size = [body[@"size"] longLongValue];
    NSString *sizeUnit = [self imageSizeString:size];
    [self sssss:body index:index sizeUnit:sizeUnit min:min second:sec times:times];
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

- (void)sssss:(NSDictionary *)body index:(NSInteger)index sizeUnit:(NSString *)sizeUnit min:(int)min second:(int)second times:(NSString *)times
{
    TTWeakSelf
    UIAlertController *alertview    = [UIAlertController alertControllerWithTitle:body[@"name"] message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config           = [UIAlertAction actionWithTitle:TTLocalString(@"plyVideo_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf aa:body];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:TTLocalString(@"deltVideo_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf bb:index body:body];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:TTLocalString(@"flDetaIf_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf cc:min second:second body:body sizeUnit:sizeUnit times:times];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)aa:(NSDictionary *)body
{
    TTSingleBackPlayViewController *vc = [[TTSingleBackPlayViewController alloc] init];
    vc.body = body;
    vc.deviceID = _did;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)bb:(NSInteger)index body:(NSDictionary *)body
{
    deleteItemWithIndex = index;
    [[TTFirmwareInterface_API sharedManager] deleteRemoteFile_with_deviceID:_did path:body[@"videoPath"] reBlock:^(NSInteger code) {}];
}

- (void)cc:(int)min second:(int)second body:(NSDictionary *)body sizeUnit:(NSString *)sizeUnit times:(NSString *)times
{
    fileNameLab.text = TTStr(@"%@：%@",TTLocalString(@"flNm_", nil),body[@"name"]);
    fileSizeLab.text = TTStr(@"%@：%@M",TTLocalString(@"flSiz_", nil),sizeUnit);
    if (min > 0) {
        fileDurationLab.text = TTStr(@"%@：%ld%@%ld%@",
                                     TTLocalString(@"recdTms_", nil),
                                     (long)min,
                                     TTLocalString(@"mins_", nil),
                                     (long)second,
                                     TTLocalString(@"secs_", nil));
    }
    else {
        fileDurationLab.text = TTStr(@"%@：%ld%@",
                                     TTLocalString(@"recdTms_", nil),
                                     (long)second,
                                     TTLocalString(@"secs_", nil));
    }
    fileStartTimeLab.text = TTStr(@"%@-%@",self.seekList_currentDate,times);
    [UIView animateWithDuration:0.25 animations:^{
        self->fileView.alpha = 1;
    }];
}

#pragma mark - NSNotification 获取录像配置信息：获取文件路径

- (void)getRecordConf:(NSNotification *)obj
{
    [self getBackPlayList];
}

- (void)getBackPlayList
{
    self.seekList_currentDate = [self.seekList_currentDate stringByReplacingOccurrencesOfString:@"_" withString:@""];
    NSString *one = [self.seekList_currentDate substringWithRange:NSMakeRange(0, 6)];
    NSString *two = [self.seekList_currentDate substringWithRange:NSMakeRange(6, 2)];
    NSString *currentDate = TTStr(@"%@/%@",one,two);
    NSString *rootdir = TTStr(@"%@/%@",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],currentDate);
    seekBackPlayList_Date = currentDate.UTF8String;
    
    int vi = 0;
    int mode = 1;
    int start = 0;
    int end = 240000;
    // 组织json字符串，lir是list remote简写，p为path简写，si是sensor index简写，m是mode简写，st是start time，e是end time
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:rootdir  forKey:@"p"];
    [body setValue:@(vi)    forKey:@"si"];
    [body setValue:@(mode)  forKey:@"m"];
    [body setValue:@(start) forKey:@"st"];
    [body setValue:@(end)   forKey:@"e"];
    [dict setValue:body     forKey:@"lir"];
    // "{\"lir\":{\"p\":\"%s\",\"si\":%d,\"m\":%d,\"st\":%d,\"e\":%d}}"
//    TLog(@"dict = %@",dict);
    NSString *json = [TTCommon convertToJsonData:(NSDictionary *)dict];
    TLog(@"json = %@",json);
    [[TTFirmwareInterface_API sharedManager] getRemoteDirInfo_with_deviceID:_did json:json reBlock:^(NSInteger code) {}];
}

#pragma mark - NSNotification 通过文件路径 + 文件数量 => 获取 回放视频列表 (存入)

- (void)getListRemotePageFile:(NSNotification *)obj
{
    [self reloadTableView];
}

- (void)reloadTableView
{
    [self.listArr removeAllObjects];
    TTWeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf dd];
    });
}

- (void)dd
{
    for (list<RemoteFileInfo_t*>::iterator i = remoteDirInfo->mRemoteFileInfoList.begin(); i != remoteDirInfo->mRemoteFileInfoList.end(); i++){
        
        RemoteFileInfo_t *rfi = *i;
        NSMutableDictionary *body = [NSMutableDictionary dictionary];
        NSString *name = [NSString stringWithUTF8String:rfi->name.c_str()];
        NSArray *timeArr1   = [name componentsSeparatedByString:@"."];
        NSArray *timeArr2   = [timeArr1.firstObject componentsSeparatedByString:@"-"];
        NSString *start     = timeArr2.firstObject;
        NSString *end       = timeArr2.lastObject;
        [body setValue:[NSString stringWithUTF8String:rfi->name.c_str()] forKey:@"name"];
        [body setValue:[NSString stringWithUTF8String:rfi->path.c_str()] forKey:@"videoPath"];
        [body setValue:@(rfi->size) forKey:@"size"];
        [body setValue:start forKey:@"start"];
        [body setValue:end forKey:@"end"];
        [self.listArr addObject:body];

    }
    TTWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf ee];
    });
}

- (void)ee
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(exitListData:)]) {
        if (self.listArr.count > 0)
            [self.delegate exitListData:YES];
        else
            [self.delegate exitListData:NO];
    }
    numLab.text = TTStr(@"%@%ld%@",TTLocalString(@"ttl_", nil),self.listArr.count,TTLocalString(@"unt_", nil));
    [ttableView reloadData];
}

@end
