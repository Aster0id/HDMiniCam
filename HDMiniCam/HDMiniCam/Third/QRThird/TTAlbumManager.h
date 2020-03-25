
#import <UIKit/UIKit.h>
@class TTAlbumManager;

@protocol TTAlbumDelegate <NSObject>

@required
- (void)AlbumManagerDidCancelWithImagePickerController:(TTAlbumManager *)albumManager;
- (void)AlbumManager:(TTAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result;
- (void)AlbumManagerDidReadQRCodeFailure:(TTAlbumManager *)albumManager;
@end

@interface TTAlbumManager : NSObject

+ (instancetype)sharedManager;
@property (nonatomic, weak) id<TTAlbumDelegate> delegate;
@property (nonatomic, assign) BOOL isOpenLog;
@property (nonatomic, assign) BOOL isPHAuthorization;
- (void)readCurrentController:(UIViewController *)currentController;

@end
