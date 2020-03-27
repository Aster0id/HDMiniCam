//
//  TTDeviceSingleDayCell.m
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDeviceSingleDayCell.h"

@implementation TTDeviceSingleDayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)btnAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(chooseItemWith:)]) {
        [_delegate chooseItemWith:self.tag - FLAG_TAG];
    }
}

- (IBAction)delelte:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteItemWith:)]) {
        [_delegate deleteItemWith:self.tag - FLAG_TAG];
    }
}

@end
