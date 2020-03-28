//void OnListRemoteDirInfoCmdResult(int cmd,const char*uuid,const char*json);
//void OnListRemotePageFileCmdResult2(int cmd,const char*uuid,const char*json);
//void OnListRemoteDirInfoCmdResult(int cmd,const char*uuid,const char*json)
//{
//    /// json 解析
//    JSONObject jsdata(json);
//    RemoteDirListInfo_t rdi;
//    /// 从返回的json结构体里面获取目录信息
//    rdi.parseJSON(jsdata);
//
//    /// 获取磁盘总空间
//    /// mTotalSize = rdi.total;
//    /// 获取磁盘已使用空间
//    /// mUsedSize = rdi.used;
//    int requireNum;
//    int in_de_x = 0;
//    start_index = 0;
//    /// 设置当前目录总共有几个文件，包括目录（IPCNetListRemoteDirInfoR的mode设置为1的时候，会包含目录）
//    total_dir_num = rdi.num;
//    /// 每次获取最多10个目录下面的文件
//    if (total_dir_num > 10){
//        requireNum = 10;
//        start_index = 10;
//    }
//    else {
//        /// 不足10个，一次性全部获取
//        requireNum = rdi.num;
//        start_index = rdi.num;
//    }
//
//    /// 组织json字符串，lp是list path简写， p为path简写，s是start简写，c是count简写
//    char jsonbuff[1024] = {0};
//    NSString *path = TTStr(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],seekBackPlayList_Date);
//    sprintf(jsonbuff,"{\"lp\":{\"p\":\"%s\",\"s\":%d,\"c\":%d}}", path.UTF8String, in_de_x, requireNum);
//    /// 按索引获取目录下的文件名，结果通过 OnListRemotePageFileCmdResult2 返回
//    IPCNetListRemotePageFileR(uuid, jsonbuff, OnListRemotePageFileCmdResult2);
//    /// 释放命令绑定资源
//    IPCNetReleaseCmdResource(cmd, uuid, OnListRemoteDirInfoCmdResult);
//}
//
//void OnListRemotePageFileCmdResult2(int cmd,const char*uuid,const char*json)
//{
//    JSONObject jsdata(json);
//    // 创建 RemoteDirInfo_t 对象
//    RemoteDirInfo_t *rdi = new RemoteDirInfo_t;
//
//    NSString *diskInfo_path = TTStr(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],seekBackPlayList_Date);
//
//    rdi->path = diskInfo_path.UTF8String;
//    rdi->parseJSON(jsdata);
//    if (remoteDirInfo == 0) {
//        remoteDirInfo = rdi;
//    }
//    else if (strcmp(remoteDirInfo->path.c_str(), rdi->path.c_str()) == 0) {
//
//        for(list<RemoteFileInfo_t*>::iterator it = rdi->mRemoteFileInfoList.begin(); it != rdi->mRemoteFileInfoList.end(); it++) {
//            RemoteFileInfo_t *rfi = *it;
//            RemoteFileInfo_t *rfi_bak = new RemoteFileInfo_t;
//            rfi_bak->name = rfi->name;
//            rfi_bak->path = rfi->path;
//            rfi_bak->type = rfi->type;
//            rfi_bak->size = rfi->size;
//            // 添加新的文件到目录
//            remoteDirInfo->mRemoteFileInfoList.push_back(rfi_bak);
//        }
//        delete rdi;
//    }
//
////    if (mRemoteRootDirInfo == 0)
////        mRemoteRootDirInfo = rdi;
//
//    IPCNetReleaseCmdResource(cmd, uuid,OnListRemotePageFileCmdResult2);
//
//    //根据当前获取到的索引，继续获取剩下的文件
//    if (total_dir_num > start_index) {
//#pragma mark - 获取数据后，发现还有数据，继续请求
//        int in_de_x = start_index;
//        int requireNum = total_dir_num - in_de_x;
//        char jsonbuff[1024] = {0};
//        if (requireNum > 10)
//            requireNum = 10;
//
//        start_index += requireNum;
//        NSString *path = TTStr(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],seekBackPlayList_Date);
//        sprintf(jsonbuff,"{\"lp\":{\"p\":\"%s\",\"s\":%d,\"c\":%d}}", path.UTF8String, in_de_x, requireNum);
//        //释放命令绑定资源
//        IPCNetListRemotePageFileR(uuid,jsonbuff,OnListRemotePageFileCmdResult2);
//    }
//    else {
//#pragma mark - 获取数据后，没有数据，发出更新提示
//        [[NSNotificationCenter defaultCenter] postNotificationName:noti_1077_KEY object:nil];
//    }
//}


//
//  TTFirmwareInterface_API.h
//  SuperIPC
//
//  Created by kevin on 2020/2/14.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPCNetManagerInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^reBlock)(NSInteger code);
typedef void(^playBackVideoOrAudioDataRetultBlock)(const char*uuid,int type,unsigned char*data,int len,long timestamp);

@interface TTFirmwareInterface_API : NSObject

{
    struct IPCNetEventHandler netHandle;
}

+ (TTFirmwareInterface_API *)sharedManager;

#pragma mark - 设备连接

- (void)connect_with_deviceID:(NSString *)deviceID password:(NSString *)password reBlock:(reBlock)reBlock;

#pragma mark - 断开连接

- (void)disconnect_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 开始获取视频

/// quality 0:主码流，高清码流，适合设备端录像， 1:子码流，标清码流，适合网络传输
- (void)startGetVideo_with_deviceID:(NSString *)deviceID quality:(int)quality reBlock:(reBlock)reBlock;

#pragma mark - 停止获取视频

- (void)stopGetVideo_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 开始获取音频

- (void)startGetAudio_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 停止获取音频

- (void)stopGetAudio_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 设备对讲
#pragma mark - 开启设备扬声器，准备接收音频数据并播放
- (void)startTalk_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 关闭设备扬声器

- (void)stopTalk_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 设备回放
#pragma mark - 设置 音频 和 视频 回调           第一步
- (void)setPlaybackAudioVideoDataCallBack_with_deviceID:(NSString *)deviceID reBlock:(playBackVideoOrAudioDataRetultBlock)reBlock;

#pragma mark - 移除 音频 和 视频 回调

- (void)removePlaybackAudioVideoDataCallBack_with_deviceID:(NSString *)deviceID;

#pragma mark - 开始录像回放                    第二步

/// path 回放路径
- (void)startPlayback_with_deviceID:(NSString *)deviceID path:(NSString *)path reBlock:(reBlock)reBlock;

#pragma mark - 停止录像回放

- (void)stopPlayback_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 暂停/继续录像回放

/// contin 暂停/继续
- (void)pausePlayback_with_deviceID:(NSString *)deviceID contin:(BOOL)contin reBlock:(reBlock)reBlock;

#pragma mark - 恢复设备出厂设置

- (void)resetDevice_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 重启设备

- (void)rebootDevice_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 获取设备Wi-Fi

- (void)getDeviceWiFi_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 设置设备Wi-Fi

/// encType 根据列表查询得到信息，不用自己写

- (void)setDeviceWiFi_with_deviceID:(NSString *)deviceID ssid:(NSString *)ssid password:(NSString *)password encType:(NSString *)encType reBlock:(reBlock)reBlock;

#pragma mark - 搜索附近Wi-Fi列表

- (void)searchDeviceWiFi_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 开始搜索附近Wi-Fi列表

- (void)startSearchDevice_with_reBlock:(reBlock)reBlock;

#pragma mark - 停止搜索附近Wi-Fi列表

- (void)stopSearchDevice_with_reBlock:(reBlock)reBlock;

#pragma mark - 修改设备密码

- (void)changeDevicePassword_with_deviceID:(NSString *)deviceID password:(NSString *)password reBlock:(reBlock)reBlock;

#pragma mark - 设备OSD配置

- (void)getOSD_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock;

- (void)setOSD_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock;

#pragma mark - 获取录像配置

- (void)getRecordConfig_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock;

#pragma mark - 获取远程目录信息

- (void)getRemoteDirInfo_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock;

#pragma mark - 获取时间轴数据的远程目录信息
/// @param vi 表示是第几个摄像头，(设备可能含有多个摄像头，暂时取 0 - 即第一个摄像头)
/// @param date 时间格式：20200214 // 2020年2月14日
- (void)getRemoteDirInfo_timeLine_with_deviceID:(NSString *)deviceID vi:(int)vi date:(int)date reBlock:(reBlock)reBlock;

#pragma mark - 播放时间轴回放视频
/// vi 表示是第几个摄像头，(设备可能含有多个摄像头，暂时取 0 - 即第一个摄像头)
/// date/time 时间格式：20200214
- (void)starPlayback_timeLine_with_deviceID:(NSString *)deviceID vi:(int)vi date:(int)date time:(int)time reBlock:(reBlock)reBlock;

#pragma mark - 删除远程文件
/// path 路径
- (void)deleteRemoteFile_with_deviceID:(NSString *)deviceID path:(NSString *)path reBlock:(reBlock)reBlock;

#pragma mark - 设置清晰度

/// level 清晰度级别 0 标清，1 高清，2 4K超清
- (void)setQualityLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock;

#pragma mark - 设备亮度

/// level 亮度级别 0 - 255
- (void)setBrightnessLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock;

#pragma mark - 设备对比度

/// level 对比度级别 0 - 255
- (void)setCompareColorLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock;

#pragma mark - 设备饱和度
- (void)getSaturationLevel_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

/// level 对比度级别 0 - 255
- (void)setSaturationLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock;

#pragma mark - 设备锐度
/// level 对比度级别 0 - 255
- (void)setAcutanceLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock;

#pragma mark - 设备恢复默认设置
- (void)setDefault_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

#pragma mark - 获取色彩/黑白模式
- (void)getIRModel_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock;

/// type type == 0 彩色画面/ type == 1 黑白画面
- (void)setIRModel_with_deviceID:(NSString *)deviceID type:(int)type reBlock:(reBlock)reBlock;

#pragma mark - 画面翻转
/// flip 0 mirror 1     
/// flip 1 mirror 0
- (void)setFilp_with_deviceID:(NSString *)deviceID flip:(int)flip mirror:(int)mirror reBlock:(reBlock)reBlock;

@end

NS_ASSUME_NONNULL_END
