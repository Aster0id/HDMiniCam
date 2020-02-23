//
//  KHJDeviceManager.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/14.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDeviceManager.h"
#import "SEP2P_Error.h"
#import "JSONStructProtocal.h"
#import "IPCNetManagerInterface.h"
#import "KHJErrorManager.h"

const char *mCurViewPath_date;
static char mCurViewPath[] = "/mnt/s0/";//根据自己需求更改此目录

//以下静态变量根据项目实际情况移至类的成员去
IPCNetRecordCfg_st recordCfg;

static int mNextStartIndex=0;
static int mTotalNum=0;
static RemoteDirInfo_t*mRemoteRootDirInfo,mSelectedRemoteDirInfo;
RemoteDirInfo_t*mCurRemoteDirInfo;

//RemoteDirInfo_t 在 JSONStructProtocal.h 定义

@interface KHJDeviceManager ()
{
    
}
@end

@implementation KHJDeviceManager

#pragma mark - 设备回调

/// 设备状态改变
/// @param uuid 设备id
/// @param status 设备状态
void onStatus(const char* uuid,int status)
{
    // 子线程回调
    if (status != 0) {
//        NSLog(@" \n onStatus \n 设备id = %s， 当前在线 ！！！！！！！！！！！！！！",uuid);
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
//    CLog(@"thread = %@",[NSThread currentThread]);
//    NSLog(@" \n onVideoData 设备id = %s \n type = %d  \n length = %d  \n timestamp = %ld",uuid,type,len,timestamp);
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
//    NSLog(@" \n onAudioData 设备id = %s \n type = %d  \n length = %d  \n timestamp = %ld",uuid,type,len,timestamp);
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
        body = [KHJUtility cString_changto_ocStringWith:jsonstr];
        CLog(@" \n 登录设备，连接设备 body = %@",body);
        
        if ([body.allKeys containsObject:@"Login.info"]) {
#pragma mark - 登录回调
//            NSString *Tick = body[@"Login.info"][@"Tick"];
//            CLog(@"Tick = %@", Tick);
        }
        else if ([body.allKeys containsObject:@"dev_info"]) {
#pragma mark - 设备信息回调
            NSString *deviceName    = body[@"dev_info"][@"name"];
            NSString *deviceID      = body[@"dev_info"][@"p2p_uuid"];
            CLog(@" \n deviceID = %@, \n deviceName = %@",deviceID, deviceName);
            NSMutableDictionary *body = [NSMutableDictionary dictionary];
            [body setValue:deviceID forKey:@"deviceID"];
            [body setValue:deviceName forKey:@"deviceName"];
            [[NSNotificationCenter defaultCenter] postNotificationName:noti_onJSONString_KEY object:body];
        }
    }
    else {
        
    }
}

void OnGetCmdResult(int cmd,const char*uuid,const char*json)
{
    NSDictionary *dict = [KHJUtility cString_changto_ocStringWith:json];
    CLog(@"dict = %@",dict);
    int ret = [dict[@"ret"] intValue];
    if (ret >= 0 && ret <= 100) {
        switch (cmd) {
            case 1075:
#pragma MARK - 获取设备SD卡信息
                [[NSNotificationCenter defaultCenter] postNotificationName:noti_1075_KEY object:dict[@"li"]];
                break;
            case 1077:
#pragma MARK - 获取
                [[NSNotificationCenter defaultCenter] postNotificationName:noti_1077_KEY object:dict[@"dir"][@"l"]];
                break;
            case 1495:
#pragma MARK - 修改饱和度、锐度、亮度
                [[NSNotificationCenter defaultCenter] postNotificationName:noti_1495_KEY object:nil];
                break;
            case 1497:
#pragma MARK - 获取饱和度、锐度、亮度等等
                [[NSNotificationCenter defaultCenter] postNotificationName:noti_1497_KEY object:dict[@"CamCfg.info"]];
                break;
            default:
                break;
        }
    }
    else {
        CLog(@"指令 = %d，执行失败 ret = %d",cmd,ret);
    }
}

void OnDownloadDataCallBack(const char*uuid,const char *file,const char*data,int len,unsigned int offset)
{
//    NSDictionary *dict = [KHJUtility cString_changto_ocStringWith:json];
//    CLog(@"dict = %@",dict);
}

void OnSearchDeviceResult(struct DevInfo *device)
{
    /**
     struct DevInfo
     {
         char mTocken;          //设置为A
         char mUUID[64];        //设备UUID
         char mCHCK[16];        //设备UUID校验码/检查码
         char mIP[128];         //设备IP
         char mSockIP[128];     //发送此消息的sock IP
         char mMAC[128];        // 设备MAC
         char mSoftVer[64];     //软件版本
         char mHwVer[64];       //硬件版本
         int mIndex;
         char mNetMask[32];     //子网掩码
         char mGateway[128];    //网关
         char mDNS1[128];       //dns1
         char mDNS2[128];       //dns2
         unsigned short nPort;  //设备端口
         char mDevName[128];    //设备名称
         char mUserName[128];   //修改时会对用户认证
         char mPassword[128];   //修改时会对用户认证
         int mDevType;          //设备类型，参见DEV_TYPE_e
         char mFlashID[128];    //设备唯一ID
         bool mFlashValid;      //设备是否校验
         char mIPv4Addr[128];
     };
     */
    CLog(@"device 11111111111111111111111111111111111111 = %@",device);
}

void OnListRemoteDirInfoCmdResult(int cmd,const char*uuid,const char*json);
void get_sdcard_files_list(const char *uuid, const char *dir)
{
    //char rootdir[]="/mnt/s0/";
    int vi=0;
    int mode=1;//0: 只扫描文件   1: 扫描目录和文件

    int start=0;//文件开始时间
    int end=240000;//文件结束时间

    //组织json字符串，lir是list remote简写， p为path简写，si是sensor index简写，m是mode简写
    //st是start time， e是end time
    char jsonbuff[1024] = {0};
    sprintf(jsonbuff,"{\"lir\":{\"p\":\"%s\",\"si\":%d,\"m\":%d,\"st\":%d,\"e\":%d}}",
        dir, vi, mode, start, end);
    IPCNetListRemoteDirInfoR(uuid, jsonbuff, OnListRemoteDirInfoCmdResult);
}

void OnListRemotePageFileCmdResult2(int cmd,const char*uuid,const char*json);
void OnListRemoteDirInfoCmdResult(int cmd,const char*uuid,const char*json)
{
    JSONObject jsdata(json);//解析json
    RemoteDirListInfo_t rdi;
    rdi.parseJSON(jsdata);//从返回的json结构体里面获取目录信息

    //mTotalSize=rdi.total;//获取磁盘总空间
    //mUsedSize=rdi.used;//获取磁盘已使用空间

    int reqnum;
    int curIndex = 0;
    mNextStartIndex = 0;
    mTotalNum = rdi.num;//设置当前目录总共有几个文件，包括目录（IPCNetListRemoteDirInfoR的mode设置为1的时候，会包含目录）
    if (mTotalNum > 10){//每次获取最多10个目录下面的文件
        reqnum = 10;
        mNextStartIndex = 10;
    } else {
        reqnum = rdi.num;//不足10个，一次性全部获取
        mNextStartIndex = rdi.num;
    }

    //组织json字符串，lp是list path简写， p为path简写，s是start简写，c是count简写
    char jsonbuff[1024] = {0};
    //
    NSString *path = KHJString(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],mCurViewPath_date);
    sprintf(jsonbuff,"{\"lp\":{\"p\":\"%s\",\"s\":%d,\"c\":%d}}", path.UTF8String, curIndex, reqnum);
    //按索引获取目录下的文件名，结果通过 OnListRemotePageFileCmdResult2 返回
    IPCNetListRemotePageFileR(uuid, jsonbuff, OnListRemotePageFileCmdResult2);

    //根据获取到的数据更新UI界面
    //lRemoteStorageFileList->updateUI();

    //释放命令绑定资源
    IPCNetReleaseCmdResource(cmd, uuid, OnListRemoteDirInfoCmdResult);
}

void OnListRemotePageFileCmdResult2(int cmd,const char*uuid,const char*json)
{
    JSONObject jsdata(json);//解析json
    RemoteDirInfo_t *rdi=new RemoteDirInfo_t;

    NSString *path = KHJString(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],mCurViewPath_date);
//    CLog(@"path = %@",path);
    
    rdi->path = path.UTF8String;
    rdi->parseJSON(jsdata);
#ifdef _WIN32
    TRACE("name:%s type:%d RemoteFileInfoListSize:%d \n",rdi->name.c_str(),rdi->type,rdi->mRemoteFileInfoList.size());
#endif

    if (mCurRemoteDirInfo == 0) {
        mCurRemoteDirInfo=rdi;
    } else if (strcmp(mCurRemoteDirInfo->path.c_str(), rdi->path.c_str()) == 0) {
        for(list<RemoteFileInfo_t*>::iterator it= rdi->mRemoteFileInfoList.begin(); it!=rdi->mRemoteFileInfoList.end(); it++){
            RemoteFileInfo_t*rfi = *it;
            RemoteFileInfo_t*rfi_bak = new RemoteFileInfo_t;
            rfi_bak->name=rfi->name;
            rfi_bak->path=rfi->path;
            rfi_bak->type=rfi->type;
            rfi_bak->size=rfi->size;
            // 添加新的文件到目录
            mCurRemoteDirInfo->mRemoteFileInfoList.push_back(rfi_bak);
        }
        delete rdi;
    }

    if (mRemoteRootDirInfo == 0) {
        mRemoteRootDirInfo=rdi;
    }
    
    IPCNetReleaseCmdResource( cmd,uuid,OnListRemotePageFileCmdResult2);

    //根据当前获取到的索引，继续获取剩下的文件
    if (mTotalNum > mNextStartIndex) {
        int curIndex = mNextStartIndex;
        int reqnum = mTotalNum - curIndex;
        char jsonbuff[1024] = {0};
        if(reqnum > 10){
            reqnum = 10;
        }
        mNextStartIndex += reqnum;
        NSString *path = KHJString(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],mCurViewPath_date);
        sprintf(jsonbuff,"{\"lp\":{\"p\":\"%s\",\"s\":%d,\"c\":%d}}", path.UTF8String, curIndex, reqnum);
        //释放命令绑定资源
        IPCNetListRemotePageFileR(uuid,jsonbuff,OnListRemotePageFileCmdResult2);
    }
}

+ (KHJDeviceManager *)sharedManager
{
    static KHJDeviceManager *manager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [KHJDeviceManager sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [KHJDeviceManager sharedManager];
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

- (void)getApiVersion_with_deviceID:(int)version
                        resultBlock:(resultBlock)resultBlock
{
    
}

/// 设备连接
/// @param deviceID 设备id
/// @param password 设备密码
/// @param resultBlock 回调
- (void)connect_with_deviceID:(NSString *)deviceID
                     password:(NSString *)password
                  resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStartIPCNetSession(deviceID.UTF8String, password.UTF8String, &netHandle);
    CLog(@"设备登录，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 断开连接
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)disconnect_with_deviceID:(NSString *)deviceID
                     resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStopIPCNetSession(deviceID.UTF8String);
    CLog(@"设备断开，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 开始获取视频
/// @param deviceID 设备id
/// @param quality 视频质量
/// @param resultBlock 回调
- (void)startGetVideo_with_deviceID:(NSString *)deviceID
                            quality:(int)quality
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStartVideo(deviceID.UTF8String, quality);
    CLog(@"开始获取视频，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 停止获取视频
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopGetVideo_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStopVideo(deviceID.UTF8String);
    CLog(@"停止获取视频，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 开始获取音频
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)startGetAudio_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStartAudio(deviceID.UTF8String);
    CLog(@"开始获取音频，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 停止获取音频
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopGetAudio_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStopAudio(deviceID.UTF8String);
    CLog(@"停止获取音频，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}


/// 开启设备扬声器，准备接收音频数据并播放
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)startTalk_with_deviceID:(NSString *)deviceID
                           type:(int)type
                    resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetStartTalkR(deviceID.UTF8String, type, OnGetCmdResult);
//    CLog(@"开始获取视频，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 关闭设备扬声器
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopTalk_with_deviceID:(NSString *)deviceID
                   resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetStopAudio(deviceID.UTF8String);
//    CLog(@"关闭设备扬声器，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

#pragma mark - 发送音频数据 不知道怎么使用这个接口
/// 发送音频数据
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)sendTalkData_with_device:(NSString *)deviceID
                       audioData:(NSString *)audioData
                          length:(int)length
                     resultBlock:(resultBlock)resultBlock
{
//    String str;
//    int ret = IPCNetPutTalkData(deviceID.UTF8String, str.data(), length);
//    CLog(@"发送音频数据，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 开始录像回放
/// @param deviceID 设备id
/// @param path 回放路径
/// @param resultBlock 回调
- (void)startPlayback_with_deviceID:(NSString *)deviceID
                               path:(NSString *)path
                        resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetStartPlaybackR(deviceID.UTF8String, path.UTF8String, OnGetCmdResult);
//    CLog(@"开始录像回放，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 停止录像回放
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)stopPlayback_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetStopPlaybackR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"停止录像回放，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 暂停录像回放
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)pausePlayback_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetPausePlaybackR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"暂停录像回放，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 回放快进
/// @param deviceID 设备id
/// @param speed 快进速度
/// @param resultBlock 回调
- (void)fastForward_with_deviceID:(NSString *)deviceID
                            speed:(int)speed
                      resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetPlaybackFastForwardR(deviceID.UTF8String, speed, OnGetCmdResult);
//    CLog(@"回放快进，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 回放快退
/// @param deviceID 设备id
/// @param speed 快进速度
/// @param resultBlock 回调
- (void)fastBackward_with_deviceID:(NSString *)deviceID
                             speed:(int)speed
                       resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetPlaybackFastBackwardR(deviceID.UTF8String, speed, OnGetCmdResult);
//    CLog(@"回放快退，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取降噪设置
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDenoiseSetting_with_deviceID:(NSString *)deviceID
                            resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetDenoiseSettingR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"获取降噪设置，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置降噪设置
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setDenoiseSetting_with_deviceID:(NSString *)deviceID
                                   json:(NSString *)json
                            resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetDenoiseSettingR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"设置降噪设置，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 恢复设备出厂设置
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)resetDevice_with_deviceID:(NSString *)deviceID
                      resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetRestoreToFactorySetting(deviceID.UTF8String);
    CLog(@"恢复设备出厂设置，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 重启设备
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)rebootDevice_with_deviceID:(NSString *)deviceID
                       resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetRebootDevice(deviceID.UTF8String);
    CLog(@"重启设备，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取设备Wi-Fi
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceWiFi_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetWiFi(deviceID.UTF8String);
    CLog(@"获取设备Wi-Fi，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

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
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetWiFi(deviceID.UTF8String, ssid.UTF8String, password.UTF8String, encType.UTF8String);
    CLog(@"设置设备Wi-Fi，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 搜索附近Wi-Fi列表
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)searchDeviceWiFi_with_deviceID:(NSString *)deviceID
                           resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSearchWiFi(deviceID.UTF8String);
    CLog(@"搜索附近Wi-Fi列表，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 搜索附近的设备
/// 局域网搜索设备，搜索结果会从 osdr 返回，搜索结果会多次返回，需要做好过滤
/// 比如同个设备，可能会从 osdr 返回多次，需要避免这种干扰
/// @param resultBlock 回调
- (void)startSearchDevice_with_resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSearchDevice(OnSearchDeviceResult);
    CLog(@"搜索附近的设备，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 停止搜索附近的设备
/// @param resultBlock 回调
- (void)stopSearchDevice_with_resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetStopSearchDevice();
    CLog(@"停止搜索附近的设备，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置局域网设置结果返回 回调，当调用局域网设置函数，结果通过OnLanSettingResult_t返回
/// int __declspec(dllexport) _stdcall IPCNetSetLanSettingResultCallback(OnLanSettingResult_t r);
/// 局域网重启设备
/// int __declspec(dllexport) _stdcall IPCNetRebootDeviceInLAN(const char*ip);
/// 局域网设置设备信息
/// int __declspec(dllexport) _stdcall IPCNetSetDeviceInfoInLAN(struct DevInfo *dev);
/// 让设备重新申请IP
/// int __declspec(dllexport) _stdcall IPCNetSetDeviceDhcpInLAN();

#pragma mark - 设备信息

/// 获取设备端信息
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceInfo_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetDevInfo(deviceID.UTF8String);
    CLog(@"获取设备端信息，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 修改设备密码
/// @param deviceID 设备id
/// @param password 新密码
/// @param resultBlock 回调
- (void)changeDevicePassword_with_deviceID:(NSString *)deviceID
                                  password:(NSString *)password
                               resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetChangeDevPwd(deviceID.UTF8String, password.UTF8String);
    CLog(@"修改设备密码，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取OSD
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getOSD_with_deviceID:(NSString *)deviceID
                        json:(NSString *)json
                 resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetOSDR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
    CLog(@"获取OSD，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置OSD
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setOSD_with_deviceID:(NSString *)deviceID
                        json:(NSString *)json
                 resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetOSDR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
    CLog(@"设置OSD，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取录像配置
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getRecordConfig_with_deviceID:(NSString *)deviceID
                                 json:(NSString *)json
                          resultBlock:(resultBlock)resultBlock
{
    IPCNetRecordGetCfg_st ipcrgc;
    ipcrgc.ViCh = 0;
//    ipcrgc.Path = "/mnt/s0";
    ipcrgc.Path = recordCfg.DiskInfo->Path;
    String str;
    ipcrgc.toJSONString(str);
    int ret = IPCNetGetRecordConfR(deviceID.UTF8String, str.c_str(), OnGetRecordConfCmdResult);
    CLog(@"获取录像配置，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

void OnGetRecordConfCmdResult(int cmd,const char*uuid,const char*json)
{
    
    JSONObject jsdata(json);//解析json
    Log("%s cmd:%d uuid:%s json:%s\n",__func__,cmd, uuid, json);
    recordCfg.parseJSON(jsdata);
    IPCNetReleaseCmdResource(cmd,uuid,OnGetRecordConfCmdResult);
    [[NSNotificationCenter defaultCenter] postNotificationName:noti_1073_KEY object:nil];
}

/// 设置录像配置
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setRecordConfig_with_deviceID:(NSString *)deviceID
                                 json:(NSString *)json
                          resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetRecordConfR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"设置录像配置，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取远程目录信息
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getRemoteDirInfo_with_deviceID:(NSString *)deviceID
                                  json:(NSString *)json
                           resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetListRemoteDirInfoR(deviceID.UTF8String, json.UTF8String, OnListRemoteDirInfoCmdResult);
    CLog(@"获取远程目录信息，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取远程 Page 文件
/// @param deviceID 设备id
/// @param path 路径
/// @param resultBlock 回调
- (void)getRemotePageFile_with_deviceID:(NSString *)deviceID
                                   path:(NSString *)path
                            resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetListRemotePageFileR(deviceID.UTF8String, path.UTF8String, OnGetCmdResult);
    CLog(@"获取远程 Page 文件，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 删除远程文件
/// @param deviceID 设备id
/// @param path 路径
/// @param resultBlock 回调
- (void)deleteRemoteFile_with_deviceID:(NSString *)deviceID
                                  path:(NSString *)path
                           resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetDeleteRemoteFileR(deviceID.UTF8String, path.UTF8String, OnGetCmdResult);
//    CLog(@"删除远程文件，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

#pragma mark - 开始下载设备文件
/// 开始下载设备文件
/// @param deviceID 设备id
/// @param path 下载路径
- (void)startDownloadFile_with_deviceID:(NSString *)deviceID
                                   path:(NSString *)path
{
//    int ret = IPCNetStartDownloadFileR(deviceID.UTF8String, path.UTF8String, OnDownloadDataCallBack, OnGetCmdResult);
//    CLog(@"开始下载设备文件，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

#pragma mark - 停止下载设备文件
/// 停止下载设备文件
/// @param deviceID 设备id
/// @param path 下载路径
- (void)stopDownloadFile_with_deviceID:(NSString *)deviceID
                                  path:(NSString *)path
{
//    int ret = IPCNetStopDownloadFileR(deviceID.UTF8String, path.UTF8String, OnGetCmdResult);
//    CLog(@"停止下载设备文件，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取PTZ控制，摇头相关
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)getPTZControl_with_deviceID:(NSString *)deviceID
                               json:(NSString *)json
                        resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetPtzCtrlR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"获取PTZ控制，摇头相关，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置PTZ控制，摇头相关
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setPTZControl_with_deviceID:(NSString *)deviceID
                               json:(NSString *)json
                        resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetPtzCtrlR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"设置PTZ控制，摇头相关，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取曝光类型
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getExpType_with_deviceID:(NSString *)deviceID
                     resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetExpTypeR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"获取曝光类型，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置曝光类型
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setExpType_with_deviceID:(NSString *)deviceID
                            json:(NSString *)json
                     resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetExpTypeR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"设置曝光类型，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取手动曝光
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getHandExpInfo_with_deviceID:(NSString *)deviceID
                         resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetManualExpInfoR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"获取手动曝光，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置手动曝光
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setHandExpInfo_with_deviceID:(NSString *)deviceID
                                json:(NSString *)json
                         resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetManualExpInfoR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"设置手动曝光，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取自动曝光
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getAutoExpInfo_with_deviceID:(NSString *)deviceID
                         resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetAutoExpInfoR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@" 获取自动曝光，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置自动曝光
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setAutoExpInfo_with_deviceID:(NSString *)deviceID
                                json:(NSString *)json
                         resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetAutoExpInfoR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"设设置自动曝光，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 获取设备热点
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getWiFiAPInfo_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetWiFiAPInfoR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"获取设备热点，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置设备热点
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setWiFiAPInfo_with_deviceID:(NSString *)deviceID
                               json:(NSString *)json
                        resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetSetWiFiAPInfoR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
//    CLog(@"设设置设备热点，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

#pragma mark - 设备设置

/// 获取设备报警信息
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceAlarm_with_deviceID:(NSString *)deviceID
                         resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetAlarmR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"获取设备报警信息，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置设备报警
/// @param deviceID 设备id
/// @param json json字符串
/// @param resultBlock 回调
- (void)setDeviceAlarm_with_deviceID:(NSString *)deviceID
                                json:(NSString *)json
                         resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetAlarmR(deviceID.UTF8String, json.UTF8String, OnGetCmdResult);
    CLog(@"设置设备报警，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取清晰度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getQualityLevel_with_deviceID:(NSString *)deviceID
                          resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetResolutionR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"获取清晰度，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置清晰度
/// @param deviceID 设备id
/// @param level 清晰度级别
/// @param resultBlock 回调
- (void)setQualityLevel_with_deviceID:(NSString *)deviceID
                                level:(int)level
                          resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetResolutionR(deviceID.UTF8String, level, OnGetCmdResult);
    CLog(@"设置清晰度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取亮度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getBrightnessLevel_with_deviceID:(NSString *)deviceID
                             resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetBrightnessR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"获取亮度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置亮度
/// @param deviceID 设备id
/// @param level 亮度级别
/// @param resultBlock 回调
- (void)setBrightnessLevel_with_deviceID:(NSString *)deviceID
                                   level:(int)level
                             resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetBrightnessR(deviceID.UTF8String, level, OnGetCmdResult);
    CLog(@"设置亮度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取对比度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getCompareColoLevel_with_deviceID:(NSString *)deviceID
                              resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetContrastR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"获取对比度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置对比度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setCompareColorLevel_with_deviceID:(NSString *)deviceID
                                     level:(int)level
                               resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetContrastR(deviceID.UTF8String, level, OnGetCmdResult);
    CLog(@"设置对比度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取色度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getColorLevel_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetHueR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"获取色度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置色度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setColorLevel_with_deviceID:(NSString *)deviceID
                              level:(int)level
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetHueR(deviceID.UTF8String, level, OnGetCmdResult);
    CLog(@"设置色度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取饱和度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getSaturationLevel_with_deviceID:(NSString *)deviceID
                             resultBlock:(resultBlock)resultBlock
{
//    int ret = IPCNetGetSaturationR(deviceID.UTF8String, OnGetCmdResult);
//    CLog(@"获取饱和度，ret = %d",ret);
//    dispatch_async(dispatch_get_main_queue(), ^{
//       resultBlock(ret);
//    });
}

/// 设置饱和度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setSaturationLevel_with_deviceID:(NSString *)deviceID
                                   level:(int)level
                             resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetSaturationR(deviceID.UTF8String, level, OnGetCmdResult);
    CLog(@"设置饱和度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取锐度
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getAcutanceLevel_with_deviceID:(NSString *)deviceID
                           resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetAcutanceR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"获取锐度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置锐度
/// @param deviceID 设备id
/// @param level 对比度级别
/// @param resultBlock 回调
- (void)setAcutanceLevel_with_deviceID:(NSString *)deviceID
                                 level:(int)level
                           resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetAcutanceR(deviceID.UTF8String, level, OnGetCmdResult);
    CLog(@"设置锐度，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 恢复图像默认设置（图像异常时可用）
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)setDefault_with_deviceID:(NSString *)deviceID
                     resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetCameraColorSettingDefaultR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"恢复图像默认设置（图像异常时可用），ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 画面翻转
/// @param deviceID 设备id
/// @param flip 翻转
/// @param mirror 镜像
/// @param resultBlock 回调
- (void)setFilp_with_deviceID:(NSString *)deviceID
                         flip:(int)flip
                       mirror:(int)mirror
                  resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetFlipMirrorR(deviceID.UTF8String, flip, mirror, OnGetCmdResult);
    CLog(@"画面翻转，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 获取设备时间
/// @param deviceID 设备id
/// @param resultBlock 回调
- (void)getDeviceTime_with_deviceID:(NSString *)deviceID
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetGetTimeR(deviceID.UTF8String, OnGetCmdResult);
    CLog(@"获取设备时间，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}

/// 设置设备时间
/// @param deviceID 设备id
/// @param time s
/// @param resultBlock 回调
- (void)setDeviceTime_with_deviceID:(NSString *)deviceID
                               time:(IPCNetTimeCfg_t *)time
                        resultBlock:(resultBlock)resultBlock
{
    int ret = IPCNetSetTimeR(deviceID.UTF8String, time, OnGetCmdResult);
    CLog(@"设置设备时间，ret = %d",ret);
    dispatch_async(dispatch_get_main_queue(), ^{
       resultBlock(ret);
    });
}



@end

