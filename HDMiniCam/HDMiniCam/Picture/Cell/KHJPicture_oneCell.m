//
//  KHJPicture_oneCell.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJPicture_oneCell.h"

@implementation KHJPicture_oneCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(longPressWith:)]) {
            [_delegate longPressWith:self.path];
        }
    }
}

- (IBAction)chooseIcon:(id)sender
{
    if (_block) {
        _block(self.path);
    }
}

@end
