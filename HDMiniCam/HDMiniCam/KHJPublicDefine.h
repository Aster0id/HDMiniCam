//
//  KHJPublicDefine.h
//  KHJCamera
//
//  Created by khj888 on 2018/12/4.
//  Copyright © 2018 khj. All rights reserved.
//

#ifndef KHJPublicDefine_h
#define KHJPublicDefine_h

// 设备状态更新通知
#define noti_onStatus_KEY @"noti_onStatus_KEY"
// 视频数据通知
#define noti_onVideoData_KEY @"noti_onVideoData_KEY"
// 音频数据通知
#define noti_onAudioData_KEY @"noti_onAudioData_KEY"
// 接口返回的json数据通知
#define noti_onJSONString_KEY @"noti_onJSONString_KEY"
// 指令回调
#define noti_1073_KEY @"noti_1073_KEY"  // 获取录像配置信息
#define noti_1075_KEY @"noti_1075_KEY"  // 获取设备SD卡，远程信息，文件个数、总空间、已用空间
#define noti_1077_KEY @"noti_1077_KEY"  //
#define noti_1497_KEY @"noti_1497_KEY"  // 获取饱和度、锐度、亮度等等
#define noti_1495_KEY @"noti_1495_KEY"  // 修改饱和度、锐度、亮度

#define FLAG_TAG                        9999999
#define KHJIMAGE(name)                  [UIImage imageNamed:name]
#define KHJString(...)                  [NSString stringWithFormat:__VA_ARGS__]
#define KHJLocalizedString(key,comment) [[NSBundle mainBundle] localizedStringForKey:(key)value:@"" table:nil]
/* 当前选择的 tabbar 下标 */
#define KHJNaviBarItemIndexKey  @"NaviBarItemIndexKey"


#endif /* KHJPublicDefine_h */
