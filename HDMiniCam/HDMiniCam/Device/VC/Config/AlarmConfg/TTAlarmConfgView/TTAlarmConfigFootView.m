//
//  TTAlarmConfigFootView.m
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTAlarmConfigFootView.h"

@implementation TTAlarmConfigFootView

- (IBAction)btnAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickFootWith:)]) {
        [_delegate clickFootWith:self.tag - FLAG_TAG];
    }
}


@end
