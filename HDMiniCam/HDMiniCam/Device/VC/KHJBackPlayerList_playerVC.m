//
//  KHJBackPlayerList_playerVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/2/28.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBackPlayerList_playerVC.h"
//
#import "H26xHwDecoder.h"
#import "KHJDeviceManager.h"
#import "JSONStructProtocal.h"

extern IPCNetRecordCfg_st recordCfg;

@interface KHJBackPlayerList_playerVC ()<H26xHwDecoderDelegate>
{
    __weak IBOutlet UILabel *titleLab;
    __weak IBOutlet UIImageView *playerImageView;
    
    __weak IBOutlet UISlider *sliderView;
    __weak IBOutlet UILabel *startTimeLab;
    __weak IBOutlet UILabel *endTimeLab;
    
    BOOL isPlay;
    __weak IBOutlet UIButton *playBtn;
}
@end

@implementation KHJBackPlayerList_playerVC

- (void)setBody:(NSDictionary *)body
{
    _body = [NSDictionary dictionaryWithDictionary:body];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[KHJDeviceManager sharedManager] startPlayback_with_deviceID:self.deviceID path:@"" resultBlock:^(NSInteger code) {
        
    }];
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (sender.tag == 20) {
        
    }
    else if (sender.tag == 30) {
        // 播放/暂停
        isPlay = !isPlay;
        if (isPlay) {
            CLog(@"播放");
        }
        else {
            CLog(@"暂停");
        }
    }
    else if (sender.tag == 40) {
        
    }
}

#pragma MARK - H26xHwDecoderDelegate

- (void)getImageWith:(UIImage *)image imageSize:(CGSize)imageSize
{
    playerImageView.image = image;
}



@end
