//
//  KHJRecordListCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJRecordListCell.h"

@implementation KHJRecordListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (IBAction)content:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(contentWith:)]) {
        [_delegate contentWith:self.tag - FLAG_TAG];
    }
}

@end
