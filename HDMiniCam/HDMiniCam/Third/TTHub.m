
#import "TTHub.h"
#import "MBProgressHUD.h"

@implementation TTHub

@synthesize hud;

+ (TTHub *)shareHub
{
    static TTHub *hub = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hub = [[TTHub alloc] init];
    });
    return hub;
}

- (void)showText:(NSString *)string addToView:(UIView *)view
{
    if (!self.hud.hidden) {
        self.hud.hidden = YES;
    }
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.detailsLabel.text = string;
    self.hud.detailsLabel.font = [UIFont boldSystemFontOfSize:14];
    self.hud.detailsLabel.numberOfLines = 2;
    self.hud.margin = 10.f;
    self.hud.removeFromSuperViewOnHide = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hud.hidden = YES;
    });
}

- (void)showText:(NSString *)string addToView:(UIView *)view type:(int)type
{
    if (self.hud.hidden == NO) {
        self.hud.hidden = YES;
    }
    self.hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [self.hud.superview bringSubviewToFront:self.hud];

    self.hud.hidden             = NO;
    self.hud.mode               = MBProgressHUDModeIndeterminate;
    self.hud.bezelView.style    = MBProgressHUDBackgroundStyleSolidColor;
    
    if (type == 0) {
        hud.contentColor                = [UIColor blackColor];
        hud.bezelView.backgroundColor   = UIColor.clearColor;
    }
    else if (type == 1) {
        hud.detailsLabel.text           = string;
        hud.contentColor                = [UIColor whiteColor];
        hud.bezelView.backgroundColor   = [UIColor lightGrayColor];
    }
}

@end









