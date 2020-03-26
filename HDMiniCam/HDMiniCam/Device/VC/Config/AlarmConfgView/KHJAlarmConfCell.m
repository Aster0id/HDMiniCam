//
//  KHJAlarmConfCell.m
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJAlarmConfCell.h"

@implementation KHJAlarmConfCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickAlarmAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickWith:)]) {
        [_delegate clickWith:self.tag - FLAG_TAG];
    }
}


@end
