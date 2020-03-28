//
//  TTWIFIConfigCell.m
//  SuperIPC
//
//  Created by 王涛 on 2020/1/19.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "TTWIFIConfigCell.h"

@implementation TTWIFIConfigCell

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
    if (_delegate && [_delegate respondsToSelector:@selector(chooseWifiWith:)]) {
        [_delegate chooseWifiWith:self.tag - FLAG_TAG];
    }
}

@end
