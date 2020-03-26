//
//  KHJVideoPlayerBaseVC.m
//  SuperIPC
//
//  Created by kevin on 2020/2/26.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJVideoPlayerBaseVC.h"
#import "H264_H265_VideoDecoder.h"
#include "JSONStructProtocal.h"
#include "IPCNetManagerInterface.h"

RecSess_t _LSession = NULL;       // 直播录屏会话

H264_H265_VideoDecoder *liveDecode;

// 解码类型
TTDecordeType decoderType;
// 多屏时，保存已添加的设备id，用于区分多屏解码器
NSMutableArray *mutliDidArr;
H264_H265_VideoDecoder *first_decoder;
H264_H265_VideoDecoder *second_decoder;
H264_H265_VideoDecoder *third_decoder;
H264_H265_VideoDecoder *fourth_decoder;

TTRecordLiveStatus liveRecordType;          // 直播是否录屏
NSString *liveRecordPath;   // 直播录屏保存路径
TTRecordBackStatus rebackPlayRecordType;    // 是否回放录屏
NSString *rebackRecordPath; // 回放录屏保存路径
dispatch_queue_t recordQueue = dispatch_queue_create("recordQueue", DISPATCH_QUEUE_SERIAL);

@interface KHJVideoPlayerBaseVC ()<H264_H265_VideoDecoderDelegate>

@end

// 监听
TTAudioPlayer *audioPlayer;
// 对讲
TTAudioRecorder *audioRecorder;

@implementation KHJVideoPlayerBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    liveDecode = [[H264_H265_VideoDecoder alloc] init];
    liveDecode.delegate = self;
    mutliDidArr = [NSMutableArray array];
}

/// 创建 监听对象 + 对讲对象
- (void)setSp_deviceID:(NSString *)sp_deviceID
{
    if (sp_deviceID.length > 0) {
        audioPlayer = nil;
        audioRecorder = nil;
        // 初始化 - 监听播放器
        audioPlayer = [[TTAudioPlayer alloc] initWithRate:TTAudioRate_8k bit:TTAudioBit_16 channel:TTAudioChannel_1];
        audioPlayer.sp_deviceID = sp_deviceID;
        audioPlayer.audio_encode_Type = IPCNET_AUDIO_ENCODE_TYPE_G711A;
        // 初始化 - 对讲录音
        audioRecorder = [[TTAudioRecorder alloc] initWithRate:TTAudioRate_8k bit:TTAudioBit_16 channel:TTAudioChannel_1];
        strcpy(audioRecorder.mUUID, sp_deviceID.UTF8String);
        audioRecorder.codeType = IPCNET_AUDIO_ENCODE_TYPE_G711A;
    }
}

- (void)getImageWith:(UIImage * _Nullable)image imageSize:(CGSize)imageSize deviceID:(NSString *)deviceID
{
    TLog(@"KHJVideoPlayerBaseVC.getImageWith");
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
    if (status >= 0) {
        NSLog(@" \n onStatus \n 设备id = %s， 当前在线",uuid);
    }
    else {
        int errorCode = status;
        NSString *statusCodeString = [KHJVideoPlayerBaseVC getErrorCcode:errorCode];
        NSLog(@" \n onStatus \n 设备id = %s \n 状态错误码 = %@",uuid,statusCodeString);
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:[[NSString alloc] initWithUTF8String:uuid] forKey:@"deviceID"];
    [body setValue:@(status) forKey:@"deviceStatus"];
    [[NSNotificationCenter defaultCenter] postNotificationName:TT_onStatus_noti_KEY object:body];
}

/// 获取视频数据
/// @param uuid 设备id
/// @param type 类型
/// @param data 视频数据
/// @param len 数据长度
/// @param timestamp 时间戳
void onVideoData(const char* uuid,int type,unsigned char*data,int len,long timestamp)
{
    if (decoderType == TTDecorde_moreLive) {
        
        NSInteger index = [mutliDidArr indexOfObject:KHJString(@"%s",uuid)];
        
        switch (index) {
            case 0:
            {
                first_decoder.deviceID = KHJString(@"%s",uuid);
                [first_decoder decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            case 1:
            {
                second_decoder.deviceID = KHJString(@"%s",uuid);
                [second_decoder decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            case 2:
            {
                third_decoder.deviceID = KHJString(@"%s",uuid);
                [third_decoder decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            case 3:
            {
                fourth_decoder.deviceID = KHJString(@"%s",uuid);
                [fourth_decoder decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
            }
                break;
            default:
                break;
        }
    }
    else if (decoderType == TTDecorde_live) {
        // 直播解码器
        [liveDecode decodeH26xVideoData:data videoSize:len frameType:type timestamp:timestamp];
        if (liveRecordType == TTRecordLive_Record) {
            // TLog(@"正在直播录屏 path = %@",liveRecordPath);
            dispatch_sync(recordQueue, ^{
                if (_LSession) {
                    int ret = IPCNetPutLocalRecordVideoFrame(_LSession, type, (const char*)data, len, timestamp);
                    if (ret == 0) TLog(@"输入 Video 数据");
                }
                else {
                    if (type >= IPCNET_H264E_NALU_BSLICE && type < IPCNET_H264E_NALU_BUTT) {
                        // h264
                        _LSession = IPCNetStartRecordLocalVideo(liveRecordPath.UTF8String, IPCNET_VIDEO_ENCODE_TYPE_H264, 30, IPCNET_AUDIO_ENCODE_TYPE_G711A, 8000, 2, 1);
                    }
                    else if (type >= IPCNET_H265E_NALU_BSLICE) {
                        // h265
                        _LSession = IPCNetStartRecordLocalVideo(liveRecordPath.UTF8String, IPCNET_VIDEO_ENCODE_TYPE_H265, 30, IPCNET_AUDIO_ENCODE_TYPE_G711A, 8000, 2, 1);
                    }
                }
            });
        }
        else if (liveRecordType == TTRecordLive_SRecod) {
            // TLog(@"停止直播录屏 path = %@",liveRecordPath);
            liveRecordType = TTRecordLive_Normal;
            IPCNetFinishLocalRecord(_LSession);
            _LSession = NULL;
        }
    }
    else {
        TLog(@"当前不解码，为什么还有打印？？？？");
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
    NSLog(@" \n onAudioData 设备id = %s \n type = %d  \n length = %d  \n timestamp = %ld",uuid,type,len,timestamp);
    [audioPlayer playThisAudioData:(uint8_t *)data audioSize:len frameType:type timestamp:timestamp];
    if (liveRecordType == TTRecordLive_Record) {
        dispatch_sync(recordQueue, ^{
            if (_LSession) {
                int ret = IPCNetPutLocalRecordAudioFrame(_LSession, type, (const char *)data, len, timestamp);
                if (ret == 0) {
                    TLog(@"输入 Audio 数据");
                }
                else {
                    TLog(@"输入 Audio 数据 失败 ret = %d",ret);
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

/// 返回的json数据
/// @param uuid 设备id
/// @param msg_type 信息类型
/// @param jsonstr json数据
void onJSONString(const char* uuid,int msg_type,const char* jsonstr)
{
    // 子线程回调
    NSLog(@" \n 设备id = %s \n messageCode = %d \n json数据 = %s",uuid,msg_type,jsonstr);
    if (msg_type == 4003) {
        // 设备连接
        NSDictionary *body = [NSDictionary dictionary];
        body = [TTCommon cString_changto_ocStringWith:jsonstr];
        TLog(@"登录设备，连接设备 body = %@",body);
        
        if ([body.allKeys containsObject:@"Login.info"]) {
#pragma mark - 登录回调
//            NSString *Tick = body[@"Login.info"][@"Tick"];
//            TLog(@"Tick = %@", Tick);
        }
        else if ([body.allKeys containsObject:@"dev_info"]) {
#pragma mark - 设备信息回调
            NSString *deviceName    = body[@"dev_info"][@"name"];
            NSString *deviceID      = body[@"dev_info"][@"p2p_uuid"];
            TLog(@" deviceID = %@, deviceName = %@",deviceID, deviceName);
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
        decoderType = TTDecorde_moreLive;
        first_decoder = [[H264_H265_VideoDecoder alloc] init];
        second_decoder = [[H264_H265_VideoDecoder alloc] init];
        third_decoder = [[H264_H265_VideoDecoder alloc] init];
        fourth_decoder = [[H264_H265_VideoDecoder alloc] init];
        first_decoder.delegate = self;
        second_decoder.delegate = self;
        third_decoder.delegate = self;
        fourth_decoder.delegate = self;
    }
    else {
        decoderType = TTDecorder_none;
        [first_decoder releaseH264_H265_VideoDecoder];
        [second_decoder releaseH264_H265_VideoDecoder];
        [third_decoder releaseH264_H265_VideoDecoder];
        [fourth_decoder releaseH264_H265_VideoDecoder];
        first_decoder = nil;
        second_decoder = nil;
        third_decoder = nil;
        fourth_decoder = nil;
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

@end
