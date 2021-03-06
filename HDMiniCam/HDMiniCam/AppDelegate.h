//
//  AppDelegate.h
//  SuperIPC
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

/**
 0324
 1、新增分享
 2、新增报警设置
 3、新增网络监测
 */

#import <UIKit/UIKit.h>
#import "TTabBarBaseViewController.h"

// IPCA000015WAABW 84567
// IPCA000002AINYZ admin
// IPCA000008GAIWC admin
// IPCA000003TCGNB admin

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL canLandscape;
@property (strong, nonatomic) TTabBarBaseViewController *rootTabBarVC;

@end

