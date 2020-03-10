//
//  AppDelegate.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KHJTabBarBaseVC.h"
// IPCA000015WAABW 84567
// IPCA000002AINYZ admin
// IPCA000008GAIWC admin

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) KHJTabBarBaseVC *tabVControll;

/*
 是否允许转向
 */
@property (nonatomic,assign) BOOL setTurnScreen;

@end

