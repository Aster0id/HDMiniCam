//
//  KHJlampConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJlampConfigVC.h"

@interface KHJlampConfigVC ()
{
    
}
@end

@implementation KHJlampConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"杂项设置", nil);
    [self.leftBtn addTarget:self action:@selector(backActon) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backActon
{
    [self.navigationController popViewControllerAnimated:YES];
}
    
- (IBAction)sbtn:(UISwitch *)sender
{
    if (sender.tag == 10) {
        TLog(@"红外灯");
    }
    else if (sender.tag == 20) {
        TLog(@"工作指示灯");
    }
}

- (IBAction)btn:(UIButton *)sender
{
    if (sender.tag == 10) {
        TLog(@"确定");
    }
    else if (sender.tag == 20) {
        TLog(@"取消");
    }
}


@end
