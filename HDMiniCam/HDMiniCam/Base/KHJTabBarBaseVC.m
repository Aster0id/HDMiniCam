//
//  KHJTabBarBaseVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJTabBarBaseVC.h"

@interface KHJTabBarBaseVC ()

@end

@implementation KHJTabBarBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:0 forKey:KHJNaviBarItemIndexKey];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        /* 广告页通知 */
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive_Adv_Message:)
//                                                     name:KDidReceiveRemoteNotificationFrom_Adv_Key
//                                                   object:nil];
    });
}

/* 接收到 - 广告 - 消息（MQTT） */
- (void)receive_Adv_Message:(NSNotification *)note
{
    NSDictionary *info = (NSDictionary *)note.object;
//    if (![SaveManager.isLogined boolValue]) {
//        TLog(@"当前未登陆！！！！！！！！！！");
//        return;
//    }
    NSString *address = info[@"address"];
    NSString *slogan = info[@"slogan"];
    
    TLog(@"address = %@",address);
    TLog(@"slogan = %@",slogan);
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self handleImageUrl:address];
    });
}

/* 广告页保存到本地，下次请求对比，先加载本地，请求后对比刷新 */
- (void)handleImageUrl:(NSString *)imgUrl
{
//    NSURL *imageURL = [NSURL URLWithString:imgUrl];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//    if (imageData && imageData.length > 0) {
//        TLog(@"更新广告页面");
//        [self saveImageToLocal:imageData withPath:imgUrl];
//    }
//    else {
//        TLog(@"更新广告页面失败");
//    }
}

/* 保存下载图片同时删除掉之前的图片 */
- (void)saveImageToLocal:(NSData *)imgData withPath:(NSString *)urlStr
{
//    NSString *preImgUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kAdv_AdvImage_Key];
//    NSString *newImgName = [[urlStr componentsSeparatedByString:@"/"] lastObject];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *path_document = NSHomeDirectory();
//    NSString *pString = [NSString stringWithFormat:@"/Documents/adv"];
//
//    NSString *imagePath = [path_document stringByAppendingString:pString];
//    BOOL existed = [fileManager fileExistsAtPath:imagePath];
//    if (!existed) {
//        [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];  // 创建路径
//    }
//    imagePath = [imagePath stringByAppendingString:[NSString stringWithFormat:@"/%@",newImgName]];
//    BOOL success = [imgData writeToFile:imagePath atomically:YES];
//    if (success) {
//        TLog(@"保存成功!");
//    }
//    else {
//        TLog(@"保存失败!");
//    }
//
//    /* 保存新的广告页 */
//    [[NSUserDefaults standardUserDefaults] setObject:urlStr forKey:kAdv_AdvImage_Key];
//    if (!preImgUrl ||(preImgUrl && [preImgUrl isEqualToString:urlStr])) {
//        return;
//    }
//
//    /* 删除旧的广告页 */
//    NSString *preImgName = [[preImgUrl componentsSeparatedByString:@"/"] lastObject];
//    pString = [NSString stringWithFormat:@"/Documents/adv/%@",preImgName];
//    imagePath = [path_document stringByAppendingString:pString];
//    if ([fileManager fileExistsAtPath:imagePath]) {
//        /* 查询文件是否存在 */
//        BOOL isSuccess = [fileManager removeItemAtPath:imagePath error:nil];
//        if (isSuccess) {
//            TLog(@"删除成功!");
//        }
//        else {
//            TLog(@"删除失败!");
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger inNum = [tabBar.items indexOfObject:item];
    TLog(@"item tag = %ld", (long)inNum);
    [[NSUserDefaults standardUserDefaults] setInteger:inNum forKey:KHJNaviBarItemIndexKey];
    
}
- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];

}


@end









