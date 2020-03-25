//
//  KHJAddDTVC.m
//  HDMiniCam
//
//  Created by kevin on 2020/3/24.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAddDTVC.h"
#import "TTHourMinSeconsPicker.h"

@interface KHJAddDTVC ()
{
    __weak IBOutlet UILabel *startTimeLab;
    __weak IBOutlet UILabel *endTimeLab;

}
@end

@implementation KHJAddDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"添加报警时间", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAction:(UIButton *)sender
{
    if (sender.tag == 10) {
        TTHourMinSeconsPicker *pick = [[TTHourMinSeconsPicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 250 + 44, SCREEN_WIDTH, 324)];
        pick.pickerType = 0;
        [pick initSubViews:nil];
        pick.confirmBlock = ^(NSString *strings) {
            self->startTimeLab.text = strings;
        };
    }
    else if (sender.tag == 20) {
        TTHourMinSeconsPicker *pick = [[TTHourMinSeconsPicker alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 250 + 44, SCREEN_WIDTH, 324)];
        pick.pickerType = 0;
        [pick initSubViews:nil];
        pick.confirmBlock = ^(NSString *strings) {
            self->endTimeLab.text = strings;
        };
    }
    else if (sender.tag == 30) {
        
        if (self.timeArr.count > 0) {
            if (_delegate && [_delegate respondsToSelector:@selector(addDefinesTime:)]) {
                [_delegate addDefinesTime:KHJString(@"%@ - %@",startTimeLab.text,endTimeLab.text)];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            NSArray *sArr = [startTimeLab.text componentsSeparatedByString:@":"];
            NSArray *eArr = [endTimeLab.text componentsSeparatedByString:@":"];
            int sHour   = [sArr.firstObject intValue];
            int sMin    = [sArr.lastObject intValue];
            int eHour   = [eArr.firstObject intValue];
            int eMin    = [eArr.lastObject intValue];
            
            __block BOOL exit = NO;
            TTWeakSelf
            [self.timeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *timeArr = [(NSString *)obj componentsSeparatedByString:@" - "];
                __block int shour = 0;
                __block int smin = 0;
                __block int ehour = 0;
                __block int emin = 0;
                [timeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx == 0) {
                        NSArray *startArr = [(NSString *)obj componentsSeparatedByString:@":"];
                        shour   = [startArr.firstObject intValue];
                        smin    = [startArr.lastObject intValue];
                    }
                    else if (idx == 1) {
                        NSArray *endArr = [(NSString *)obj componentsSeparatedByString:@":"];
                        ehour   = [endArr.firstObject intValue];
                        emin    = [endArr.lastObject intValue];
                    }
                }];
                
                int SNUM    = sHour * 60 + sMin;
                int ENUM    = eHour * 60 + eMin;
                int snum    = shour * 60 + smin;
                int ennum   = ehour * 60 + emin;
                if ((SNUM < ennum && SNUM > snum ) || (ENUM > snum && ENUM < ennum)) {
                    exit = YES;
                    *stop = NO;
                }
            }];
            
            if (!exit) {
                TLog(@"添加的时间 = %@",KHJString(@"%@ - %@",startTimeLab.text,endTimeLab.text));
//                if (_delegate && [_delegate respondsToSelector:@selector(addDefinesTime:)]) {
//                    [_delegate addDefinesTime:KHJString(@"%@ - %@",startTimeLab.text,endTimeLab.text)];
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
            }
            else {
                [weakSelf.view makeToast:KHJLocalizedString(@"计划已包含该时间", nil)];
            }
        }
    }
    else if (sender.tag == 40) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
