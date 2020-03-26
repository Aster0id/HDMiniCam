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
- (NSArray *)get_all_video_and_pic_File;
#pragma mark - 获取直播视频截图文件路径
- (NSString *)get_live_screenShot_DocPath_with_deviceID:(NSString *)deviceID;
#pragma mark - 视频每日最后一张截图保存的文件夹路径
- (NSString *)get_screenShot_DocPath_deviceID:(NSString *)deviceID;
#pragma mark - 视频每日录屏的截图保存的文件夹路径
- (NSString *)get_recordVideo_screenShot_DocPath_with_deviceID:(NSString *)deviceID;
#pragma mark - 获取 直播录屏 存放路径
- (NSString *)get_live_recordVideo_DocPath_with_deviceID:(NSString *)deviceID;
#pragma mark - 获取 直播录屏 路径下的文件
- (NSArray *)get_live_record_VideoArray_with_deviceID:(NSString *)deviceID;
#pragma mark - 获取 回放录屏 存放路径
- (NSString *)get_reback_recordVideo_DocPath_with_deviceID:(NSString *)deviceID;
#pragma mark - 获取 回放录屏 路径下的文件
- (NSArray *)get_reback_record_videoArray_with_deviceID:(NSString *)deviceID;
#pragma mark - 获取视频或图片的名称
- (NSString *)get_videoName_With_fileType:(NSString *)fileType deviceID:(NSString *)deviceID;
#pragma mark - 删除文件
- (BOOL)delete_videoFile_With_path:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
