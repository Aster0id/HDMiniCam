//
//  KHJWIFIConfigVC.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJWIFIConfigVC.h"
#import "KHJWIFIConfigCell.h"
#import "ZQAlterField.h"

@interface KHJWIFIConfigVC ()<UITableViewDelegate, UITableViewDataSource>
{
    UIView *back_groundView;
    __weak IBOutlet UILabel *wifiName;
    __weak IBOutlet UITableView *contentTBV;
    
}
@end

@implementation KHJWIFIConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"wifi设置", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJWIFIConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJWIFIConfigCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJWIFIConfigCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    WeakSelf
    cell.block = ^(int row) {
        CLog(@"row = %ld",(long)row);
        [weakSelf changewifi:@"changewifi"];
    };
    return cell;
}

- (void)changewifi:(NSString *)wifiname
{
    WeakSelf
    ZQAlterField *alertView = [ZQAlterField alertView];
    alertView.title = KHJString(@"%@%@",KHJLocalizedString(@"更改 Wi-Fi 为：", nil),@"dddassadadasasd");
    alertView.placeholder = KHJLocalizedString(@"请输入 Wi-Fi 密码", nil);
    alertView.Maxlength = 50;
    alertView.ensureBgColor = KHJUtility.appMainColor;
    [alertView ensureClickBlock:^(NSString *inputString, int type) {
        CLog(@"输入内容为%@",inputString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf changeConnectWifi:inputString];
        });
    }];
    [alertView show];
}

- (void)changeConnectWifi:(NSString *)pwd
{
    [self addShadow_changeNetwork];
}

- (void)addShadow_changeNetwork
{
    back_groundView = [[UIView alloc] init];
    back_groundView.frame            = CGRectMake(0, 1,SCREEN_WIDTH,SCREEN_HEIGHT);
    back_groundView.backgroundColor  = [UIColor colorWithRed:(40/255.0f) green:(40/255.0f) blue:(40/255.0f) alpha:1.0f];
    back_groundView.alpha            = 0.6;
    [[[UIApplication sharedApplication] keyWindow] addSubview:back_groundView];
    [[KHJHub shareHub] showText:KHJLocalizedString(@"changeNetTooSlow", nil) addToView:self.view type:_default];
    //   设置超时，以防设备断开，一直请求
    __weak typeof(back_groundView) weakVackgroundView = back_groundView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(90 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [KHJHub shareHub].hud.hidden = YES;
        [weakVackgroundView removeFromSuperview];
        [[KHJToast share] showToastActionWithToastType:_SuccessType
                                          toastPostion:_CenterPostion tip:@""
                                               content:KHJLocalizedString(@"changeNetTimeOut", nil)];
    });
}

@end
