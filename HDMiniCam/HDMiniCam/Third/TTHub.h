
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface TTHub : NSObject

@property (nonatomic,strong) MBProgressHUD *hud;

+ (TTHub *)shareHub;
- (void)showText:(NSString *)string addToView:(UIView *)view;
- (void)showText:(NSString *)string addToView:(UIView *)view type:(int)type;

@end
