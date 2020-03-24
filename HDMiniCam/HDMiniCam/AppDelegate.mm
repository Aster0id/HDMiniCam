//
//  AppDelegate.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "AppDelegate.h"
#import "KHJDeviceListVC.h"
#import "KHJBaseNavigationController.h"
#import "KHJPictureListVC.h"
#import "KHJRecordListVC.h"
#import "KHJAlarmListVC.h"
#import "KHJVideoPlayer_hf_VC.h"
#pragma mark - ios13 开启地理位置权限，获取Wi-Fi名称
#import <CoreLocation/CoreLocation.h>
#import "KHJDeviceManager.h"
#import "KHJDataBase.h"
//
#import "AFNetworkReachabilityManager.h"

@interface AppDelegate ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #pragma mark - 启动时，调动底层
    KHJDataBase *db = [KHJDataBase sharedDataBase];
    [db initDataBase];
    NSArray *list = [[KHJDataBase sharedDataBase] getAllDeviceInfo];
    for (int i = 0; i < list.count; i++) {
        KHJDeviceInfo *info = [[KHJDeviceInfo alloc] init];
        info = list[i];
        [[KHJDeviceManager sharedManager] connect_with_deviceID:info.deviceID password:info.devicePassword resultBlock:^(NSInteger code) {}];
    }

    // 如果是iOS13 未开启地理位置权限 需要提示一下
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 13) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self initHomeView];
    
    [self checkNetworking];
    return YES;
}

- (void)initHomeView
{
    //三个导航栏控制器，注意标题问题
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.tabVControll) {
        [UIApplication sharedApplication].delegate.window.rootViewController = nil;
        appDelegate.tabVControll = nil;
    }
    KHJTabBarBaseVC * tabbar = [[KHJTabBarBaseVC alloc] init];
    appDelegate.tabVControll = tabbar;//关闭横屏仅允许竖屏
    
    KHJDeviceListVC *vc1 = [[KHJDeviceListVC alloc] init];
    KHJBaseNavigationController *deviceListNavi = [[KHJBaseNavigationController  alloc] initWithRootViewController:vc1];
    deviceListNavi.tabBarItem.title = KHJLocalizedString(@"vide_", nil);
    
    KHJPictureListVC *vc2 = [[KHJPictureListVC alloc] init];
    KHJBaseNavigationController *pictureNavi = [[KHJBaseNavigationController  alloc] initWithRootViewController:vc2];
    pictureNavi.tabBarItem.title = KHJLocalizedString(@"pic_", nil);
    
    KHJRecordListVC *vc3 = [[KHJRecordListVC alloc] init];
    KHJBaseNavigationController *recordNavi = [[KHJBaseNavigationController  alloc] initWithRootViewController:vc3];
    recordNavi.tabBarItem.title = KHJLocalizedString(@"recrd_", nil);
    
//    KHJAlarmListVC *vc4 = [[KHJAlarmListVC alloc] init];
//    KHJBaseNavigationController *alarmListNavi = [[KHJBaseNavigationController  alloc] initWithRootViewController:vc4];
//    alarmListNavi.tabBarItem.title = KHJLocalizedString(@"报警", nil);

    [deviceListNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:KHJUtility.appMainColor}
                                             forState:UIControlStateSelected];
    [deviceListNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blackColor}
                                             forState:UIControlStateNormal];
    
    [pictureNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:KHJUtility.appMainColor}
                                          forState:UIControlStateSelected];
    [pictureNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blackColor}
                                          forState:UIControlStateNormal];
    
    [recordNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:KHJUtility.appMainColor}
                                         forState:UIControlStateSelected];
    [recordNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blackColor}
                                         forState:UIControlStateNormal];
    
//    [alarmListNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:KHJUtility.appMainColor,}
//                                            forState:UIControlStateSelected];
//    [alarmListNavi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blackColor,}
//                                            forState:UIControlStateNormal];
    
//    [tabbar setViewControllers:@[deviceListNavi, pictureNavi, recordNavi, alarmListNavi]];
    [tabbar setViewControllers:@[deviceListNavi, pictureNavi, recordNavi]];

    //设置tabar图像
    pictureNavi.tabBarItem.image = [KHJIMAGE(@"picture_n") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    pictureNavi.tabBarItem.selectedImage = [KHJIMAGE(@"picture_s") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
    recordNavi.tabBarItem.image = [KHJIMAGE(@"record_n") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    recordNavi.tabBarItem.selectedImage = [KHJIMAGE(@"record_s") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    alarmListNavi.tabBarItem.image = [KHJIMAGE(@"alarm_n") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    alarmListNavi.tabBarItem.selectedImage = [KHJIMAGE(@"alarm_s") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    deviceListNavi.tabBarItem.image = [KHJIMAGE(@"video_n") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    deviceListNavi.tabBarItem.selectedImage = [KHJIMAGE(@"video_s") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = appDelegate.tabVControll;
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 监听手机 “横屏、竖屏” 状态

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.setTurnScreen)  {
        /* 横屏 */
        return UIInterfaceOrientationMaskLandscape;
    }
    else {
        /* 竖屏 */
        return UIInterfaceOrientationMaskPortrait;
    }
}

// 是否支持设备自动旋转

- (BOOL)shouldAutorotate
{
    if (self.setTurnScreen == YES) {
        //为1的话,支持旋转
        return YES;
    }
    return NO;
}

- (void)checkNetworking
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                CLog(@"---------------------------------------------------- 未知网络");
                break;
            case 0:
                CLog(@"---------------------------------------------------- 网络不可达");
                break;
            case 1:
                CLog(@"---------------------------------------------------- GPRS网络");
                break;
            case 2:
                CLog(@"---------------------------------------------------- wifi网络");
                break;
            default:
                break;
        }
        if (status == AFNetworkReachabilityStatusReachableViaWWAN
           || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            CLog(@"有网");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"netStateChange" object:@"手机有网络"];
        }
        else {
            CLog(@"没网");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"netStateChange" object:@"手机无网络"];
        }
    }];
}

@end
