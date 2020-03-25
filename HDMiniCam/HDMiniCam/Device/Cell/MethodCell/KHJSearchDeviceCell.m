//
//  KHJSearchDeviceCell.m
//  HDMiniCam
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJSearchDeviceCell.h"

@implementation KHJSearchDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)btn:(id)sender {
    if (_block) {
        _block(self.tag - FLAG_TAG);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
