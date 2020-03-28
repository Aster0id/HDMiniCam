//
//  TTPlayerBaseViewController.m
//  SuperIPC
//
//  Created by kevin on 2020/2/26.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTPlayerBaseViewController.h"
#import "H264_H265_VideoDecoder.h"
#include "JSONStructProtocal.h"
#include "IPCNetManagerInterface.h"

RecSess_t _LSession = NULL;       // 直播录屏会话

H264_H265_VideoDecoder *liveDecode;

// 解码类型
TTDecordeType decoderType;

// 多屏时，保存已添加的设备id，用于区分多屏解码器
NSMutableArray          *mutliArr;
H264_H265_VideoDecoder  *mutliFirst;
H264_H265_VideoDecoder  *mutliSecond;
H264_H265_VideoDecoder  *mutliThird;
H264_H265_VideoDecoder  *mutliFour;

TTRecordLiveStatus liveRecordType;          // 直播是否录屏
NSString *liveRecordPath;   // 直播录屏保存路径
TTRecordBackStatus rebackPlayRecordType;    // 是否回放录屏
NSString *rebackRecordPath; // 回放录屏保存路径
dispatch_queue_t recordQueue = dispatch_queue_create("recordQueue", DISPATCH_QUEUE_SERIAL);

@interface TTPlayerBaseViewController ()<H264_H265_VideoDecoderDelegate>

@end

// 监听
TTAudioPlayer *audioPlayer;
// 对讲
TTAudioRecorder *audioRecorder;

@implementation TTPlayerBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeDataSource];
}

- (instancetype)init
{
    if (self = [super init]) {
        mutliArr            = [NSMutableArray array];
        liveDecode          = [[H264_H265_VideoDecoder alloc] init];
        liveDecode.delegate = self;
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    if (self = [super initWithFrame:frame]) {
//
//    }
//    return self;
//}

- (void)customizeDataSource
{

}

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    TLog(@"getImageWith");
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

#pragma mark - 设备状态回调

void onStatus(const char* uuid,int status)
{
    [TTPlayerBaseViewController onStatus:TTStr(@"%s",uuid) status:status];
    // 更新设备状态
    [TTPlayerBaseViewController updateDeviceStatus:TTStr(@"%s",uuid) status:status];
}

#pragma mark - 视频数据回调

void onVideoData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    if (decoderType == TTDecorde_moreLive) {
        // 多屏解码
        [TTPlayerBaseViewController decoderMoreLive:TTStr(@"%s",uuid)
                                              index:[mutliArr indexOfObject:TTStr(@"%s",uuid)]
                                             length:len
                                          timestamp:timestamp
                                          videoData:data
                                               type:type];
    }
    else if (decoderType == TTDecorde_live) {
        // 直播解码器
        [TTPlayerBaseViewController decoderSingleLive:len timestamp:timestamp videoData:data type:type];
        // 直播录屏
        [TTPlayerBaseViewController device_is_or_not_RecordingVideo:len timestamp:timestamp videoData:data type:type];
    }
}

#pragma mark - 音频数据回调

void onAudioData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    // 播放视频的音频
    [TTPlayerBaseViewController decoderAudio:len timestamp:timestamp audioData:data type:type];
    // 是否录制音频
    [TTPlayerBaseViewController device_is_or_not_RecordingAudio:len timestamp:timestamp audioData:data type:type];
}

#pragma mark - json数据回调

void onJSONString(const char* uuid,int msg_type,const char* jsonstr)
{
    
}

#pragma mark - 多屏

- (void)setInitMutliDecorder:(BOOL)initMutliDecorder
{
    if (initMutliDecorder) {
        decoderType     = TTDecorde_moreLive;
        mutliFirst      = [[H264_H265_VideoDecoder alloc] init];
        mutliSecond     = [[H264_H265_VideoDecoder alloc] init];
        mutliThird      = [[H264_H265_VideoDecoder alloc] init];
        mutliFour       = [[H264_H265_VideoDecoder alloc] init];
        mutliFirst.delegate     = self;
        mutliSecond.delegate    = self;
        mutliThird.delegate     = self;
        mutliFour.delegate      = self;
    }
    else {
        decoderType = TTDecorder_none;
        [mutliFirst     releaseH264_H265_VideoDecoder];
        [mutliSecond    releaseH264_H265_VideoDecoder];
        [mutliThird     releaseH264_H265_VideoDecoder];
        [mutliFour      releaseH264_H265_VideoDecoder];
        mutliFirst  = nil;
        mutliSecond = nil;
        mutliThird  = nil;
        mutliFour   = nil;
    }
}

- (void)sp_releaseDecoder
{
    [liveDecode releaseH264_H265_VideoDecoder];
}

#pragma mark - errorCode

+ (NSString *)getErrorCcode:(int)code
{
    if (code == 0)
        return @"设备连接成功";
    else if (code == -1)
        return @"设备未初始化";
    else if (code == -2)
        return @"设备已初始化";
    else if (code == -3)
        return @"操作超时";
    else if (code == -4)
        return @"ID无效";
    else if (code == -5)
        return @"参数无效";
    else if (code == -6)
        return @"设备离线";
    else if (code == -7)
        return @"无法解析名称";
    else if (code == -8)
        return @"前缀无效";
    else if (code == -9)
        return @"设备id过期";
    else if (code == -10)
        return @"没有可用的中继服务器";
    else if (code == -11)
        return @"无效的 session";
    else if (code == -12)
        return @"session 关闭";
    else if (code == -13)
        return @"session 关闭超时";
    else if (code == -14)
        return @"session 已关闭";
    else if (code == -15)
        return @"远程站点缓冲区已满";
    else if (code == -16)
        return @"用户监听断裂";
    else if (code == -17)
        return @"session 数量达到最大";
    else if (code == -18)
        return @"UDP端口绑定失败";
    else if (code == -19)
        return @"用户连接断裂";
    else if (code == -20)
        return @"session 关闭的内存不足";
    else if (code == -21)
        return @"内部致命错误";
    else if (code == -22)
        return @"没有连接的对象";
    else if (code == -23)
        return @"没有工作的对象";
    else if (code == -24)
        return @"初始化失败";
    else if (code == -25)
        return @"对象未准备好";
    else if (code == -26)
        return @"密码错误";
    else if (code == -27)
        return @"连接丢失";
    else if (code == -28)
        return @"数据太长";
    else if (code == -29)
        return @"未知错误";
    return @"未知错误";
}


#pragma mark - 直播解码

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param videoData 视频数据
/// @param type 数据类型
+ (void)decoderSingleLive:(int)length
                timestamp:(long)stamp
                videoData:(unsigned char*)videoData
                     type:(int)type
{
    [liveDecode decodeH26xVideoData:videoData videoSize:length frameType:type timestamp:stamp];
}

#pragma mark - 直播录屏

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param videoData 视频数据
/// @param type 数据类型
+ (void)device_is_or_not_RecordingVideo:(int)length
                              timestamp:(long)stamp
                              videoData:(unsigned char*)videoData
                                   type:(int)type
{
    if (liveRecordType == TTRecordLive_Record) {
        dispatch_sync(recordQueue, ^{
            if (_LSession) {
                IPCNetPutLocalRecordVideoFrame(_LSession, type, (const char*)videoData, length, stamp);
            }
            else {
                if (type >= IPCNET_H264E_NALU_BSLICE && type < IPCNET_H264E_NALU_BUTT) {
#pragma mark - H264 开始录屏
                    _LSession = IPCNetStartRecordLocalVideo(liveRecordPath.UTF8String, IPCNET_VIDEO_ENCODE_TYPE_H264, 30, IPCNET_AUDIO_ENCODE_TYPE_G711A, 8000, 2, 1);
                }
                else if (type >= IPCNET_H265E_NALU_BSLICE) {
#pragma mark - H265 开始录屏
                    _LSession = IPCNetStartRecordLocalVideo(liveRecordPath.UTF8String, IPCNET_VIDEO_ENCODE_TYPE_H265, 30, IPCNET_AUDIO_ENCODE_TYPE_G711A, 8000, 2, 1);
                }
            }
        });
    }
    else if (liveRecordType == TTRecordLive_SRecod) {
        liveRecordType = TTRecordLive_Normal;
        IPCNetFinishLocalRecord(_LSession);
        _LSession = NULL;
    }
}

#pragma mark - 多屏解码功能

/// @param deviceID 设备id
/// @param index 下标
/// @param length 长度
/// @param stamp 时间戳
/// @param videoData 解码数据
/// @param type 类型
+ (void)decoderMoreLive:(NSString *)deviceID
                  index:(NSInteger)index
                 length:(int)length
              timestamp:(long)stamp
              videoData:(unsigned char*)videoData
                   type:(int)type
{
    if (index == 0) {
        mutliFirst.deviceID = deviceID;
        [mutliFirst decodeH26xVideoData:videoData videoSize:length frameType:type timestamp:stamp];
    }
    else if (index == 1) {
        mutliSecond.deviceID = deviceID;
        [mutliSecond decodeH26xVideoData:videoData videoSize:length frameType:type timestamp:stamp];
    }
    else if (index == 2) {
        mutliThird.deviceID = deviceID;
        [mutliThird decodeH26xVideoData:videoData videoSize:length frameType:type timestamp:stamp];
    }
    else if (index == 3) {
        mutliFour.deviceID = deviceID;
        [mutliFour decodeH26xVideoData:videoData videoSize:length frameType:type timestamp:stamp];
    }
}


#pragma mark - 音频播放

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param audioData 视频数据
/// @param type 数据类型
+ (void)decoderAudio:(int)length
           timestamp:(long)stamp
           audioData:(unsigned char*)audioData
                type:(int)type
{
    [audioPlayer playThisAudioData:(uint8_t *)audioData audioSize:length frameType:type timestamp:stamp];
}

#pragma mark - 音频录屏

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param audioData 音频数据
/// @param type 数据类型
+ (void)device_is_or_not_RecordingAudio:(int)length
                              timestamp:(long)stamp
                              audioData:(unsigned char*)audioData
                                   type:(int)type
{
    if (liveRecordType == TTRecordLive_Record) {
        dispatch_sync(recordQueue, ^{
            if (_LSession) {
                IPCNetPutLocalRecordAudioFrame(_LSession, type, (const char *)audioData, length, stamp);
            }
        });
    }
    else if (liveRecordType == TTRecordLive_SRecod) {
        liveRecordType = TTRecordLive_Normal;
        IPCNetFinishLocalRecord(_LSession);
        _LSession = NULL;
    }
}

#pragma mark - 更新设备状态

/// @param deviceID 设备ID
/// @param status 设备状态
+ (void)updateDeviceStatus:(NSString *)deviceID status:(int)status
{
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:deviceID forKey:@"deviceID"];
    [body setValue:@(status) forKey:@"deviceStatus"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TT_onStatus_noti_KEY object:body];
}

/// debug 打印 onStatus
/// @param deviceID 设备ID
/// @param status 设备状态
+ (void)onStatus:(NSString *)deviceID status:(int)status
{
#ifdef DEBUG
    if (status >= 0) {
        NSLog(@" \n onStatus \n 设备id = %@， 当前在线",deviceID);
    }
    else {
        NSString *statusCodeString = [TTPlayerBaseViewController getErrorCcode:status];
        NSLog(@" \n onStatus \n 设备id = %@ \n 状态错误码 = %@",deviceID,statusCodeString);
    }
#endif
}

/// 创建 监听对象 + 对讲对象
- (void)setSp_deviceID:(NSString *)sp_deviceID
{
    if (sp_deviceID.length > 0) {
        audioPlayer = nil;
        audioRecorder = nil;
        // 初始化 - 监听播放器
        audioPlayer = [[TTAudioPlayer alloc] initWithRate:TTAudioRate_8k bit:TTAudioBit_16 channel:TTAudioChannel_1];
        audioPlayer.audio_encode_Type = IPCNET_AUDIO_ENCODE_TYPE_G711A;
        audioPlayer.sp_deviceID = sp_deviceID;
        // 初始化 - 对讲录音
        audioRecorder = [[TTAudioRecorder alloc] initWithRate:TTAudioRate_8k bit:TTAudioBit_16 channel:TTAudioChannel_1];
        strcpy(audioRecorder.mUUID, sp_deviceID.UTF8String);
        audioRecorder.codeType = IPCNET_AUDIO_ENCODE_TYPE_G711A;
    }
}

@end

