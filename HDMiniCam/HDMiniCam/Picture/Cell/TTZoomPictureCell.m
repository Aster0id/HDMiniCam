//
//  TTZoomPictureCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTZoomPictureCell.h"

@implementation TTZoomPictureCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
}

- (void)setImagePath:(NSString *)imagePath
{
    TLog(@"imagePath = %@",imagePath);
    _imagePath = imagePath;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (_delegate && [_delegate respondsToSelector:@selector(longPressWith:)]) {
            [_delegate longPressWith:_imagePath];
        }
    }
}

- (IBAction)chooseIcon:(id)sender
{
    if (_block) {
        _block(_imagePath);
    }
}

@end
