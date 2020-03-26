
#import "TTAudioTool.h"

@implementation TTAudioTool

+ (void)get_Audio_Property_With_filePath:(NSString *)filePath



                           completeBlock:(void (^)(AudioFileID audioFileID,
                                                   
                                                   AudioStreamBasicDescription audioFileFormat,

                                                   UInt64 packetNums,
                                               
                                                   UInt64 maxFramesPerPacket,
                                               
                                                   
                                                   UInt64 fileLengthFrames))completeBlock
                          
                              
                              errorBlock:(void (^)(NSError *error))errorBlock
{
    NSError *error;
    UInt64 packetNums = 0;
    AudioFileID audioFileID;
    UInt64 maxFramesPerPacket = 0;
    AudioStreamBasicDescription audioFileFormat = {};
    NSURL *url = [NSURL fileURLWithPath:filePath];
    OSStatus status = AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFileID);
    if (status != noErr) {
        error = [NSError errorWithDomain:@"打开文件失败" code:1008601 userInfo:nil];
        if (errorBlock)
            errorBlock(error);
        return;
    }
    
    uint32_t size = sizeof(AudioStreamBasicDescription);
    status = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &size, &audioFileFormat);
    if (status != noErr) {
        error = [NSError errorWithDomain:[NSString stringWithFormat:@"读取文件格式出错，error status %d", (int)status] code:1008602 userInfo:nil];
        if (errorBlock)
            errorBlock(error);

        return;
    }
    
    //读取文件总的packet数量
    size = sizeof(packetNums);
    status = AudioFileGetProperty(audioFileID,
                                  kAudioFilePropertyAudioDataPacketCount,
                                  &size,
                                  &packetNums);
    if (error != noErr) {
        error = [NSError errorWithDomain:[NSString stringWithFormat:@"读取文件packets总数出错，error status %d", (int)status] code:1008603 userInfo:nil];
        if (errorBlock)
            errorBlock(error);

        return;
    }
    
    // 读取单个packet的最大帧数
    maxFramesPerPacket = audioFileFormat.mFramesPerPacket;
    
    if (maxFramesPerPacket == 0) {
        size = sizeof(maxFramesPerPacket);
        status = AudioFileGetProperty(audioFileID, kAudioFilePropertyMaximumPacketSize, &size, &maxFramesPerPacket);
        if (status != noErr) {
            error = [NSError errorWithDomain:[NSString stringWithFormat:@"读取单个packet的最大数量出错，error status %d", (int)status] code:1008604 userInfo:nil];
            if (errorBlock)
                errorBlock(error);
            return;
        }
        if (status == noErr && maxFramesPerPacket == 0) {
            error = [NSError errorWithDomain:@"AudioFileGetProperty error or sizePerPacket = 0" code:1008605 userInfo:nil];
            if (errorBlock)
                errorBlock(error);
            return;
        }
    }
    
    UInt64 numFrames = maxFramesPerPacket * packetNums;
    AudioFileClose(audioFileID);
    if (completeBlock)
        completeBlock(audioFileID,audioFileFormat,packetNums,maxFramesPerPacket,numFrames);
}

+ (AudioStreamBasicDescription)alloc_Audio_Stream_Basic_Description_With_FormatID:(TTAudioFormatID)mFormatID
                                                                  
                                                                     mFormatFlags:(TTAudioFormatFlags)mFormatFlags
                                                                     
                                                                      mSampleRate:(TTAudioRate)mSampleRate
                                                                 
                                                                 mFramesPerPacket:(UInt32)mFramesPerPacket
                                                                
                                                                
                                                                mChannelsPerFrame:(UInt32)mChannelsPerFrame
                                                                
                                                                  mBitsPerChannel:(UInt32)mBitsPerChannel
{
    AudioStreamBasicDescription _outputFormat;
    memset(&_outputFormat, 0, sizeof(_outputFormat));


    _outputFormat.mFormatID         = mFormatID;

    _outputFormat.mSampleRate       = mSampleRate;

    _outputFormat.mFormatFlags      = mFormatFlags;

    _outputFormat.mBitsPerChannel   = mBitsPerChannel;

    _outputFormat.mFramesPerPacket  = mFramesPerPacket;
    _outputFormat.mChannelsPerFrame = mChannelsPerFrame;

    _outputFormat.mBytesPerFrame    = mBitsPerChannel * mChannelsPerFrame / 8;


    _outputFormat.mBytesPerPacket   = mBitsPerChannel * mChannelsPerFrame / 8 * mFramesPerPacket;

    return _outputFormat;


}

+ (AudioComponentDescription)alloc_Audio_Component_Description_With_ComponentType:(OSType)componentType componentSubType:(OSType)componentSubType componentFlags:(UInt32)componentFlags componentFlagsMask:(UInt32)componentFlagsMask
{
    AudioComponentDescription outputDesc;
    outputDesc.componentType = componentType;
    outputDesc.componentSubType = componentSubType;
    outputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDesc.componentFlags = componentFlags;
    outputDesc.componentFlagsMask = componentFlagsMask;
    return outputDesc;
}
@end
