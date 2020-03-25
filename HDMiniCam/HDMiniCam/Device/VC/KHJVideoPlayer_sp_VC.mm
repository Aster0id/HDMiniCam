//
//  KHJVideoPlayer_sp_VC.m
//  HDMiniCam
//
//  Created by kevin on 2020/2/12.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayer_sp_VC.h"
#import "KHJVideoPlayer_hf_VC.h"
#import "KHJDeviceManager.h"
//
#import "JSONStructProtocal.h"
//
#import "TTPlayVoiceManager.h"
#import <Photos/Photos.h>
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "UIDevice+TFDevice.h"

//  当前解码类型
extern TTDecordeType currentDecorderType;
// 是否直播录屏
extern NSString *liveRecordVideoPath;
extern TTRecordLiveStatus liveRecordType;
// 彩色/黑白画面
extern IPCNetPicColorInfo_st picColorCfg;
// 监听
extern XBAudioUnitPlayer *audioPlayer;
// 对讲
extern XBAudioUnitRecorder *audioRecorder;

@interface KHJVideoPlayer_sp_VC ()<H26xHwDecoderDelegate>
{
    __weak IBOutlet UIView *hpNaviView;
    __weak IBOutlet UIButton *hpBackBtn;
    __weak IBOutlet UILabel *hpTitleLab;
    __weak IBOutlet UIButton *hpQualityBtn;
    __weak IBOutlet UIView *hpStackBackView;
    __weak IBOutlet UIStackView *hpStackView;
    __weak IBOutlet UIButton *hpListenBtn;
    __weak IBOutlet UIButton *hpTalkBtn;
    __weak IBOutlet UIButton *hpRecordBtn;
    __weak IBOutlet UIButton *spListenBtn;
    __weak IBOutlet UIButton *spTalkBtn;
    
    __weak IBOutlet UIView *naviView;
    __weak IBOutlet UILabel *spTitleLab;
    __weak IBOutlet NSLayoutConstraint *naviViewCH;
    __weak IBOutlet UIView *slideView;
    __weak IBOutlet UILabel *sliderNameLab;
    __weak IBOutlet UILabel *sliderPercentLab;
    __weak IBOutlet UISlider *sliderControl;
    __weak IBOutlet UIImageView *playerImageView;
    __weak IBOutlet UIView *playerView;
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIView *bottomView;
    
    NSTimer *recordTimer;
    NSInteger recordTimes;
    __weak IBOutlet UIButton *recordBtn;
    __weak IBOutlet UIView *recordTimeView;
    __weak IBOutlet UILabel *recordTimeLab;
    int qualityLevel;
    __weak IBOutlet UILabel *qualityLab;
    
    __weak IBOutlet UIImageView *oneImgView;
    __weak IBOutlet UILabel *oneLab;
    __weak IBOutlet UIImageView *twoImgView;
    __weak IBOutlet UILabel *twoLab;
    __weak IBOutlet UIImageView *threeImgView;
    __weak IBOutlet UILabel *threeLab;
    __weak IBOutlet UIImageView *fourImgView;
    __weak IBOutlet UILabel *fourLab;
    __weak IBOutlet UIImageView *fiveImgView;
    __weak IBOutlet UILabel *fiveLab;
    __weak IBOutlet UIImageView *sixImgView;
    __weak IBOutlet UILabel *sixLab;
    
    __weak IBOutlet UIImageView *sevenImgView;
    __weak IBOutlet UILabel *sevenLab;
    __weak IBOutlet UIImageView *eightImgView;
    __weak IBOutlet UILabel *eightLab;
    
    UITapGestureRecognizer *tap;
    __weak IBOutlet UIActivityIndicatorView *activeView;
    BOOL isHengping;
}

@property (nonatomic, strong) NSMutableDictionary *_1497_body;
@property (nonatomic, strong) NSMutableDictionary *change_1497_body;

@end

@implementation KHJVideoPlayer_sp_VC

- (NSMutableDictionary *)_1497_body
{
    if (!__1497_body) {
        __1497_body = [NSMutableDictionary dictionary];
    }
    return __1497_body;
}

- (NSMutableDictionary *)change_1497_body
{
    if (!_change_1497_body) {
        _change_1497_body = [NSMutableDictionary dictionary];
    }
    return _change_1497_body;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
}

- (void)customizeDataSource
{
    currentDecorderType = TTDecorde_live;
    spTitleLab.text = self.deviceInfo.deviceName;
    hpTitleLab.text = self.deviceInfo.deviceName;
    [self addNoti];
    self.sp_deviceID = self.deviceID;
    sliderControl.continuous = NO;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [playerImageView addGestureRecognizer:tap];
    [self startVideo];
}

- (void)startVideo
{
    [activeView startAnimating];
    qualityLevel = 0;
    qualityLab.text = KHJLocalizedString(@"sd_", nil);
    [[KHJDeviceManager sharedManager] startGetVideo_with_deviceID:self.deviceID quality:1 resultBlock:^(NSInteger code) {}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getVideoStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientChange:(NSNotification *)notification
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationPortrait) {
        NSLog(@"竖屏");
        if (isHengping) {
            isHengping = NO;
            AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.canLandscape = NO;//关闭横屏仅允许竖屏
            [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
            naviView.alpha = 1;
            hpBackBtn.alpha = 0;
            hpNaviView.alpha = 0;
            hpTitleLab.alpha = 0;
            hpQualityBtn.alpha = 0;
            hpStackView.alpha = 0;
            hpStackBackView.alpha = 0;
            slideView.hidden = YES;
            centerView.hidden = NO;
            bottomView.hidden = NO;
            naviViewCH.constant = 44;
        }
    }
    else if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight) {
        NSLog(@"横屏");
        if (!isHengping) {
            isHengping = YES;
            // 全屏
            naviView.alpha = 0;
            hpBackBtn.alpha = 1;
            hpNaviView.alpha = 1;
            hpTitleLab.alpha = 1;
            hpQualityBtn.alpha = 0.25;
            hpStackView.alpha = 1;
            hpStackBackView.alpha = 0.25;
            slideView.hidden = YES;
            centerView.hidden = YES;
            bottomView.hidden = YES;
            naviViewCH.constant = 0;
            AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.canLandscape   = YES;
            [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
        }
    }
}

- (void)getVideoStatus
{
    /// 获取当前视频的分辨率
    [[KHJDeviceManager sharedManager] getQualityLevel_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    /// 获取饱和度、liangdu_、duibidu_、ruidu_
    [[KHJDeviceManager sharedManager] getSaturationLevel_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    /// 获取色彩/黑白模式
    [[KHJDeviceManager sharedManager] getIRModel_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
}

#pragma MARK - H26xHwDecoderDelegate

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    if (activeView.isAnimating) {
        [activeView stopAnimating];
    }
    playerImageView.image = image;
}

- (void)addNoti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetFilpCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetIRModeCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnGetIRModeCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetQualityLevelCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnGetSaturationLevelCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnSetSaturationLevelCmdResult_noti_key" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetSaturationLevelCmdResult)
                                                 name:@"OnSetSaturationLevelCmdResult_noti_key"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGetSaturationLevelCmdResult:)
                                                 name:@"OnGetSaturationLevelCmdResult_noti_key"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnGetIRModeCmdResult)
                                                 name:@"OnGetIRModeCmdResult_noti_key"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetIRModeCmdResult)
                                                 name:@"OnSetIRModeCmdResult_noti_key"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetFilpCmdResult)
                                                 name:@"OnSetFilpCmdResult_noti_key"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnSetQualityLevelCmdResult)
                                                 name:@"OnSetQualityLevelCmdResult_noti_key"
                                               object:nil];
}

- (void)OnSetQualityLevelCmdResult
{
    // 0 标清，1 高清，2 4K超清
    if (qualityLevel == 0) {
        qualityLab.text = KHJLocalizedString(@"sd_", nil);
    }
    else if (qualityLevel == 1) {
        qualityLab.text = KHJLocalizedString(@"hd_", nil);
    }
    else if (qualityLevel == 2) {
        qualityLab.text = KHJLocalizedString(@"kd_", nil);
    }
}

- (void)OnSetFilpCmdResult
{
    [self.view makeToast:KHJLocalizedString(@"chgSucc_", nil)];
}

// 获取 彩色/黑色 画面
- (void)OnGetIRModeCmdResult
{
    if (picColorCfg.Type == 0) {
        TLog(@"彩色画面");
    }
    else {
        TLog(@"黑白画面");
    }
}

- (void)OnSetIRModeCmdResult
{
    [self.view makeToast:KHJLocalizedString(@"chgSucc_", nil)];
}

- (void)OnSetSaturationLevelCmdResult
{
    if (self.change_1497_body.count > 0) {
        NSString *key = self.change_1497_body.allKeys.firstObject;
        NSString *value = self.change_1497_body.allValues.firstObject;
        [self._1497_body setValue:value forKey:key];
        [self.view makeToast:KHJLocalizedString(@"setSucc_", nil)];
    }
}

- (void)OnGetSaturationLevelCmdResult:(NSNotification *)noti
{
    self._1497_body = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)noti.object];
}

- (void)tapAction
{
    if (isHengping) {
        hpBackBtn.hidden = !hpBackBtn.hidden;
        hpNaviView.hidden = !hpNaviView.hidden;
        hpTitleLab.hidden = !hpTitleLab.hidden;
        hpQualityBtn.hidden = !hpQualityBtn.hidden;
        hpStackView.hidden = !hpStackView.hidden;
        hpStackBackView.hidden = !hpStackBackView.hidden;
    }
    else {
        if (!slideView.hidden) {
            slideView.hidden = YES;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    currentDecorderType = TTDecorder_none;
    [self stopTalk];
    [self stopListen];
    liveRecordType = TTRecordLive_Normal;
    [[KHJDeviceManager sharedManager] stopGetVideo_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    [[KHJDeviceManager sharedManager] stopGetAudio_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    [self sp_releaseDecoder];
    [super viewWillDisappear:animated];
}

- (IBAction)topBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        [self saveImage];
        [self.navigationController popViewControllerAnimated:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(loadCellPic:)]) {
            [_delegate loadCellPic:self.row];
        }
    }
    else if (sender.tag == 20) {
        // 上下控制
    }
    else if (sender.tag == 30) {
        // 左右控制
    }
    else if (sender.tag == 50) {
        // 预置点
        KHJVideoPlayer_hf_VC *vc = [[KHJVideoPlayer_hf_VC alloc] init];
        vc.deviceID = self.deviceID;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender.tag == 60) {
        isHengping = NO;
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.canLandscape = NO;//关闭横屏仅允许竖屏
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
        naviView.alpha = 1;
        hpBackBtn.alpha = 0;
        hpNaviView.alpha = 0;
        hpTitleLab.alpha = 0;
        hpQualityBtn.alpha = 0;
        hpStackView.alpha = 0;
        hpStackBackView.alpha = 0;
        slideView.hidden = YES;
        centerView.hidden = NO;
        bottomView.hidden = NO;
        naviViewCH.constant = 44;
    }
}

- (IBAction)hpSixBtnAction:(UIButton *)sender
{
    if (sender.tag == 0) {
        // 监听
        hpListenBtn.selected = !hpListenBtn.selected;
        spListenBtn.selected = hpListenBtn.selected;
        if (hpListenBtn.selected) {
            [self startListen];
            oneImgView.highlighted = YES;
        }
        else {
            [self stopListen];
            oneImgView.highlighted = NO;
        }
    }
    else if (sender.tag == 1) {
        // 对讲
        hpTalkBtn.selected = !hpTalkBtn.selected;
        spTalkBtn.selected = hpTalkBtn.selected;
        if (hpTalkBtn.selected) {
            [self startTalk];
            twoImgView.highlighted = YES;
        }
        else {
            [self stopTalk];
            twoImgView.highlighted = NO;
        }
    }
    else if (sender.tag == 2) {
        // 拍照
        [self takePhoto];
    }
    else if (sender.tag == 3) {
        // 录像
        hpRecordBtn.selected = !hpRecordBtn.selected;
        recordBtn.selected = hpRecordBtn.selected;
        if (hpRecordBtn.selected) {
            [self gotoStartRecord];
        }
        else {
            [self gotoStopRecord];
        }
    }
    else if (sender.tag == 4) {
        // 垂直镜像
        [[KHJDeviceManager sharedManager] setFilp_with_deviceID:self.deviceID
                                                           flip:1
                                                         mirror:0
                                                    resultBlock:^(NSInteger code) {}];
    }
    else if (sender.tag == 5) {
        // 水平镜像
        [[KHJDeviceManager sharedManager] setFilp_with_deviceID:self.deviceID
                                                           flip:0
                                                         mirror:1
                                                    resultBlock:^(NSInteger code) {}];
    }
}

- (IBAction)fiveBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 全屏
        naviView.alpha = 0;
        hpBackBtn.alpha = 1;
        hpNaviView.alpha = 1;
        hpTitleLab.alpha = 1;
        hpQualityBtn.alpha = 0.25;
        hpStackView.alpha = 1;
        hpStackBackView.alpha = 0.25;
        slideView.hidden = YES;
        centerView.hidden = YES;
        bottomView.hidden = YES;
        naviViewCH.constant = 0;

        isHengping = YES;
        AppDelegate *appDelegate    = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.canLandscape   = YES;
        [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
    }
    else if (sender.tag == 20) {
        // 设置
        [self gotoSetup];
    }
    else if (sender.tag == 30) {
        // 录像
        recordBtn.selected = !recordBtn.selected;
        hpRecordBtn.selected = recordBtn.selected;
        if (recordBtn.selected) {
            [self gotoStartRecord];
        }
        else {
            [self gotoStopRecord];
        }
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
        // 监听
        spListenBtn.selected = !spListenBtn.selected;
        hpListenBtn.selected = spListenBtn.selected;
        
        if (spListenBtn.selected) {
            [self startListen];
            oneImgView.highlighted = YES;
        }
        else {
            [self stopListen];
            oneImgView.highlighted = NO;
        }
    }
    else if (sender.tag == 20) {
        // 对讲
        spTalkBtn.selected = !spTalkBtn.selected;
        hpTalkBtn.selected = spTalkBtn.selected;
        if (spTalkBtn.selected) {
            [self startTalk];
            twoImgView.highlighted = YES;
        }
        else {
            [self stopTalk];
            twoImgView.highlighted = NO;
        }
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

#pragma mark - 设置

- (void)gotoSetup
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"HMSet_", nil)
                                                                       message:KHJLocalizedString(@"SXSet_", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"baohedu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:1];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"liangdu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:2];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"ruidu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:3];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"duibidu_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:4];
    }];
    
    NSString *picColor = picColorCfg.Type == 0 ? KHJLocalizedString(@"colorView_", nil) : KHJLocalizedString(@"blackView_", nil);
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:picColor style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:5];
    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"chuizhijingxiang_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:6];
    }];
    UIAlertAction *config6 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"shuipingjingxiang_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:7];
    }];
    UIAlertAction *config7 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"defatValue_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:8];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];

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
    KHJLocalizedString(@"baohedu_", nil),
    KHJLocalizedString(@"liangdu_", nil),
    KHJLocalizedString(@"ruidu_", nil),
    KHJLocalizedString(@"duibidu_", nil),
    KHJLocalizedString(@"color/black_", nil),
    KHJLocalizedString(@"chuizhijingxiang_", nil),
    KHJLocalizedString(@"shuipingjingxiang_", nil),
    KHJLocalizedString(@"defatValue_", nil)];
    
    sliderNameLab.text = arr[index - 1];
    if (index == 1 || index == 2 || index == 3 || index == 4) {
        slideView.hidden = NO;
        if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"baohedu_", nil)]) {
            float percent = [self._1497_body[@"Saturtion"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
        else if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"liangdu_", nil)]) {
            float percent = [self._1497_body[@"Brightness"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
        else if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"ruidu_", nil)]) {
            float percent = [self._1497_body[@"Acutance"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
        else if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"duibidu_", nil)]) {
            float percent = [self._1497_body[@"Contrast"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
    }
    else if (index == 5) {
        TLog(@"彩色/黑白");
        int type = 0;
        if (picColorCfg.Type == 0) {
            type = 1;
        }
        else {
            type = 0;
        }
        [[KHJDeviceManager sharedManager] setIRModel_with_deviceID:self.deviceID type:type resultBlock:^(NSInteger code) {}];
    }
    else if (index == 6) {
        TLog(@"垂直镜像");
        [[KHJDeviceManager sharedManager] setFilp_with_deviceID:self.deviceID flip:1 mirror:0 resultBlock:^(NSInteger code) {}];
    }
    else if (index == 7) {
        TLog(@"水平镜像");
        [[KHJDeviceManager sharedManager] setFilp_with_deviceID:self.deviceID flip:0 mirror:1 resultBlock:^(NSInteger code) {}];
    }
    else if (index == 8) {
        TLog(@"恢复默认值");
        TTWeakSelf
        [[KHJDeviceManager sharedManager] setDefault_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {
            if (code >= 0) {
                [weakSelf.view makeToast:KHJLocalizedString(@"devBecomeDft_", nil)];
            }
            else {
                [weakSelf.view makeToast:KHJLocalizedString(@"reTry_", nil)];
            }
        }];
    }
    else {
        slideView.hidden = YES;
    }
}

- (IBAction)sliderAction:(UISlider *)sender
{
    int persent = (int)(sender.value*100);
    int value = persent*2.55;
    sliderPercentLab.text = KHJString(@"%d%%",persent);
    [self.change_1497_body removeAllObjects];
    if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"baohedu_", nil)]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Saturtion"];
        [[KHJDeviceManager sharedManager] setSaturationLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
    else if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"liangdu_", nil)]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Brightness"];
        [[KHJDeviceManager sharedManager] setBrightnessLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
    else if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"ruidu_", nil)]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Acutance"];
        [[KHJDeviceManager sharedManager] setAcutanceLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
    else if ([sliderNameLab.text isEqualToString:KHJLocalizedString(@"duibidu_", nil)]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Contrast"];
        [[KHJDeviceManager sharedManager] setCompareColorLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
}

#pragma mark - 录像

/// 开始录像
- (void)gotoStartRecord
{
    recordTimeView.hidden = NO;
    [self fireTimer];
    // 直播录屏，截取数据
    liveRecordType = TTRecordLive_Recording;
    liveRecordVideoPath = [[[TTFileManager sharedModel] get_live_recordVideo_DocPath_with_deviceID:self.deviceID] stringByAppendingPathComponent:[[TTFileManager sharedModel] get_videoName_With_fileType:@"mp4" deviceID:self.deviceID]];
}

/// 停止录像
- (void)gotoStopRecord
{
    recordTimeView.hidden = YES;
    // 结束直播录屏，停止截取数据
    liveRecordVideoPath = @"";
    liveRecordType = TTRecordLive_stopRecoding;
}

#pragma mark - 切换清晰度

- (void)gotoChangeQuality
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"setQualty_", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"kd_", nil)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:2];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"hd_", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:1];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"sd_", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:0];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil)
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
    qualityLevel = level;
    [[KHJDeviceManager sharedManager] setQualityLevel_with_deviceID:self.deviceID level:qualityLevel resultBlock:^(NSInteger code) {}];
}

#pragma mark - 监听

- (void)startListen
{
    [[KHJDeviceManager sharedManager] startGetAudio_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    [audioPlayer start];
}

- (void)stopListen
{
    [audioPlayer stop];
    [[KHJDeviceManager sharedManager] stopGetAudio_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
}

#pragma mark - 对讲

- (void)startTalk
{
    [[KHJDeviceManager sharedManager] startTalk_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    [audioRecorder start];
}

- (void)stopTalk
{
    [audioRecorder stop];
    [[KHJDeviceManager sharedManager] stopTalk_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
}

#pragma mark - 截图

- (void)takePhoto
{
    //播放拍照声音
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"screenShot" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [[TTPlayVoiceManager shareInstance] playVoiceWithURL:url];
    
    NSString *savedImagePath = [[[TTFileManager sharedModel] get_live_screenShot_DocPath_with_deviceID:self.deviceID] stringByAppendingPathComponent:[[TTFileManager sharedModel] get_videoName_With_fileType:@"jpg" deviceID:self.deviceID]];
    TLog(@"saveImagePath = %@",savedImagePath);

    //截取指定区域图片
    UIImage *screenImage = [self snapsHotView:playerView];
    // png格式的二进制
    NSData *imagedata = UIImageJPEGRepresentation(screenImage,0.5);
    BOOL is = [imagedata writeToFile:savedImagePath atomically:YES];
    if (is) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPictureVC_noti" object:nil];
        [self loadImageFinished:[[UIImage alloc] initWithContentsOfFile:savedImagePath]];
    }
    else {
        [[TTHub shareHub] showText:KHJLocalizedString(@"picFail_", nil) addToView:self.view];
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
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips_", nil)
                                                                                message:KHJLocalizedString(@"setPhotoQuanX_", nil)
                                                                         preferredStyle:(UIAlertControllerStyleAlert)];
       UIAlertAction *action = [UIAlertAction actionWithTitle:KHJLocalizedString(@"IGeit", nil)
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
       }];
   }
}

#pragma mark - Timer

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
    int hour = (int)recordTimes / 3600;
    int min  = (int)(recordTimes - hour * 3600) / 60;
    int sec  = (int)(recordTimes - hour * 3600 - min * 60);
    recordTimes ++;
    recordTimeLab.text = KHJString(@"%02d:%02d:%02d", hour, min, sec);
}

/* 停止倒计时 */
- (void)stopTimer
{
    if ([recordTimer isValid] || recordTimer != nil) {
        [recordTimer invalidate];
        recordTimer = nil;
        recordTimes = 0;
    }
}

#pragma mark - 截图

- (void)saveImage
{
    UIImage *screenImage = [self screenshot_imageView:playerImageView];
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
    NSString *year = KHJString(@"%ld", (long)[components year]);
    NSString *month = KHJString(@"%02ld", (long)[components month]);
    NSString *day = KHJString(@"%02ld", (long)[components day]);
    NSString *imagePath1 = [[[TTFileManager sharedModel] get_screenShot_DocPath_deviceID:self.deviceInfo.deviceID] stringByAppendingPathComponent:KHJString(@"%@%@%@.png",year,month,day)];
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

@end
