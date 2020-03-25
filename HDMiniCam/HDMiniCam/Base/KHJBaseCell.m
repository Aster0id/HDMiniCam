//
//  KHJBaseCell.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

@implementation KHJBaseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *aaaa  = [[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetHeight(self.frame) - 1, SCREEN_WIDTH - 12, 1)];
    aaaa.backgroundColor = [TTCommon ios13_systemColor:UIColor.lightGrayColor earlier_systemColoer:UIColorFromRGB(0xF5F5F5)];
    [self addSubview:aaaa];
}

- (UIView *)lineView
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetHeight(self.frame), SCREEN_WIDTH - 12, 1)];
    lineView.backgroundColor = [TTCommon ios13_systemColor:UIColor.lightGrayColor earlier_systemColoer:UIColorFromRGB(0xF5F5F5)];
    return lineView;
}


@end
