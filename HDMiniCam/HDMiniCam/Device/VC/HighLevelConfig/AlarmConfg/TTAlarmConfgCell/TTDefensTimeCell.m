//
//  TTDefensTimeCell.m
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDefensTimeCell.h"

@implementation TTDefensTimeCell

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
    if (_delegate && [_delegate respondsToSelector:@selector(closeWithSection:row:)]) {
        [_delegate closeWithSection:self.section row:self.tag - FLAG_TAG];
    }
}

@end
