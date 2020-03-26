//
//  TTPlayerBaseViewController.h
//  SuperIPC
//
//  Created by kevin on 2020/2/26.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
// 监听/对讲
#import "TTAudioPlayer.h"
#import "TTAudioRecorder.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^onVideoImageBlock)(UIImage *image, CGSize imageSize);

@interface TTPlayerBaseViewController : UIViewController

@property (nonatomic, copy) NSString *sp_deviceID;
- (void)sp_releaseDecoder;

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UILabel  *titleLab;

@property (nonatomic, strong) onVideoImageBlock imageBlock;

// 初始化多屏解码器
@property (nonatomic, assign) BOOL initMutliDecorder;

#pragma mark - 直播解码

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param videoData 视频数据
/// @param type 数据类型
+ (void)decoderSingleLive:(int)length
                timestamp:(long)stamp
                videoData:(unsigned char*)videoData
                     type:(int)type;

#pragma mark - 直播录屏

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param videoData 视频数据
/// @param type 数据类型
+ (void)device_is_or_not_RecordingVideo:(int)length
                              timestamp:(long)stamp
                              videoData:(unsigned char*)videoData
                                   type:(int)type;

#pragma mark - 多屏解码功能

/// @param deviceID 设备id
/// @param index 下标
/// @param length 长度
/// @param stamp 时间戳
/// @param videoData 解码数据
/// @param type 类型
+ (void)decoderMoreLive:(NSString *)deviceID
                  index:(NSInteger)index
                 length:(int)length
              timestamp:(long)stamp
              videoData:(unsigned char*)videoData
                   type:(int)type;

#pragma mark - 音频录屏

/// @param length 数据长度
/// @param stamp 数据时间戳
/// @param audioData 音频数据
/// @param type 数据类型
+ (void)device_is_or_not_RecordingAudio:(int)length
                              timestamp:(long)stamp
                              audioData:(unsigned char*)audioData
                                   type:(int)type;

@end

NS_ASSUME_NONNULL_END
