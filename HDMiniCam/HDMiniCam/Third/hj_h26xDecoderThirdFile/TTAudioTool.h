
#import <Foundation/Foundation.h>
#import "TTAudioHeader.h"

@interface TTAudioTool : NSObject

+ (void)get_Audio_Property_With_filePath:(NSString *)filePath
                       
                           completeBlock:(void (^)(AudioFileID audioFileID,
                           
                                                   AudioStreamBasicDescription audioFileFormat,
                                               
                                                   UInt64 packetNums,
                                               
                                                   UInt64 maxFramesPerPacket,
                                               
                                                   UInt64 fileLengthFrames))completeBlock
                          
                              errorBlock:(void (^)(NSError *error))errorBlock;

+ (AudioStreamBasicDescription)alloc_Audio_Stream_Basic_Description_With_FormatID:(TTAudioFormatID)mFormatID
                                                               
                                                                     mFormatFlags:(TTAudioFormatFlags)mFormatFlags
                                                                      
                                                                      mSampleRate:(TTAudioRate)mSampleRate
                                                            
                                                                 mFramesPerPacket:(UInt32)mFramesPerPacket
                                                                
                                                                mChannelsPerFrame:(UInt32)mChannelsPerFrame
                                                             
                                                                  mBitsPerChannel:(UInt32)mBitsPerChannel;


+ (AudioComponentDescription)alloc_Audio_Component_Description_With_ComponentType:(OSType)componentType

                                                                 componentSubType:(OSType)componentSubType

                                                              
                                                                   componentFlags:(UInt32)componentFlags

                                                               componentFlagsMask:(UInt32)componentFlagsMask;

@end

