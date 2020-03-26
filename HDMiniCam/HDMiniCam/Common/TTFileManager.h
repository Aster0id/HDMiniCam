//
//  TTFileManager.h
//  SuperIPC
//
//  Created by kevin on 2020/3/25.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTFileManager : NSObject

+ (TTFileManager *)sharedModel;
#pragma mark - 获取当前用户文件夹下所有视频和图片文件
- (NSArray *)getAllVideoAndPictureFile;
#pragma mark - 获取直播视频截图文件路径
- (NSString *)getliveScreenShotWithDeviceID:(NSString *)deviceID;
#pragma mark - 视频每日最后一张截图保存的文件夹路径
- (NSString *)getScreenShotWithDeviceID:(NSString *)deviceID;
#pragma mark - 视频每日录屏的截图保存的文件夹路径
- (NSString *)getRecordScreenShotWithDeviceID:(NSString *)deviceID;
#pragma mark - 获取 直播录屏 存放路径
- (NSString *)getLiveRecordVideoWithDeviceID:(NSString *)deviceID;
#pragma mark - 获取 直播录屏 路径下的文件
- (NSArray *)getLiveRecordVideoArrayWithDeviceID:(NSString *)deviceID;
#pragma mark - 获取 回放录屏 存放路径
- (NSString *)getRebackRecordVideoWithDeviceID:(NSString *)deviceID;
#pragma mark - 获取 回放录屏 路径下的文件
- (NSArray *)getRebackRecordVideoArrayWithDeviceID:(NSString *)deviceID;
#pragma mark - 获取视频或图片的名称
- (NSString *)getVideoNameWithFileType:(NSString *)fileType deviceID:(NSString *)deviceID;
#pragma mark - 删除文件
- (BOOL)deleteVideoFileWithFilePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
