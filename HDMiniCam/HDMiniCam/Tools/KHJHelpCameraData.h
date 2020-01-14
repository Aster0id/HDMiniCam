//
//  KHJHelpCameraData.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJHelpCameraData : NSObject

// 类似于工具类  获取iOS文件夹下一些东西/路径 等
+ (KHJHelpCameraData *)sharedModel;
// 获取当前用户文件夹下所有文件
- (NSArray *)getAllFile;
// 获取图片路径 存储的时候加上设备uid标记是哪一台设备的
- (NSString *)getTakeCameraDocPath ;
// 获取视频路径
- (NSString *)getTakeVideoDocPath ;
// 获取音频文件夹路径
- (NSString *)getAudioDocPath;
// 取得一个目录下得所有图片文件名
-(NSArray *)getPictureArray;
// 取得报警下载的图片
-(NSArray *)getAlarmPictureArray;
// 取得一个目录下得所有mp4视频文件名
-(NSArray *)getmp4VideoArray;
// 返回存储存储的照片或者视频的名字
- (NSString *)getVideoNameWithType:(NSString *)fileType;
// 获取SD卡下载视频或图片的名称
- (NSString *)getVideoNameWithType:(NSString *)fileType withDate:(NSString *)dateString andTime:(NSString *)timeString;
// 转换路径（sd卡录制的文件命名不同）
- (NSString *)changeName:(NSString *)fileName withType:(NSInteger) type;
//删除文件
- (BOOL)DeleateFileWithPath:(NSString *)path;
//自动生成10位随机密码
- (NSString *)getRandomPassword;
//wifi安全选项转换为nsstring
-(NSString *)switchEncptry:(int)enctype;
//报警图片文件夹
- (NSString *)getTakeAlarmDocPath;
/**
 获取报警音频文件夹路径
 */
- (NSString *)getAlarmAudioDocPath_caf;
/**
 文件夹路径 + 文件名称 = 文件可写入
 */
- (NSString *)getAlarmAudioDocPath_AMR;
/*
 获取 amr音频格式的文件路径 下所有音频文件
 */
- (NSArray *)getAll_AMR_Audio;

/**
 ap模式下不同设备类型的固件升级的统一文件路径
 */
- (NSString *)getFirmwareUpgradeDocPathWith:(NSString *)deviceType;
/**
 获取 设备类型下的所有固件文件
 */
- (NSArray *)getAll_FirmwareUpgradeFileWith:(NSString *)deviceType;

@end
