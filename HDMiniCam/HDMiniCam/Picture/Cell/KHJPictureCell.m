//
//  KHJPictureCell.m
//  HDMiniCam
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJPictureCell.h"

@implementation KHJPictureCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self inits];
    }
    return self;
}

- (void)inits
{
    _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _image.backgroundColor = UIColor.blueColor;
    [self addSubview:_image];
    
    _lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _lab.textColor = UIColor.blackColor;
    _lab.backgroundColor = UIColor.clearColor;
    [self addSubview:_lab];
    
}

@end
