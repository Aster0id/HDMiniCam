//
//  H264_H265_VideoDecoder.m
//  test3
//
//  Created by kevin on 2020/2/21.
//  Copyright © 2020 fenzhi. All rights reserved.
//

#import "H264_H265_VideoDecoder.h"
#import <CoreImage/CoreImage.h>
#import "pthread.h"
#import "list.h"

#ifndef FreeCharP
#define FreeCharP(p) if (p) {free(p); p = NULL;}
#endif


typedef enum : NSUInteger {
    HWVideoFrameType_UNKNOWN = 0,
    HWVideoFrameType_I,
    HWVideoFrameType_P,
    HWVideoFrameType_B,
    HWVideoFrameType_SPS,
    HWVideoFrameType_PPS,//f_pps
    HWVideoFrameType_SEI,
    HWVideoFrameType_VPS,
} HWVideoFrameType;

typedef struct {
    int type;
    unsigned char*data;
    int len;
    long timestamp;
	struct list_head list;
}VideoFramePackage;

@interface H264_H265_VideoDecoder ()
{
    VTDecompressionSessionRef mDeocderSession;
    CMVideoFormatDescriptionRef mDecoderFormatDescription;
    
    uint8_t *pVPS;
    uint8_t *pSPS;
    uint8_t *pPPS;//f_pps
    uint8_t *prPPS;//r_pps
    uint8_t *pSEI;
    NSInteger mVpsSize;
    NSInteger mSpsSize;
    NSInteger mPpsSize;
    NSInteger mSeiSize;
    NSInteger mrPpsSize;
    
    NSInteger mINalCount;        //I帧起始码个数
    NSInteger mPBNalCount;       //P、B帧起始码个数
    NSInteger mINalIndex;       //I帧起始码开始位
    
    BOOL mIsNeedReinit;         //需要重置解码器
    
    VideoEncodeFormat videoFormat;
	
	struct list_head mVideoFramePackageList;
    pthread_mutex_t mVideoFramePackageListLock;
    BOOL mDecodeThreadRunning;
	NSThread*mNSThread;
}
@end

static void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration )
{
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

@implementation H264_H265_VideoDecoder

- (instancetype)init
{
    if (self = [super init]) {
        pSPS = pPPS = pSEI = NULL;
        mSpsSize = mPpsSize = mSeiSize = 0;
        mINalCount = mPBNalCount = mINalIndex = 0;
        mIsNeedReinit = NO;
        
        _showType = H264HWDataType_Image;
        _isNeedPerfectImg = NO;
        _pixelBuffer = NULL;
    }
    
	INIT_LIST_HEAD(&mVideoFramePackageList);
	pthread_mutex_init(&mVideoFramePackageListLock, NULL);
	mDecodeThreadRunning = TRUE;
	mNSThread = [[NSThread alloc]initWithTarget:self selector:@selector(DecodeThread) object:self];
	mNSThread.name = @"decode thread";
	[mNSThread start];
	
    return self;
}

- (void)dealloc
{
    [self releaseH264_H265_VideoDecoder];
}
 
- (BOOL)initH264_H265_VideoDecoder:(VideoEncodeFormat)videoType
{
    if (mDeocderSession) {
        return YES;
    }
    
    videoFormat = videoType;
    NSLog(@"initH264_H265_VideoDecoder videoFormat:%d", (int)videoFormat);
    OSStatus status=-1;
    if (videoFormat == H264EncodeFormat) {
        const uint8_t *const parameterSetPointers[2] = {pSPS,pPPS};
        const size_t parameterSetSizes[2] = {mSpsSize, mPpsSize};
        
        status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSizes, 4, &mDecoderFormatDescription);
    }else if(videoFormat == H265EncodeFormat){
        if(mrPpsSize==0){
            const uint8_t *const parameterSetPointers[3] = {pVPS, pSPS, pPPS};
            const size_t parameterSetSizes[3] = {mVpsSize, mSpsSize, mPpsSize};
            if (@available(iOS 11.0, *)) {
                status = CMVideoFormatDescriptionCreateFromHEVCParameterSets(kCFAllocatorDefault,
                                                                             3,
                                                                             parameterSetPointers,
                                                                             parameterSetSizes,
                                                                             4,
                                                                             NULL,
                                                                             &mDecoderFormatDescription);
            } else {
                status = -1;
                NSLog(@"%s:%d System version is too low!",__func__,__LINE__);
            }
        }else{
            const uint8_t *const parameterSetPointers[4] = {pVPS, pSPS, pPPS, prPPS};
            const size_t parameterSetSizes[4] = {mVpsSize, mSpsSize, mPpsSize, mrPpsSize};
            if (@available(iOS 11.0, *)) {
                status = CMVideoFormatDescriptionCreateFromHEVCParameterSets(kCFAllocatorDefault,
                                                                             4,
                                                                             parameterSetPointers,
                                                                             parameterSetSizes,
                                                                             4,
                                                                             NULL,
                                                                             &mDecoderFormatDescription);
            } else {
                status = -1;
                NSLog(@"%s:%d System version is too low!",__func__,__LINE__);
            }
        }
    }
    
    if (status == noErr) {
        //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
        //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
        //      kCVPixelFormatType_24RGB    //使用24位bitsPerPixel
        //      kCVPixelFormatType_32BGRA   //使用32位bitsPerPixel，kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
        uint32_t pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;  //NV12
        if (self.showType == H264HWDataType_Pixel) {
            pixelFormatType = kCVPixelFormatType_420YpCbCr8Planar;
        }
        const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
        const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &pixelFormatType) };
        CFDictionaryRef attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              mDecoderFormatDescription,
                                              NULL, attrs,
                                              &callBackRecord,
                                              &mDeocderSession);
        CFRelease(attrs);
        NSLog(@"Init H264 hardware decoder success");
    } else {
        NSLog(@"%@", [NSString stringWithFormat:@"Init H264 hardware decoder fail: %d", (int)status]);
        return NO;
    }
    
    return YES;
}
 
- (void)removeH264_H265_VideoDecoder
{
    if(mDeocderSession) {
        VTDecompressionSessionInvalidate(mDeocderSession);
        CFRelease(mDeocderSession);
        mDeocderSession = NULL;
    }
    
    if(mDecoderFormatDescription) {
        CFRelease(mDecoderFormatDescription);
        mDecoderFormatDescription = NULL;
    }
}

static int exitFlag = -1;
- (void)releaseH264_H265_VideoDecoder
{
	pthread_mutex_lock(&mVideoFramePackageListLock);
	BOOL decodeThreadRunning = mDecodeThreadRunning;
	if(decodeThreadRunning){
		int cnt=100;
		exitFlag=0;
		mDecodeThreadRunning=FALSE;
		pthread_mutex_unlock(&mVideoFramePackageListLock);
		[mNSThread cancel];
		while(cnt-->0 && exitFlag!=886){
			usleep(100000);
		}
	}else{
		pthread_mutex_unlock(&mVideoFramePackageListLock);
		[mNSThread cancel];
	}
    
    //[mNSThread dein];
    //[mNSThread release];
	mNSThread=NULL;
	
	//delete all the package
	NSLog(@"All the video package should be delete here to free memory on list");
	
    [self removeH264_H265_VideoDecoder];
    [self releaseSliceInfo];
    
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = NULL;
    }
	
	pthread_mutex_destroy(&mVideoFramePackageListLock);
	
	VideoFramePackage *afp=NULL;
	struct list_head *s,*n;
	list_for_each_safe(s, n, &mVideoFramePackageList) {
		afp = list_entry(s, VideoFramePackage, list);
		list_del(&afp->list);
		free(afp);
	}
}
 
- (void)releaseSliceInfo
{
    if(pVPS){
        FreeCharP(pVPS);
        pVPS=NULL;
    }
    if(pSPS){
        FreeCharP(pSPS);
        pSPS=NULL;
    }
    if(pPPS){
        FreeCharP(pPPS);
        pPPS=NULL;
    }
    if(prPPS){
        FreeCharP(prPPS);
        prPPS=NULL;
    }
    if(pSEI){
        FreeCharP(pSEI);
        pSEI=NULL;
    }
    
    mSpsSize = 0;
    mPpsSize = 0;
    mSeiSize = 0;
}
 
- (CGSize)decodeH264VideoData:(uint8_t *)videoData videoSize:(NSInteger)videoSize videoType:(VideoEncodeFormat)videoType
{
    //NSLog(@"decodeH264VideoData 第一步：视频解码出图片");
    CGSize imageSize = CGSizeMake(0, 0);
    if (videoData && videoSize > 0) {
        BOOL formatChanged = videoFormat!=videoType;
        if(formatChanged){
            videoFormat=videoType;
        }
        HWVideoFrameType frameFlag = [self analyticalData:videoData size:videoSize];
        if (mIsNeedReinit || formatChanged) {
            mIsNeedReinit = NO;
            [self removeH264_H265_VideoDecoder];
        }
        
        if (pSPS && pPPS && (frameFlag == HWVideoFrameType_I || frameFlag == HWVideoFrameType_P || frameFlag == HWVideoFrameType_B)) {
            uint8_t *buffer = NULL;
            if (frameFlag == HWVideoFrameType_I) {
                int nalExtra = (mINalCount==3?1:0);      //如果是3位的起始码，转为大端时需要增加1位
                videoSize -= mINalIndex;
                buffer = (uint8_t *)malloc(videoSize + nalExtra);
                memcpy(buffer + nalExtra, videoData + mINalIndex, videoSize);
                videoSize += nalExtra;
            } else {
                int nalExtra = (mPBNalCount==3?1:0);
                buffer = (uint8_t *)malloc(videoSize + nalExtra);
                memcpy(buffer + nalExtra, videoData, videoSize);
                videoSize += nalExtra;
            }
            
            uint32_t nalSize = (uint32_t)(videoSize - 4);
            uint32_t *pNalSize = (uint32_t *)buffer;
            *pNalSize = CFSwapInt32HostToBig(nalSize);
            
            CVPixelBufferRef pixelBuffer = NULL;
            if ([self initH264_H265_VideoDecoder:videoType]) {
                pixelBuffer = [self decode:buffer videoSize:videoSize];
                
                if(pixelBuffer) {
                    NSInteger width = CVPixelBufferGetWidth(pixelBuffer);
                    NSInteger height = CVPixelBufferGetHeight(pixelBuffer);
                    imageSize = CGSizeMake(width, height);
                    
                    if (self.showType == H264HWDataType_Pixel) {
                        if (_pixelBuffer) {
                            CVPixelBufferRelease(_pixelBuffer);
                        }
                        self.pixelBuffer = CVPixelBufferRetain(pixelBuffer);
                    } else {
                        if (frameFlag == HWVideoFrameType_B) {  //若B帧未进行乱序解码，顺序播放，则在此需要去除，否则解码图形则是灰色。
                            size_t planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
                            if (planeCount >= 2 && planeCount <= 3) {
                                CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                                u_char *yDestPlane = (u_char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
                                if (planeCount == 2) {
                                    u_char *uvDestPlane = (u_char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
                                    if (yDestPlane[0] == 0x80 && uvDestPlane[0] == 0x80 && uvDestPlane[1] == 0x80) {
                                        frameFlag = HWVideoFrameType_UNKNOWN;
                                        NSLog(@"Video YUV data parse error: Y=%02x U=%02x V=%02x", yDestPlane[0], uvDestPlane[0], uvDestPlane[1]);
                                    }
                                } else if (planeCount == 3) {
                                    u_char *uDestPlane = (u_char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
                                    u_char *vDestPlane = (u_char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);
                                    if (yDestPlane[0] == 0x80 && uDestPlane[0] == 0x80 && vDestPlane[0] == 0x80) {
                                        frameFlag = HWVideoFrameType_UNKNOWN;
                                        NSLog(@"Video YUV data parse error: Y=%02x U=%02x V=%02x", yDestPlane[0], uDestPlane[0], vDestPlane[0]);
                                    }
                                }
                                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                            }
                        }
                        
                        if (frameFlag != HWVideoFrameType_UNKNOWN) {
                            self.image = [self pixelBufferToImage:pixelBuffer];
                            if (_delegate && [_delegate respondsToSelector:@selector(getImageWith:imageSize:deviceID:)]) {
                                TTWeakSelf
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf.delegate getImageWith:self.image imageSize:imageSize deviceID:self.deviceID];
                                });
                            }
                        }
                    }
                    
                    CVPixelBufferRelease(pixelBuffer);
                }
            }
            
            FreeCharP(buffer);
        }
    }
    //NSLog(@"decodeH264VideoData end");
    return imageSize;
}

//将视频数据封装成CMSampleBufferRef进行解码
- (CVPixelBufferRef)decode:(uint8_t *)videoBuffer videoSize:(NSInteger)videoBufferSize
{
    //NSLog(@"第三步：将视频数据封装成CMSampleBufferRef进行解码");
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                          (void *)videoBuffer,
                                                          videoBufferSize,
                                                          kCFAllocatorNull,
                                                          NULL,
                                                          0,
                                                          videoBufferSize,
                                                          0,
                                                          &blockBuffer);
    if (status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = { videoBufferSize };
        status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, mDecoderFormatDescription, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
        
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            
            if (self.showType == H264HWDataType_Layer && _displayLayer) {
                
                CFArrayRef attachments      = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
                CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
                CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
                if ([self.displayLayer isReadyForMoreMediaData]) {
                    __weak typeof(self) weak_self = self;
                    dispatch_sync(dispatch_get_main_queue(),^{
                        __strong typeof(weak_self) strong_self = weak_self;
                        [strong_self.displayLayer enqueueSampleBuffer:sampleBuffer];
                    });
                }
                CFRelease(sampleBuffer);
                
            }
            else {
                VTDecodeFrameFlags flags = 0;
                VTDecodeInfoFlags flagOut = 0;
                OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(mDeocderSession, sampleBuffer, flags, &outputPixelBuffer, &flagOut);
                CFRelease(sampleBuffer);
                if (decodeStatus == kVTVideoDecoderMalfunctionErr) {
                    NSLog(@"Decode failed status: kVTVideoDecoderMalfunctionErr");
                    CVPixelBufferRelease(outputPixelBuffer);
                    outputPixelBuffer = NULL;
                } else if(decodeStatus == kVTInvalidSessionErr) {
                    NSLog(@"Invalid session, reset decoder session");
                    [self removeH264_H265_VideoDecoder];
                } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                    NSLog(@"%@", [NSString stringWithFormat:@"Decode failed status=%d(Bad data)", (int)decodeStatus]);
                } else if(decodeStatus != noErr) {
                    NSLog(@"%@", [NSString stringWithFormat:@"Decode failed status=%d", (int)decodeStatus]);
                }
            }
        }
        
        CFRelease(blockBuffer);
    }
    
    return outputPixelBuffer;
}
 
- (UIImage *)pixelBufferToImage:(CVPixelBufferRef)pixelBuffer
{
    UIImage *image = nil;
    if (!self.isNeedPerfectImg) {
        //第1种绘制（可直接显示，不可保存为文件(无效缺少图像描述参数)）
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        image = [UIImage imageWithCIImage:ciImage];
    }
    else {
        //第2种绘制（可直接显示，可直接保存为文件，相对第一种性能消耗略大）
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        CIContext *temporaryContext = [CIContext contextWithOptions:nil];
        CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
        image = [[UIImage alloc] initWithCGImage:videoImage];
        CGImageRelease(videoImage);
    }
    
    return image;
}
 
- (UIImage *)snapshot
{
    UIImage *img = nil;
    if (self.displayLayer) {
        
        UIGraphicsBeginImageContext(self.displayLayer.bounds.size);
        [self.displayLayer renderInContext:UIGraphicsGetCurrentContext()];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        if (self.showType == H264HWDataType_Pixel) {
            if (self.pixelBuffer) {
                img = [self pixelBufferToImage:self.pixelBuffer];
            }
        } else {
            img = self.image;
        }
        
        if (!self.isNeedPerfectImg) {
            UIGraphicsBeginImageContext(CGSizeMake(img.size.width, img.size.height));
            [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    return img;
}
 
 
//从起始位开始查询SPS、PPS、SEI、I、B、P帧起始码，遇到I、P、B帧则退出
//存在多种情况：
//1、起始码是0x0 0x0 0x0 0x01 或 0x0 0x0 0x1
//2、每个SPS、PPS、SEI、I、B、P帧为单独的Slice
//3、I帧中包含SPS、PPS、I数据Slice
//4、I帧中包含第3点的数据之外还包含SEI，顺序：SPS、PPS、SEI、I
//5、起始位是AVCC协议格式的大端数据(不支持多Slice的视频帧)
- (HWVideoFrameType)analyticalData:(const uint8_t *)buffer size:(NSInteger)size
{
    BOOL fpps=FALSE;
    NSInteger preIndex = 0;
    HWVideoFrameType preFrameType = HWVideoFrameType_UNKNOWN;
    HWVideoFrameType curFrameType = HWVideoFrameType_UNKNOWN;
    for (int i=0; i<size && i<300; i++) {       //一般第四种情况下的帧起始信息不会超过(32+256+12)位，可适当增大，为了不循环整个帧片数据
        int nalSize = [self getNALHeaderLen:(buffer + i) size:size-i];
        if (nalSize == 0 && i == 0) {   //当每个Slice起始位开始若使用AVCC协议则判断帧大小是否一致
            uint32_t *pNalSize = (uint32_t *)(buffer);
            uint32_t videoSize = CFSwapInt32BigToHost(*pNalSize);    //大端模式转为系统端模式
            if (videoSize == size - 4) {     //是大端模式(AVCC)
                nalSize = 4;
            }
        }
        
        if (nalSize && i + nalSize + 1 < size) {
            int sliceType = 0;
            if(videoFormat == H264EncodeFormat){
                sliceType = buffer[i + nalSize] & 0x1F;
                //NSLog(@"h264 sliceType:%d", sliceType);
            }else if(videoFormat == H265EncodeFormat){
                sliceType = (buffer[i + nalSize] & 0x7E)>>1;
                //NSLog(@"h265 sliceType:%d", sliceType);
            }
            
            if (sliceType == 0x1) {
                mPBNalCount = nalSize;
                if (buffer[i + nalSize] == 0x1) {   //B帧
                    curFrameType = HWVideoFrameType_B;
                } else {    //P帧
                    curFrameType = HWVideoFrameType_P;
                }
                break;
            } else if (sliceType == 0x5 || (sliceType>=16 && sliceType<=21)) {     //IDR(I帧)
                if (preFrameType == HWVideoFrameType_VPS) {
                    //NSLog(@"%d: VPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pVPS size:&mVpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_PPS) {
                    //NSLog(@"%d: PPS", __LINE__);
                    if(fpps==FALSE){
                        fpps=TRUE;
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&pPPS size:&mPpsSize start:preIndex end:i];
                    }else{
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&prPPS size:&mrPpsSize start:preIndex end:i];
                    }
                }else if (preFrameType == HWVideoFrameType_SPS) {
                    //NSLog(@"%d: SPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pSPS size:&mSpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_SEI)  {
                    //NSLog(@"%d: SEI", __LINE__);
                    [self getSliceInfo:buffer slice:&pSEI size:&mSeiSize start:preIndex end:i];
                }
                mINalCount = nalSize;
                mINalIndex = i;
                curFrameType = HWVideoFrameType_I;
                goto Goto_Exit;
            } else if (sliceType == 0x7 || sliceType == 33) {      //SPS
                if (preFrameType == HWVideoFrameType_VPS) {
                    //NSLog(@"%d: VPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pVPS size:&mVpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_PPS) {
                    //NSLog(@"%d: PPS", __LINE__);
                    if(fpps==FALSE){
                        fpps=TRUE;
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&pPPS size:&mPpsSize start:preIndex end:i];
                    }else{
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&prPPS size:&mrPpsSize start:preIndex end:i];
                    }
                }else if (preFrameType == HWVideoFrameType_SPS) {
                    //NSLog(@"%d: SPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pSPS size:&mSpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_SEI)  {
                    //NSLog(@"%d: SEI", __LINE__);
                    [self getSliceInfo:buffer slice:&pSEI size:&mSeiSize start:preIndex end:i];
                }
                curFrameType = HWVideoFrameType_SPS;
                preIndex = i + nalSize;
                i += nalSize;
            } else if (sliceType == 0x8 || sliceType == 34) {      //PPS
                if (preFrameType == HWVideoFrameType_VPS) {
                    //NSLog(@"%d: VPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pVPS size:&mVpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_PPS) {
                    //NSLog(@"%d: PPS", __LINE__);
                    if(fpps==FALSE){
                        fpps=TRUE;
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&pPPS size:&mPpsSize start:preIndex end:i];
                    }else{
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&prPPS size:&mrPpsSize start:preIndex end:i];
                    }
                }else if (preFrameType == HWVideoFrameType_SPS) {
                    //NSLog(@"%d: SPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pSPS size:&mSpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_SEI)  {
                    //NSLog(@"%d: SEI", __LINE__);
                    [self getSliceInfo:buffer slice:&pSEI size:&mSeiSize start:preIndex end:i];
                }
                curFrameType = HWVideoFrameType_PPS;
                preIndex = i + nalSize;
                i += nalSize;
            } else if (sliceType == 0x6 || sliceType == 39 || sliceType == 40) {      //SEI
                if (preFrameType == HWVideoFrameType_VPS) {
                    //NSLog(@"%d: VPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pVPS size:&mVpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_PPS) {
                    //NSLog(@"%d: PPS", __LINE__);
                    if(fpps==FALSE){
                        fpps=TRUE;
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&pPPS size:&mPpsSize start:preIndex end:i];
                    }else{
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&prPPS size:&mrPpsSize start:preIndex end:i];
                    }
                }else if (preFrameType == HWVideoFrameType_SPS) {
                    //NSLog(@"%d: SPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pSPS size:&mSpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_SEI)  {
                    //NSLog(@"%d: SEI", __LINE__);
                    [self getSliceInfo:buffer slice:&pSEI size:&mSeiSize start:preIndex end:i];
                }
                curFrameType = HWVideoFrameType_SEI;
                preIndex = i + nalSize;
                i += nalSize;
            } else if (sliceType == 32) {      //VPS
                if (preFrameType == HWVideoFrameType_VPS) {
                    //NSLog(@"%d: VPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pVPS size:&mVpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_PPS) {
                    //NSLog(@"%d: PPS", __LINE__);
                    if(fpps==FALSE){
                        fpps=TRUE;
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&pPPS size:&mPpsSize start:preIndex end:i];
                    }else{
                        mIsNeedReinit = [self getSliceInfo:buffer slice:&prPPS size:&mrPpsSize start:preIndex end:i];
                    }
                }else if (preFrameType == HWVideoFrameType_SPS) {
                    //NSLog(@"%d: SPS", __LINE__);
                    mIsNeedReinit = [self getSliceInfo:buffer slice:&pSPS size:&mSpsSize start:preIndex end:i];
                }else if (preFrameType == HWVideoFrameType_SEI)  {
                    //NSLog(@"%d: SEI", __LINE__);
                    [self getSliceInfo:buffer slice:&pSEI size:&mSeiSize start:preIndex end:i];
                }
                curFrameType = HWVideoFrameType_VPS;
                preIndex = i + nalSize;
                i += nalSize;
            }
            
            //NSLog(@"%d: preFrameType:%d curFrameType:%d", __LINE__, (int)preFrameType, (int)curFrameType);
            preFrameType = curFrameType;
        }
    }
    
    //SPS、PPS、SEI为单独的Slice帧片
    if (preFrameType == HWVideoFrameType_UNKNOWN && preIndex != 0) {
        if (curFrameType == HWVideoFrameType_SPS) {
            mIsNeedReinit = [self getSliceInfo:buffer slice:&pSPS size:&mSpsSize start:preIndex end:size];
        } else if (curFrameType == HWVideoFrameType_PPS) {
            mIsNeedReinit = [self getSliceInfo:buffer slice:&pPPS size:&mPpsSize start:preIndex end:size];
        } else if (curFrameType == HWVideoFrameType_SEI)  {
            [self getSliceInfo:buffer slice:&pSEI size:&mSeiSize start:preIndex end:size];
        } else if (curFrameType == HWVideoFrameType_VPS)  {
            [self getSliceInfo:buffer slice:&pVPS size:&mVpsSize start:preIndex end:size];
        }
    }
    
Goto_Exit:
    //NSLog(@"mIsNeedReinit:%d", mIsNeedReinit);
    return curFrameType;
}
 
//获取NAL的起始码长度是3还4
- (int)getNALHeaderLen:(const uint8_t *)buffer size:(NSInteger)size
{
    if (size >= 4 && buffer[0] == 0x0 && buffer[1] == 0x0 && buffer[2] == 0x0 && buffer[3] == 0x1) {
        return 4;
    } else if (size >= 3 && buffer[0] == 0x0 && buffer[1] == 0x0 && buffer[2] == 0x1) {
        return 3;
    }
    
    return 0;
}
 
//给SPS、PPS、SEI的Buf赋值，返回YES表示不同于之前的值
- (BOOL)getSliceInfo:(const uint8_t *)videoBuf slice:(uint8_t **)sliceBuf size:(NSInteger *)size start:(NSInteger)start end:(NSInteger)end
{
    BOOL isDif = NO;
    
    NSInteger len = end - start;
    uint8_t *tempBuf = (uint8_t *)(*sliceBuf);
    if (tempBuf) {
        if (len != *size || memcmp(tempBuf, videoBuf + start, len) != 0) {
            free(tempBuf);
            tempBuf = (uint8_t *)malloc(len);
            memcpy(tempBuf, videoBuf + start, len);
            
            *sliceBuf = tempBuf;
            *size = len;
            
            isDif = YES;
        }
    } else {
        tempBuf = (uint8_t *)malloc(len);
        memcpy(tempBuf, videoBuf + start, len);
        
        *sliceBuf = tempBuf;
        *size = len;
    }
    
    return isDif;
}

- (void)DecodeThread{
    while (mDecodeThreadRunning) {
		pthread_mutex_lock(&mVideoFramePackageListLock);
        if(list_empty(&mVideoFramePackageList)){
			pthread_mutex_unlock(&mVideoFramePackageListLock);
			usleep(5000);
			continue;
		}
		
		VideoFramePackage *vfp=NULL;
		struct list_head *s;
		list_for_each(s, &mVideoFramePackageList) {
			vfp = list_entry(s, VideoFramePackage, list);
			list_del(&vfp->list);
			break;
		}
		pthread_mutex_unlock(&mVideoFramePackageListLock);
		//if(vfp!=NULL)
		{
			if(vfp->type<20){
				[self decodeH264VideoData:vfp->data videoSize:vfp->len videoType:H264EncodeFormat];
			}else{
				[self decodeH264VideoData:vfp->data videoSize:vfp->len videoType:H265EncodeFormat];
			}
			free(vfp);
		}
		
		//if ([[NSThreadcurrentThread] isCancelled]){
        // //   break;
        //}
    }
	pthread_mutex_lock(&mVideoFramePackageListLock);
	mDecodeThreadRunning = FALSE;
	exitFlag=886;
	pthread_mutex_unlock(&mVideoFramePackageListLock);
	
	//if ([[NSThreadcurrentThread] isCancelled]){
	[NSThread exit];
	//}
}

- (int)decodeH26xVideoData:(uint8_t *)videoData videoSize:(int)videoSize frameType:(int)frameType timestamp:(long)timestamp
{
	if (mDecodeThreadRunning != TRUE){
        TLog(@"mDecodeThreadRunning != TRUE - 1");
		return -1;
	}
	if(videoData==NULL || videoSize<=0){
		TLog(@"param invalid! videoData:%p || videoSize:%d", videoData, videoSize);
		return -1;
	}
	VideoFramePackage*vfp = (VideoFramePackage*)malloc(sizeof(VideoFramePackage) + videoSize);
	if(vfp==NULL){
		NSLog(@"decodeH26xVideoData malloc failed!");
		return -1;
	}
	
	memset(vfp,0,sizeof(VideoFramePackage) + videoSize);
	INIT_LIST_HEAD(&vfp->list);
	vfp->data = ((uint8_t*)vfp) + sizeof(VideoFramePackage);
	memcpy(vfp->data, videoData, videoSize);
	vfp->type = frameType;
	vfp->timestamp = timestamp;
	vfp->len = videoSize;
	pthread_mutex_lock(&mVideoFramePackageListLock);
	list_add_tail(&vfp->list, &mVideoFramePackageList);
	pthread_mutex_unlock(&mVideoFramePackageListLock);
	return videoSize;
}

@end
