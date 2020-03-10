//
//  KHJVideoPlayer_sp_VC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/12.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayer_sp_VC.h"
#import "KHJVideoPlayer_hp_VC.h"
#import "KHJVideoPlayer_hf_VC.h"
#import "KHJMutliScreenVC.h"
#import "KHJDeviceManager.h"
//
#import "JSONStructProtocal.h"
//
#import "PlayLocalMusic.h"
#import <Photos/Photos.h>
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/AssetsLibrary.h>

// 是否直播录屏
extern NSString *liveRecordVideoPath;
extern KHJLiveRecordType liveRecordType;
// 彩色/黑白画面
extern IPCNetPicColorInfo_st picColorCfg;
// 监听
extern XBAudioUnitPlayer *audioPlayer;
// 对讲
extern XBAudioUnitRecorder *audioRecorder;

@interface KHJVideoPlayer_sp_VC ()<H26xHwDecoderDelegate>
{
    __weak IBOutlet UIView *slideView;
    __weak IBOutlet UILabel *sliderNameLab;
    __weak IBOutlet UILabel *sliderPercentLab;
    __weak IBOutlet UISlider *sliderControl;
    __weak IBOutlet UIImageView *playerImageView;
    __weak IBOutlet UIView *playerView;
    __weak IBOutlet UIView *centerView;
    __weak IBOutlet UIView *bottomView;
    
    BOOL startRecord;
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
    qualityLab.text = KHJLocalizedString(@"标清", nil);
    [[KHJDeviceManager sharedManager] startGetVideo_with_deviceID:self.deviceID quality:1 resultBlock:^(NSInteger code) {}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getVideoStatus];
}

- (void)getVideoStatus
{
    /// 获取当前视频的分辨率
    [[KHJDeviceManager sharedManager] getQualityLevel_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    /// 获取饱和度、亮度、对比度、锐度
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
        qualityLab.text = KHJLocalizedString(@"标清", nil);
    }
    else if (qualityLevel == 1) {
        qualityLab.text = KHJLocalizedString(@"高清", nil);
    }
    else if (qualityLevel == 2) {
        qualityLab.text = KHJLocalizedString(@"4K超清", nil);
    }
}

- (void)OnSetFilpCmdResult
{
    [self.view makeToast:@"切换成功"];
}

// 获取 彩色/黑色 画面
- (void)OnGetIRModeCmdResult
{
    if (picColorCfg.Type == 0) {
        CLog(@"彩色画面");
    }
    else {
        CLog(@"黑白画面");
    }
}

- (void)OnSetIRModeCmdResult
{
    if (picColorCfg.Type == 0) {
        [self.view makeToast:@"彩色画面切换成功"];
    }
    else {
        [self.view makeToast:@"黑白画面切换成功"];
    }
}

- (void)OnSetSaturationLevelCmdResult
{
    if (self.change_1497_body.count > 0) {
        NSString *key = self.change_1497_body.allKeys.firstObject;
        NSString *value = self.change_1497_body.allValues.firstObject;
        [self._1497_body setValue:value forKey:key];
        if ([key isEqualToString:@"Saturtion"]) {
            [self.view makeToast:@"色彩饱和度 设置成功"];
        }
        else if ([key isEqualToString:@"Brightness"]) {
            [self.view makeToast:@"亮度 设置成功"];
        }
        else if ([key isEqualToString:@"Acutance"]) {
            [self.view makeToast:@"亮度 设置成功"];
        }
        else if ([key isEqualToString:@"Contrast"]) {
            [self.view makeToast:@"对比度 设置成功"];
        }
    }
}

- (void)OnGetSaturationLevelCmdResult:(NSNotification *)noti
{
    self._1497_body = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)noti.object];
}

- (void)tapAction
{
    if (!slideView.hidden) {
        slideView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTalk];
    [self stopListen];
    liveRecordType = KHJLiveRecordType_Normal;
    [[KHJDeviceManager sharedManager] stopGetVideo_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    [[KHJDeviceManager sharedManager] stopGetAudio_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
    [super viewWillDisappear:animated];
}

- (IBAction)topBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        [self.navigationController popViewControllerAnimated:YES];
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
}

- (IBAction)fiveBtn:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 全屏
        KHJVideoPlayer_hp_VC *vc = [[KHJVideoPlayer_hp_VC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender.tag == 20) {
        // 设置
        [self gotoSetup];
    }
    else if (sender.tag == 30) {
        // 录像
        sender.selected = !sender.selected;
        if (sender.selected) {
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
        sender.selected = !sender.selected;
        if (sender.selected) {
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
        sender.selected = !sender.selected;
        if (sender.selected) {
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
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:@"画面设置" message:@"根据需求设置当前属性" preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"色彩饱和度", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:1];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"亮度", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:2];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"锐度", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:3];
    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"对比度", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:4];
    }];
    
    NSString *picColor = picColorCfg.Type == 0 ? @"切换至黑白画面" : @"切换至彩色画面";
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:picColor style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:5];
    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"垂直镜像", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:6];
    }];
    UIAlertAction *config6 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"水平镜像", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:7];
    }];
    UIAlertAction *config7 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"恢复默认值", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf chooseSetupWith:8];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];

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
    NSArray *arr = @[@"色彩饱和度",@"亮度",@"锐度",@"对比度",@"彩色/黑白",@"垂直镜像",@"水平镜像",@"恢复默认值"];
    sliderNameLab.text = arr[index - 1];
    if (index == 1 || index == 2 || index == 3 || index == 4) {
        slideView.hidden = NO;
        if ([sliderNameLab.text isEqualToString:@"色彩饱和度"]) {
            float percent = [self._1497_body[@"Saturtion"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
        else if ([sliderNameLab.text isEqualToString:@"亮度"]) {
            float percent = [self._1497_body[@"Brightness"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
        else if ([sliderNameLab.text isEqualToString:@"锐度"]) {
            float percent = [self._1497_body[@"Acutance"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
        else if ([sliderNameLab.text isEqualToString:@"对比度"]) {
            float percent = [self._1497_body[@"Contrast"] intValue]/255.0;
            sliderControl.value = percent;
            sliderPercentLab.text = KHJString(@"%d%%",(int)(percent*100));
        }
    }
    else if (index == 5) {
        CLog(@"彩色/黑白");
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
        CLog(@"垂直镜像");
        [[KHJDeviceManager sharedManager] setFilp_with_deviceID:self.deviceID flip:1 mirror:0 resultBlock:^(NSInteger code) {}];
    }
    else if (index == 7) {
        CLog(@"水平镜像");
        [[KHJDeviceManager sharedManager] setFilp_with_deviceID:self.deviceID flip:0 mirror:1 resultBlock:^(NSInteger code) {}];
    }
    else if (index == 8) {
        CLog(@"恢复默认值");
        WeakSelf
        [[KHJDeviceManager sharedManager] setDefault_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {
            if (code >= 0) {
                [weakSelf.view makeToast:@"设备已恢复默认值"];
            }
            else {
                [weakSelf.view makeToast:@"恢复失败，请重试！"];
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
    if ([sliderNameLab.text isEqualToString:@"色彩饱和度"]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Saturtion"];
        [[KHJDeviceManager sharedManager] setSaturationLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
    else if ([sliderNameLab.text isEqualToString:@"亮度"]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Brightness"];
        [[KHJDeviceManager sharedManager] setBrightnessLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
    else if ([sliderNameLab.text isEqualToString:@"锐度"]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Acutance"];
        [[KHJDeviceManager sharedManager] setAcutanceLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
    else if ([sliderNameLab.text isEqualToString:@"对比度"]) {
        [self.change_1497_body setValue:KHJString(@"%d",value) forKey:@"Contrast"];
        [[KHJDeviceManager sharedManager] setCompareColorLevel_with_deviceID:self.deviceID level:value resultBlock:^(NSInteger code) {}];
    }
}

#pragma mark - 录像

/// 开始录像
- (void)gotoStartRecord
{
    startRecord = YES;
    recordTimeView.hidden = NO;
    [self fireTimer];
    
    // 直播录屏，截取数据
    liveRecordType = KHJLiveRecordType_Recording;
    liveRecordVideoPath = [[[KHJHelpCameraData sharedModel] getTakeVideoDocPath_with_deviceID:self.deviceID] stringByAppendingPathComponent:[[KHJHelpCameraData sharedModel] getVideoNameWithType:@"mp4" deviceID:self.deviceID]];
}

/// 停止录像
- (void)gotoStopRecord
{
    startRecord = NO;
    recordTimeView.hidden = YES;
    // 结束直播录屏，停止截取数据
    liveRecordVideoPath = @"";
    liveRecordType = KHJLiveRecordType_stopRecoding;
}

#pragma mark - 切换清晰度

- (void)gotoChangeQuality
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:@"设置画面清晰度" message:nil preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"4K超清", nil)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:2];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"高清", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:1];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"标清", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf setQualityWith:0];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil)
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"photoshutter" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [[PlayLocalMusic shareInstance] play:url repeates:0];
    
    NSString *savedImagePath = [[[KHJHelpCameraData sharedModel] getTakeCameraDocPath_deviceID:self.deviceID] stringByAppendingPathComponent:[[KHJHelpCameraData sharedModel] getVideoNameWithType:@"jpg" deviceID:self.deviceID]];
    CLog(@"saveImagePath = %@",savedImagePath);

    //截取指定区域图片
    UIImage *screenImage = [self snapsHotView:playerView];
    // png格式的二进制
    NSData *imagedata = UIImageJPEGRepresentation(screenImage,0.5);
    BOOL is = [imagedata writeToFile:savedImagePath atomically:YES];
    if (is) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPictureVC_noti" object:nil];
        [self loadImageFinished:[[UIImage alloc] initWithContentsOfFile:savedImagePath]];
        [[KHJHub shareHub] showText:KHJLocalizedString(@"PhotoSuccess", nil) addToView:self.view];
    }
    else {
        [[KHJHub shareHub] showText:KHJLocalizedString(@"PhotoFail", nil) addToView:self.view];
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
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                message:@"请您先去设置允许APP访问您的相册 设置>隐私>相册"
                                                                         preferredStyle:(UIAlertControllerStyleAlert)];
       UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了"
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


@end
