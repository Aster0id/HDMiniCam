//
//  H264HwDecoder.h
//  test3
//
//  Created by khj888 on 2020/2/21.
//  Copyright © 2020 fenzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVSampleBufferDisplayLayer.h>


typedef enum : NSUInteger {
    H264EncodeFormat,
    H265EncodeFormat,
} VideoEncodeFormat;

typedef enum : NSUInteger {
    H264HWDataType_Image = 0,
    H264HWDataType_Pixel,
    H264HWDataType_Layer,
} H264HWDataType;

@protocol H264HwDecoderDelegate <NSObject>

- (void)getImageWith:(UIImage *)image imageSize:(CGSize)imageSize;

@end

NS_ASSUME_NONNULL_BEGIN

@interface H264HwDecoder : NSObject

@property (nonatomic, strong) id<H264HwDecoderDelegate> delegate;

@property (nonatomic,assign) H264HWDataType showType;                   //显示类型
@property (nonatomic,strong) UIImage *image;                            //解码成RGB数据时的IMG
@property (nonatomic,assign) CVPixelBufferRef pixelBuffer;              //解码成YUV数据时的解码BUF
@property (nonatomic,strong) AVSampleBufferDisplayLayer *displayLayer;  //显示图层
@property (nonatomic,assign) BOOL isNeedPerfectImg;                     //是否读取完整UIImage图形(showType为0时才有效)
 
- (instancetype)init;
 
/**
 H264视频流解码
 @param videoData 视频帧数据
 @param videoSize 视频帧大小
 @return 视图的宽高(width, height)，当为接收为AVSampleBufferDisplayLayer时返回接口是无效的
 */
- (CGSize)decodeH264VideoData:(uint8_t *)videoData videoSize:(NSInteger)videoSize videoType:(VideoEncodeFormat)videoType;
 
/**
 释放解码器
 */
- (void)releaseH264HwDecoder;
 
/**
 视频截图
 @return IMG
 */
- (UIImage *)snapshot;

@end

NS_ASSUME_NONNULL_END
