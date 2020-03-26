
#import "TTAudioPlayer.h"
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
}AudioFramePackage;

@interface TTAudioPlayer ()
{
    struct list_head mAudioFramePackageList;

}
@property (nonatomic,assign) TTAudioBit bit;


@property (nonatomic,assign) TTAudioRate rate;

@property (nonatomic,assign) TTAudioChannel channel;

@end

@implementation TTAudioPlayer

- (instancetype)initWithRate:(TTAudioRate)rate bit:(TTAudioBit)bit channel:(TTAudioChannel)channel
{
    if (self = [super init])
    {
        self.rate = rate;
        self.bit = bit;
        self.channel = channel;
		INIT_LIST_HEAD(&mAudioFramePackageList);
		pthread_mutex_init(&tt_audio_frame_packageList_Lock, NULL);
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.rate = TTAudioRate_44k;
        self.bit = TTAudioBit_16;
        self.channel = TTAudioChannel_1;
		
		INIT_LIST_HEAD(&mAudioFramePackageList);
		pthread_mutex_init(&tt_audio_frame_packageList_Lock, NULL);
    }
    return self;
}

- (void)dealloc
{
    [self destroy];
}

- (void)destroy
{
    if (tt_audio_unit) {
        OSStatus status;
        status = AudioComponentInstanceDispose(tt_audio_unit);
        CheckError(status, "tt_audio_unit释放失败");
    }
}

- (void)initAudioUnitWithRate:(TTAudioRate)rate bit:(TTAudioBit)bit channel:(TTAudioChannel)channel
{
    NSError *error = nil;
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [session setActive:YES error:nil];
    
    AudioComponentDescription outputDesc = [TTAudioTool alloc_Audio_Component_Description_With_ComponentType:kAudioUnitType_Output
                                                                                       
                                                                                            componentSubType:kAudioUnitSubType_VoiceProcessingIO
                                                                                         
                                                                                              componentFlags:0
                                                                                     
                                                                                          componentFlagsMask:0];
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &outputDesc);
    AudioComponentInstanceNew(outputComponent, &tt_audio_unit);
    
    
    
    //设置输出格式
    int mFramesPerPacket = 1;
    
    AudioStreamBasicDescription streamDesc = [TTAudioTool alloc_Audio_Stream_Basic_Description_With_FormatID:kAudioFormatLinearPCM
                                                                                           mFormatFlags:(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved)
                                                                                            mSampleRate:rate
                                                                                       mFramesPerPacket:mFramesPerPacket
                                                                                      mChannelsPerFrame:channel
                                                                                        mBitsPerChannel:bit];
    
    OSStatus status = AudioUnitSetProperty(tt_audio_unit,
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
    status = AudioUnitSetProperty(tt_audio_unit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &outputCallBackStruct,
                                  sizeof(outputCallBackStruct));
    CheckError(status, "SetProperty EnableIO failure");
}

- (void)start
{
    if (tt_audio_unit == nil)
        [self initAudioUnitWithRate:self.rate bit:self.bit channel:self.channel];

    AudioOutputUnitStart(tt_audio_unit);
}

- (void)stop
{
    if (tt_audio_unit == nil)
        return;

    OSStatus status;
    status = AudioOutputUnitStop(tt_audio_unit);
    CheckError(status, "tt_audio_unit停止失败");
}

static OSStatus outputCallBackFun(    void *                            inRefCon,
                                  AudioUnitRenderActionFlags *    ioActionFlags,
                                  const AudioTimeStamp *            inTimeStamp,
                                  UInt32                            inBusNumber,
                                  UInt32                            inNumberFrames,
                                  AudioBufferList * __nullable    ioData)
{
    memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
    TTAudioPlayer *player = (__bridge TTAudioPlayer *)(inRefCon);
	
	AudioBuffer buffer = ioData->mBuffers[0];
	struct list_head *s,*n;
	int readLen=0;
	
	pthread_mutex_lock(&player->tt_audio_frame_packageList_Lock);
	list_for_each_safe(s, n, &player->mAudioFramePackageList) {
		AudioFramePackage *afp = list_entry(s, AudioFramePackage, list);
		int copyLen = 0;
		copyLen = (afp->len-afp->read_pos) > (buffer.mDataByteSize-readLen) ? (buffer.mDataByteSize-readLen): (afp->len-afp->read_pos);
		memcpy((unsigned char*)(buffer.mData) + readLen, afp->data+afp->read_pos, copyLen);
		readLen += copyLen;
		afp->read_pos += copyLen;
		if (afp->read_pos >= afp->len) {
			list_del(&afp->list);
			free(afp);
		}
        else {
			break;
		}
	}
	pthread_mutex_unlock(&player->tt_audio_frame_packageList_Lock);
	buffer.mDataByteSize = readLen;
    return noErr;
}

- (int)playThisAudioData:(uint8_t *)audioData audioSize:(int)audioSize frameType:(int)frameType timestamp:(long)timestamp
{
	int j;
	if (tt_audio_unit == nil)
		return -1;
	if (audioData == NULL ||
        audioSize <= 0)
		return -1;
    
	static int16_t *pcmdata = NULL;
	static int pcmBufLen = 0;
	int pcm_len = 0;
	if (frameType == IPCNET_AUDIO_G711A) {
		pcm_len = audioSize*2;
		if(pcmBufLen < pcm_len){
			pcmBufLen = pcm_len;
			pcmdata = (int16_t *)realloc(pcmdata, pcmBufLen);
		}
		for(j = 0;j < audioSize; j++){
			pcmdata[j]=IPCNetALawDecode(audioData[j]);
		}
	}
    else if(frameType == IPCNET_AUDIO_G711U) {
		pcm_len = audioSize*2;
		if (pcmBufLen < pcm_len) {
			pcmBufLen = pcm_len;
			pcmdata = (int16_t *)realloc(pcmdata, pcmBufLen);
		}
		for(j = 0;j < audioSize; j++) {
			pcmdata[j]=IPCNetMuLawDecode(audioData[j]);
		}
	}
    else if(frameType == IPCNET_AUDIO_PCM) {
		pcm_len = audioSize;
		if(pcmBufLen<audioSize){
			pcmBufLen = audioSize;
			pcmdata = (int16_t *)realloc(pcmdata, pcmBufLen);
		}
		memcpy(pcmdata, audioData, pcm_len);
	}
    else {
		return -1;
	}
	
	AudioFramePackage*vfp = (AudioFramePackage*)malloc(sizeof(AudioFramePackage) + pcm_len);
	if (vfp == NULL) {
		return -1;
	}
	
	memset(vfp,0,sizeof(AudioFramePackage) + pcm_len);
	INIT_LIST_HEAD(&vfp->list);
	vfp->data = ((uint8_t*)vfp) + sizeof(AudioFramePackage);
	memcpy(vfp->data, pcmdata, pcm_len);
	vfp->type = IPCNET_AUDIO_PCM;
	vfp->timestamp = timestamp;
	vfp->len = pcm_len;
	pthread_mutex_lock(&tt_audio_frame_packageList_Lock);
	list_add_tail(&vfp->list, &mAudioFramePackageList);
	pthread_mutex_unlock(&tt_audio_frame_packageList_Lock);
	return audioSize;
}
@end

