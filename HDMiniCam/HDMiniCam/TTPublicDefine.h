//
//  TTPublicDefine.h
//  KHJCamera
//
//  Created by kevin on 2018/12/4.
//  Copyright © 2018 khj. All rights reserved.
//

#ifndef TTPublicDefine_h
#define TTPublicDefine_h

#define FLAG_TAG 20190515

#define TT_onStatus_noti_KEY                    @"TT_onStatus_noti_KEY"                 // 设备状态更新通知
#define TT_addDevice_noti_KEY                   @"TT_addDevice_noti_KEY"                // 添加设备通知
#define TT_getRecordConf_noti_KEY               @"TT_getRecordConf_noti_KEY"            // 获取录像配置信息
#define TT_getTimeLineInfo_noti_KEY             @"TT_getTimeLineInfo_noti_KEY"          // 获取设备时间轴信息
#define TT_deleteRemoteFile_noti_KEY            @"TT_deleteRemoteFile_noti_KEY"         // 删除远程文件
#define TT_getSearchDeviceWiFi_noti_KEY         @"TT_getSearchDeviceWiFi_noti_KEY"      // 搜索设备周围的Wi-Fi
#define TT_getListRemotePageFile_noti_KEY       @"TT_getListRemotePageFile_noti_KEY"    // 获取远程sd卡视频信息
#define TT_getDeviceWiFiCmdResult_noti_KEY      @"TT_getDeviceWiFiCmdResult_noti_KEY"   // 获取设备连接的Wi-Fi

#define TTIMG(name)                 [UIImage imageNamed:name]
#define TTStr(...)                  [NSString stringWithFormat:__VA_ARGS__]
#define TTString(...)               [NSString stringWithFormat:__VA_ARGS__]
#define TTString2(...)               [NSString stringWithFormat:__VA_ARGS__]
#define TTString3(...)               [NSString stringWithFormat:__VA_ARGS__]
#define TTLocalString(key,comment)  [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
#define TTLocalString1(key,comment)  [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
#define TTLocalString2(key,comment)  [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
#define TTLocalString3(key,comment)  [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
#define TTLocalString4(key,comment)  [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
#define TTLocalizableString3(key,comment)  [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]

#define TTRGB(r, g, b)              [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define TT_Red_green_blue(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]


#endif /* TTPublicDefine_h */
