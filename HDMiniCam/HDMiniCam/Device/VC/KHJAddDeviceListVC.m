//
//  KHJAddDeviceListVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAddDeviceListVC.h"
#import "KHJSearchDeviceVC.h"
#import "KHJOnlineVC.h"

@interface KHJAddDeviceListVC ()
{
    
    
}
@end

@implementation KHJAddDeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"添加设备", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hand:(id)sender {
    KHJSearchDeviceVC *vc = [[KHJSearchDeviceVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)online:(id)sender {
    KHJOnlineVC *vc = [[KHJOnlineVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)wifi:(id)sender {
}

@end
