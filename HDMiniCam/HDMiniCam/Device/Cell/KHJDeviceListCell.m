//
//  KHJDeviceListCell.m
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJDeviceListCell.h"

@implementation KHJDeviceListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDeviceID:(NSString *)deviceID
{
    _deviceID = deviceID;
    NSString *path_document = NSHomeDirectory();
    NSString *pString       = KHJString(@"/Documents/%@.png",deviceID);
    NSString *imagePath     = [path_document stringByAppendingString:pString];
    UIImage *image          = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        self.bigIMGV.image  = image;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btn1:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(gotoVideoWithIndex:)]){
        [_delegate gotoVideoWithIndex:self.tag - FLAG_TAG];
    }
}

- (IBAction)btn2:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(gotoSetupWithIndex:)]) {
        [_delegate gotoSetupWithIndex:self.deviceID];
    }
}

@end
