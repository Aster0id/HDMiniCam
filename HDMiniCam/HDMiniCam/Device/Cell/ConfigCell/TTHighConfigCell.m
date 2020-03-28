//
//  TTHighConfigCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTHighConfigCell.h"

@implementation TTHighConfigCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)action:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickWithCell:)]) {
        [_delegate clickWithCell:self.tag - FLAG_TAG];
    }
}

@end
