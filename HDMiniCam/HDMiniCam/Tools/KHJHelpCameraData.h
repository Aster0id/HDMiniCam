//
//  KHJHelpCameraData.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHJHelpCameraData : NSObject

// 类似于工具类  获取iOS文件夹下一些东西/路径等
+ (KHJHelpCameraData *)sharedModel;

#pragma mark - 获取当前用户文件夹下所有文件
- (NSArray *)getAllFile;

#pragma mark - 获取图片路径 存储的时候加上设备uid标记是哪一台设备的
- (NSString *)getTakeCameraDocPath_deviceID:(NSString *)deviceID;
#pragma mark - 视频的保存文件夹路径
- (NSString *)getTakeVideoDocPath_with_deviceID:(NSString *)deviceID;

#pragma mark - 取得一个目录下得所有图片文件名
- (NSArray *)getPictureArray_with_deviceID:(NSString *)deviceID;

#pragma mark - 取得一个目录下得所有mp4视频文件名
- (NSArray *)getmp4VideoArray_with_deviceID:(NSString *)deviceID;

#pragma mark - 获取视频或图片的名称
- (NSString *)getVideoNameWithType:(NSString *)fileType deviceID:(NSString *)deviceID;

#pragma mark - 删除文件
- (BOOL)DeleateFileWithPath:(NSString *)path;

@end
