//
//  KHJVideoPlayerBaseVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/26.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJVideoPlayerBaseVC.h"
#import "H26xHwDecoder.h"
#import "KHJErrorManager.h"
#include "JSONStructProtocal.h"
#include "IPCNetManagerInterface.h"

H26xHwDecoder *h264Decode;

// 初始化多屏解码器
BOOL isMutliDecorder;
NSMutableArray *mutliDeviceIDList;
H26xHwDecoder *h264Decode1;
H26xHwDecoder *h264Decode2;
H26xHwDecoder *h264Decode3;
H26xHwDecoder *h264Decode4;

// 是否直播录屏
KHJLiveRecordType liveRecordType;
// 直播录屏保存路径
NSString *liveRecordVideoPath;
// 直播录屏会话
RecSess_t gVideoRecordSession = NULL;
dispatch_queue_t recordQueue = dispatch_queue_create("recordQueue", DISPATCH_QUEUE_SERIAL);

@interface KHJVideoPlayerBaseVC ()<H26xHwDecoderDelegate>

@end

// 监听
XBAudioUnitPlayer *audioPlayer;
// 对讲
XBAudioUnitRecorder *audioRecorder;

@implementation KHJVideoPlayerBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    h264Decode = [[H26xHwDecoder alloc] init];
    h264Decode.delegate = self;
    mutliDeviceIDList = [NSMutableArray array];
}

/// 创建 监听对象 + 对讲对象
- (void)setSp_deviceID:(NSString *)sp_deviceID
{
    if (sp_deviceID.length > 0) {
        audioPlayer = nil;
        audioRecorder = nil;
        // 初始化 - 监听播放器
        audioPlayer = [[XBAudioUnitPlayer alloc] initWithRate:XBAudioRate_8k bit:XBAudioBit_16 channel:XBAudioChannel_1];
        audioPlayer.mUUID = sp_deviceID;
        audioPlayer.codeType = IPCNET_AUDIO_ENCODE_TYPE_G711A;
        // 初始化 - 对讲录音
        audioRecorder = [[XBAudioUnitRecorder alloc] initWithRate:XBAudioRate_8k bit:XBAudioBit_16 channel:XBAudioChannel_1];
        strcpy(audioRecorder.mUUID, sp_deviceID.UTF8String);
        audioRecorder.codeType = IPCNET_AUDIO_ENCODE_TYPE_G711A;
    }
}

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    CLog(@"KHJVideoPlayerBaseVC.getImageWith");
}

- (UIButton *)leftBtn
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 66, 44);
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    [leftBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = barBut;
    return leftBtn;
}

- (UILabel *)titleLab
{
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, SCREEN_WIDTH - 160, 44)];
    titleLab.font = [UIFont systemFontOfSize:17];
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLab;
    return titleLab;
}

- (UIButton *)rightBtn
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 66, 44);
    rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barBut;
    return rightBtn;
}

#pragma mark - 设备回调

/// 设备状态改变
/// @param uuid 设备id
/// @param status 设备状态
/// IPCNetStartIPCNetSession这个函数是连接函数，连接成功，状态会从onStatus返回
void onStatus(const char* uuid,int status)
{
    // 子线程回调
    if (status != 0) {
        NSLog(@" \n onStatus \n 设备id = %s， 当前在线 ！！！！！！！！！！！！！！",uuid);
    }
    else {
        NSString *statusCodeString = [KHJErrorManager getError_with_code:status];
        NSLog(@" \n onStatus \n 设备id = %s \n 状态错误 = %@",uuid,statusCodeString);
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:[[NSString alloc] initWithUTF8String:uuid] forKey:@"deviceID"];
    [body setValue:@(status) forKey:@"deviceStatus"];
    [[NSNotificationCenter defaultCenter] postNotificationName:noti_onStatus_KEY object:body];
}

/// 获取视频数据
/// @param uuid 设备id
/// @param type 类型
/// @param data 视频数据
/// @param len 数据长度
/// @param timestamp 时间戳
void onVideoData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    // 子线程回调
    // NSLog(@"onVideoData uuid:%s type:%d len:%d timestamp:%ld\n\n",uuid,type,len,timestamp);
    if (isMutliDecorder) {
        // 多屏解码器
        NSInteger index = [mutliDeviceIDList indexOfObject:KHJString(@"%s",uuid)];
        // CLog(@"uuid = %s, index = %ld",uuid,(long)index);
        switch (index) {
            case 0:
            {
                h264Decode1.deviceID = KHJString(@"%s",uuid);
                [h264Decode1 decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            case 1:
            {
                h264Decode2.deviceID = KHJString(@"%s",uuid);
                [h264Decode2 decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            case 2:
            {
                h264Decode3.deviceID = KHJString(@"%s",uuid);
                [h264Decode3 decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            case 3:
            {
                h264Decode4.deviceID = KHJString(@"%s",uuid);
                [h264Decode4 decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            default:
                break;
        }
    }
    else {
        // 竖屏解码器
        [h264Decode decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
        if (liveRecordType == KHJLiveRecordType_Recording) {
            // CLog(@"正在直播录屏 path = %@",liveRecordVideoPath);
            dispatch_sync(recordQueue, ^{
                if (gVideoRecordSession) {
                    if (type >= 20 && type < 30) {
                        int ret = IPCNetPutLocalRecordAudioFrame(gVideoRecordSession, type, (const char *)data, len, timestamp);
                        if (ret == 0) CLog(@"输入 Audio 数据");
                    }
                    else {
                        int ret = IPCNetPutLocalRecordVideoFrame(gVideoRecordSession, type, (const char *)data, len, timestamp);
                        if (ret == 0) CLog(@"输入 视频 数据");
                    }
                }
                else {
                    if (type >= 20 && type < 30) {
                        // Audio
                    }
                    else {
                        if (type >= 0 && type < 20)
                            gVideoRecordSession = IPCNetStartRecordLocalVideo(liveRecordVideoPath.UTF8String, IPCNET_VIDEO_ENCODE_TYPE_H264, 30, IPCNET_AUDIO_ENCODE_TYPE_G711A, 8000, 2, 1);
                        else
                            gVideoRecordSession = IPCNetStartRecordLocalVideo(liveRecordVideoPath.UTF8String, IPCNET_VIDEO_ENCODE_TYPE_H265, 30, IPCNET_AUDIO_ENCODE_TYPE_G711A, 8000, 2, 1);
                    }
                }
            });
        }
        else if (liveRecordType == KHJLiveRecordType_stopRecoding) {
            // CLog(@"停止直播录屏 path = %@",liveRecordVideoPath);
            liveRecordType = KHJLiveRecordType_Normal;
            IPCNetFinishLocalRecord(gVideoRecordSession);
            gVideoRecordSession = NULL;
        }
    }
}

/// 获取音频数据
/// @param uuid 设备id
/// @param type 类型
/// @param data 音频数据
/// @param len 数据长度
/// @param timestamp 时间戳
void onAudioData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    // 子线程回调
//    CLog(@"onAudioData = %@",[NSThread currentThread]);
    NSLog(@" \n onAudioData 设备id = %s \n type = %d  \n length = %d  \n timestamp = %ld",uuid,type,len,timestamp);
    [audioPlayer playThisAudioData:(uint8_t *)data audioSize:len frameType:type timestamp:timestamp];
}

/// 返回的json数据
/// @param uuid 设备id
/// @param msg_type 信息类型
/// @param jsonstr json数据
void onJSONString(const char* uuid,int msg_type,const char* jsonstr)
{
    // 子线程回调
//    NSLog(@" \n 设备id = %s \n messageCode = %d \n json数据 = %s",uuid,msg_type,jsonstr);
    if (msg_type == 4003) {
        // 设备连接
        NSDictionary *body = [NSDictionary dictionary];
        body = [KHJUtility cString_changto_ocStringWith:jsonstr];
        CLog(@"登录设备，连接设备 body = %@",body);
        
        if ([body.allKeys containsObject:@"Login.info"]) {
#pragma mark - 登录回调
//            NSString *Tick = body[@"Login.info"][@"Tick"];
//            CLog(@"Tick = %@", Tick);
        }
        else if ([body.allKeys containsObject:@"dev_info"]) {
#pragma mark - 设备信息回调
            NSString *deviceName    = body[@"dev_info"][@"name"];
            NSString *deviceID      = body[@"dev_info"][@"p2p_uuid"];
            CLog(@" deviceID = %@, deviceName = %@",deviceID, deviceName);
            NSMutableDictionary *body2 = [NSMutableDictionary dictionary];
            [body2 setValue:deviceID forKey:@"deviceID"];
            [body2 setValue:deviceName forKey:@"deviceName"];
            [[NSNotificationCenter defaultCenter] postNotificationName:noti_onJSONString_KEY object:body2];
        }
    }
    else {
        
    }
}

#pragma mark - 多屏

- (void)setInitMutliDecorder:(BOOL)initMutliDecorder
{
    if (initMutliDecorder) {
        isMutliDecorder = YES;
        h264Decode1 = [[H26xHwDecoder alloc] init];
        h264Decode2 = [[H26xHwDecoder alloc] init];
        h264Decode3 = [[H26xHwDecoder alloc] init];
        h264Decode4 = [[H26xHwDecoder alloc] init];
        h264Decode1.delegate = self;
        h264Decode2.delegate = self;
        h264Decode3.delegate = self;
        h264Decode4.delegate = self;
    }
    else {
        isMutliDecorder = NO;
        [h264Decode1 releaseH26xHwDecoder];
        [h264Decode2 releaseH26xHwDecoder];
        [h264Decode3 releaseH26xHwDecoder];
        [h264Decode4 releaseH26xHwDecoder];
        h264Decode1 = nil;
        h264Decode2 = nil;
        h264Decode3 = nil;
        h264Decode4 = nil;
    }
}

- (void)sp_releaseDecoder
{
    [h264Decode releaseH26xHwDecoder];
}

@end
