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
    self.titleLab.text = KHJLocalizedString(@"时区设置", nil);
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
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"title", nil)
                                                                       message:KHJLocalizedString(@"选择时区", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
    WeakSelf
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-11:00) 中途岛、萨摩亚", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [weakSelf setTimeZoneWith:0 title:@"(GMT-11:00) 中途岛、萨摩亚"];
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-10:00) 夏威夷", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-10:00) 夏威夷"];
    }];
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-09:00) 阿拉斯加", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-09:00) 阿拉斯加"];
                                                    }];
    UIAlertAction *config3 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-08:00) 太平洋标准时间", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-08:00) 太平洋标准时间"];
                                                    }];
    UIAlertAction *config4 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-07:00) 山地时间(美国和加拿大)", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-07:00) 山地时间(美国和加拿大)"];
                                                    }];
    UIAlertAction *config5 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-06:00) 中央时间", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-06:00) 中央时间"];
                                                    }];
    UIAlertAction *config6 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-05:00) 东部时间", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-05:00) 东部时间"];
                                                    }];
    UIAlertAction *config7 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-04:00) 大西洋标准时间，西巴西", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-04:00) 大西洋标准时间，西巴西"];
                                                    }];
    UIAlertAction *config8 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-03:30) 纽芬兰", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-03:30) 纽芬兰"];
                                                    }];
    UIAlertAction *config9 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-03:00) 东巴西、格陵兰", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-03:00) 东巴西、格陵兰"];
                                                    }];
    UIAlertAction *confi10 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-02:00) 中大西洋", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-02:00) 中大西洋"];
                                                    }];
    UIAlertAction *confi11 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT-01:00) 亚速尔群岛", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT-01:00) 亚速尔群岛"];
                                                    }];
    UIAlertAction *confi12 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT) 甘比亚、赖比瑞亚、摩洛哥", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT) 甘比亚、赖比瑞亚、摩洛哥"];
                                                    }];
    UIAlertAction *confi13 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+01:00) 捷克、N", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+01:00) 捷克、N"];
                                                    }];
    UIAlertAction *confi14 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+02:00) 希腊、乌克兰、土耳其", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+02:00) 希腊、乌克兰、土耳其"];
                                                    }];
    UIAlertAction *confi15 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+03:00) 伊拉克、约旦、科威特", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+03:00) 伊拉克、约旦、科威特"];
                                                    }];
    UIAlertAction *confi16 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+03:30) 莫斯科冬令时间", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+03:30) 莫斯科冬令时间"];
                                                    }];
    UIAlertAction *confi17 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+04:00) 亚美尼亚", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+04:00) 亚美尼亚"];
                                                    }];
    UIAlertAction *confi18 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+05:00) 巴基斯坦、俄罗斯", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+05:00) 巴基斯坦、俄罗斯"];
                                                    }];
    UIAlertAction *confi19 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+05:30) 印度、孟买、加尔各答", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+05:30) 印度、孟买、加尔各答"];
                                                    }];
    UIAlertAction *confi20 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+06:00) 孟加拉、俄罗斯", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+06:00) 孟加拉、俄罗斯"];
                                                    }];
    UIAlertAction *confi21 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+07:00) 泰国、俄罗斯", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+07:00) 泰国、俄罗斯"];
                                                    }];
    UIAlertAction *confi22 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+08:00) 北京、台北、新加坡", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+08:00) 北京、台北、新加坡"];
                                                    }];
    UIAlertAction *confi23 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+09:00) 日本、韩国", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+09:00) 日本、韩国"];
                                                    }];
    UIAlertAction *confi24 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+10:00) 关岛、俄罗斯", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+10:00) 关岛、俄罗斯"];
                                                    }];
    UIAlertAction *confi25 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+11:00) 索罗门群岛", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+11:00) 索罗门群岛"];
                                                    }];
    UIAlertAction *confi26 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"(GMT+12:00) 奥克兰、惠灵顿、裴济", nil)
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        [weakSelf setTimeZoneWith:0 title:@"(GMT+12:00) 奥克兰、惠灵顿、裴济"];
                                                    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"取消", nil)
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
