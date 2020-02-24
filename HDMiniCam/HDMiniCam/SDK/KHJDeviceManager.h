//
//  KHJDeviceManager.h
//  HDMiniCam
//
//  Created by khj888 on 2020/2/14.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPCNetManagerInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^resultBlock)(NSInteger code);

@interface KHJDeviceManager : NSObject

{
    struct IPCNetEventHandler netHandle;
}

+ (KHJDeviceManager *)sharedManager;

- (void)getApiVersion_with_deviceID:(int)version
                        resultBlock:(resultBlock)resultBlock;

/// 设备连接
/// @param deviceID 设备id
/// @param password 设备密码
/// @param resultBlock 回调
- (void)connect_with_deviceID:(NSString *)deviceID
                     password:(NSString *)password
                  resultBlock:(resultBlock)resultBlock;

/// 断开连接
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)disconnect_with_deviceID:(NSString *)deviceID
                     resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备视频

/// 开始获取视频
/// @param deviceID 设备id
/// @param quality 视频质量
/// @param resultBlock 回调
- (void)startGetVideo_with_deviceID:(NSString *)deviceID
                            quality:(int)quality
                        resultBlock:(resultBlock)resultBlock;

/// 停止获取视频
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopGetVideo_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备音频

/// 开始获取音频
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)startGetAudio_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

/// 停止获取音频
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopGetAudio_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备对讲

/// 开启设备扬声器，准备接收音频数据并播放
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)startTalk_with_deviceID:(NSString *)deviceID
                           type:(int)type
                    resultBlock:(resultBlock)resultBlock;

/// 关闭设备扬声器
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopTalk_with_deviceID:(NSString *)deviceID
                   resultBlock:(resultBlock)resultBlock;

/// 发送音频数据
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)sendTalkData_with_device:(NSString *)deviceID
                       audioData:(NSString *)audioData
                          length:(int)length
                     resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备回放

/// 开始录像回放
/// @param deviceID 设备id
/// @param path 回放路径
/// @param resultBlock 回调
- (void)startPlayback_with_deviceID:(NSString *)deviceID
                               path:(NSString *)path
                        resultBlock:(resultBlock)resultBlock;

/// 停止录像回放
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopPlayback_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock;

/// 暂停录像回放
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)pausePlayback_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

/// 回放快进
/// @param deviceID 设备id
/// @param speed 快进速度
/// @param resultBlock 回调
- (void)fastForward_with_deviceID:(NSString *)deviceID
                            speed:(int)speed
                      resultBlock:(resultBlock)resultBlock;

/// 回放快退
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)fastBackward_with_deviceID:(NSString *)deviceID
                             speed:(int)speed
                       resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备降噪设置

/// 获取降噪设置
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDenoiseSetting_with_deviceID:(NSString *)deviceID
                            resultBlock:(resultBlock)resultBlock;

/// 设置降噪设置
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setDenoiseSetting_with_deviceID:(NSString *)deviceID
                                   json:(NSString *)json
                            resultBlock:(resultBlock)resultBlock;

#pragma mark - 恢复设备出厂设置

/// 恢复设备出厂设置
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)resetDevice_with_deviceID:(NSString *)deviceID
                      resultBlock:(resultBlock)resultBlock;

#pragma mark - 重启设备

/// 重启设备
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)rebootDevice_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备 Wi-Fi

/// 获取设备Wi-Fi
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceWiFi_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

/// 设置设备Wi-Fi
/// @param deviceID 设备id
/// @param ssid Wi-Fi账号
/// @param password Wi-Fi密码
/// @param encType encType
/// @param resultBlock 回调
- (void)setDeviceWiFi_with_deviceID:(NSString *)deviceID
                               ssid:(NSString *)ssid
                           password:(NSString *)password
                            encType:(NSString *)encType
                        resultBlock:(resultBlock)resultBlock;

/// 搜索附近Wi-Fi列表
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)searchDeviceWiFi_with_deviceID:(NSString *)deviceID
                           resultBlock:(resultBlock)resultBlock;


/// 开始搜索附近Wi-Fi列表
/// @param resultBlock 回调
- (void)startSearchDevice_with_resultBlock:(resultBlock)resultBlock;

/// 停止搜索附近Wi-Fi列表
/// @param resultBlock 回调
- (void)stopSearchDevice_with_resultBlock:(resultBlock)resultBlock;

/// 局域网搜索设备，搜索结果会从 osdr 返回，搜索结果会多次返回，需要做好过滤
/// 比如同个设备，可能会从 osdr 返回多次，需要避免这种干扰
/// int __declspec(dllexport) _stdcall IPCNetSearchDevice(OnSearchDeviceResult_t osdr);
/// int __declspec(dllexport) _stdcall IPCNetStopSearchDevice();

/// 设置局域网设置结果返回 回调，当调用局域网设置函数，结果通过OnLanSettingResult_t返回
/// int __declspec(dllexport) _stdcall IPCNetSetLanSettingResultCallback(OnLanSettingResult_t r);
/// 局域网重启设备
/// int __declspec(dllexport) _stdcall IPCNetRebootDeviceInLAN(const char*ip);
/// 局域网设置设备信息
/// int __declspec(dllexport) _stdcall IPCNetSetDeviceInfoInLAN(struct DevInfo *dev);
/// 让设备重新申请IP
/// int __declspec(dllexport) _stdcall IPCNetSetDeviceDhcpInLAN();

#pragma mark - 设备端信息

/// 获取设备端信息
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceInfo_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

#pragma mark - 修改设备密码

/// 修改设备密码
/// @param deviceID 设备id
/// @param password 新密码
/// @param resultBlock 回调
- (void)changeDevicePassword_with_deviceID:(NSString *)deviceID
                                  password:(NSString *)password
                               resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备OSD配置

/// 获取OSD
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getOSD_with_deviceID:(NSString *)deviceID
                        json:(NSString *)json
                 resultBlock:(resultBlock)resultBlock;

/// 设置OSD
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setOSD_with_deviceID:(NSString *)deviceID
                        json:(NSString *)json
                 resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备录像配置

/// 获取录像配置
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getRecordConfig_with_deviceID:(NSString *)deviceID
                                 json:(NSString *)json
                          resultBlock:(resultBlock)resultBlock;

/// 设置录像配置
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setRecordConfig_with_deviceID:(NSString *)deviceID
                                 json:(NSString *)json
                          resultBlock:(resultBlock)resultBlock;

#pragma mark - 远程目录信息

/// 获取远程目录信息
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getRemoteDirInfo_with_deviceID:(NSString *)deviceID
                                  json:(NSString *)json
                           resultBlock:(resultBlock)resultBlock;

/// 获取时间轴数据的远程目录信息
/// @param deviceID 设备id
/// @param vi 表示是第几个摄像头，(设备可能含有多个摄像头，暂时取 0 - 即第一个摄像头)
/// @param date 时间格式：20200214 // 2020年2月14日
/// @param resultBlock 回调
- (void)getRemoteDirInfo_timeLine_with_deviceID:(NSString *)deviceID
                                             vi:(int)vi
                                           date:(int)date
                                    resultBlock:(resultBlock)resultBlock;

/// 获取远程 Page 文件
/// @param deviceID 设备id
/// @param path 路径
/// @param resultBlock 回调
- (void)getRemotePageFile_with_deviceID:(NSString *)deviceID
                                   path:(NSString *)path
                            resultBlock:(resultBlock)resultBlock;



/// 删除远程文件
/// @param deviceID 设备id
/// @param path 路径
/// @param resultBlock 回调
- (void)deleteRemoteFile_with_deviceID:(NSString *)deviceID
                                  path:(NSString *)path
                           resultBlock:(resultBlock)resultBlock;

#pragma mark - 下载设备文件

/// 开始下载设备文件
/// @param deviceID 设备id
/// @param path 下载路径
- (void)startDownloadFile_with_deviceID:(NSString *)deviceID
                                   path:(NSString *)path;

/// 停止下载设备文件
/// @param deviceID 设备id
/// @param path 下载路径
- (void)stopDownloadFile_with_deviceID:(NSString *)deviceID
                                  path:(NSString *)path;

#pragma mark - 设备PTZ控制，摇头相关

/// 获取PTZ控制，摇头相关
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getPTZControl_with_deviceID:(NSString *)deviceID
                               json:(NSString *)json
                        resultBlock:(resultBlock)resultBlock;

/// 设置PTZ控制，摇头相关
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setPTZControl_with_deviceID:(NSString *)deviceID
                               json:(NSString *)json
                        resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备曝光类型

/// 获取曝光类型
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getExpType_with_deviceID:(NSString *)deviceID
                     resultBlock:(resultBlock)resultBlock;

/// 设置曝光类型
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setExpType_with_deviceID:(NSString *)deviceID
                            json:(NSString *)json
                     resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备手动曝光

/// 获取手动曝光
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getHandExpInfo_with_deviceID:(NSString *)deviceID
                         resultBlock:(resultBlock)resultBlock;

/// 设置手动曝光
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setHandExpInfo_with_deviceID:(NSString *)deviceID
                                json:(NSString *)json
                         resultBlock:(resultBlock)resultBlock;

#pragma mark - 自动曝光

/// 获取自动曝光
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getAutoExpInfo_with_deviceID:(NSString *)deviceID
                         resultBlock:(resultBlock)resultBlock;

/// 设置自动曝光
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setAutoExpInfo_with_deviceID:(NSString *)deviceID
                                json:(NSString *)json
                         resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备热点

/// 获取设备热点
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getWiFiAPInfo_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

/// 设置设备热点
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setWiFiAPInfo_with_deviceID:(NSString *)deviceID
                               json:(NSString *)json
                        resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备报警信息

/// 获取设备报警信息
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceAlarm_with_deviceID:(NSString *)deviceID
                         resultBlock:(resultBlock)resultBlock;

/// 设置设备报警
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setDeviceAlarm_with_deviceID:(NSString *)deviceID
                                json:(NSString *)json
                         resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备清晰度

/// 获取清晰度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getQualityLevel_with_deviceID:(NSString *)deviceID
                          resultBlock:(resultBlock)resultBlock;

/// 设置清晰度
/// @param deviceID 设备id
/// @param level 清晰度级别
/// @param resultBlock 回调
- (void)setQualityLevel_with_deviceID:(NSString *)deviceID
                                level:(int)level
                          resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备亮度

/// 获取亮度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getBrightnessLevel_with_deviceID:(NSString *)deviceID
                             resultBlock:(resultBlock)resultBlock;

/// 设置亮度
/// @param deviceID 设备id
/// @param level 亮度级别
/// @param resultBlock 回调
- (void)setBrightnessLevel_with_deviceID:(NSString *)deviceID
                                   level:(int)level
                             resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备对比度

/// 获取对比度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getCompareColoLevel_with_deviceID:(NSString *)deviceID
                              resultBlock:(resultBlock)resultBlock;

/// 设置对比度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setCompareColorLevel_with_deviceID:(NSString *)deviceID
                                     level:(int)level
                               resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备色度

/// 获取色度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getColorLevel_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

/// 设置色度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setColorLevel_with_deviceID:(NSString *)deviceID
                              level:(int)level
                        resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备饱和度

/// 获取饱和度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getSaturationLevel_with_deviceID:(NSString *)deviceID
                             resultBlock:(resultBlock)resultBlock;

/// 设置饱和度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setSaturationLevel_with_deviceID:(NSString *)deviceID
                                   level:(int)level
                             resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备锐度

/// 获取锐度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getAcutanceLevel_with_deviceID:(NSString *)deviceID
                           resultBlock:(resultBlock)resultBlock;

/// 设置锐度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setAcutanceLevel_with_deviceID:(NSString *)deviceID
                                 level:(int)level
                           resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备恢复默认设置

/// 恢复默认设置
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)setDefault_with_deviceID:(NSString *)deviceID
                     resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备画面翻转

/// 画面翻转
/// @param deviceID 设备id
/// @param flip 翻转
/// @param mirror 镜像
/// @param resultBlock 回调
- (void)setFilp_with_deviceID:(NSString *)deviceID
                         flip:(int)flip
                       mirror:(int)mirror
                  resultBlock:(resultBlock)resultBlock;

#pragma mark - 设备时间

/// 获取设备时间
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceTime_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock;

/// 设置设备时间
/// @param deviceID 设备id
/// @param time s
/// @param resultBlock 回调
- (void)setDeviceTime_with_deviceID:(NSString *)deviceID
                               time:(IPCNetTimeCfg_t *)time
                        resultBlock:(resultBlock)resultBlock;



@end

NS_ASSUME_NONNULL_END
