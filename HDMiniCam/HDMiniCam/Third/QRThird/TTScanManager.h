
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class TTScanManager;

@protocol TTScanManagerDelegate <NSObject>

@required
- (void)QRCodeScanManager:(TTScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects;
@optional
- (void)QRCodeScanManager:(TTScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue;
@end
@interface TTScanManager : NSObject
+ (instancetype)sharedManager;
@property (nonatomic, weak) id<TTScanManagerDelegate> delegate;
- (void)setupSessionPreset:(NSString *)sessionPreset metadataObjectTypes:(NSArray *)metadataObjectTypes currentController:(UIViewController *)currentController;
- (void)startRunning;
- (void)stopRunning;
- (void)videoPreviewLayerRemoveFromSuperlayer;
- (void)playSoundName:(NSString *)name;
- (void)resetSampleBufferDelegate;
- (void)cancelSampleBufferDelegate;

@end

