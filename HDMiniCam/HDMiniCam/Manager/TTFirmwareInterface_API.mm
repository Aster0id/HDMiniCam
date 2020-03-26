//
//  TTFirmwareInterface_API.m
//  SuperIPC
//
//  Created by kevin on 2020/2/14.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTFirmwareInterface_API.h"
#import "SEP2P_Error.h"
#import "JSONStructProtocal.h"
#import "IPCNetManagerInterface.h"
#import "H264_H265_VideoDecoder.h"

/**
 typedef struct IPCNetRecordCfg{
     int ViCh;//sensor index.
     DiskInfo_st *DiskInfo;
     int RecMinsOptionNum;
     int RecMinsOption[32];
     int RecMins;//set with index of RecMinsOption
     bool AutoDel;
     int VeCh;
     RecTime_st *RecTime[8];
     int PackageType;
     int ReserveSize;
     IPCNetRecordCfg(){
         int i;
         DiskInfo=new DiskInfo_st;
         for(i=0;i<8;i++){
             RecTime[i]=new RecTime_st;
         }
     }
     ~IPCNetRecordCfg(){
         int i;
         delete DiskInfo;
         for(i=0;i<8;i++){
             delete RecTime[i];
         }
     }
     boolean parseJSON(JSONObject &jsdata){
         JSONObject *jsroot= jsdata.getJSONObject("Rec.Conf");
         if(jsroot!=0){
             int value;
             jsroot->getInt("ViCh",ViCh);
             JSONObject *jsDiskInfo=jsroot->getJSONObject("DiskInfo");
             if(jsDiskInfo){
                 jsDiskInfo->getInt("Free",value);
                 DiskInfo->Free=value;
                 jsDiskInfo->getInt("Total",value);
                 DiskInfo->Total=value;
                 jsDiskInfo->getString("Path",DiskInfo->Path);
 
                 jsDiskInfo->getBoolean("isValid",DiskInfo->isValid);
 
                 jsDiskInfo->getInt("Type",DiskInfo->Type);
 
                 delete jsDiskInfo;
             }
             jsroot->getInt("RecMins",value);
             RecMins=value;
             JSONArray*jsaRecMinsOption=jsroot->getJSONArray("RecMinsOption");
             if(jsaRecMinsOption){
                 int rl=jsaRecMinsOption->getLength();
                 RecMinsOptionNum=rl;
                 rl=rl>32?32:rl;
                 for(int i=0;i<rl;i++){
                     jsaRecMinsOption->getInt(i,value);
                     RecMinsOption[i]=value;
                 }
 
                 delete jsaRecMinsOption;
             }
             jsroot->getInt("VeCh",VeCh);
             jsroot->getBoolean("AutoDel",AutoDel);
             jsroot->getInt("PackageType",PackageType);
             jsroot->getInt("ReserveSize",ReserveSize);
 
             JSONArray*jsaRecTime=jsroot->getJSONArray("RecTime");
             if(jsaRecTime){
                 int i;
                 for(i=0;i<jsaRecTime->getLength();i++){
                     JSONObject*jsRt=jsaRecTime->getJSONObject(i);
                     if(jsRt){
                         jsRt->getInt("En",RecTime[i]->En);
                         jsRt->getString("St1",RecTime[i]->St1);
                         jsRt->getString("Ed1",RecTime[i]->Ed1);
                         jsRt->getString("St2",RecTime[i]->St2);
                         jsRt->getString("Ed2",RecTime[i]->Ed2);
                         delete jsRt;
                     }
                 }
                 delete jsaRecTime;
             }
 
             delete jsroot;
         }
         
         return true;
     }
     int toJSONString(String&str){
         JSONObject jsroot;
 
         JSONObject jresult;
         jresult.put("ViCh", ViCh);
         jresult.putBoolean("AutoDel", AutoDel);
         jresult.put("PackageType", PackageType);
         jresult.put("ReserveSize", ReserveSize);
         jresult.put("VeCh", VeCh);
         jresult.put("RecMins", RecMins);
         JSONObject jsDiskInfo;
         //no need
         jresult.put("DiskInfo",jsDiskInfo);
         JSONArray jsaRecMinsOption;
         //no need
         jresult.put("RecMinsOption",jsaRecMinsOption);
 
         JSONArray jsaRecTime;
         int i;
         for(i=0;i<8;i++){
             JSONObject jsRt;
             jsRt.put("En",RecTime[i]->En);
             jsRt.put("St1",RecTime[i]->St1);
             jsRt.put("Ed1",RecTime[i]->Ed1);
             jsRt.put("St2",RecTime[i]->St2);
             jsRt.put("Ed2",RecTime[i]->Ed2);
             jsaRecTime.put(i,jsRt);
         }
         jresult.put("RecTime",jsaRecTime);
                 
         jsroot.put("Rec.Conf", jresult);
         
         jsroot.toString(str);
         return str.length();
     }
 }IPCNetRecordCfg_st;
 */
/// 录像配置信息，用于获取远程视频文件的目录路径
IPCNetRecordCfg_st recordCfg;
/// 远程视频文件目录路径
/// recordCfg.DiskInfo->Path.c_str()

/// 彩色/黑色      - 结构体 - 获取当前色彩信息，只用修改type就可以进行黑白/彩色切换
IPCNetPicColorInfo_st colorCfg;
playBackVideoOrAudioDataRetultBlock playBackDataBlock;

static int start_index = 0;
static int total_dir_num = 0;
RemoteDirInfo_t *remoteDirInfo;


// 查询远程视频列表的日期
const char *checkRemoteVideoList_Date;


@implementation TTFirmwareInterface_API

+ (TTFirmwareInterface_API *)sharedManager
{
    static TTFirmwareInterface_API *manager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [TTFirmwareInterface_API sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [TTFirmwareInterface_API sharedManager];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        netHandle.onStatus = onStatus;
        netHandle.onAudioData = onAudioData;
        netHandle.onVideoData = onVideoData;
        netHandle.onJSONString = onJSONString;
        IPCNetInitialize("");
    }
    return self;
}

#pragma mark - 设备连接

- (void)connect_with_deviceID:(NSString *)deviceID password:(NSString *)password reBlock:(reBlock)reBlock
{
    int ret = IPCNetStartIPCNetSession(deviceID.UTF8String, password.UTF8String, &netHandle);
    TLog(@"设备登录connect_with_deviceID，ret = %d",ret);
}

#pragma mark - 断开连接

- (void)disconnect_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStopIPCNetSession(deviceID.UTF8String);
    TLog(@"设备断开disconnect_with_deviceID，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
        reBlock(ret);
    });
}

#pragma mark - 开始获取视频

/// quality 0:主码流，高清码流，适合设备端录像， 1:子码流，标清码流，适合网络传输
- (void)startGetVideo_with_deviceID:(NSString *)deviceID quality:(int)quality reBlock:(reBlock)reBlock
{
    int ret = IPCNetStartVideo(deviceID.UTF8String, quality);
    TLog(@"开始获取视频startGetVideo_with_deviceID，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       reBlock(ret);
    });
}

#pragma mark - 停止获取视频

- (void)stopGetVideo_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStopVideo(deviceID.UTF8String);
    TLog(@"停止获取视频stopGetVideo_with_deviceID，ret = %d",ret);
}

#pragma mark - 开始获取音频

- (void)startGetAudio_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStartAudio(deviceID.UTF8String);
    TLog(@"开始获取音频startGetAudio_with_deviceID，ret = %d",ret);
}

#pragma mark - 停止获取音频

- (void)stopGetAudio_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStopAudio(deviceID.UTF8String);
    TLog(@"停止获取音频stopGetAudio_with_deviceID，ret = %d",ret);
}

#pragma mark - 开启设备扬声器，准备接收音频数据并播放

- (void)startTalk_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStartTalk(deviceID.UTF8String, IPCNET_AUDIO_G711A);
    TLog(@"开启设备扬声器，准备接收音频数据并播放startTalk_with_deviceID，ret = %d",ret);
}

#pragma mark - 关闭设备扬声器

- (void)stopTalk_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStopTalk(deviceID.UTF8String);
    TLog(@"关闭设备扬声器stopTalk_with_deviceID，ret = %d",ret);
}

#pragma mark - 设置 音频 和 视频 回调           第一步
- (void)setPlaybackAudioVideoDataCallBack_with_deviceID:(NSString *)deviceID reBlock:(playBackVideoOrAudioDataRetultBlock)reBlock
{
    int ret = IPCNetSetPlaybackAudioVideoDataCallBack(deviceID.UTF8String, OnSetPlaybackAudioVideoDataCallBackCmdResult);
    TLog(@"设置 音频 和 视频 回调setPlaybackAudioVideoDataCallBack_with_deviceID，ret = %d",ret);
    playBackDataBlock = reBlock;
}

#pragma mark - 移除 音频 和 视频 回调

- (void)removePlaybackAudioVideoDataCallBack_with_deviceID:(NSString *)deviceID
{
    int ret = IPCNetSetPlaybackAudioVideoDataCallBack(deviceID.UTF8String, NULL);
    TLog(@"移除 音频 和 视频 回调startPlayback_with_deviceID，ret = %d",ret);
    playBackDataBlock = nil;
}

/// 获取sd卡回放 音频 或 视频数据
/// @param uuid 设备id
/// @param type 类型
/// @param data 音频 或 视频 数据
/// @param len 数据长度
/// @param timestamp 时间戳
void OnSetPlaybackAudioVideoDataCallBackCmdResult(const char*uuid,int type,unsigned char*data,int len,long timestamp)
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        TLog(@"设置 音频 和 视频 回调 uuid = %s type = %d len = %d timestamp = %ld \n", uuid, type, len, (long)timestamp);
        if (playBackDataBlock) {
            playBackDataBlock(uuid, type, data, len, timestamp);
        }
    });
}

#pragma mark - 开始录像回放                    第二步

/// path 回放路径
- (void)startPlayback_with_deviceID:(NSString *)deviceID path:(NSString *)path reBlock:(reBlock)reBlock
{
    int ret = IPCNetStartPlaybackR(deviceID.UTF8String, path.UTF8String, OnStartPlaybackCmdResult);
    TLog(@"开始视频回放startPlayback_with_deviceID，ret = %d",ret);
}

void OnStartPlaybackCmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnStartPlaybackCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
}

#pragma mark - 停止录像回放

- (void)stopPlayback_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetStopPlaybackR(deviceID.UTF8String, OnGetStopPlaybackCmdResult);
    TLog(@"停止视频回放stopPlayback_with_deviceID，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ret >= 0) {
           reBlock(ret);
        }
        else {
            TLog(@"stopPlayback_with_deviceID 调用失败........................");
        }
    });
}

void OnGetStopPlaybackCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnGetStopPlaybackCmdResult dict = %@",dict);
}

#pragma mark - 暂停/继续录像回放

/// contin 暂停/继续
- (void)pausePlayback_with_deviceID:(NSString *)deviceID contin:(BOOL)contin reBlock:(reBlock)reBlock
{
    if (!contin) {
        int ret = IPCNetRestorePlaybackAfterPause(deviceID.UTF8String);
        TLog(@"暂停播放回放视频pausePlayback_with_deviceID，ret = %d",ret);
        dispatch_async(dispatch_get_main_queue(), ^{
           reBlock(ret);
        });
    }
    else {
        int ret = IPCNetPausePlaybackR(deviceID.UTF8String, OnGetPausePlaybackCmdResult);
        TLog(@"继续播放回放视频pausePlayback_with_deviceID，ret = %d",ret);
        dispatch_async(dispatch_get_main_queue(), ^{
           reBlock(ret);
        });
    }
}

void OnGetPausePlaybackCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnGetPausePlaybackCmdResult dict = %@",dict);
}

#pragma mark - 恢复设备出厂设置

- (void)resetDevice_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetRestoreToFactorySetting(deviceID.UTF8String);
    TLog(@"恢复设备出厂设置resetDevice_with_deviceID，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{

        reBlock(ret);
    });
}

#pragma mark - 重启设备

- (void)rebootDevice_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetRebootDevice(deviceID.UTF8String);
    TLog(@"重启设备rebootDevice_with_deviceID，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ret >= 0) {
            reBlock(ret);
        }
        else {
            TLog(@"rebootDevice_with_deviceID 调用失败........................");
        }
    });
}

#pragma mark - 获取设备Wi-Fi

- (void)getDeviceWiFi_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetGetWiFiR(deviceID.UTF8String, OnGetDeviceWiFi_CmdResult);
    TLog(@"获取设备Wi-FigetDeviceWiFi_with_deviceID，ret = %d",ret);
}
void OnGetDeviceWiFi_CmdResult(int cmd,const char*uuid,const char*json)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TT_getDeviceWiFiCmdResult_noti_KEY object:[TTCommon cString_changto_ocStringWith:json]];
}

#pragma mark - 设置设备Wi-Fi
/// encType 根据列表查询得到信息，不用自己写
- (void)setDeviceWiFi_with_deviceID:(NSString *)deviceID ssid:(NSString *)ssid password:(NSString *)password encType:(NSString *)encType reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetWiFi(deviceID.UTF8String, ssid.UTF8String, password.UTF8String, encType.UTF8String);
    TLog(@"设置设备Wi-FisetDeviceWiFi_with_deviceID，ret = %d",ret);
}

#pragma mark - 搜索附近Wi-Fi列表
- (void)searchDeviceWiFi_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetSearchWiFiR(deviceID.UTF8String, OnSearchDeviceWiFi_CmdResult);
    TLog(@"搜索附近Wi-Fi列表searchDeviceWiFi_with_deviceID，ret = %d",ret);
}

void OnSearchDeviceWiFi_CmdResult(int cmd,const char*uuid,const char*json)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TT_getSearchDeviceWiFi_noti_KEY object:[TTCommon cString_changto_ocStringWith:json]];
}

#pragma mark - 开始搜索附近Wi-Fi列表
- (void)startSearchDevice_with_reBlock:(reBlock)reBlock
{
    int ret = IPCNetSearchDevice(OnSearchDeviceResult);
    TLog(@"搜索附近的设备startSearchDevice_with_reBlock，ret = %d",ret);
}

void OnSearchDeviceResult(struct DevInfo *device)
{
    NSString *uuid = TTStr(@"%s",device->mUUID);
    NSString *deviceIP = TTStr(@"%s",device->mIP);
    NSString *name = TTStr(@"%s",device->mDevName);
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:uuid forKey:@"deviceID"];
    [body setValue:name forKey:@"deviceName"];
    [body setValue:deviceIP forKey:@"deviceIP"];
    [body setValue:@"admin" forKey:@"devicePassword"];// admin 原始密码
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OnSearchDeviceResult_noti_key" object:body];
}

/// 停止搜索附近的设备
/// @param reBlock 回调
- (void)stopSearchDevice_with_reBlock:(reBlock)reBlock
{
    int ret = IPCNetStopSearchDevice();
    TLog(@"停止搜索附近的设备stopSearchDevice_with_reBlock，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
        reBlock(ret);
    });
}

#pragma mark - 修改设备密码
- (void)changeDevicePassword_with_deviceID:(NSString *)deviceID password:(NSString *)password reBlock:(reBlock)reBlock
{
    int ret = IPCNetChangeDevPwd(deviceID.UTF8String, password.UTF8String);
    TLog(@"修改设备密码changeDevicePassword_with_deviceID，ret = %d",ret);
}

#pragma mark - 设备OSD配置
- (void)getOSD_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock
{
    int ret = IPCNetGetOSDR(deviceID.UTF8String, json.UTF8String, OnGetOSDConfCmdResult);
    TLog(@"获取OSDgetOSD_with_deviceID，ret = %d",ret);
}

void OnGetOSDConfCmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnGetOSDConfCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
}

- (void)setOSD_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetOSDR(deviceID.UTF8String, json.UTF8String, OnSetOSDConfCmdResult);
    TLog(@"设置OSDsetOSD_with_deviceID，ret = %d",ret);
}

void OnSetOSDConfCmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnSetOSDConfCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
}

#pragma mark - 获取录像配置
- (void)getRecordConfig_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock
{
    IPCNetRecordGetCfg_st ipcrgc;
    ipcrgc.ViCh = 0;
    ipcrgc.Path = recordCfg.DiskInfo->Path;
    String str;
    ipcrgc.toJSONString(str);
    int ret = IPCNetGetRecordConfR(deviceID.UTF8String, str.c_str(), OnGetRecordConfCmdResult);
    TLog(@"获取录像配置getRecordConfig_with_deviceID，ret = %d",ret);
}

void OnGetRecordConfCmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnGetRecordConfCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
    JSONObject jsdata(json);
    recordCfg.parseJSON(jsdata);
    IPCNetReleaseCmdResource(cmd,uuid,OnGetRecordConfCmdResult);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TT_getRecordConf_noti_KEY object:nil];
    });
}

#pragma mark - 获取远程目录信息
- (void)getRemoteDirInfo_with_deviceID:(NSString *)deviceID json:(NSString *)json reBlock:(reBlock)reBlock
{
    int ret = IPCNetListRemoteDirInfoR(deviceID.UTF8String, json.UTF8String, OnListRemoteDirInfoCmdResult);
    TLog(@"获取远程目录信息getRemoteDirInfo_with_deviceID，ret = %d",ret);
}

void OnListRemoteDirInfoCmdResult(int cmd,const char*uuid,const char*json)
{
    /// json 解析
    JSONObject jsdata(json);
    RemoteDirListInfo_t rdi;
    /// 从返回的json结构体里面获取目录信息
    rdi.parseJSON(jsdata);

    /// 获取磁盘总空间
    /// mTotalSize = rdi.total;
    /// 获取磁盘已使用空间
    /// mUsedSize = rdi.used;
    int requireNum;
    int in_de_x = 0;
    start_index = 0;
    /// 设置当前目录总共有几个文件，包括目录（IPCNetListRemoteDirInfoR的mode设置为1的时候，会包含目录）
    total_dir_num = rdi.num;
    /// 每次获取最多10个目录下面的文件
    if (total_dir_num > 10){
        requireNum = 10;
        start_index = 10;
    }
    else {
        /// 不足10个，一次性全部获取
        requireNum = rdi.num;
        start_index = rdi.num;
    }

    /// 组织json字符串，lp是list path简写， p为path简写，s是start简写，c是count简写
    char jsonbuff[1024] = {0};
    NSString *path = TTStr(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],checkRemoteVideoList_Date);
    sprintf(jsonbuff,"{\"lp\":{\"p\":\"%s\",\"s\":%d,\"c\":%d}}", path.UTF8String, in_de_x, requireNum);
    /// 按索引获取目录下的文件名，结果通过 OnListRemotePageFileCmdResult2 返回
    IPCNetListRemotePageFileR(uuid, jsonbuff, OnListRemotePageFileCmdResult2);
    /// 释放命令绑定资源
    IPCNetReleaseCmdResource(cmd, uuid, OnListRemoteDirInfoCmdResult);
}

void OnListRemotePageFileCmdResult2(int cmd,const char*uuid,const char*json)
{
    JSONObject jsdata(json);
    // 创建 RemoteDirInfo_t 对象
    RemoteDirInfo_t *rdi = new RemoteDirInfo_t;

    NSString *diskInfo_path = TTStr(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],checkRemoteVideoList_Date);

    rdi->path = diskInfo_path.UTF8String;
    rdi->parseJSON(jsdata);
    if (remoteDirInfo == 0) {
        remoteDirInfo = rdi;
    }
    else if (strcmp(remoteDirInfo->path.c_str(), rdi->path.c_str()) == 0) {
        
        for(list<RemoteFileInfo_t*>::iterator it = rdi->mRemoteFileInfoList.begin(); it != rdi->mRemoteFileInfoList.end(); it++) {
            RemoteFileInfo_t *rfi = *it;
            RemoteFileInfo_t *rfi_bak = new RemoteFileInfo_t;
            rfi_bak->name = rfi->name;
            rfi_bak->path = rfi->path;
            rfi_bak->type = rfi->type;
            rfi_bak->size = rfi->size;
            // 添加新的文件到目录
            remoteDirInfo->mRemoteFileInfoList.push_back(rfi_bak);
        }
        delete rdi;
    }

    IPCNetReleaseCmdResource(cmd, uuid,OnListRemotePageFileCmdResult2);

    //根据当前获取到的索引，继续获取剩下的文件
    if (total_dir_num > start_index) {
#pragma mark - 获取数据后，发现还有数据，继续请求
        int in_de_x = start_index;
        int requireNum = total_dir_num - in_de_x;
        char jsonbuff[1024] = {0};
        if (requireNum > 10)
            requireNum = 10;

        start_index += requireNum;
        NSString *path = TTStr(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],checkRemoteVideoList_Date);
        sprintf(jsonbuff,"{\"lp\":{\"p\":\"%s\",\"s\":%d,\"c\":%d}}", path.UTF8String, in_de_x, requireNum);
        //释放命令绑定资源
        IPCNetListRemotePageFileR(uuid,jsonbuff,OnListRemotePageFileCmdResult2);
    }
    else {
#pragma mark - 获取数据后，没有数据，发出更新提示
        [[NSNotificationCenter defaultCenter] postNotificationName:TT_getListRemotePageFile_noti_KEY object:nil];
    }
}

#pragma mark - 获取时间轴数据的远程目录信息
/// @param vi 表示是第几个摄像头，(设备可能含有多个摄像头，暂时取 0 - 即第一个摄像头)
/// @param date 时间格式：20200214 // 2020年2月14日
- (void)getRemoteDirInfo_timeLine_with_deviceID:(NSString *)deviceID vi:(int)vi date:(int)date reBlock:(reBlock)reBlock
{
    char jsonbuff[1024] = {0};
    sprintf(jsonbuff,"{\"RecInfo\":{\"vi\":%d,\"date\":%d}}", vi, date);
    int ret = IPCNetListRemoteDirInfoR(deviceID.UTF8String, jsonbuff, OnGetRemoteDirInfo_timeLine_CmdResult);
    TLog(@"获取时间轴数据的远程目录信息getRemoteDirInfo_timeLine_with_deviceID，ret = %d",ret);
}

void OnGetRemoteDirInfo_timeLine_CmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnGetRemoteDirInfo_timeLine_CmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
    NSDictionary *backPlay_result = [TTCommon cString_changto_ocStringWith:json];
    NSArray *result_array = backPlay_result[@"RecInfo"][@"period"];
    TLog(@"OnGetRemoteDirInfo_timeLine_CmdResult = %ld",(long)result_array.count);
    [[NSNotificationCenter defaultCenter] postNotificationName:TT_getTimeLineInfo_noti_KEY object:result_array];
}

#pragma mark - 播放时间轴回放视频
/// vi 表示是第几个摄像头，(设备可能含有多个摄像头，暂时取 0 - 即第一个摄像头)
/// date 时间格式：20200214
/// time 时间格式：20200214
- (void)starPlayback_timeLine_with_deviceID:(NSString *)deviceID vi:(int)vi date:(int)date time:(int)time reBlock:(reBlock)reBlock
{
    int ret = IPCNetStartPlaybackAtTimeR(deviceID.UTF8String, vi, date, time, OnStarPlayback_timeLine_CmdResult);
    TLog(@"播放时间轴回放视频starPlayback_timeLine_with_deviceID，ret = %d",ret);
}

void OnStarPlayback_timeLine_CmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnStartPlaybackCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
//    NSDictionary *backPlay_result = [TTCommon cString_changto_ocStringWith:json];
//    NSArray *result_array = backPlay_result[@"RecInfo"][@"period"];
//    TLog(@"result_array.count = %ld",(long)result_array.count);
//    [[NSNotificationCenter defaultCenter] postNotificationName:TT_getTimeLineInfo_noti_KEY object:result_array];
}

#pragma mark - 删除远程文件
/// path 路径
- (void)deleteRemoteFile_with_deviceID:(NSString *)deviceID path:(NSString *)path reBlock:(reBlock)reBlock
{
    int ret = IPCNetDeleteRemoteFileR(deviceID.UTF8String, path.UTF8String, OnDeleteRemoteFileCmdResult);
    TLog(@"删除远程文件deleteRemoteFile_with_deviceID，ret = %d",ret);
}

void OnDeleteRemoteFileCmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnDeleteRemoteFileCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
    NSDictionary *result = [TTCommon cString_changto_ocStringWith:json];
    dispatch_async(dispatch_get_main_queue(), ^{
        int ret = [result[@"ret"] intValue];
        if (ret == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TT_deleteRemoteFile_noti_KEY object:nil];
        }
    });
}

#pragma mark - 设置清晰度
/// level 清晰度级别 0 标清，1 高清，2 4K超清
- (void)setQualityLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetResolutionR(deviceID.UTF8String, level, OnSetQualityLevelCmdResult);
    TLog(@"设置清晰度setQualityLevel_with_deviceID，ret = %d",ret);
}

void OnSetQualityLevelCmdResult(int cmd,const char*uuid,const char*json)
{
    TLog(@"OnSetQualityLevelCmdResult %s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnSetQualityLevelCmdResult dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OnSetQualityLevelCmdResult_noti_key" object:nil];
        });
    }
    else {
        TLog(@"OnSetQualityLevelCmdResult 调用失败........................");
    }
}

#pragma mark - 设备亮度
/// level 亮度级别 0 - 255
- (void)setBrightnessLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetBrightnessR(deviceID.UTF8String, level, OnSetStration_Actce_Britness_CompColor_CmdResult);
    TLog(@"设置亮度setBrightnessLevel_with_deviceID，ret = %d",ret);
}

#pragma mark - 设备对比度
/// level 对比度级别 0 - 255
- (void)setCompareColorLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetContrastR(deviceID.UTF8String, level, OnSetStration_Actce_Britness_CompColor_CmdResult);
    TLog(@"设置对比度setCompareColorLevel_with_deviceID，ret = %d",ret);
}

/// level 对比度级别 0 - 255
- (void)setSaturationLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetSaturationR(deviceID.UTF8String, level, OnSetStration_Actce_Britness_CompColor_CmdResult);
    TLog(@"设置饱和度setSaturationLevel_with_deviceID，ret = %d",ret);
}

#pragma mark - 设备锐度
/// level 对比度级别 0 - 255
- (void)setAcutanceLevel_with_deviceID:(NSString *)deviceID level:(int)level reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetAcutanceR(deviceID.UTF8String, level, OnSetStration_Actce_Britness_CompColor_CmdResult);
    TLog(@"设置锐度setAcutanceLevel_with_deviceID，ret = %d",ret);
}

void OnSetStration_Actce_Britness_CompColor_CmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnSetStration_Actce_Britness_CompColor_CmdResult dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OnSetStration_Actce_Britness_CompColor_CmdResult_noti_key" object:nil];
        });
    }
    else {
        TLog(@"OnSetStration_Actce_Britness_CompColor_CmdResult 调用失败........................");
    }
}

#pragma mark - 设备饱和度

- (void)getSaturationLevel_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetGetSaturationR(deviceID.UTF8String, OnGetSaturationLevelCmdResult);
    TLog(@"获取饱和度getSaturationLevel_with_deviceID，ret = %d",ret);
}

void OnGetSaturationLevelCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnGetSaturationLevelCmdResult dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OnGetSaturationLevelCmdResult_noti_key" object:dict[@"CamCfg.info"]];
    }
    else {
        TLog(@"OnGetSaturationLevelCmdResult 调用失败........................");
    }
}

#pragma mark - 设备恢复默认设置
- (void)setDefault_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetCameraColorSettingDefault(deviceID.UTF8String);
    TLog(@"恢复图像默认设置（图像异常时可用）setDefault_with_deviceID，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       if (ret >= 0) {
           reBlock(ret);
       }
       else {
           TLog(@"setDefault_with_deviceID 调用失败........................");
       }
    });
}

#pragma mark - 获取色彩/黑白模式
- (void)getIRModel_with_deviceID:(NSString *)deviceID reBlock:(reBlock)reBlock
{
    int ret = IPCNetGetIRModeR(deviceID.UTF8String, OnGetIRModeCmdResult);
    TLog(@"获取色彩/黑白模式getIRModel_with_deviceID，ret = %d",ret);
}

void OnGetIRModeCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnGetIRModeCmdResult dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0) {
        JSONObject jsdata(json);
        colorCfg.parseJSON(jsdata);
        IPCNetReleaseCmdResource(cmd,uuid,OnGetIRModeCmdResult);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OnGetIRModeCmdResult_noti_key" object:nil];
        });
    }
    else {
        TLog(@"OnGetIRModeCmdResult 调用失败........................");
    }
}

/// type type == 0 彩色画面/ type == 1 黑白画面
- (void)setIRModel_with_deviceID:(NSString *)deviceID type:(int)type reBlock:(reBlock)reBlock
{
    String str;
    colorCfg.Type = type;
    colorCfg.toJSONString(str);
    int ret = IPCNetSetIRModeR(deviceID.UTF8String, str.c_str(), OnSetIRModeCmdResult);
    TLog(@"获取色彩/黑白模式，ret = %d",ret);
}

void OnSetIRModeCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnSetIRModeCmdResult dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OnSetIRModeCmdResult_noti_key" object:nil];
        });
    }
    else {
        TLog(@"OnSetIRModeCmdResult 调用失败........................");
    }
}

#pragma mark - 画面翻转
/// flip 0 mirror 1
/// flip 1 mirror 0
- (void)setFilp_with_deviceID:(NSString *)deviceID flip:(int)flip mirror:(int)mirror reBlock:(reBlock)reBlock
{
    int ret = IPCNetSetFlipMirrorR(deviceID.UTF8String, flip, mirror, OnSetFilpCmdResult);
    TLog(@"画面翻转setFilp_with_deviceID，ret = %d",ret);
}

void OnSetFilpCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [TTCommon cString_changto_ocStringWith:json];
    TLog(@"OnSetFilpCmdResult dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OnSetFilpCmdResult_noti_key" object:nil];
        });
    }
    else {
        TLog(@"OnSetFilpCmdResult 调用失败........................");
    }
}

@end

