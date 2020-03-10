//
//  XBAudioUnitPlayer.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/29.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioUnitPlayer.h"
#import "XBAudioTool.h"
#import "pthread.h"
#import "list.h"
#include "IPCNetManagerInterface.h"

typedef struct {
    int type;
    unsigned char*data;
    int len;
	int read_pos;
    long timestamp;
	struct list_head list;
}AudioFramePackage;

@interface XBAudioUnitPlayer ()
{
    AudioUnit audioUnit;
	
    IPCNET_AUDIO_ENCODE_TYPE_et codeType;
    
	struct list_head mAudioFramePackageList;
    pthread_mutex_t mAudioFramePackageListLock;
}
@property (nonatomic,assign) XBAudioBit bit;
@property (nonatomic,assign) XBAudioRate rate;
@property (nonatomic,assign) XBAudioChannel channel;
@end

@implementation XBAudioUnitPlayer

- (instancetype)initWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel
{
    if (self = [super init])
    {
        self.rate = rate;
        self.bit = bit;
        self.channel = channel;
		INIT_LIST_HEAD(&mAudioFramePackageList);
		pthread_mutex_init(&mAudioFramePackageListLock, NULL);
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.rate = XBAudioRate_44k;
        self.bit = XBAudioBit_16;
        self.channel = XBAudioChannel_1;
		
		INIT_LIST_HEAD(&mAudioFramePackageList);
		pthread_mutex_init(&mAudioFramePackageListLock, NULL);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"XBAudioUnitPlayer销毁");
    [self destroy];
}

- (void)destroy
{
    if (audioUnit)
    {
        OSStatus status;
        status = AudioComponentInstanceDispose(audioUnit);
        CheckError(status, "audioUnit释放失败");
    }
}

- (void)initAudioUnitWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel
{
    //设置session
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    //初始化audioUnit
    AudioComponentDescription outputDesc = [XBAudioTool allocAudioComponentDescriptionWithComponentType:kAudioUnitType_Output
                                                                                       componentSubType:kAudioUnitSubType_VoiceProcessingIO
                                                                                         componentFlags:0
                                                                                     componentFlagsMask:0];
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &outputDesc);
    AudioComponentInstanceNew(outputComponent, &audioUnit);
    
    
    
    //设置输出格式
    int mFramesPerPacket = 1;
    
    AudioStreamBasicDescription streamDesc = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:kAudioFormatLinearPCM
                                                                                           mFormatFlags:(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved)
                                                                                            mSampleRate:rate
                                                                                       mFramesPerPacket:mFramesPerPacket
                                                                                      mChannelsPerFrame:channel
                                                                                        mBitsPerChannel:bit];
    
    OSStatus status = AudioUnitSetProperty(audioUnit,
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Input,
                                           kOutputBus,
                                           &streamDesc,
                                           sizeof(streamDesc));
    CheckError(status, "SetProperty StreamFormat failure");
    
    //设置回调
    AURenderCallbackStruct outputCallBackStruct;
    outputCallBackStruct.inputProc = outputCallBackFun;
    outputCallBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &outputCallBackStruct,
                                  sizeof(outputCallBackStruct));
    CheckError(status, "SetProperty EnableIO failure");
}

- (void)start
{
    if (audioUnit == nil)
    {
        [self initAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
    }
    AudioOutputUnitStart(audioUnit);
}

- (void)stop
{
    if (audioUnit == nil)
    {
        return;
    }
    OSStatus status;
    status = AudioOutputUnitStop(audioUnit);
    CheckError(status, "audioUnit停止失败");
}

static OSStatus outputCallBackFun(    void *                            inRefCon,
                                  AudioUnitRenderActionFlags *    ioActionFlags,
                                  const AudioTimeStamp *            inTimeStamp,
                                  UInt32                            inBusNumber,
                                  UInt32                            inNumberFrames,
                                  AudioBufferList * __nullable    ioData)
{
    memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
    //    memset(ioData->mBuffers[1].mData, 0, ioData->mBuffers[1].mDataByteSize);
    
    XBAudioUnitPlayer *player = (__bridge XBAudioUnitPlayer *)(inRefCon);
    typeof(player) __weak weakPlayer = player;
	
	AudioBuffer buffer = ioData->mBuffers[0];
	
	struct list_head *s,*n;
	int readLen=0;
	
	pthread_mutex_lock(&player->mAudioFramePackageListLock);
	list_for_each_safe(s, n, &player->mAudioFramePackageList) {
		AudioFramePackage *afp = list_entry(s, AudioFramePackage, list);
		int copyLen = 0;
		copyLen = (afp->len-afp->read_pos) > (buffer.mDataByteSize-readLen) ? (buffer.mDataByteSize-readLen): (afp->len-afp->read_pos);
		memcpy((unsigned char*)(buffer.mData) + readLen, afp->data+afp->read_pos, copyLen);
		readLen += copyLen;
		afp->read_pos += copyLen;
			
		if(afp->read_pos >= afp->len){
			list_del(&afp->list);
			free(afp);
		}else{
			break;
		}
	}
	pthread_mutex_unlock(&player->mAudioFramePackageListLock);
	
	buffer.mDataByteSize = readLen;
	
    return noErr;
}

- (int)playThisAudioData:(uint8_t *)audioData audioSize:(int)audioSize frameType:(int)frameType timestamp:(long)timestamp
{
	int j;
	if (audioUnit == nil){
		return -1;
	}
	if(audioData==NULL || audioSize<=0){
		NSLog(@"param invalid! audioData:%p || audioSize:%d", audioData, audioSize);
		return -1;
	}
    
    NSLog(@"audioData:%p audioSize:%d", audioData, audioSize);
	static int16_t *pcmdata=NULL;
	static int pcmBufLen=0;
	
	int pcm_len=0;
	//convert AudioFramePackage data to pcm
	if(frameType == IPCNET_AUDIO_G711A){
		pcm_len = audioSize*2;
		if(pcmBufLen<pcm_len){
			pcmBufLen = pcm_len;
			pcmdata = (int16_t *)realloc(pcmdata, pcmBufLen);
		}
		for(j=0;j<audioSize;j++){
			pcmdata[j]=IPCNetALawDecode(audioData[j]);
		}
	}else if(frameType == IPCNET_AUDIO_G711U){
		pcm_len = audioSize*2;
		if(pcmBufLen<pcm_len){
			pcmBufLen = pcm_len;
			pcmdata = (int16_t *)realloc(pcmdata, pcmBufLen);
		}
		for(j=0;j<audioSize;j++){
			pcmdata[j]=IPCNetMuLawDecode(audioData[j]);
		}
	}else if(frameType == IPCNET_AUDIO_PCM){
		pcm_len = audioSize;
		if(pcmBufLen<audioSize){
			pcmBufLen = audioSize;
			pcmdata = (int16_t *)realloc(pcmdata, pcmBufLen);
		}
		memcpy(pcmdata, audioData, pcm_len);
	}else{
		NSLog(@"Not support this type:%d\n", frameType);
		return -1;
	}
	
	AudioFramePackage*vfp = (AudioFramePackage*)malloc(sizeof(AudioFramePackage) + pcm_len);
	if(vfp==NULL){
		NSLog(@"playThisAudioData malloc failed!");
		return -1;
	}
	
	memset(vfp,0,sizeof(AudioFramePackage) + pcm_len);
	INIT_LIST_HEAD(&vfp->list);
	vfp->data = ((uint8_t*)vfp) + sizeof(AudioFramePackage);
	memcpy(vfp->data, pcmdata, pcm_len);
	vfp->type = IPCNET_AUDIO_PCM;
	vfp->timestamp = timestamp;
	vfp->len = pcm_len;
	pthread_mutex_lock(&mAudioFramePackageListLock);
	list_add_tail(&vfp->list, &mAudioFramePackageList);
	pthread_mutex_unlock(&mAudioFramePackageListLock);
	return audioSize;
}
@end

