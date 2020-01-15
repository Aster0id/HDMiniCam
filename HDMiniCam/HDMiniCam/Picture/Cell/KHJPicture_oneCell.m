//
//  KHJPicture_oneCell.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJPicture_oneCell.h"

@implementation KHJPicture_oneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)chooseIcon:(id)sender {
    if (_block) {
        _block(self.tag - FLAG_TAG);
    }
}

@end
