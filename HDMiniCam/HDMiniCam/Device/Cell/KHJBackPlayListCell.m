//
//  KHJBackPlayListCell.m
//  HDMiniCam
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBackPlayListCell.h"

@implementation KHJBackPlayListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btn:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(chooseItemWith:)]) {
        [_delegate chooseItemWith:self.tag - FLAG_TAG];
    }
}

@end
