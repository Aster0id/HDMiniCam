//
//  TTAllDeviceCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTAllDeviceCell.h"

@implementation TTAllDeviceCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)content:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(chooseDeviceWithRow:)]) {
        [_delegate chooseDeviceWithRow:self.tag - FLAG_TAG];
    }
}

@end
