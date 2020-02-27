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
#import "KHJPickerView.h"
#import "KHJVideoModel.h"
#import "JSONStructProtocal.h"

extern RecordDatePeriod_t gRecordDatePeriod;
/**
 list<RecordPeriod_t*> mNormalRecordPeriodList;              // 正常记录期间列表
 list<RecordPeriod_t*> mMoveDetectRecordPeriodList;          // 移动检测记录期间列表
 list<RecordPeriod_t*> mObjectDetectRecordPeriodList;        // 对象检测记录期间列表
 list<RecordPeriod_t*> mSoundDetectRecordPeriodList;         // 声音检测记录期间列表
 list<RecordPeriod_t*> mCryDetectRecordPeriodList;           // 哭泣检测记录时间列表
 list<RecordPeriod_t*> mHumanShapeDetectRecordPeriodList;    // 人体形状检测记录期间列表
 list<RecordPeriod_t*> mFaceDetectRecordPeriodList;          // 人脸检测记录周期列表
 */

@interface KHJVideoPlayer_hf_VC ()<ZFTimeLineDelegate,KHJBackPlayListVCSaveListDelegate>
{
    __weak IBOutlet UILabel *nameLab;
    __weak IBOutlet UIView *reconnectView;
    __weak IBOutlet UIButton *preDayBtn;
    __weak IBOutlet UILabel *dateLAB;
    __weak IBOutlet UIButton *nextDayBtn;
    
    __weak IBOutlet UIView *timeLineContent;
    __weak IBOutlet UIButton *recordBtn;
    
    __weak IBOutlet UILabel *listenLab;
    __weak IBOutlet UIImageView *listenImgView;
    
    BOOL exitVideoList;
    
    // 当天零点时间戳
    NSTimeInterval currentTimeInterval;
    NSTimeInterval zeroTimeInterval;
    NSTimeInterval todayTimeInterval;
}

@property (nonatomic, strong) NSMutableArray *videoList;

@property (nonatomic, strong) KHJPickerView *datePickerView;
@property (nonatomic, copy) ZFTimeLine *zfTimeView;

@end

@implementation KHJVideoPlayer_hf_VC

- (KHJPickerView *)datePickerView
{
    if (!_datePickerView) {
//        if (IS_IPHONE_5) {
//            _datePickerView = [[KHJPickerView alloc] initWithFrame:CGRectMake(0, segment.frame.size.height+segment.frame.origin.y+6, SCREEN_WIDTH, 40)];
//        }
//        else {
//            _datePickerView = [[KHJPickerView alloc] initWithFrame:CGRectMake(0, segment.frame.size.height+segment.frame.origin.y+10, SCREEN_WIDTH, 40)];
//        }
        _datePickerView.hidden = YES;
    }
    return _datePickerView;
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
    nextDayBtn.hidden = YES;
    [timeLineContent addSubview:self.zfTimeView];
    
    NSDate *date = [NSDate date];
    currentTimeInterval = [date timeIntervalSince1970];
    todayTimeInterval = [NSDate getZeroWithTimeInterverl:currentTimeInterval];
    zeroTimeInterval = [NSDate getZeroWithTimeInterverl:currentTimeInterval];

    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy_MM_dd"];
    dateLAB.text = [formatter1 stringFromDate:date];
    [self getTimeLineDataWith:dateLAB.text];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_timeLineInfo_1075_key:) name:noti_timeLineInfo_1075_KEY object:nil];
}

- (void)noti_timeLineInfo_1075_key:(NSNotification *)noti
{
    WeakSelf
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (list<RecordPeriod_t*>::iterator i = gRecordDatePeriod.mTotalRecordList.begin(); i != gRecordDatePeriod.mTotalRecordList.end(); i++) {

            RecordPeriod_t *rfi = *i;
            NSString *start = KHJString(@"%d",rfi->start);
            NSString *end = KHJString(@"%d",rfi->end);
            int type = rfi->type;
            NSString *startString   = KHJString(@"%06d",[start intValue]);
            NSString *endString     = KHJString(@"%06d",[end intValue]);

            int startHour = [[startString substringWithRange:NSMakeRange(0, 2)] intValue];
            int startMin = [[startString substringWithRange:NSMakeRange(2, 2)] intValue];
            int startSec = [[startString substringWithRange:NSMakeRange(4, 2)] intValue];
            int startTimeInterval = startHour * 3600 + startMin * 60 + startSec;
            
            int endHour = [[endString substringWithRange:NSMakeRange(0, 2)] intValue];
            int endMin = [[endString substringWithRange:NSMakeRange(2, 2)] intValue];
            int endSec = [[endString substringWithRange:NSMakeRange(4, 2)] intValue];
            int endTimeInterval = endHour * 3600 + endMin * 60 + endSec;

            KHJVideoModel *model = [[KHJVideoModel alloc] init];
            model.startTime = startTimeInterval + self->zeroTimeInterval; // 起始时间
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
            CLog(@"weakSelf.videoList.count ======= %ld",(long)weakSelf.videoList.count);
            weakSelf.zfTimeView.timesArr = weakSelf.videoList;
            [weakSelf.zfTimeView updateCurrentInterval:self->currentTimeInterval];
        });
    });
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
        zeroTimeInterval -= 24*3600;
        currentTimeInterval -= 24*3600;
        [self.videoList removeAllObjects];
        dateLAB.text = [KHJCalculate prevDay:dateLAB.text];
        [self getTimeLineDataWith:dateLAB.text];
        nextDayBtn.hidden = NO;
    }
    else if (sender.tag == 40) {
        // 选择日历
        
    }
    else if (sender.tag == 50) {
        // 后一天
        zeroTimeInterval += 24*3600;
        currentTimeInterval += 24*3600;
        [self.videoList removeAllObjects];
        dateLAB.text = [KHJCalculate nextDay:dateLAB.text];
        [self getTimeLineDataWith:dateLAB.text];
        if (zeroTimeInterval == todayTimeInterval) {
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
        vc.deviceID = self.deviceID;
        vc.exitVideoList = exitVideoList;
        [self.navigationController pushViewController:vc animated:YES];
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
    CLog(@"LineBeginMove");
}

- (void)timeLine:(ZFTimeLine *)timeLine moveToDate:(NSTimeInterval)date
{
    CLog(@" timeLine: moveToDate: ");
}


@end
