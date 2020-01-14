//
//  NAVVController.m
//  KHJCamera
//
//  Created by hezewen on 2018/6/15.
//  Copyright © 2018年 khj. All rights reserved.
//

#import "NAVVController.h"

@interface NAVVController ()

@end

@implementation NAVVController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *navBar = self.navigationBar;
    if (@available(iOS 10.0, *)) {
        UIImage *image = [UIImage imageNamed:@"bgN"];
        [navBar setTranslucent:false];
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    else {
        UIImage *image = [self imageFromColor:KHJUtility.appMainColor withSize:CGSizeMake(SCREEN_WIDTH, 64)];
        [navBar setTranslucent:false];
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [navBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
}

- (nullable UIImage *)imageFromColor:(nonnull UIColor *)color withSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
//    [self setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}
@end
