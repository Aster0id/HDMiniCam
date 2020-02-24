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
    __weak IBOutlet UIButton *nextDayBtn;
    
    __weak IBOutlet UIView *timeLineContent;
    __weak IBOutlet UIButton *recordBtn;
    
    __weak IBOutlet UILabel *listenLab;
    __weak IBOutlet UIImageView *listenImgView;
    
    BOOL exitVideoList;
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
    [timeLineContent addSubview:self.zfTimeView];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *str = [formatter stringFromDate:date];
    [[KHJDeviceManager sharedManager] getRemoteDirInfo_timeLine_with_deviceID:self.deviceID vi:0 date:[str intValue] resultBlock:^(NSInteger code) {
        CLog(@"code = %ld",(long)code);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_timeLineInfo_1075_key:) name:noti_timeLineInfo_1075_KEY object:nil];
}

- (void)noti_timeLineInfo_1075_key:(NSNotification *)noti
{
//    NSDictionary *body = (NSDictionary *)noti.object;
//    NSDictionary *RecInfo = body[@"RecInfo"];
//    CLog(@"vi = %@",RecInfo[@"vi"]);
//    CLog(@"date = %@",RecInfo[@"date"]);
//    CLog(@"period = %@",RecInfo[@"period"]);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (list<RecordPeriod_t*>::iterator i= gRecordDatePeriod.mTotalRecordList.begin(); i != gRecordDatePeriod.mTotalRecordList.end(); i++) {

            RecordPeriod_t *rfi = *i;
            NSString *start = KHJString(@"%d",rfi->start);
            NSString *end = KHJString(@"%d",rfi->end);
            int type = rfi->type;
            if (type == 0) {
                CLog(@"thread = %@,正常录制 start = %@ end = %@", [NSThread currentThread], start, end);
            }
            else if (type == 1) {
                CLog(@"移动检测录制 start = %@ end = %@",start,end);
            }
            else if (type == 3) {
                CLog(@"声音检测录制 start = %@ end = %@",start,end);
            }
            
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
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(exitListData:)]) {
//                if (weakSelf.listArr.count > 0) {
//                    [weakSelf.delegate exitListData:YES];
//                }
//                else {
//                    [weakSelf.delegate exitListData:NO];
//                }
//            }
//            [self->contentList reloadData];
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
        vc.delegate = self;
        vc.deviceID = self.deviceID;
        vc.exitVideoList = exitVideoList;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
