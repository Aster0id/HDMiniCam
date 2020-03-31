//
//  TTDeviceListCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDeviceListCell.h"

@implementation TTDeviceListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btn1:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(gotoVideoWithIndex:)]){
        [_delegate gotoVideoWithIndex:self.deviceID];
    }
}

- (IBAction)btn2:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(gotoSetupWithIndex:)]) {
        [_delegate gotoSetupWithIndex:self.deviceID];
    }
}

@end
