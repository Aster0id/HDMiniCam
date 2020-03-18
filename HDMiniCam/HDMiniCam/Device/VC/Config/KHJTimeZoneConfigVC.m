//
//  KHJTimeZoneConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJTimeZoneConfigVC.h"

@interface KHJTimeZoneConfigVC ()
{
    __weak IBOutlet UILabel *time;
    __weak IBOutlet UILabel *timeZone;
    __weak IBOutlet UILabel *timeServer;
}
@end

@implementation KHJTimeZoneConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"tmZoneSetup_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy年MM月dd日 HH:MM:ss"];
    time.text = [format stringFromDate:[NSDate date]];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn:(UIButton *)sender
{
    if (sender.tag == 10) {
        CLog(@"选择时区");
        [self chooseTimeZone];
    }
    else if (sender.tag == 20) {
        CLog(@"时间服务器");
    }
    else if (sender.tag == 30) {
        CLog(@"确定");
    }
    else if (sender.tag == 40) {
        CLog(@"取消");
    }
    else if (sender.tag == 50) {
        CLog(@"用APP同步时间");
    }
}

- (void)chooseTimeZone
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"chooseTimeZone_", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJString(@"(GMT-11:00) %@",KHJLocalizedString(@"ztd_", nil))
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-11:00) %@",KHJLocalizedString(@"ztd_", nil))];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-10:00) %@",KHJLocalizedString(@"xwy_", nil), nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-10:00) %@",KHJLocalizedString(@"xwy_", nil), nil)];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-09:00) %@",KHJLocalizedString(@"alsj_", nil), nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-09:00) %@",KHJLocalizedString(@"alsj_", nil), nil)];
                                                    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-08:00) %@",KHJLocalizedString(@"tpy_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-08:00) %@",KHJLocalizedString(@"tpy_", nil))];
                                                    }];
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-07:00) %@",KHJLocalizedString(@"sdsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-07:00) %@",KHJLocalizedString(@"sdsj_", nil))];
                                                    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-06:00) %@",KHJLocalizedString(@"zysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-06:00) %@",KHJLocalizedString(@"zysj_", nil))];
                                                    }];
    UIAlertAction *config6 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-05:00)%@",KHJLocalizedString(@"dbsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-05:00)%@",KHJLocalizedString(@"dbsj_", nil))];
                                                    }];
    UIAlertAction *config7 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-04:00)%@",KHJLocalizedString(@"dxysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-04:00)%@",KHJLocalizedString(@"dxysj_", nil))];
                                                    }];
    UIAlertAction *config8 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-03:30)%@",KHJLocalizedString(@"nflsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-03:30)%@",KHJLocalizedString(@"nflsj_", nil))];
                                                    }];
    UIAlertAction *config9 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-03:00)%@",KHJLocalizedString(@"gllsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-03:00)%@",KHJLocalizedString(@"gllsj_", nil))];
                                                    }];
    UIAlertAction *confi10 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-02:00)%@",KHJLocalizedString(@"zdxysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-02:00)%@",KHJLocalizedString(@"zdxysj_", nil))];
                                                    }];
    UIAlertAction *confi11 = [UIAlertAction actionWithTitle:KHJString(@"(GMT-01:00)%@",KHJLocalizedString(@"ysrqdsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT-01:00)%@",KHJLocalizedString(@"ysrqdsj_", nil))];
                                                    }];
    UIAlertAction *confi12 = [UIAlertAction actionWithTitle:KHJString(@"(GMT)%@",KHJLocalizedString(@"mlgsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT)%@",KHJLocalizedString(@"mlgsj_", nil))];
                                                    }];
    UIAlertAction *confi13 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+01:00) %@",KHJLocalizedString(@"jksj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+01:00) %@",KHJLocalizedString(@"jksj_", nil))];
                                                    }];
    UIAlertAction *confi14 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+02:00) %@",KHJLocalizedString(@"wklsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+02:00) %@",KHJLocalizedString(@"wklsj_", nil))];
                                                    }];
    UIAlertAction *confi15 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+03:00) %@",KHJLocalizedString(@"ylksj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+03:00) %@",KHJLocalizedString(@"ylksj_", nil))];
                                                    }];
    UIAlertAction *confi16 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+03:30) %@",KHJLocalizedString(@"mskdlsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+03:30) %@",KHJLocalizedString(@"mskdlsj_", nil))];
                                                    }];
    UIAlertAction *confi17 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+04:00) %@",KHJLocalizedString(@"ymnysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+04:00) %@",KHJLocalizedString(@"ymnysj_", nil))];
                                                    }];
    UIAlertAction *confi18 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+05:00) %@",KHJLocalizedString(@"bjstsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+05:00) %@",KHJLocalizedString(@"bjstsj_", nil))];
                                                    }];
    UIAlertAction *confi19 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+05:30) %@",KHJLocalizedString(@"ydsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+05:30) %@",KHJLocalizedString(@"ydsj_", nil))];
                                                    }];
    UIAlertAction *confi20 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+06:00) %@",KHJLocalizedString(@"elssj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+06:00) %@",KHJLocalizedString(@"elssj_", nil))];
                                                    }];
    UIAlertAction *confi21 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+07:00) %@",KHJLocalizedString(@"tgsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+07:00) %@",KHJLocalizedString(@"tgsj_", nil))];
                                                    }];
    UIAlertAction *confi22 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+08:00) %@",KHJLocalizedString(@"bjsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+08:00) %@",KHJLocalizedString(@"bjsj_", nil))];
                                                    }];
    UIAlertAction *confi23 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+09:00) %@",KHJLocalizedString(@"rbsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+09:00) %@",KHJLocalizedString(@"rbsj_", nil))];
                                                    }];
    UIAlertAction *confi24 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+10:00) %@",KHJLocalizedString(@"gdsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+10:00) %@",KHJLocalizedString(@"gdsj_", nil))];
                                                    }];
    UIAlertAction *confi25 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+11:00) %@",KHJLocalizedString(@"slmsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+11:00) %@",KHJLocalizedString(@"slmsj_", nil))];
                                                    }];
    UIAlertAction *confi26 = [UIAlertAction actionWithTitle:KHJString(@"(GMT+12:00) %@",KHJLocalizedString(@"hldsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:KHJString(@"(GMT+12:00) %@",KHJLocalizedString(@"hldsj_", nil))];
                                                    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:config3];
    [alertview addAction:config4];
    [alertview addAction:config5];
    [alertview addAction:config6];
    [alertview addAction:config7];
    [alertview addAction:config8];
    [alertview addAction:config9];
    [alertview addAction:confi10];
    [alertview addAction:confi11];
    [alertview addAction:confi12];
    [alertview addAction:confi13];
    [alertview addAction:confi14];
    [alertview addAction:confi15];
    [alertview addAction:confi16];
    [alertview addAction:confi17];
    [alertview addAction:confi18];
    [alertview addAction:confi19];
    [alertview addAction:confi20];
    [alertview addAction:confi21];
    [alertview addAction:confi22];
    [alertview addAction:confi23];
    [alertview addAction:confi24];
    [alertview addAction:confi25];
    [alertview addAction:confi26];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

- (void)setTimeZoneWith:(NSInteger)row title:(NSString *)title
{
    timeZone.text = title;
}

@end
