//
//  FKHJBaseVC.m
//  KHJCamera
//
//  Created by khj888 on 2019/2/20.
//  Copyright © 2019 FKHJ. All rights reserved.
//

#import "FKHJBaseVC.h"

@interface FKHJBaseVC ()



@end

@implementation FKHJBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UIButton *)leftBtn
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 66, 44);
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    [leftBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = barBut;
    return leftBtn;
}

- (UILabel *)titleLab
{
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, SCREEN_WIDTH - 160, 44)];
    titleLab.font = [UIFont systemFontOfSize:17];
//    titleLab.textColor = UIColorFromRGB(0x333333);
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLab;
    return titleLab;
}

- (UIButton *)rightBtn
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 66, 44);
    rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    UIBarButtonItem  *barBut = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barBut;
    return rightBtn;
}


@end
