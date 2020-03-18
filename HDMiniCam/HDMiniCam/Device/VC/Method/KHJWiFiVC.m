//
//  KHJWiFiVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/23.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJWiFiVC.h"
#import "KHJWiFiVC_2.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface KHJWiFiVC ()
{
    __weak IBOutlet UITextField *accountTF;
    __weak IBOutlet UITextField *passwordTF;
    
}
@end

@implementation KHJWiFiVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"cfgNet_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchSSIDInfo];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
    accountTF.text = ssid;
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
        passwordTF.secureTextEntry = !passwordTF.secureTextEntry;
    }
    else if (sender.tag == 30) {
        KHJWiFiVC_2 *vc = [[KHJWiFiVC_2 alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
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
