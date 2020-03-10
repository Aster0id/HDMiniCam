//
//  XBAudioUnitRecorder.m
//  XBVoiceTool
//
//  Created by xxb on 2018/6/28.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAudioUnitRecorder.h"
#import "XBAudioTool.h"
#import "pthread.h"
#import "list.h"
#include "IPCNetManagerInterface.h"

#define UUID_MAX_LEN 64
#define subPathPCM @"/Documents/xbMedia"
#define stroePath [NSHomeDirectory() stringByAppendingString:subPathPCM]

typedef struct {
    int type;
    unsigned char*data;
    int len;
	int read_pos;
    long timestamp;
	struct list_head list;
}AudioFramePackage;

@interface XBAudioUnitRecorder ()
{
    AudioUnit audioUnit;
	
	//IPCNET_AUDIO_ENCODE_TYPE_et codeType;
	
	struct list_head mAudioFramePackageList;
    pthread_mutex_t mAudioFramePackageListLock;
    BOOL mSendThreadRunning;
	NSThread*mNSThread;
}
@property (nonatomic,assign) XBAudioBit bit;
@property (nonatomic,assign) XBAudioRate rate;
@property (nonatomic,assign) XBAudioChannel channel;
@property (nonatomic,assign) AudioStreamBasicDescription inputStreamDesc;
@end

@implementation XBAudioUnitRecorder

- (instancetype)initWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel
{
    if (self = [super init])
    {
        self.bit = bit;
        self.rate = rate;
        self.channel = channel;
        
        [self initInputAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
		
		INIT_LIST_HEAD(&mAudioFramePackageList);
		pthread_mutex_init(&mAudioFramePackageListLock, NULL);
		mSendThreadRunning = TRUE;
		mNSThread = [[NSThread alloc]initWithTarget:self selector:@selector(SendThread) object:self];
		mNSThread.name = @"Send thread";
		[mNSThread start];
    }
    return self;
}
- (instancetype)init
{
    if (self = [super init])
    {
        self.bit = XBAudioBit_16;
        self.rate = XBAudioRate_44k;
        self.channel = XBAudioChannel_1;
        
        [self initInputAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
		
		INIT_LIST_HEAD(&mAudioFramePackageList);
		pthread_mutex_init(&mAudioFramePackageListLock, NULL);
		mSendThreadRunning = TRUE;
		mNSThread = [[NSThread alloc]initWithTarget:self selector:@selector(SendThread) object:self];
		mNSThread.name = @"Send thread";
		[mNSThread start];
    }
    return self;
}
- (void)dealloc
{
    CheckError(AudioComponentInstanceDispose(audioUnit),
               "AudioComponentInstanceDispose failed");
    NSLog(@"XBAudioUnitRecorder销毁");
	
	pthread_mutex_lock(&mAudioFramePackageListLock);
	BOOL decodeThreadRunning = mSendThreadRunning;
	if(decodeThreadRunning){
		int cnt=100;
		exitFlag=0;
		mSendThreadRunning=FALSE;
		pthread_mutex_unlock(&mAudioFramePackageListLock);
		[mNSThread cancel];
		while(cnt-->0 && exitFlag!=886){
			usleep(100000);
		}
	}else{
		pthread_mutex_unlock(&mAudioFramePackageListLock);
		[mNSThread cancel];
	}
    
    //[mNSThread dein];
    //[mNSThread release];
	mNSThread=NULL;
	
	//delete all the package
	NSLog(@"All the audio package should be delete here to free memory on list");
	
	pthread_mutex_destroy(&mAudioFramePackageListLock);
    free(_mUUID);
}

- (void)initInputAudioUnitWithRate:(XBAudioRate)rate bit:(XBAudioBit)bit channel:(XBAudioChannel)channel
{
    //设置AVAudioSession
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    //初始化audioUnit
    AudioComponentDescription inputDesc = [XBAudioTool allocAudioComponentDescriptionWithComponentType:kAudioUnitType_Output componentSubType:kAudioUnitSubType_RemoteIO componentFlags:0 componentFlagsMask:0];
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &inputDesc);
    CheckError(AudioComponentInstanceNew(inputComponent, &audioUnit), "AudioComponentInstanceNew failure");
    
    _mUUID = malloc(64);
	memset(_mUUID, 0, UUID_MAX_LEN);
    //self.mUUID =[NSString stringWithUTF8String:""];

    //设置输出流格式
    int mFramesPerPacket = 1;
    
    AudioStreamBasicDescription inputStreamDesc = [XBAudioTool allocAudioStreamBasicDescriptionWithMFormatID:kAudioFormatLinearPCM mFormatFlags:(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsPacked) mSampleRate:rate mFramesPerPacket:mFramesPerPacket mChannelsPerFrame:channel mBitsPerChannel:bit];
    self.inputStreamDesc = inputStreamDesc;
    
    OSStatus status = AudioUnitSetProperty(audioUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kInputBus,
                         &inputStreamDesc,
                         sizeof(inputStreamDesc));
    CheckError(status, "setProperty inputStreamFormat error");
    
//    status = AudioUnitSetProperty(audioUnit,
//                                           kAudioUnitProperty_StreamFormat,
//                                           kAudioUnitScope_Input,
//                                           kOutputBus,
//                                           &inputStreamDesc,
//                                           sizeof(inputStreamDesc));
//    CheckError(status, "setProperty outputStreamFormat error");
    
    
    //麦克风输入设置为1（yes）
    int inputEnable = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &inputEnable,
                                  sizeof(inputEnable));
    CheckError(status, "setProperty EnableIO error");
    
    //设置回调
    AURenderCallbackStruct inputCallBackStruce;
    inputCallBackStruce.inputProc = inputCallBackFun;
    inputCallBackStruce.inputProcRefCon = (__bridge void * _Nullable)(self);
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &inputCallBackStruce,
                                  sizeof(inputCallBackStruce));
    CheckError(status, "setProperty InputCallback error");
    
    AudioStreamBasicDescription outputDesc0;
    UInt32 size = sizeof(outputDesc0);
    CheckError(AudioUnitGetProperty(audioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &outputDesc0,
                                    &size),"get property failure");
    
    AudioStreamBasicDescription outputDesc1;
    size = sizeof(outputDesc1);
    CheckError(AudioUnitGetProperty(audioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &outputDesc1,
                                    &size),"get property failure");
}

- (void)start
{
    [self delete];
    AudioOutputUnitStart(audioUnit);
    _isRecording = YES;
}

static int exitFlag = -1;

- (void)stop
{
    CheckError(AudioOutputUnitStop(audioUnit),
               "AudioOutputUnitStop failed");
    
    _isRecording = NO;
}



- (AudioStreamBasicDescription)getOutputFormat
{
    return self.inputStreamDesc;
//    AudioStreamBasicDescription outputDesc0;
//    UInt32 size = sizeof(outputDesc0);
//    CheckError(AudioUnitGetProperty(audioUnit,
//                                    kAudioUnitProperty_StreamFormat,
//                                    kAudioUnitScope_Output,
//                                    0,
//                                    &outputDesc0,
//                                    &size),"get property failure");
//    return outputDesc0;
}

static OSStatus inputCallBackFun(    void *                            inRefCon,
                    AudioUnitRenderActionFlags *    ioActionFlags,
                    const AudioTimeStamp *            inTimeStamp,
                    UInt32                            inBusNumber,
                    UInt32                            inNumberFrames,
                    AudioBufferList * __nullable    ioData)
{

    XBAudioUnitRecorder *recorder = (__bridge XBAudioUnitRecorder *)(inRefCon);
    typeof(recorder) __weak weakRecorder = recorder;
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    
    AudioUnitRender(recorder->audioUnit,
                    ioActionFlags,
                    inTimeStamp,
                    kInputBus,
                    inNumberFrames,
                    &bufferList);
    
	int16_t *pcmdata = (int16_t*)bufferList.mBuffers[0].mData;
	int pcmlen = bufferList.mBuffers[0].mDataByteSize;
	uint8_t*encdata=NULL;
	int enclen=0;
	int i;
	//转换格式
	if(recorder->_codeType == IPCNET_AUDIO_ENCODE_TYPE_G711U){
		enclen = pcmlen/2;
		encdata = (uint8_t*)malloc(enclen);
		for(i=0;i<enclen;i++){
			encdata[i] = IPCNetMuLawEncode(pcmdata[i]);
		}
	}else if(recorder->_codeType == IPCNET_AUDIO_ENCODE_TYPE_PCM){
		enclen = pcmlen;
		encdata = (uint8_t*)malloc(enclen);
		memcpy(encdata, pcmdata, enclen);
	}else if(recorder->_codeType == IPCNET_AUDIO_ENCODE_TYPE_AAC){
		NSLog(@"目前还未实现AAC，需要实现\n");
		return noErr;
	}else{// if(codeType == IPCNET_AUDIO_ENCODE_TYPE_G711A)
	//默认是G711A
        char datastr[1024]={0};
		enclen = pcmlen/2;
		encdata = (uint8_t*)malloc(enclen);
		for(i=0;i<enclen;i++){
			encdata[i] = IPCNetALawEncode(pcmdata[i]);
            //sprintf(datastr + strlen(datastr), "%02x ", pcmdata[i]);
		}
        //NSLog(@"datastr:%s", datastr);
	}
    //NSLog(@"codeType:%d enclen:%d", recorder->_codeType, enclen);
    
	AudioFramePackage *afp=(AudioFramePackage*)malloc(sizeof(AudioFramePackage) + enclen);
	memset(afp,0,sizeof(AudioFramePackage) + enclen);
	INIT_LIST_HEAD(&afp->list);
	afp->data = ((uint8_t*)afp) + sizeof(AudioFramePackage);
	memcpy(afp->data, encdata, enclen);
	//afp->type = frameType;
	afp->timestamp = inTimeStamp;
	afp->len = enclen;
	//afp->read_pos = 0;
    //NSLog(@"put len:%d", afp->len);
	
	free(encdata);
	
	pthread_mutex_lock(&recorder->mAudioFramePackageListLock);
    list_add_tail(&afp->list, &recorder->mAudioFramePackageList);
	pthread_mutex_unlock(&recorder->mAudioFramePackageListLock);
    
    return noErr;
}
- (void)delete
{
    NSString *pcmPath = stroePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pcmPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
    }
}

- (void)SendThread{
    int sendlen = 320;
    uint8_t*sendbuf = NULL;
    int dataSizeInBuf=0;
    while (mSendThreadRunning) {
		pthread_mutex_lock(&mAudioFramePackageListLock);
        if(list_empty(&mAudioFramePackageList)){
			pthread_mutex_unlock(&mAudioFramePackageListLock);
			usleep(5000);
			continue;
		}
		
		AudioFramePackage *afp=NULL;
		struct list_head *s;
		list_for_each(s, &mAudioFramePackageList) {
			afp = list_entry(s, AudioFramePackage, list);
			//list_del(&afp->list);
			break;
		}
		pthread_mutex_unlock(&mAudioFramePackageListLock);
		//if(afp!=NULL)
		{
			if(sendbuf==NULL){
				sendbuf = (uint8_t*)malloc(sendlen);
			}
			//convert audio format
			//如果传输的音频是g711a/g711u，那么采集的是pcm，在这里按照320字节一包直接发送数据
			//如果传输的音频是aac，由系统自带编码器编码之后，不需要在转换，直接发送
			//每次发送320字节
			if(_codeType == IPCNET_AUDIO_ENCODE_TYPE_G711A || _codeType == IPCNET_AUDIO_ENCODE_TYPE_G711U ||
				_codeType == IPCNET_AUDIO_ENCODE_TYPE_PCM){
				int wantLen = sendlen-dataSizeInBuf;
				int copyLen = 0;
				copyLen = (afp->len-afp->read_pos) > wantLen ? wantLen: (afp->len-afp->read_pos);
				memcpy(sendbuf + dataSizeInBuf, afp->data+afp->read_pos, copyLen);
				dataSizeInBuf += copyLen;
				afp->read_pos += copyLen;
                
				if(afp->read_pos >= afp->len){
                    //NSLog(@"free pkg read_pos:%d len:%d", afp->read_pos, afp->len);
                    pthread_mutex_lock(&mAudioFramePackageListLock);
					list_del(&afp->list);
                    pthread_mutex_unlock(&mAudioFramePackageListLock);
					free(afp);
				}
				if(dataSizeInBuf>=sendlen){
                    //NSLog(@"mUUID:%p", self.mUUID);
                    NSLog(@"send %s audio %d bytes", self.mUUID, dataSizeInBuf);
					IPCNetPutTalkData(self.mUUID, sendbuf, dataSizeInBuf);
					dataSizeInBuf=0;
				}
			}else{// if(codeType == IPCNET_AUDIO_ENCODE_TYPE_AAC){
				//aac 或是其他未知音频，直接发送
                
				//send out
				IPCNetPutTalkData(self.mUUID, afp->data, afp->len);
				
				pthread_mutex_lock(&mAudioFramePackageListLock);
				list_del(&afp->list);
				pthread_mutex_unlock(&mAudioFramePackageListLock);
				free(afp);
			}
		}
    }
	pthread_mutex_lock(&mAudioFramePackageListLock);
	mSendThreadRunning = FALSE;
	exitFlag=886;
	pthread_mutex_unlock(&mAudioFramePackageListLock);
	
	//if ([[NSThreadcurrentThread] isCancelled]){
	[NSThread exit];
	//}
}
@end
