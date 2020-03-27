//
//  TTDeviceAllDayCell.m
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTDeviceAllDayCell.h"
#import "TTFileManager.h"

@implementation TTDeviceAllDayCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setDeviceID:(NSString *)deviceID
{
    NSString *imagePath     = [[[TTFileManager sharedModel] getScreenShotWithDeviceID:deviceID] stringByAppendingPathComponent:TTStr(@"%@.png",self.date)];
    self.picImgView.image   = [UIImage imageWithContentsOfFile:imagePath];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(chooseDateWith:)]) {
        [_delegate chooseDateWith:self.tag - FLAG_TAG];
    }
}

@end
