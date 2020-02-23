//
//  KHJVideoPlayer_hf_VC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/13.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayer_hf_VC.h"
#import "KHJDeviceManager.h"
#import "ZFTimeLine.h"
#import "KHJBackPlayListVC.h"

//
#import "JSONStructProtocal.h"

extern const char *mCurViewPath_date;
extern IPCNetRecordCfg_st recordCfg;

@interface KHJVideoPlayer_hf_VC ()<ZFTimeLineDelegate>
{
    __weak IBOutlet UILabel *nameLab;
    __weak IBOutlet UIView *reconnectView;
    __weak IBOutlet UIButton *preDayBtn;
    __weak IBOutlet UIButton *nextDayBtn;
    
    __weak IBOutlet UIView *timeLineContent;
    __weak IBOutlet UIButton *recordBtn;
    
    __weak IBOutlet UILabel *listenLab;
    __weak IBOutlet UIImageView *listenImgView;
}

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, copy) ZFTimeLine *zfTimeView;

@end

@implementation KHJVideoPlayer_hf_VC

- (NSMutableArray *)videoList
{
    if (!_videoList) {
        _videoList = [NSMutableArray array];
    }
    return _videoList;
}

- (ZFTimeLine *)zfTimeView
{
    if (!_zfTimeView) {
        _zfTimeView = [[ZFTimeLine alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        _zfTimeView.delegate = self;
    }
    return _zfTimeView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[KHJDeviceManager sharedManager] getRecordConfig_with_deviceID:self.deviceID json:@"" resultBlock:^(NSInteger code) {
        CLog(@"code = %ld",(long)code);
    }];
    
    [timeLineContent addSubview:self.zfTimeView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1073_key:) name:noti_1073_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1075_key:) name:noti_1075_KEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1077_key:) name:noti_1077_KEY object:nil];
}

- (void)noti_1073_key:(NSNotification *)obj
{
    [self getBackPlayList];
}

- (void)noti_1075_key:(NSNotification *)obj
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM/dd"];
    //获取当前时间日期展示字符串 如：2019-05-23-13:58:59
    NSString *str = [formatter stringFromDate:date];
    
    NSString *rootdir = KHJString(@"%@/%@",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],str);
    NSDictionary *result = (NSDictionary *)obj.object;
    CLog(@"num of files:%@ disk size:%@ MB used size:%@ MB\n",result[@"n"], result[@"t"], result[@"u"]);
    //组织json字符串，lp是list path简写， p为path简写，s是start简写，c是count简写
//    int count = [result[@"n"] intValue];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:rootdir  forKey:@"p"];
    [body setValue:@(0)     forKey:@"s"];
    [body setValue:@(10)    forKey:@"c"];
    [dict setValue:body     forKey:@"lp"];
    NSString *json = [KHJUtility convertToJsonData:(NSDictionary *)dict];
    [[KHJDeviceManager sharedManager] getRemotePageFile_with_deviceID:self.deviceID path:json resultBlock:^(NSInteger code) {
        CLog(@"code = %ld",(long)code);
    }];
}

- (void)noti_1077_key:(NSNotification *)obj
{
    [self.videoList addObjectsFromArray:(NSArray *)obj.object];
    CLog(@"videoList = %@",self.videoList);
}

- (void)getBackPlayList
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMM/dd"];
    //获取当前时间日期展示字符串 如：2019-05-23-13:58:59
    NSString *str = [formatter stringFromDate:date];
    mCurViewPath_date = str.UTF8String;
    
    NSString *rootdir = KHJString(@"%@/%@",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],str);
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
//    CLog(@"dict = %@",dict);
    NSString *json = [KHJUtility convertToJsonData:(NSDictionary *)dict];
//    CLog(@"json = %@",json);
    [[KHJDeviceManager sharedManager] getRemoteDirInfo_with_deviceID:self.deviceID json:json resultBlock:^(NSInteger code) {
        CLog(@"code = %ld",(long)code);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender.tag == 20) {
        // 连接失败，点击重连
        
    }
    else if (sender.tag == 30) {
        // 前一天
        
    }
    else if (sender.tag == 40) {
        // 选择日历
        
    }
    else if (sender.tag == 50) {
        // 后一天
        
    }
    else if (sender.tag == 60) {
        // 拍照
    }
    else if (sender.tag == 70) {
        // 录屏
        recordBtn.selected = !recordBtn.selected;
    }
    else if (sender.tag == 80) {
        // 监听
        listenImgView.highlighted = !listenImgView.highlighted;
    }
    else if (sender.tag == 90) {
        // 浏览
        KHJBackPlayListVC *vc = [[KHJBackPlayListVC alloc] init];
        vc.deviceID = self.deviceID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 时间轴滑动

- (void)LineBeginMove
{
    CLog(@"LineBeginMove");
}

- (void)timeLine:(ZFTimeLine *)timeLine moveToDate:(NSTimeInterval)date
{
    CLog(@" timeLine: moveToDate: ");
}


@end
