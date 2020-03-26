//
//  TTBaseCell.m
//  SuperIPC
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "TTBaseCell.h"

@implementation TTBaseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIView *line  = [[UIView alloc] initWithFrame:CGRectMake(12, CGRectGetHeight(self.frame) - 1, SCREEN_WIDTH - 12, 1)];
    line.backgroundColor = [TTCommon ios13_systemColor:UIColor.lightGrayColor earlier_systemColoer:UIColorFromRGB(0xF5F5F5)];
    [self addSubview:line];
}

@end
