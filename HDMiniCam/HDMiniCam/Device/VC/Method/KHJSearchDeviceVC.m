//
//  KHJSearchDeviceVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJSearchDeviceVC.h"
#import "KHJSearchDeviceCell.h"

@interface KHJSearchDeviceVC ()<UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *contentTBV;
    
}
@end

@implementation KHJSearchDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLab.text = KHJLocalizedString(@"搜索局域网", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJSearchDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJSearchDeviceCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJSearchDeviceCell" owner:nil options:nil][0];
    }
    return cell;
}

@end