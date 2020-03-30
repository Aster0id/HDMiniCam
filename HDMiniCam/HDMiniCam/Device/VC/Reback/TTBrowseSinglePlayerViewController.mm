//
//  TTBrowseSinglePlayerViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/2/28.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBrowseSinglePlayerViewController.h"
//
#import "H264_H265_VideoDecoder.h"
#import "TTFirmwareInterface_API.h"
#import "JSONStructProtocal.h"
#import "IPCNetManagerInterface.h"

extern IPCNetRecordCfg_st recordCfg;

@interface TTBrowseSinglePlayerViewController ()<H264_H265_VideoDecoderDelegate>
{
    __weak IBOutlet UIImageView *playerImageView;
    NSInteger _hour;
    __weak IBOutlet UIActivityIndicatorView *activeView;
    NSInteger _min;
    H264_H265_VideoDecoder *h264Decode;
    NSInteger _second;
}

// 是否正在播放
@property (nonatomic, assign) BOOL isPlay;
// 视频总时长
@property (nonatomic, assign) NSInteger zongshichang;

@property (weak, nonatomic) IBOutlet UIButton   *playBtn;
@property (weak, nonatomic) IBOutlet UILabel    *videoName;
@property (weak, nonatomic) IBOutlet UILabel    *startBtn;
@property (weak, nonatomic) IBOutlet UILabel    *z_startBtn;
@property (weak, nonatomic) IBOutlet UISlider   *slierBtn;

@end

@implementation TTBrowseSinglePlayerViewController

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
    [[TTFirmwareInterface_API sharedManager] removePlaybackAudioVideoDataCallBack_with_deviceID:self.deviceID];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)customizeDataSource
{
    _isPlay = YES;
    _slierBtn.value = 0;
    _videoName.text = self.body[@"name"];
    _zongshichang = [self.body[@"end"] integerValue] - [self.body[@"start"] integerValue];

    h264Decode = [[H264_H265_VideoDecoder alloc] init];
    h264Decode.delegate = self;
}

- (void)customizeAppearance
{
    playerImageView.hidden  = YES;
    // 更新开始label时间
    [self loadStartTimeSeconds:self.zongshichang label:_z_startBtn];

    
    _slierBtn.minimumValue = 0;
    _slierBtn.maximumValue = _zongshichang;
    // 注册回调
    [self registerCallBack];
    // 获取音视频数据
    [self getVideo_Audio_Data];
}

#pragma mark - 注册完监听回调，再开始获取音频数据

- (void)getVideo_Audio_Data
{
    [[TTFirmwareInterface_API sharedManager] startPlayback_with_deviceID:self.deviceID
                                                                    path:self.body[@"videoPath"]
                                                                 reBlock:^(NSInteger code) {}];
}

#pragma mark - 获取sd卡回放 视频数据

- (void)getPlayBackVideo_With_deviceID:(const char* )deviceID
                              dataType:(int)dataType
                                  data:(unsigned char *)data
                                length:(int)length
                            timeStamps:(long)timeStamps
{
    [h264Decode decodeH26xVideoData:data videoSize:length frameType:dataType timestamp:timeStamps];
}

#pragma MARK - H264_H265_VideoDecoderDelegate

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    playerImageView.image = image;
}

#pragma mark - Action

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TTFirmwareInterface_API sharedManager] stopPlayback_with_deviceID:self.deviceID reBlock:^(NSInteger code) {}];
    });
}

- (IBAction)startAction:(id)sender
{
    TTWeakSelf
    if (_isPlay) {
#pragma mark - 暂停
        [[TTFirmwareInterface_API sharedManager] pausePlayback_with_deviceID:self.deviceID contin:YES reBlock:^(NSInteger code) {
            if (code >= 0) {
                weakSelf.isPlay = NO;
            }
        }];
    }
    else {
#pragma mark - 开始
        [[TTFirmwareInterface_API sharedManager] pausePlayback_with_deviceID:self.deviceID contin:NO reBlock:^(NSInteger code) {
            if (code >= 0) {
                weakSelf.isPlay = YES;
            }
        }];
    }
}

#pragma mark - 注册音频数据/视频数据回调

- (void)registerCallBack
{
    TTWeakSelf
    [[TTFirmwareInterface_API sharedManager] setPlaybackAudioVideoDataCallBack_with_deviceID:self.deviceID reBlock:^(const char * _Nonnull uuid, int type, unsigned char * _Nonnull data, int len, long timestamp) {
        TLog(@"timestamp = %ld",timestamp);
        [self->activeView stopAnimating];
        self->playerImageView.hidden = NO;
        if (type < 20) {
            [weakSelf less20:timestamp uid:uuid type:type data:data length:len];
        }
        else if (type >= 50) {
            [weakSelf more50:timestamp uid:uuid type:type data:data length:len];
        }
        else {
            // 音频数据
        }
    }];
}

#pragma makr - type < 20

- (void)less20:(long)stamp
           uid:(const char * _Nonnull)uid
          type:(int)type
          data:(unsigned char * _Nonnull)data
        length:(int)len
{
    // h265数据
    self.slierBtn.value = (int)(stamp / 1000 + 1);
    // 更新开始label时间
    [self loadStartTimeSeconds:(NSInteger)self.slierBtn.value label:_startBtn];
    
    if (_slierBtn.value != _zongshichang) {
#pragma mark - 未播完
        if (_isPlay) {
#pragma mark - 正在播放
            _playBtn.selected = YES;
            [self getPlayBackVideo_With_deviceID:uid dataType:type data:data length:len timeStamps:stamp];
        }
        else {
#pragma mark - 暂停播放
            _playBtn.selected = NO;
        }
    }
    else {
#pragma mark - 已播完
        _playBtn.selected = NO;
        TLog(@"播放结束，差一步移除回调监听");
        /// 未完成
        [self endPlayer_noti];
    }
}

#pragma makr - 20 < type <= 50

- (void)more50:(long)stamp
           uid:(const char * _Nonnull)uid
          type:(int)type
          data:(unsigned char * _Nonnull)data
        length:(int)len
{
    // h265数据
    _slierBtn.value = (int)(stamp / 1000 + 1);
    // 更新开始label时间
    [self loadStartTimeSeconds:(NSInteger)_slierBtn.value label:_startBtn];
    
    if (_slierBtn.value != _zongshichang) {
#pragma mark - 未播完
        if (_isPlay) {
#pragma mark - 正在播放
            _playBtn.selected = YES;
            [self getPlayBackVideo_With_deviceID:uid dataType:type data:data length:len timeStamps:stamp];
        }
        else {
#pragma mark - 暂停播放
            _playBtn.selected = NO;
        }
    }
    else {
#pragma mark - 已播完
        _playBtn.selected = NO;
        TLog(@"播放结束，差一步移除回调监听");
        /// 未完成
        [self endPlayer_noti];
    }
}

- (void)endPlayer_noti
{
    
}

#pragma mark - 更新开始label时间

- (void)loadStartTimeSeconds:(NSInteger)time label:(UILabel *)label
{
    _hour = time / 3600;
    _min  = (time - _hour * 3600) / 60;
    _second  = time - _hour * 3600 - _min * 60;
    label.text = TTStr(@"%02ld:%02ld:%02ld", (long)_hour, (long)_min, (long)_second);
}


@end
