//
//  KHJWiFiVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/23.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJWiFiVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface KHJWiFiVC ()
{
    
}
@end

@implementation KHJWiFiVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchSSIDInfo];
    self.titleLab.text = KHJLocalizedString(@"配置网络", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    CLog(@"ifs = %@",ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        NSString *SSIDString =[(NSDictionary *)info objectForKey:@"SSID"];
        [self saveSSID:SSIDString];
        if (info && [info count]) {
            break;
        }
    }
}

- (void)saveSSID:(NSString *)ssid
{
    CLog(@"ssid == %@", ssid);
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn:(UIButton *)sender
{
    if (sender.tag == 10) {
        CLog(@"切换网络");
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[self prefsUrlWithQuery:@{@"root": @"WIFI"}]];
        }
        else {
            if ([[UIApplication sharedApplication] canOpenURL:[self prefsUrlWithQuery:@{@"root": @"WIFI"}]]) {
                [[UIApplication sharedApplication] openURL:[self prefsUrlWithQuery:@{@"root": @"WIFI"}]];
            }
        }
    }
    else if (sender.tag == 20) {
        CLog(@"显示/隐藏密码");
    }
    else if (sender.tag == 30) {
        CLog(@"下一步");
    }
}

- (NSURL *)prefsUrlWithQuery:(NSDictionary *)query
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:@"QXBwLVByZWZz" options:0];
    NSString *scheme = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableString *url = [NSMutableString stringWithString:scheme];
    for (int i = 0; i < query.allKeys.count; i ++) {
        NSString *key = [query.allKeys objectAtIndex:i];
        NSString *value = [query valueForKey:key];
        [url appendFormat:@"%@%@=%@", (i == 0 ? @":" : @"?"), key, value];
    }
    return [NSURL URLWithString:url];
}

@end
