//
//  KHJAlarmConfHeadView.m
//  HDMiniCam
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAlarmConfHeadView.h"

@implementation KHJAlarmConfHeadView

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (IBAction)switchBtnAction:(UISwitch *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickHeadWith:)]) {
        [_delegate clickHeadWith:self.tag - FLAG_TAG];
    }
}

@end
