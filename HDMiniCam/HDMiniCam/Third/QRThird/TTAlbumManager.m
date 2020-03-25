
#import "TTAlbumManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIImage+SGImageSize.h"

@interface TTAlbumManager ()
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) NSString *detectorString;
@end

@implementation TTAlbumManager

+ (instancetype)sharedManager
{
    static TTAlbumManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTAlbumManager alloc] init];
    });
    return manager;
}

- (void)initialization
{
    _isOpenLog = YES;
}

- (void)readCurrentController:(UIViewController *)currentController
{
    [self initialization];
    self.currentVC = currentController;
    
    if (currentController == nil) {
        @throw [NSException exceptionWithName:@"SGQRCode" reason:@"readCurrentController: 方法中的 currentController 参数不能为空" userInfo:nil];
    }
    
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    
                    self.isPHAuthorization = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self enterImagePickerController];
                    });
                    if (self.isOpenLog) {
                        NSLog(@"用户第一次同意了访问相册权限 - - %@", [NSThread currentThread]);
                    }
                } else {
                    
                    if (self.isOpenLog) {
                        NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }
            }];
            
        }
        else if (status == PHAuthorizationStatusAuthorized) {
            
            self.isPHAuthorization = YES;
            if (self.isOpenLog) {
                NSLog(@"访问相机权限 - - %@", [NSThread currentThread]);
            }
            [self enterImagePickerController];
        }
        else if (status == PHAuthorizationStatusDenied) {
            
            [self enterImagePickerController];
        }
        else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"tips", nil) message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:KHJLocalizedString(@"commit", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self.currentVC presentViewController:alertC animated:YES completion:nil];
        }
    }
}

- (void)enterImagePickerController
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self.currentVC presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.currentVC dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumManagerDidCancelWithImagePickerController:)]) {
        [self.delegate AlbumManagerDidCancelWithImagePickerController:self];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [UIImage SG_imageSizeWithScreenImage:info[UIImagePickerControllerOriginalImage]];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count == 0) {
        if (self.isOpenLog) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumManagerDidReadQRCodeFailure:)]) {
                [self.delegate AlbumManagerDidReadQRCodeFailure:self];
            }
        }
        [self.currentVC dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    else {
        for (int index = 0; index < [features count]; index ++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            if (self.isOpenLog) {
                NSLog(@"相册中读取二维码数据信息 - - %@", resultStr);
            }
            self.detectorString = resultStr;
        }
        [self.currentVC dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumManager:didFinishPickingMediaWithResult:)]) {
                [self.delegate AlbumManager:self didFinishPickingMediaWithResult:self.detectorString];
            }
        }];
    }
}

- (void)setIsOpenLog:(BOOL)isOpenLog
{
    _isOpenLog = isOpenLog;
}


@end

