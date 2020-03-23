//
//  KHJDefensTimeCell.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDefensTimeCell.h"

@implementation KHJDefensTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)closeBtnAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(closeWith:)]) {
        [_delegate closeWith:self.tag - FLAG_TAG];
    }
}

@end
