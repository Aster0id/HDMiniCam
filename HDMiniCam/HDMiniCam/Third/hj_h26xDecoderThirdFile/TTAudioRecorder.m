
#import "TTAudioRecorder.h"
#import "TTAudioTool.h"
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
} AudioFramePackage;

@interface TTAudioRecorder ()
{
    AudioUnit audio_Unit;
    NSThread *mm_thread;

    BOOL send_thread_Running;

    
    #pragma mark - 增加对象
    BOOL addNewDEVICE;
    NSString *deviceID;
    #pragma mark - 增加对象

    
    
    pthread_mutex_t m_pthread_mutex_t_Lock;
    
    #pragma mark - 增加对象
    BOOL addNewDEVICE2;
    NSString *deviceID2;
    #pragma mark - 增加对象

    struct list_head audio_frame_package_List;
    
}

@property (nonatomic,assign) TTAudioBit bit;

#pragma mark - 增加对象
@property (nonatomic, assign) NSInteger index;
#pragma mark - 增加对象

@property (nonatomic,assign) TTAudioRate rate;


@property (nonatomic,assign) TTAudioChannel channel;

@property (nonatomic,assign) AudioStreamBasicDescription inputStreamDesc;


@end

@implementation TTAudioRecorder

- (instancetype)initWithRate:(TTAudioRate)rate bit:(TTAudioBit)bit channel:(TTAudioChannel)channel
{
    if (self = [super init])
    {
        self.bit = bit;
        self.rate = rate;
        self.channel = channel;
        
        [self initInputAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
		
		INIT_LIST_HEAD(&audio_frame_package_List);
		pthread_mutex_init(&m_pthread_mutex_t_Lock, NULL);
		send_thread_Running = TRUE;
		mm_thread = [[NSThread alloc]initWithTarget:self selector:@selector(SendThread) object:self];
		mm_thread.name = @"Send thread";
		[mm_thread start];
    }
    return self;
}
- (instancetype)init
{
    if (self = [super init])
    {
        self.bit        = TTAudioBit_16;
        self.rate       = TTAudioRate_44k;
        self.channel    = TTAudioChannel_1;
        [self initInputAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];
		
		INIT_LIST_HEAD(&audio_frame_package_List);
		pthread_mutex_init(&m_pthread_mutex_t_Lock, NULL);
		send_thread_Running = TRUE;
		mm_thread = [[NSThread alloc]initWithTarget:self selector:@selector(SendThread) object:self];
		mm_thread.name = @"Send thread";
		[mm_thread start];
    }
    return self;
}
- (void)dealloc
{
    CheckError(AudioComponentInstanceDispose(audio_Unit),
               "AudioComponentInstanceDispose failed");

	pthread_mutex_lock(&m_pthread_mutex_t_Lock);
	BOOL decodeThreadRunning = send_thread_Running;
	if (decodeThreadRunning) {
		int cnt = 100;
		exitFlag = 0;
		send_thread_Running = FALSE;
		pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
		[mm_thread cancel];
		while (cnt-->0 && exitFlag != 886){
            usleep(100000);
		}
	}
    else {
		pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
		[mm_thread cancel];
	}
    
	mm_thread = NULL;
	pthread_mutex_destroy(&m_pthread_mutex_t_Lock);
    free(_mUUID);
}

- (void)initInputAudioUnitWithRate:(TTAudioRate)rate bit:(TTAudioBit)bit channel:(TTAudioChannel)channel
{
    //设置AVAudioSession
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    AudioComponentDescription inputDesc = [TTAudioTool alloc_Audio_Component_Description_With_ComponentType:kAudioUnitType_Output componentSubType:kAudioUnitSubType_RemoteIO componentFlags:0 componentFlagsMask:0];
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &inputDesc);
    CheckError(AudioComponentInstanceNew(inputComponent, &audio_Unit), "AudioComponentInstanceNew failure");
    
    _mUUID = malloc(64);
	memset(_mUUID, 0, 64);
    //self.mUUID =[NSString stringWithUTF8String:""];

    //设置输出流格式
    int mFramesPerPacket = 1;
    
    AudioStreamBasicDescription inputStreamDesc = [TTAudioTool alloc_Audio_Stream_Basic_Description_With_FormatID:kAudioFormatLinearPCM mFormatFlags:(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsPacked) mSampleRate:rate mFramesPerPacket:mFramesPerPacket mChannelsPerFrame:channel mBitsPerChannel:bit];
    self.inputStreamDesc = inputStreamDesc;
    
    OSStatus status = AudioUnitSetProperty(audio_Unit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kInputBus,
                         &inputStreamDesc,
                         sizeof(inputStreamDesc));
    CheckError(status, "setProperty inputStreamFormat error");
    
    //麦克风输入设置为1（yes）
    int inputEnable = 1;
    status = AudioUnitSetProperty(audio_Unit,
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
    
    status = AudioUnitSetProperty(audio_Unit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &inputCallBackStruce,
                                  sizeof(inputCallBackStruce));
    CheckError(status, "setProperty InputCallback error");
    
    AudioStreamBasicDescription outputDesc0;
    UInt32 size = sizeof(outputDesc0);
    CheckError(AudioUnitGetProperty(audio_Unit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &outputDesc0,
                                    &size),"get property failure");
    
    AudioStreamBasicDescription outputDesc1;
    size = sizeof(outputDesc1);
    CheckError(AudioUnitGetProperty(audio_Unit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &outputDesc1,
                                    &size),"get property failure");
}

- (void)start
{
    [self delete];
    AudioOutputUnitStart(audio_Unit);
    _isRecording = YES;
}

static int exitFlag = -1;

- (void)stop
{
    CheckError(AudioOutputUnitStop(audio_Unit),
               "AudioOutputUnitStop failed");
    
    _isRecording = NO;
}



- (AudioStreamBasicDescription)getOutputFormat
{
    return self.inputStreamDesc;
}

static OSStatus inputCallBackFun(    void *                            inRefCon,
                    AudioUnitRenderActionFlags *    ioActionFlags,
                    const AudioTimeStamp *            inTimeStamp,
                    UInt32                            inBusNumber,
                    UInt32                            inNumberFrames,
                    AudioBufferList * __nullable    ioData)
{

    TTAudioRecorder *recorder = (__bridge TTAudioRecorder *)(inRefCon);
    typeof(recorder) __weak weakRecorder = recorder;
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    
    AudioUnitRender(recorder->audio_Unit,
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
	}
    
    
    else if(recorder->_codeType == IPCNET_AUDIO_ENCODE_TYPE_PCM){
		enclen = pcmlen;
		encdata = (uint8_t*)malloc(enclen);
		memcpy(encdata, pcmdata, enclen);
	}
    else if(recorder->_codeType == IPCNET_AUDIO_ENCODE_TYPE_AAC){

		return noErr;
	}
    else {

        char datastr[1024] = {0};
		enclen = pcmlen/2;
		encdata = (uint8_t*)malloc(enclen);
		for(i = 0;i < enclen; i++){
			encdata[i] = IPCNetALawEncode(pcmdata[i]);
		}
	}
    
	AudioFramePackage *afp=(AudioFramePackage*)malloc(sizeof(AudioFramePackage) + enclen);
	memset(afp,0,sizeof(AudioFramePackage) + enclen);
	INIT_LIST_HEAD(&afp->list);
	afp->data = ((uint8_t*)afp) + sizeof(AudioFramePackage);
	memcpy(afp->data, encdata, enclen);
	afp->timestamp = inTimeStamp;
	afp->len = enclen;
	
	free(encdata);
	pthread_mutex_lock(&recorder->m_pthread_mutex_t_Lock);
    list_add_tail(&afp->list, &recorder->audio_frame_package_List);
	pthread_mutex_unlock(&recorder->m_pthread_mutex_t_Lock);
    return noErr;
}

- (void)delete
{
    NSString *pcmPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/xbMedia"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pcmPath])
        [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
}

- (void)SendThread
{
    int sendlen = 320;
    uint8_t*sendbuf = NULL;
    int dataSizeInBuf=0;
    while (send_thread_Running) {
		pthread_mutex_lock(&m_pthread_mutex_t_Lock);
        if(list_empty(&audio_frame_package_List)){
			pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
			usleep(5000);
			continue;
		}
		
		AudioFramePackage *afp=NULL;
		struct list_head *s;
		list_for_each(s, &audio_frame_package_List) {
			afp = list_entry(s, AudioFramePackage, list);
			break;
		}
		pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
		{
			if (sendbuf == NULL)
                sendbuf = (uint8_t*)malloc(sendlen);
			if (_codeType == IPCNET_AUDIO_ENCODE_TYPE_G711A ||
                _codeType == IPCNET_AUDIO_ENCODE_TYPE_G711U ||
                _codeType == IPCNET_AUDIO_ENCODE_TYPE_PCM) {
                int wantLen = sendlen-dataSizeInBuf;
				int copyLen = 0;
				copyLen = (afp->len-afp->read_pos) > wantLen ? wantLen: (afp->len-afp->read_pos);
				memcpy(sendbuf + dataSizeInBuf, afp->data+afp->read_pos, copyLen);
				dataSizeInBuf += copyLen;
				afp->read_pos += copyLen;
                
				if (afp->read_pos >= afp->len) {
                    pthread_mutex_lock(&m_pthread_mutex_t_Lock);
					list_del(&afp->list);
                    pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
					free(afp);
				}
				if (dataSizeInBuf >= sendlen){
                    
					IPCNetPutTalkData(self.mUUID, sendbuf, dataSizeInBuf);
					dataSizeInBuf=0;
				}
			}
            else {
                
				IPCNetPutTalkData(self.mUUID, afp->data, afp->len);
				
				pthread_mutex_lock(&m_pthread_mutex_t_Lock);
				list_del(&afp->list);
				pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
				free(afp);
			}
		}
    }
	pthread_mutex_lock(&m_pthread_mutex_t_Lock);
	send_thread_Running = FALSE;
	exitFlag=886;
	pthread_mutex_unlock(&m_pthread_mutex_t_Lock);
	
	//if ([[NSThreadcurrentThread] isCancelled]){
	[NSThread exit];
	//}
}
@end
