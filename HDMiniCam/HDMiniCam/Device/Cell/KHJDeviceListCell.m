//
//  KHJDeviceListCell.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDeviceListCell.h"

@implementation KHJDeviceListCell

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
        [_delegate gotoVideoWithIndex:self.tag - FLAG_TAG];
    }
}

- (IBAction)btn2:(id)sender{
    if (self.connected){
        if (_delegate && [_delegate respondsToSelector:@selector(gotoSetupWithIndex:)]) {
            [_delegate gotoSetupWithIndex:self.tag - FLAG_TAG];
        }
    }
    else {
        if (_delegate && [_delegate respondsToSelector:@selector(reConnectWithIndex:)]) {
            [_delegate reConnectWithIndex:self.tag - FLAG_TAG];
        }
    }
}

@end
