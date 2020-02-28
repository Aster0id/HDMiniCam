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
#import "NSDate+JLZero.h"
#import "KHJBackPlayListVC.h"
//
#import "JKUIPickDate.h"
#import "KHJVideoModel.h"
#import "JSONStructProtocal.h"

typedef void(^runloopBlock)(void);

extern IPCNetRecordCfg_st recordCfg;
extern RecordDatePeriod_t gRecordDatePeriod;

@interface KHJVideoPlayer_hf_VC ()<ZFTimeLineDelegate,KHJBackPlayListVCSaveListDelegate,H26xHwDecoderDelegate>
{
    __weak IBOutlet UILabel *nameLab;
    __weak IBOutlet UIView *reconnectView;
    __weak IBOutlet UIImageView *playerImageView;
    __weak IBOutlet UIButton *preDayBtn;
    __weak IBOutlet UILabel *dateLAB;
    __weak IBOutlet UIButton *nextDayBtn;
    
    __weak IBOutlet UIView *timeLineContent;
    __weak IBOutlet UIButton *recordBtn;
    
    __weak IBOutlet UILabel *listenLab;
    __weak IBOutlet UIImageView *listenImgView;
    
    BOOL exitVideoList;
    NSTimer *recordTimer;
}

@property (nonatomic, assign) NSInteger recordTimes;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
// 装记任务的Arr
@property (nonatomic, strong) NSMutableArray *MP4_taskArray;
// 最大任务数
@property (nonatomic, assign) NSUInteger maxTask;

@property (nonatomic, assign) NSTimeInterval zeroTimeInterval;
@property (nonatomic, assign) NSTimeInterval todayTimeInterval;
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *videoList;

@property (nonatomic, copy) ZFTimeLine *zfTimeView;

@end

@implementation KHJVideoPlayer_hf_VC

#pragma MARK - H26xHwDecoderDelegate

- (void)getImageWith:(UIImage *)image imageSize:(CGSize)imageSize
{
    playerImageView.image = image;
}

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
    _recordTimes = 2;
    [self addMP4_RunloopObserver];
    nextDayBtn.hidden = YES;
    [timeLineContent addSubview:self.zfTimeView];

    NSDate *date = [NSDate date];
    _currentTimeInterval = [date timeIntervalSince1970];
    _todayTimeInterval = [NSDate getZeroWithTimeInterverl:_currentTimeInterval];
    _zeroTimeInterval = [NSDate getZeroWithTimeInterverl:_currentTimeInterval];

    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy_MM_dd"];
    dateLAB.text = [formatter1 stringFromDate:date];
    [self fireTimer];
    [self getTimeLineDataWith:dateLAB.text];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_timeLineInfo_1075_key:) name:noti_timeLineInfo_1075_KEY object:nil];
//    [[KHJDeviceManager sharedManager] getRecordConfig_with_deviceID:self.deviceID json:@"" resultBlock:^(NSInteger code) {
//        CLog(@"code = %ld",(long)code);
//    }];
//    // 1、获取录像配置信息：获取文件路径
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1073_key:) name:noti_1073_KEY object:nil];
//    // 3、通过文件路径 + 文件数量 => 获取 回放视频列表
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_1077_key:) name:noti_1077_KEY object:nil];
}

//- (void)noti_1073_key:(NSNotification *)noti
//{
//    NSString *date = [dateLAB.text stringByReplacingOccurrencesOfString:@"_" withString:@""];
//    NSString *one = [date substringWithRange:NSMakeRange(0, 6)];
//    NSString *two = [date substringWithRange:NSMakeRange(6, 2)];
//    NSString *rootdir = KHJString(@"%@/%@",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],KHJString(@"%@/%@",one,two));
//    int vi = 0;
//    // 0: 只扫描文件   1: 扫描目录和文件
//    int mode = 1;
//    // 文件开始时间
//    int start = 0;
//    // 文件结束时间
//    int end = 240000;
//
//    // 组织json字符串，lir是list remote简写，p为path简写，si是sensor index简写，m是mode简写，st是start time，e是end time
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    NSMutableDictionary *body = [NSMutableDictionary dictionary];
//    [body setValue:rootdir forKey:@"p"];
//    [body setValue:@(vi) forKey:@"si"];
//    [body setValue:@(mode) forKey:@"m"];
//    [body setValue:@(start) forKey:@"st"];
//    [body setValue:@(end) forKey:@"e"];
//    [dict setValue:body forKey:@"lir"];
//    NSString *json = [KHJUtility convertToJsonData:(NSDictionary *)dict];
//    [[KHJDeviceManager sharedManager] getRemoteDirInfo_with_deviceID:self.deviceID json:json resultBlock:^(NSInteger code) {
//        CLog(@"code = %ld",(long)code);
//    }];
//}

- (void)noti_timeLineInfo_1075_key:(NSNotification *)noti
{
    WeakSelf
    [self addMP4_tasks:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *backPlayList = [NSArray arrayWithArray:(NSArray *)noti.object];

            for (int i = 0; i < backPlayList.count; i++) {
                NSDictionary *body = backPlayList[i];
                int type                = [body[@"type"] intValue];
                NSString *startString   = KHJString(@"%06d",[body[@"start"] intValue]);
                NSString *endString     = KHJString(@"%06d",[body[@"end"] intValue]);

                int startHour   = [[startString substringWithRange:NSMakeRange(0, 2)] intValue];
                int startMin    = [[startString substringWithRange:NSMakeRange(2, 2)] intValue];
                int startSec    = [[startString substringWithRange:NSMakeRange(4, 2)] intValue];
                int startTimeInterval   = startHour * 3600 + startMin * 60 + startSec;

                int endHour = [[endString substringWithRange:NSMakeRange(0, 2)] intValue];
                int endMin  = [[endString substringWithRange:NSMakeRange(2, 2)] intValue];
                int endSec  = [[endString substringWithRange:NSMakeRange(4, 2)] intValue];
                int endTimeInterval = endHour * 3600 + endMin * 60 + endSec;

                KHJVideoModel *model = [[KHJVideoModel alloc] init];
                model.startTime = startTimeInterval + weakSelf.zeroTimeInterval; // 起始时间
                model.durationTime = endTimeInterval - startTimeInterval;// 视频时长
                if (type == 0) {        // 正常录制
                    model.recType = 0;
                }
                else if (type == 1) {   // 移动检测录制
                    model.recType = 2;
                }
                else if (type == 3) {   // 声音检测录制
                    model.recType = 4;
                }
                [weakSelf.videoList addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.zfTimeView.timesArr = weakSelf.videoList;
                [weakSelf.zfTimeView updateCurrentInterval:weakSelf.currentTimeInterval];
            });
        });
    }];
}

//- (void)noti_1077_key:(NSNotification *)obj
//{
//    [self reloadTableView];
//}

//- (void)reloadTableView
//{
//    WeakSelf
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        for (list<RemoteFileInfo_t*>::iterator i= mCurRemoteDirInfo->mRemoteFileInfoList.begin(); i != mCurRemoteDirInfo->mRemoteFileInfoList.end(); i++){
//            RemoteFileInfo_t *rfi = *i;
//            NSMutableDictionary *body = [NSMutableDictionary dictionary];
//            NSString *name = [NSString stringWithUTF8String:rfi->name.c_str()];
//            NSArray *timeArr1 = [name componentsSeparatedByString:@"."];
//            NSArray *timeArr2 = [timeArr1.firstObject componentsSeparatedByString:@"-"];
//            NSString *start = timeArr2.firstObject;
//            NSString *end = timeArr2.lastObject;
//            [body setValue:[NSString stringWithUTF8String:rfi->name.c_str()] forKey:@"name"];
//            [body setValue:[NSString stringWithUTF8String:rfi->path.c_str()] forKey:@"videoPath"];
//            [body setValue:@(rfi->size) forKey:@"size"];
//            [body setValue:start forKey:@"start"];
//            [body setValue:end forKey:@"end"];
//            [weakSelf.listArr addObject:body];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(exitListData:)]) {
//                if (weakSelf.listArr.count > 0) {
//                    [weakSelf.delegate exitListData:YES];
//                }
//                else {
//                    [weakSelf.delegate exitListData:NO];
//                }
//            }
//            [self->contentList reloadData];
//        });
//    });
//}

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
        _zeroTimeInterval -= 24*3600;
        _currentTimeInterval -= 24*3600;
        [self.videoList removeAllObjects];
        dateLAB.text = [KHJCalculate prevDay:dateLAB.text];
        [self getTimeLineDataWith:dateLAB.text];
        nextDayBtn.hidden = NO;
    }
    else if (sender.tag == 40) {
        // 选择日历
        JKUIPickDate *pickdate = [JKUIPickDate setDate];
        WeakSelf
        [pickdate passvalue:^(NSString *date) {
            self->dateLAB.text = date;
            [weakSelf chooseDate:date];
        }];
    }
    else if (sender.tag == 50) {
        // 后一天
        _zeroTimeInterval += 24*3600;
        _currentTimeInterval += 24*3600;
        [self.videoList removeAllObjects];
        dateLAB.text = [KHJCalculate nextDay:dateLAB.text];
        [self getTimeLineDataWith:dateLAB.text];
        if (_zeroTimeInterval == _todayTimeInterval) {
            nextDayBtn.hidden = YES;
        }
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
        vc.delegate = self;
        vc.date = dateLAB.text;
        vc.deviceID = self.deviceID;
        vc.exitVideoList = exitVideoList;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)chooseDate:(NSString *)date
{
    NSTimeInterval tt       = [KHJCalculate UTCDateFromLocalString2:date];
    NSTimeInterval cTime    = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval ct = _currentTimeInterval - [NSDate getZeroWithTimeInterverl:_currentTimeInterval];
    _currentTimeInterval = tt + ct;
    _zeroTimeInterval = [NSDate getZeroWithTimeInterverl:_currentTimeInterval];
    if (cTime - tt < 24*60*60) {//是当前日期
        nextDayBtn.hidden = _zeroTimeInterval == _todayTimeInterval;
    }
    else {//是之前日期
        [self.videoList removeAllObjects];
        [self getTimeLineDataWith:dateLAB.text];
        nextDayBtn.hidden = _zeroTimeInterval == _todayTimeInterval;
    }
}

- (void)getTimeLineDataWith:(NSString *)date
{
    NSString *time = [date stringByReplacingOccurrencesOfString:@"_" withString:@""];
    [[KHJDeviceManager sharedManager] getRemoteDirInfo_timeLine_with_deviceID:self.deviceID vi:0 date:[time intValue] resultBlock:^(NSInteger code) {}];
}

- (void)exitListData:(BOOL)isExit
{
    exitVideoList = isExit;
}

#pragma mark - 时间轴滑动

- (void)LineBeginMove
{
    CLog(@"LineBeginMove 停止回放");
//    [[KHJDeviceManager sharedManager] stopPlayback_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
}

- (void)timeLine:(ZFTimeLine *)timeLine moveToDate:(NSTimeInterval)date
{
    CLog(@" timeLine: moveToDate: %f",date - _zeroTimeInterval);
//    NSInteger index = [KHJCalculate binarySearchSDCardStart:self.videoList target:date];
//    if (index == -1) {
//        [self.view makeToast:@"当前没有视频！"];
//    }
//    else {
//        [self.view makeToast:KHJString(@"当前第 %ld 个视频，总共 %ld 个视频", index, self.videoList.count)];
//    }
//    if (self.videoList.count < index) {
//        return;
//    }
//    self.currentIndex = index;
}

#pragma mark - Timer ---------------------------------------------------------------

/* 开启倒计时 */
- (void)fireTimer
{
    [self stopTimer];
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:recordTimer forMode:NSRunLoopCommonModes];
    [recordTimer fire];
}

- (void)timerAction
{
    _recordTimes--;
    if (_recordTimes == 0) {
        [self stopTimer];
        self.activityView.hidden = YES;
    }
    else {
        self.activityView.hidden = NO;
    }
}

/* 停止倒计时 */
- (void)stopTimer
{
    if ([recordTimer isValid] || recordTimer != nil) {
        [recordTimer invalidate];
        _recordTimes = 2;
        recordTimer = nil;
    }
}


#pragma mark - ---------------------------------------------------------------

- (NSMutableArray *)MP4_taskArray
{
    if (!_MP4_taskArray) {
        _MP4_taskArray = [NSMutableArray array];
    }
    return _MP4_taskArray;
}

/* 添加MP4，预览图加载任务 */
- (void)addMP4_tasks:(runloopBlock)task
{
    [self.MP4_taskArray addObject:task];
}

// 添加runloop观察者
- (void)addMP4_RunloopObserver
{
    // 1.获取当前Runloop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
    // 2.定义观察者
    static CFRunLoopObserverRef defaultModeObserver;
    defaultModeObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                  kCFRunLoopBeforeWaiting,
                                                  YES,
                                                  0,
                                                  &MP4_callBack,
                                                  &context);
    // 3. 给当前Runloop添加观察者
    CFRunLoopAddObserver(runloop, defaultModeObserver, kCFRunLoopCommonModes);
    // C中出现 copy,retain,Create等关键字,都需要release
    CFRelease(defaultModeObserver);
}

static void MP4_callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    KHJVideoPlayer_hf_VC *vc  = (__bridge KHJVideoPlayer_hf_VC *)info;
    if (vc.MP4_taskArray.count == 0) {
        return;
    }
    runloopBlock block          = [vc.MP4_taskArray firstObject];
    if (block) {
        block();
    }
    [vc.MP4_taskArray removeObjectAtIndex:0];
    vc.recordTimes = 2;
}

@end
