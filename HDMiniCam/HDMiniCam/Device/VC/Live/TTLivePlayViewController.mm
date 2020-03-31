//
//  TTLivePlayViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/2/12.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTLivePlayViewController.h"

#pragma mark - 回放视频
#import "TTRebackPlayViewController.h"

#pragma mark - API
#import "JSONStructProtocal.h"
#import "TTFirmwareInterface_API.h"

#pragma mark - 截图
#import <Photos/Photos.h>
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/AssetsLibrary.h>

#pragma mark - 当前解码类型
extern TTDecordeType            decoderType;
#pragma mark - 是否直播录屏
extern NSString *               liveRecordPath;
#pragma mark - 直播是否录屏
extern TTRecordLiveStatus       liveRecordType;
#pragma mark - 彩色/黑白画面
extern IPCNetPicColorInfo_st    colorCfg;
#pragma mark - 监听
extern TTAudioPlayer *          audioPlayer;
#pragma mark - 对讲
extern TTAudioRecorder *        audioRecorder;

@interface TTLivePlayViewController ()
<
H264_H265_VideoDecoderDelegate
>
{
    
#pragma mark - 横屏组件
    // 导航条
    __weak IBOutlet UIView *hpNaviView;
    // 返回按钮
    __weak IBOutlet UIButton *hpBackBtn;
    // 横屏title
    __weak IBOutlet UILabel *hpTitleLab;
    // 质量按钮
    __weak IBOutlet UIButton *hpQualityBtn;
    // 横屏返回 stackView
    __weak IBOutlet UIView *hpStackBackView;
    // 横屏6个按钮
    __weak IBOutlet UIStackView *hpStackView;
    // 监听按钮
    __weak IBOutlet UIButton *hpListenBtn;
    // 对讲按钮
    __weak IBOutlet UIButton *hpTalkBtn;
    // 录屏按钮
    __weak IBOutlet UIButton *hpRecordBtn;
    
    
    UITapGestureRecognizer *tap;
}

@property (nonatomic, assign) BOOL isLandscape;

#pragma mark - someBtn
@property (weak, nonatomic) IBOutlet UIButton *spTalkBtn;
@property (weak, nonatomic) IBOutlet UIButton *spListenBtn;
@property (weak, nonatomic) IBOutlet UIImageView *playerImageView;

#pragma mark - 导航view
@property (weak, nonatomic) IBOutlet UIView *naviTitleView;
@property (weak, nonatomic) IBOutlet UILabel *naviTitleLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *naviTitleViewCH;


#pragma mark - 设置饱和度等
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *leftLab;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;

#pragma mark - 横屏时，要隐藏的view
@property (weak, nonatomic) IBOutlet UIView *hpHiddenView1;
@property (weak, nonatomic) IBOutlet UIView *hpHiddenView2;

#pragma mark - 录屏功能相关控件
@property (nonatomic, assign) NSInteger recordSec;  // 录屏时长
@property (nonatomic, strong) NSTimer *recordTimer; // 录屏定时器
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIView *recordSubView;
@property (weak, nonatomic) IBOutlet UILabel *recordSubView_timeLabel;

#pragma mark - 视频质量
@property (nonatomic, assign) int qualityLevel;
@property (weak, nonatomic) IBOutlet UILabel *qualityLab;

#pragma mark - 监听、对讲、截图
@property (weak, nonatomic) IBOutlet UIImageView *firstLeftImage;
@property (weak, nonatomic) IBOutlet UIImageView *firstRightImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondLeftImage;
@property (weak, nonatomic) IBOutlet UILabel *firstLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstRightLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLeftLabel;

#pragma mark - 菊花
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSMutableDictionary *pictureParams;
@property (nonatomic, strong) NSMutableDictionary *pictureParams_second;

@end

@implementation TTLivePlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
    [self customizeAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    decoderType = TTDecorder_none;
    [self stopTalk];
    [self stopListen];
    liveRecordType = TTRecordLive_Normal;
    [[TTFirmwareInterface_API sharedManager] stopGetVideo_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
    [[TTFirmwareInterface_API sharedManager] stopGetAudio_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
    [self sp_releaseDecoder];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getVideoStatus];
}

#pragma mark - customize

- (void)customizeDataSource
{
    decoderType = TTDecorde_live;
    self.sp_deviceID = self.deviceID;
    hpTitleLab.text = self.deviceInfo.deviceName;
    self.naviTitleLab.text = self.deviceInfo.deviceName;
    [self startVideo];
}

- (void)customizeAppearance
{
    self.slider.continuous = NO;
    [self addNSNotificationCenter];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.playerImageView addGestureRecognizer:tap];
}

#pragma MARK - H264_H265_VideoDecoderDelegate

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    self.playerImageView.image = image;
}

- (IBAction)topBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
#pragma mark - 返回上个界面
        [self addPopNavigation];
    }
    else if (sender.tag == 50) {
#pragma mark - 查看回放界面
        [self gotoReback];
    }
    else if (sender.tag == 60) {
#pragma mark - 横竖屏切换
        [self changePictureToLandscape];
    }
}

- (IBAction)hpSixBtnAction:(UIButton *)sender
{
    if (sender.tag == 0) {
#pragma mark - 横屏监听
        [self landscape_listenAction];
    }
    else if (sender.tag == 1) {
#pragma mark - 横屏对讲
        [self landscape_talkAction];
    }
    else if (sender.tag == 2) {
#pragma mark - 横屏拍照
        [self takePhoto];
    }
    else if (sender.tag == 3) {
#pragma mark - 横屏录像
        [self landscape_recordAction];
    }
    else if (sender.tag == 4) {
#pragma mark - 横屏垂直镜像
        [self landscape_filp_vertical_Action];
    }
    else if (sender.tag == 5) {
#pragma mark - 横屏垂直镜像
        [self landscape_filp_level_Action];
    }
}



- (IBAction)fiveBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
#pragma mark - 全屏
        [self fullScreenAction];
    }
    else if (sender.tag == 20) {
#pragma mark - 设置
        [self sp_setup];
    }
    else if (sender.tag == 30) {
#pragma mark - 录像
        [self sp_record];
    }
    else if (sender.tag == 40) {
        // 标清
        sender.selected = !sender.selected;
        [self gotoChangeQuality];
    }
}

- (IBAction)eightBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
#pragma mark - 监听功能
        [self listenAction];
    }
    else if (sender.tag == 20) {
#pragma mark - 对讲功能
        [self talkAction];
    }
    else if (sender.tag == 30) {
        // 截图
        [self takePhoto];
    }
    else if (sender.tag == 40) {
        // 暂无
    }
    else if (sender.tag == 50) {
        // 暂无
    }
    else if (sender.tag == 60) {
        // 暂无
    }
    else if (sender.tag == 70) {
        // 暂无
    }
    else if (sender.tag == 80) {
        // 暂无
    }
}

- (IBAction)sliderAction:(UISlider *)sender
{
    int persent = (int)(sender.value*100);
    [self setSliderValue:persent*2.55 persent:persent];
}

#pragma mark - 设置slider的值

- (void)setSliderValue:(int)value persent:(int)persent
{
    self.rightLab.text = TTStr(@"%d%%",persent);
    [self.pictureParams_second removeAllObjects];
    if ([self.leftLab.text isEqualToString:TTLocalString(@"BaoHDu_", nil)]) {
        [self.pictureParams_second setValue:TTStr(@"%d",value) forKey:@"Saturtion"];
        [[TTFirmwareInterface_API sharedManager] setSaturationLevel_with_deviceID:self.deviceID level:value reBlock:^(NSInteger code) {}];
    }
    else if ([self.leftLab.text isEqualToString:TTLocalString(@"LiangDu_", nil)]) {
        [self.pictureParams_second setValue:TTStr(@"%d",value) forKey:@"Brightness"];
        [[TTFirmwareInterface_API sharedManager] setBrightnessLevel_with_deviceID:self.deviceID level:value reBlock:^(NSInteger code) {}];
    }
    else if ([self.leftLab.text isEqualToString:TTLocalString(@"RuiDu_", nil)]) {
        [self.pictureParams_second setValue:TTStr(@"%d",value) forKey:@"Acutance"];
        [[TTFirmwareInterface_API sharedManager] setAcutanceLevel_with_deviceID:self.deviceID level:value reBlock:^(NSInteger code) {}];
    }
    else if ([self.leftLab.text isEqualToString:TTLocalString(@"DuiBiDu_", nil)]) {
        [self.pictureParams_second setValue:TTStr(@"%d",value) forKey:@"Contrast"];
        [[TTFirmwareInterface_API sharedManager] setCompareColorLevel_with_deviceID:self.deviceID level:value reBlock:^(NSInteger code) {}];
    }
}

#pragma mark - 录像

/// 开始录像
- (void)gotoStartRecord
{
    self.recordSubView.hidden = NO;
    [self fireTimer];
    // 直播录屏，截取数据
    liveRecordType = TTRecordLive_Record;
    liveRecordPath = [[[TTFileManager sharedModel] getLiveRecordVideoWithDeviceID:self.deviceID] stringByAppendingPathComponent:[[TTFileManager sharedModel] getVideoNameWithFileType:@"mp4" deviceID:self.deviceID]];
}

/// 停止录像
- (void)gotoStopRecord
{
    self.recordSubView.hidden = YES;
    // 结束直播录屏，停止截取数据
    liveRecordPath = @"";
    liveRecordType = TTRecordLive_SRecod;
}

#pragma mark - 切换清晰度

- (void)gotoChangeQuality
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:TTLocalString(@"setPictQality_", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:TTLocalString(@"kd_", nil)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:2];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:TTLocalString(@"hd_", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:1];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:TTLocalString(@"sd_", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:0];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil)
                                                     style:UIAlertActionStyleCancel handler:nil];

    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setQualityWith:(int)level
{
    // 0 标清，1 高清，2 4K超清
    self.qualityLevel = level;
    [[TTFirmwareInterface_API sharedManager] setQualityLevel_with_deviceID:self.deviceID level:self.qualityLevel reBlock:^(NSInteger code) {}];
}

#pragma mark - 监听

- (void)startListen
{
    [[TTFirmwareInterface_API sharedManager] startGetAudio_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
    [audioPlayer start];
}

- (void)stopListen
{
    [audioPlayer stop];
    [[TTFirmwareInterface_API sharedManager] stopGetAudio_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
}

#pragma mark - 对讲

- (void)startTalk
{
    [[TTFirmwareInterface_API sharedManager] startTalk_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
    [audioRecorder start];
}

- (void)stopTalk
{
    [audioRecorder stop];
    [[TTFirmwareInterface_API sharedManager] stopTalk_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
}

#pragma mark - Timer

/* 开启倒计时 */
- (void)fireTimer
{
    [self stopTimer];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.recordTimer forMode:NSRunLoopCommonModes];
    [self.recordTimer fire];
}

- (void)timerAction
{
    int hour = (int)self.recordSec / 3600;
    int min  = (int)(self.recordSec - hour * 3600) / 60;
    int sec  = (int)(self.recordSec - hour * 3600 - min * 60);
    self.recordSec ++;
    self.recordSubView_timeLabel.text = TTStr(@"%02d:%02d:%02d", hour, min, sec);
}

/* 停止倒计时 */
- (void)stopTimer
{
    if ([self.recordTimer isValid] ||
        self.recordTimer != nil) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
        self.recordSec = 0;
    }
}

#pragma mark - 截图

- (void)saveImage
{
    UIImage *screenImage = [self screenshot_imageView:self.playerImageView];
    NSString *path_document = NSHomeDirectory();
    NSString *pString = [NSString stringWithFormat:@"/Documents/%@.png",self.deviceInfo.deviceID];
    NSString *imagePath = [path_document stringByAppendingString:pString];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(screenImage) writeToFile:imagePath atomically:YES];
    
    #pragma  mark - 获取当天的日期：年/月/日
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay;
    NSDateComponents *components = [calendar components:unit fromDate:today];
    NSString *year = TTStr(@"%ld", (long)[components year]);
    NSString *month = TTStr(@"%02ld", (long)[components month]);
    NSString *day = TTStr(@"%02ld", (long)[components day]);
    NSString *imagePath1 = [[[TTFileManager sharedModel] getScreenShotWithDeviceID:self.deviceInfo.deviceID] stringByAppendingPathComponent:TTStr(@"%@%@%@.png",year,month,day)];
    [UIImagePNGRepresentation(screenImage) writeToFile:imagePath1 atomically:YES];
}

- (UIImage *)screenshot_imageView:(UIImageView *)imageView
{
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size,YES,[UIScreen mainScreen].scale);
    [imageView drawViewHierarchyInRect:imageView.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSDictionary *)getTodayDate
{
    NSDate *today = [NSDate date];
    /* 日历类 */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    /* 日历构成的格式 */
    NSCalendarUnit unit = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay;
    /* 获取对应的时间点 */
    NSDateComponents *components = [calendar components:unit fromDate:today];
    
    NSString *year = [NSString stringWithFormat:@"%ld", (long)[components year]];
    NSString *month = [NSString stringWithFormat:@"%02ld", (long)[components month]];
    NSString *day = [NSString stringWithFormat:@"%02ld", (long)[components day]];
    
    NSMutableDictionary *todayDic = [[NSMutableDictionary alloc] init];
    [todayDic setObject:year forKey:@"year"];
    [todayDic setObject:month forKey:@"month"];
    [todayDic setObject:day forKey:@"day"];
    return todayDic;
}

#pragma mark - 初始化图像参数

- (NSMutableDictionary *)pictureParams
{
    if (!_pictureParams) {
        _pictureParams = [NSMutableDictionary dictionary];
    }
    return _pictureParams;
}

- (NSMutableDictionary *)pictureParams_second
{
    if (!_pictureParams_second) {
        _pictureParams_second = [NSMutableDictionary dictionary];
    }
    return _pictureParams_second;
}

#pragma mark - 开始获取视频数据

- (void)startVideo
{
    [self.indicatorView startAnimating];
    self.qualityLevel = 0;
    self.qualityLab.text = TTLocalString(@"sd_", nil);
    [[TTFirmwareInterface_API sharedManager] startGetVideo_with_deviceID:self.deviceID quality:1 reBlock:^(NSInteger code) {}];
}

#pragma mark - 获取视频状态

- (void)getVideoStatus
{
    /// 获取饱和度、liangdu_、duibidu_、ruidu_
    [[TTFirmwareInterface_API sharedManager] getSaturationLevel_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
    /// 获取色彩/黑白模式
    [[TTFirmwareInterface_API sharedManager] getIRModel_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
}

#pragma mark - 添加通知

- (void)addNSNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetFilpCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetIRModeCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnGetIRModeCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetQualityLevelCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnGetSaturationLevelCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetStration_Actce_Britness_CompColor_CmdResult_noti_key" object:nil];
}

#pragma mark - 通知 @"OnSetStration_Actce_Britness_CompColor_CmdResult_noti_key" 通知

- (void)addOnSetSaturationLevelCmdResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetSaturationLevelCmdResult) name:@"OnSetStration_Actce_Britness_CompColor_CmdResult_noti_key" object:nil];
}

- (void)OnSetSaturationLevelCmdResult
{
    if (self.pictureParams_second.count > 0) {
        NSString *key = self.pictureParams_second.allKeys.firstObject;
        NSString *value = self.pictureParams_second.allValues.firstObject;
        [self.pictureParams setValue:value forKey:key];
        [self.view makeToast:TTLocalString(@"setDevicInfoSucce_", nil)];
    }
}

#pragma mark - 添加 @"OnGetSaturationLevelCmdResult_noti_key" 通知

- (void)addOnGetSaturationLevelCmdResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGetSaturationLevelCmdResult:) name:@"OnGetSaturationLevelCmdResult_noti_key" object:nil];
}

- (void)OnGetSaturationLevelCmdResult:(NSNotification *)noti
{
    self.pictureParams = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)noti.object];
}

#pragma mark - 添加 UIDeviceOrientationDidChangeNotification 通知

- (void)addOrientChange
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientChange:(NSNotification *)notification
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationPortrait) {
        NSLog(@"竖屏");
        if (self.isLandscape) {
            [self becomeShuPing];
        }
    }
    else if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight) {
        NSLog(@"横屏");
        if (!self.isLandscape) {
            [self becomeHengPing];
        }
    }
}


- (void)becomeShuPing
{
    self.isLandscape = NO;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape = NO;//关闭横屏仅允许竖屏
    [UIDevice TTurnAroundDirection:UIInterfaceOrientationPortrait];
    self.naviTitleView.alpha = 1;
    hpBackBtn.alpha = 0;
    hpNaviView.alpha = 0;
    hpTitleLab.alpha = 0;
    hpQualityBtn.alpha = 0;
    hpStackView.alpha = 0;
    hpStackBackView.alpha = 0;
    self.slideView.hidden = YES;
    self.hpHiddenView1.hidden = NO;
    self.hpHiddenView2.hidden = NO;
    self.naviTitleViewCH.constant = 44;
}

- (void)becomeHengPing
{
    self.isLandscape = YES;
    // 全屏
    hpBackBtn.alpha = 1;
    hpNaviView.alpha = 1;
    hpTitleLab.alpha = 1;
    hpQualityBtn.alpha = 0.25;
    hpStackView.alpha = 1;
    hpStackBackView.alpha = 0.25;
    self.slideView.hidden = YES;
    self.hpHiddenView1.hidden = YES;
    self.hpHiddenView2.hidden = YES;
    self.naviTitleView.alpha = 0;
    self.naviTitleViewCH.constant = 0;
    AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape   = YES;
    [UIDevice TTurnAroundDirection:UIInterfaceOrientationLandscapeRight];
}

#pragma mark - 添加 @"OnSetQualityLevelCmdResult_noti_key" 通知

- (void)addOnSetQualityLevelCmdResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetQualityLevelCmdResult) name:@"OnSetQualityLevelCmdResult_noti_key" object:nil];
}

- (void)OnSetQualityLevelCmdResult
{
    // 0 标清，1 高清，2 4K超清
    if (self.qualityLevel == 0)
        self.qualityLab.text = TTLocalString(@"sd_", nil);
    else if (self.qualityLevel == 1)
        self.qualityLab.text = TTLocalString(@"hd_", nil);
    else if (self.qualityLevel == 2)
        self.qualityLab.text = TTLocalString(@"kd_", nil);
}

#pragma mark - 添加 @"OnSetQualityLevelCmdResult_noti_key" 通知

- (void)addOnGetIRModeCmdResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGetIRModeCmdResult) name:@"OnGetIRModeCmdResult_noti_key" object:nil];
}

- (void)OnGetIRModeCmdResult
{
    if (colorCfg.Type == 0) {
        TLog(@"彩色画面");
    }
    else {
        TLog(@"黑白画面");
    }
}

#pragma mark - 添加 @"OnSetQualityLevelCmdResult_noti_key" 通知
- (void)addOnSetIRModeCmdResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetIRModeCmdResult) name:@"OnSetIRModeCmdResult_noti_key" object:nil];
}

- (void)OnSetIRModeCmdResult
{
    [self.view makeToast:TTLocalString(@"chageSucce_", nil)];
}

#pragma mark - 添加 @"OnSetQualityLevelCmdResult_noti_key" 通知

- (void)addOnSetFilpCmdResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetFilpCmdResult) name:@"OnSetFilpCmdResult_noti_key" object:nil];
}

- (void)OnSetFilpCmdResult
{
    [self.view makeToast:TTLocalString(@"chageSucce_", nil)];
}

#pragma mark - 返回上个界面
- (void)addPopNavigation
{
    [self saveImage];
    [self.navigationController popViewControllerAnimated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(loadCellPic:)]) {
        [_delegate loadCellPic:self.row];
    }
}

#pragma mark - 查看回放界面
- (void)gotoReback
{
    TTRebackPlayViewController *vc = [[TTRebackPlayViewController alloc] init];
    vc.info = self.deviceInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 横竖屏切换
- (void)changePictureToLandscape
{
    self.isLandscape = NO;
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape = NO;
    [UIDevice TTurnAroundDirection:UIInterfaceOrientationPortrait];
    hpBackBtn.alpha = 0;
    hpNaviView.alpha = 0;
    hpTitleLab.alpha = 0;
    hpQualityBtn.alpha = 0;
    hpStackView.alpha = 0;
    hpStackBackView.alpha = 0;
    self.slideView.hidden = YES;
    self.hpHiddenView1.hidden = NO;
    self.hpHiddenView2.hidden = NO;
    
    self.naviTitleView.alpha = 1;
    self.naviTitleViewCH.constant = 44;
}

#pragma mark - 监听功能
- (void)listenAction
{
    self.spListenBtn.selected = !self.spListenBtn.selected;
    hpListenBtn.selected = self.spListenBtn.selected;
    
    if (self.spListenBtn.selected) {
        [self startListen];
        self.firstLeftImage.highlighted = YES;
    }
    else {
        [self stopListen];
        self.firstLeftImage.highlighted = NO;
    }
}

#pragma mark - 对讲功能
- (void)talkAction
{
    self.spTalkBtn.selected = !self.spTalkBtn.selected;
    hpTalkBtn.selected = self.spTalkBtn.selected;
    if (self.spTalkBtn.selected) {
        [self startTalk];
        self.firstRightImage.highlighted = YES;
    }
    else {
        [self stopTalk];
        self.firstRightImage.highlighted = NO;
    }
}

#pragma mark - 截图
- (void)takePhoto
{
    NSString *savedImagePath = [[[TTFileManager sharedModel] getliveScreenShotWithDeviceID:self.deviceID] stringByAppendingPathComponent:[[TTFileManager sharedModel] getVideoNameWithFileType:@"jpg" deviceID:self.deviceID]];
    UIImage *screenImage = [self snapsHotView:self.playerImageView];
    NSData *imagedata = UIImageJPEGRepresentation(screenImage,0.5);
    BOOL is = [imagedata writeToFile:savedImagePath atomically:YES];
    if (is) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPictureVC_noti" object:nil];
        [self loadImageFinished:[[UIImage alloc] initWithContentsOfFile:savedImagePath]];
    }
    else {
        [[TTHub shareHub] showText:TTLocalString(@"getPicFail_", nil) addToView:self.view];
    }
}
- (UIImage *)snapsHotView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,[UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)loadImageFinished:(UIImage *)image
{
    PHAuthorizationStatus status =  [PHPhotoLibrary authorizationStatus];
   if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TTLocalString(@"tips_", nil)
                                                                                message:TTLocalString(@"setPhotoQuanX_", nil)
                                                                         preferredStyle:(UIAlertControllerStyleAlert)];
       UIAlertAction *action = [UIAlertAction actionWithTitle:TTLocalString(@"IGetttttt_it", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
           
       }];
       [alertController addAction:action];
       [self presentViewController:alertController animated:YES completion:nil];
   }
   else {
       [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
           [PHAssetChangeRequest creationRequestForAssetFromImage:image];
       } completionHandler:^(BOOL success, NSError * _Nullable error) {
           NSLog(@"保存相册success = %d, error = %@", success, error);
           if (success) {
               NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TT_screenShot" ofType:@"mp3"];
               NSURL *url = [NSURL fileURLWithPath:filePath];
               [[TTCommon share] playVoiceWithURL:url];
           }
       }];
   }
}

#pragma mark - 横屏监听
- (void)landscape_listenAction
{
    hpListenBtn.selected = !hpListenBtn.selected;
    self.spListenBtn.selected = hpListenBtn.selected;
    if (hpListenBtn.selected) {
        [self startListen];
        self.firstLeftImage.highlighted = YES;
    }
    else {
        [self stopListen];
        self.firstLeftImage.highlighted = NO;
    }
}

#pragma mark - 横屏对讲
- (void)landscape_talkAction
{
    hpTalkBtn.selected = !hpTalkBtn.selected;
    self.spTalkBtn.selected = hpTalkBtn.selected;
    if (hpTalkBtn.selected) {
        [self startTalk];
        self.firstRightImage.highlighted = YES;
    }
    else {
        [self stopTalk];
        self.firstRightImage.highlighted = NO;
    }
}

#pragma mark - 横屏录像
- (void)landscape_recordAction
{
    hpRecordBtn.selected = !hpRecordBtn.selected;
    self.recordBtn.selected = hpRecordBtn.selected;
    if (hpRecordBtn.selected) {
        [self gotoStartRecord];
    }
    else {
        [self gotoStopRecord];
    }
}

#pragma mark - 设置画面彩色/黑色
- (void)setDeviceIRModel
{
    int type = 0;
    if (colorCfg.Type == 0) {
        type = 1;
    }
    else {
        type = 0;
    }
    [[TTFirmwareInterface_API sharedManager] setIRModel_with_deviceID:self.deviceID type:type reBlock:^(NSInteger code) {}];
}

#pragma mark - 横屏垂直镜像
- (void)landscape_filp_vertical_Action
{
    [[TTFirmwareInterface_API sharedManager] setFilp_with_deviceID:self.deviceID flip:1 mirror:0 reBlock:^(NSInteger code) {}];
}

#pragma mark - 横屏垂直镜像
- (void)landscape_filp_level_Action
{
    [[TTFirmwareInterface_API sharedManager] setFilp_with_deviceID:self.deviceID flip:0 mirror:1 reBlock:^(NSInteger code) {}];
}

#pragma mark - 恢复默认值
- (void)setDeviceDefault
{
    TTWeakSelf
    [[TTFirmwareInterface_API sharedManager] setDefault_with_deviceID:self.deviceID reBlock:^(NSInteger code) {
        if (code >= 0) {
            [weakSelf.view makeToast:TTLocalString(@"hadBcomeDefalt_", nil)];
        }
        else {
            [weakSelf.view makeToast:TTLocalString(@"reTry_", nil)];
        }
    }];
}

#pragma mark - 全屏按钮
- (void)fullScreenAction
{
    // 全屏
    self.isLandscape = YES;
    self.naviTitleView.alpha = 0;
    hpBackBtn.alpha = 1;
    hpNaviView.alpha = 1;
    hpTitleLab.alpha = 1;
    hpQualityBtn.alpha = 0.25;
    hpStackView.alpha = 1;
    hpStackBackView.alpha = 0.25;
    
    self.naviTitleViewCH.constant = 0;
    self.slideView.hidden = YES;
    self.hpHiddenView1.hidden = YES;
    self.hpHiddenView2.hidden = YES;
    
    AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.canLandscape   = YES;
    [UIDevice TTurnAroundDirection:UIInterfaceOrientationLandscapeRight];
}

#pragma mark - 竖屏录像
- (void)sp_record
{
    self.recordBtn.selected = !self.recordBtn.selected;
    hpRecordBtn.selected = self.recordBtn.selected;
    if (self.recordBtn.selected) {
        [self gotoStartRecord];
    }
    else {
        [self gotoStopRecord];
    }
}

#pragma mark - 竖屏设置
- (void)sp_setup
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:TTLocalString(@"picSet_", nil)
                                                                       message:TTLocalString(@"SXSet_", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:TTLocalString(@"BaoHDu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:1];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:TTLocalString(@"LiangDu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:2];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:TTLocalString(@"RuiDu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:3];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:TTLocalString(@"DuiBiDu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:4];
    }];
    NSString *picColor = colorCfg.Type == 0 ? TTLocalString(@"BcomeColr_", nil) : TTLocalString(@"BcomeBlac_", nil);
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:picColor style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:5];
    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:TTLocalString(@"ChuiZhiJingXiang_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:6];
    }];
    UIAlertAction *config6 = [UIAlertAction actionWithTitle:TTLocalString(@"ShuiPingJingXiang_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:7];
    }];
    UIAlertAction *config7 = [UIAlertAction actionWithTitle:TTLocalString(@"BcomeDefatValu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:8];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cacel_", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:config3];
    [alertview addAction:config4];
    [alertview addAction:config5];
    [alertview addAction:config6];
    [alertview addAction:config7];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)chooseSetupWith:(NSInteger)index
{
    NSArray *arr = @[
    TTLocalString(@"BaoHDu_", nil),
    TTLocalString(@"LiangDu_", nil),
    TTLocalString(@"RuiDu_", nil),
    TTLocalString(@"DuiBiDu_", nil),
    TTLocalString(@"colo/blac_", nil),
    TTLocalString(@"ChuiZhiJingXiang_", nil),
    TTLocalString(@"ShuiPingJingXiang_", nil),
    TTLocalString(@"BcomeDefatValu_", nil)];
    
    self.leftLab.text = arr[index - 1];
    if (index == 1 || index == 2 || index == 3 || index == 4) {
#pragma mark - 选择图像参数
        [self choosePicturePramas];
    }
    else if (index == 5) {
#pragma mark - 设置画面彩色/黑色
        [self setDeviceIRModel];
    }
    else if (index == 6) {
#pragma mark - 横屏垂直镜像
        [self landscape_filp_vertical_Action];
    }
    else if (index == 7) {
#pragma mark - 横屏垂直镜像
        [self landscape_filp_level_Action];
    }
    else if (index == 8) {
#pragma mark - 恢复默认值
        [self setDeviceDefault];
    }
    else {
        self.slideView.hidden = YES;
    }
}

#pragma mark - 选择图像参数
- (void)choosePicturePramas
{
    self.slideView.hidden = NO;
    if ([self.leftLab.text isEqualToString:TTLocalString(@"BaoHDu_", nil)]) {
        float percent = [self.pictureParams[@"Saturtion"] intValue]/255.0;
        self.slider.value = percent;
        self.rightLab.text = TTStr(@"%d%%",(int)(percent*100));
    }
    else if ([self.leftLab.text isEqualToString:TTLocalString(@"LiangDu_", nil)]) {
        float percent = [self.pictureParams[@"Brightness"] intValue]/255.0;
        self.slider.value = percent;
        self.rightLab.text = TTStr(@"%d%%",(int)(percent*100));
    }
    else if ([self.leftLab.text isEqualToString:TTLocalString(@"RuiDu_", nil)]) {
        float percent = [self.pictureParams[@"Acutance"] intValue]/255.0;
        self.slider.value = percent;
        self.rightLab.text = TTStr(@"%d%%",(int)(percent*100));
    }
    else if ([self.leftLab.text isEqualToString:TTLocalString(@"DuiBiDu_", nil)]) {
        float percent = [self.pictureParams[@"Contrast"] intValue]/255.0;
        self.slider.value = percent;
        self.rightLab.text = TTStr(@"%d%%",(int)(percent*100));
    }
}

#pragma mark - tap手势
- (void)tapAction
{
    if (self.isLandscape) {
        hpBackBtn.hidden = !hpBackBtn.hidden;
        hpNaviView.hidden = !hpNaviView.hidden;
        hpTitleLab.hidden = !hpTitleLab.hidden;
        hpQualityBtn.hidden = !hpQualityBtn.hidden;
        hpStackView.hidden = !hpStackView.hidden;
        hpStackBackView.hidden = !hpStackBackView.hidden;
    }
    else {
        if (!self.slideView.hidden)
            self.slideView.hidden = YES;
    }
}

@end
