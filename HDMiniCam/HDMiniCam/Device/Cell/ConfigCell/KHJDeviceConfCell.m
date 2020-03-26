//
//  KHJDeviceConfCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJDeviceConfCell.h"

@implementation KHJDeviceConfCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btn:(id)sender {
    if (_block) {
        _block(self.tag - FLAG_TAG);
    }
}

@end
