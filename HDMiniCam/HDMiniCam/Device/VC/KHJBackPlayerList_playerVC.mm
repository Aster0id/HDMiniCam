//
//  KHJBackPlayerList_playerVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/28.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBackPlayerList_playerVC.h"
//
#import "H26xHwDecoder.h"
#import "KHJDeviceManager.h"
#import "JSONStructProtocal.h"
#import "IPCNetManagerInterface.h"

extern IPCNetRecordCfg_st recordCfg;

@interface KHJBackPlayerList_playerVC ()<H26xHwDecoderDelegate>
{
    __weak IBOutlet UILabel *nameLab;
    __weak IBOutlet UIImageView *playerImageView;
    __weak IBOutlet UIActivityIndicatorView *activeView;
    
    __weak IBOutlet UISlider *sliderView;
    __weak IBOutlet UILabel *startTimeLab;
    __weak IBOutlet UILabel *endTimeLab;
    
    BOOL isPlay;
    __weak IBOutlet UIButton *playBtn;
    
    H26xHwDecoder *h264Decode;
    int totalTime;
}
@end

@implementation KHJBackPlayerList_playerVC

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
    [[KHJDeviceManager sharedManager] removePlaybackAudioVideoDataCallBack_with_deviceID:self.deviceID];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

- (void)customizeDataSource
{
    isPlay = YES;
    playerImageView.hidden = YES;
    nameLab.text = self.body[@"name"];
    h264Decode = [[H26xHwDecoder alloc] init];
    h264Decode.delegate = self;
    totalTime = [self.body[@"end"] intValue] - [self.body[@"start"] intValue];
    int hour = totalTime / 3600;
    int min  = (totalTime - hour * 3600) / 60;
    int sec  = totalTime - hour * 3600 - min * 60;
    sliderView.minimumValue = 0;
    sliderView.maximumValue = totalTime;
    endTimeLab.text = KHJString(@"%02d:%02d:%02d", hour, min, sec);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endPlayer_noti) name:@"endPlayer_noti" object:nil];
}

- (void)endPlayer_noti
{
    // 移除回调监听
    
}

- (void)customizeAppearance
{
    [self registerCallBack];
    // 注册完监听回调，再开始获取音频数据
    [[KHJDeviceManager sharedManager] startPlayback_with_deviceID:self.deviceID path:self.body[@"videoPath"] resultBlock:^(NSInteger code) {
        CLog(@"播放回放视频 - %@",self.body[@"name"]);
    }];
}

/// 获取sd卡回放 视频数据
/// @param deviceID 设备id
/// @param dataType 数据类型
/// @param data 音频 或 视频
/// @param length 数据长度
/// @param timeStamps 时间戳
- (void)getPlayBackVideo_With_deviceID:(const char* )deviceID dataType:(int)dataType data:(unsigned char *)data length:(int)length timeStamps:(long)timeStamps
{
    [h264Decode decodeH26xVideoData:data videoSize:length frameType:dataType timestamp:timeStamps];
}

/// 获取sd卡回放 音频数据
/// @param deviceID 设备id
/// @param dataType 数据类型
/// @param data 音频 或 视频
/// @param length 数据长度
/// @param timeStamps 时间戳
- (void)getPlayBackAudio_With_deviceID:(const char* )deviceID dataType:(int)dataType data:(unsigned char *)data length:(int)length timeStamps:(long)timeStamps
{
    
}

#pragma MARK - H26xHwDecoderDelegate

- (void)getImageWith:(UIImage *)image imageSize:(CGSize)imageSize
{
    playerImageView.image = image;
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        [self.navigationController popViewControllerAnimated:YES];
        WeakSelf
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[KHJDeviceManager sharedManager] removePlaybackAudioVideoDataCallBack_with_deviceID:weakSelf.deviceID];
            [[KHJDeviceManager sharedManager] stopPlayback_with_deviceID:self.deviceID resultBlock:^(NSInteger code) {}];
        });
    }
    else if (sender.tag == 20) {
        
    }
    else if (sender.tag == 30) {
        if (isPlay) {
            // 暂停
            CLog(@"暂停播放回放视频 - %@",self.body[@"name"]);
            [[KHJDeviceManager sharedManager] pausePlayback_with_deviceID:self.deviceID contin:YES resultBlock:^(NSInteger code) {
                self->isPlay = NO;
            }];
        }
        else {
            // 开始
            CLog(@"继续播放回放视频 - %@",self.body[@"name"]);
            [[KHJDeviceManager sharedManager] pausePlayback_with_deviceID:self.deviceID contin:NO resultBlock:^(NSInteger code) {
                self->isPlay = YES;
            }];
        }
    }
    else if (sender.tag == 40) {
        
    }
}

// 注册音频数据/视频数据回调
- (void)registerCallBack
{
    WeakSelf
    [[KHJDeviceManager sharedManager] setPlaybackAudioVideoDataCallBack_with_deviceID:self.deviceID resultBlock:^(const char * _Nonnull uuid, int type, unsigned char * _Nonnull data, int len, long timestamp) {
        [self->activeView stopAnimating];
        self->playerImageView.hidden = NO;
        if (type < 20) {
            // h265数据
            self->sliderView.value = (int)(timestamp / 1000 + 1);
            int time = (int)self->sliderView.value;
            int hour = time / 3600;
            int min  = (time - hour * 3600) / 60;
            int sec  = time - hour * 3600 - min * 60;
            self->startTimeLab.text = KHJString(@"%02d:%02d:%02d", hour, min, sec);
            if (self->sliderView.value != self->totalTime) {
                // 未播完
                if (self->isPlay) {
                    // 正在播放
                    self->playBtn.selected = YES;
                    [weakSelf getPlayBackVideo_With_deviceID:uuid dataType:type data:data length:len timeStamps:timestamp];
                }
                else {
                    // 暂停播放
                    self->playBtn.selected = NO;
                }
            }
            else {
                // 已播完
                self->playBtn.selected = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"endPlayer_noti" object:nil];
            }
        }
        else if (type >= 50) {
            // h265数据
            self->sliderView.value = (int)(timestamp / 1000 + 1);
            int time = (int)self->sliderView.value;
            int hour = time / 3600;
            int min  = (time - hour * 3600) / 60;
            int sec  = time - hour * 3600 - min * 60;
            self->startTimeLab.text = KHJString(@"%02d:%02d:%02d", hour, min, sec);
            if (self->sliderView.value != self->totalTime) {
                // 未播完
                if (self->isPlay) {
                    // 正在播放
                    self->playBtn.selected = YES;
                    [weakSelf getPlayBackVideo_With_deviceID:uuid dataType:type data:data length:len timeStamps:timestamp];
                }
                else {
                    // 暂停播放
                    self->playBtn.selected = NO;
                }
            }
            else {
                // 已播完
                self->playBtn.selected = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"endPlayer_noti" object:nil];
            }
        }
        else {
            // 音频数据
            
        }
    }];
}

@end
