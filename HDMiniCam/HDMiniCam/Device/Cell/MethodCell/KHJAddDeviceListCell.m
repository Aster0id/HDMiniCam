//
//  KHJAddDeviceListCell.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/18.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAddDeviceListCell.h"

@implementation KHJAddDeviceListCell

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
    if (_block) {
        _block(self.tag - FLAG_TAG);
    }
}

@end
