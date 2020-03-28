//
//  TTAlarmConfigCollectionCell.m
//  SuperIPC
//
//  Created by kevin on 2020/3/24.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTAlarmConfigCollectionCell.h"

@implementation TTAlarmConfigCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)btnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundColor:UIColorFromRGB(0x34C42E)];
    }
    else {
        [sender setBackgroundColor:UIColor.clearColor];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(clickCellWith:select:)]) {
        [_delegate clickCellWith:self.tag - FLAG_TAG select:sender.selected];
    }
}

@end
