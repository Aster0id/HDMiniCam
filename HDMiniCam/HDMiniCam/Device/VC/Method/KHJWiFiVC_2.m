//
//  KHJWiFiVC_2.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/28.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJWiFiVC_2.h"

@interface KHJWiFiVC_2 ()

@end

@implementation KHJWiFiVC_2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"cfgNet_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
