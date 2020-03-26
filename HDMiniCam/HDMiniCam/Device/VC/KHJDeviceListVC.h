
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
//    NSString *path = KHJString(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],checkRemoteVideoList_Date);
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
//    NSString *diskInfo_path = KHJString(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],checkRemoteVideoList_Date);
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
//        NSString *path = KHJString(@"%@/%s",[NSString stringWithUTF8String:recordCfg.DiskInfo->Path.c_str()],checkRemoteVideoList_Date);
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
//  KHJDeviceListVC.h
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KHJDeviceListVC : KHJBaseVC

@end

NS_ASSUME_NONNULL_END
