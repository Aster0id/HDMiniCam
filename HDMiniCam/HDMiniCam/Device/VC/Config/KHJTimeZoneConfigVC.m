//
//  KHJTimeZoneConfigVC.m
//  SuperIPC
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
    self.titleLab.text = TTLocalString(@"tmZoneSetup_", nil);
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
        TLog(@"选择时区");
        [self chooseTimeZone];
    }
    else if (sender.tag == 20) {
        TLog(@"时间服务器");
    }
    else if (sender.tag == 30) {
        TLog(@"确定");
    }
    else if (sender.tag == 40) {
        TLog(@"取消");
    }
    else if (sender.tag == 50) {
        TLog(@"用APP同步时间");
    }
}

- (void)chooseTimeZone
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:TTLocalString(@"chooseTimeZone_", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
    TTWeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:TTStr(@"(GMT-11:00) %@",TTLocalString(@"ztd_", nil))
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-11:00) %@",TTLocalString(@"ztd_", nil))];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-10:00) %@",TTLocalString(@"xwy_", nil), nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-10:00) %@",TTLocalString(@"xwy_", nil), nil)];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-09:00) %@",TTLocalString(@"alsj_", nil), nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-09:00) %@",TTLocalString(@"alsj_", nil), nil)];
                                                    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-08:00) %@",TTLocalString(@"tpy_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-08:00) %@",TTLocalString(@"tpy_", nil))];
                                                    }];
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-07:00) %@",TTLocalString(@"sdsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-07:00) %@",TTLocalString(@"sdsj_", nil))];
                                                    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-06:00) %@",TTLocalString(@"zysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-06:00) %@",TTLocalString(@"zysj_", nil))];
                                                    }];
    UIAlertAction *config6 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-05:00)%@",TTLocalString(@"dbsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-05:00)%@",TTLocalString(@"dbsj_", nil))];
                                                    }];
    UIAlertAction *config7 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-04:00)%@",TTLocalString(@"dxysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-04:00)%@",TTLocalString(@"dxysj_", nil))];
                                                    }];
    UIAlertAction *config8 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-03:30)%@",TTLocalString(@"nflsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-03:30)%@",TTLocalString(@"nflsj_", nil))];
                                                    }];
    UIAlertAction *config9 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-03:00)%@",TTLocalString(@"gllsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-03:00)%@",TTLocalString(@"gllsj_", nil))];
                                                    }];
    UIAlertAction *confi10 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-02:00)%@",TTLocalString(@"zdxysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-02:00)%@",TTLocalString(@"zdxysj_", nil))];
                                                    }];
    UIAlertAction *confi11 = [UIAlertAction actionWithTitle:TTStr(@"(GMT-01:00)%@",TTLocalString(@"ysrqdsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT-01:00)%@",TTLocalString(@"ysrqdsj_", nil))];
                                                    }];
    UIAlertAction *confi12 = [UIAlertAction actionWithTitle:TTStr(@"(GMT)%@",TTLocalString(@"mlgsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT)%@",TTLocalString(@"mlgsj_", nil))];
                                                    }];
    UIAlertAction *confi13 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+01:00) %@",TTLocalString(@"jksj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+01:00) %@",TTLocalString(@"jksj_", nil))];
                                                    }];
    UIAlertAction *confi14 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+02:00) %@",TTLocalString(@"wklsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+02:00) %@",TTLocalString(@"wklsj_", nil))];
                                                    }];
    UIAlertAction *confi15 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+03:00) %@",TTLocalString(@"ylksj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+03:00) %@",TTLocalString(@"ylksj_", nil))];
                                                    }];
    UIAlertAction *confi16 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+03:30) %@",TTLocalString(@"mskdlsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+03:30) %@",TTLocalString(@"mskdlsj_", nil))];
                                                    }];
    UIAlertAction *confi17 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+04:00) %@",TTLocalString(@"ymnysj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+04:00) %@",TTLocalString(@"ymnysj_", nil))];
                                                    }];
    UIAlertAction *confi18 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+05:00) %@",TTLocalString(@"bjstsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+05:00) %@",TTLocalString(@"bjstsj_", nil))];
                                                    }];
    UIAlertAction *confi19 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+05:30) %@",TTLocalString(@"ydsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+05:30) %@",TTLocalString(@"ydsj_", nil))];
                                                    }];
    UIAlertAction *confi20 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+06:00) %@",TTLocalString(@"elssj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+06:00) %@",TTLocalString(@"elssj_", nil))];
                                                    }];
    UIAlertAction *confi21 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+07:00) %@",TTLocalString(@"tgsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+07:00) %@",TTLocalString(@"tgsj_", nil))];
                                                    }];
    UIAlertAction *confi22 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+08:00) %@",TTLocalString(@"bjsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+08:00) %@",TTLocalString(@"bjsj_", nil))];
                                                    }];
    UIAlertAction *confi23 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+09:00) %@",TTLocalString(@"rbsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+09:00) %@",TTLocalString(@"rbsj_", nil))];
                                                    }];
    UIAlertAction *confi24 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+10:00) %@",TTLocalString(@"gdsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+10:00) %@",TTLocalString(@"gdsj_", nil))];
                                                    }];
    UIAlertAction *confi25 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+11:00) %@",TTLocalString(@"slmsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+11:00) %@",TTLocalString(@"slmsj_", nil))];
                                                    }];
    UIAlertAction *confi26 = [UIAlertAction actionWithTitle:TTStr(@"(GMT+12:00) %@",TTLocalString(@"hldsj_", nil))
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:TTStr(@"(GMT+12:00) %@",TTLocalString(@"hldsj_", nil))];
                                                    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:TTLocalString(@"cancel_", nil)
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
