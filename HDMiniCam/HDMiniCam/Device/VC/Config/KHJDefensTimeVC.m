//
//  KHJDefensTimeVC.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJDefensTimeVC.h"
#import "KHJAlarmConfHeadView.h"
#import "KHJAlarmConfFootView.h"
#import "KHJDefensTimeCell.h"

@interface KHJDefensTimeVC ()<UITableViewDelegate, UITableViewDataSource, KHJAlarmConfHeadViewDelegate, KHJAlarmConfFootViewDelegate, KHJDefensTimeCellDelegate>
{
    __weak IBOutlet UITableView *contentTBV;
    BOOL isEveryDay;
    BOOL sevenOn;
    BOOL firstOn;
    BOOL secondOn;
    BOOL thirdOn;
    BOOL fourOn;
    BOOL fiveOn;
    BOOL sixOn;
}
@end

@implementation KHJDefensTimeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    isEveryDay = NO;
    self.titleLab.text = KHJLocalizedString(@"报警触发设置", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isEveryDay) {
        return 1;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            // 每天
            return 0;
        }
            break;
        case 1:
        {
            // 周日
            if (sevenOn) {
                return 0;
            }
            return 2;
        }
            break;
        case 2:
        {
            // 周一
            if (firstOn) {
                return 0;
            }
            return 3;
        }
            break;
        case 3:
        {
            // 周二
            if (secondOn) {
                return 0;
            }
            return 4;
        }
            break;
        case 4:
        {
            // 周三
            if (thirdOn) {
                return 0;
            }
            return 2;
        }
            break;
        case 5:
        {
            // 周四
            if (fourOn) {
                return 0;
            }
            return 3;
        }
            break;
        case 6:
        {
            // 周五
            if (fiveOn) {
                return 0;
            }
            return 2;
        }
            break;
        case 7:
        {
            // 周六
            if (sixOn) {
                return 0;
            }
            return 2;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (isEveryDay) {
        if (section == 0) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = isEveryDay;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"每天", nil);
            return head;
        }
    }
    else {
        if (section == 0) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = isEveryDay;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周日", nil);
            return head;
        }
        else if (section == 1) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = sevenOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周日", nil);
            return head;
        }
        else if (section == 2) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = firstOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周一", nil);
            return head;
        }
        else if (section == 3) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = secondOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周二", nil);
            return head;
        }
        else if (section == 4) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = thirdOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周三", nil);
            return head;
        }
        else if (section == 5) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = fourOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周四", nil);
            return head;
        }
        else if (section == 6) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = fiveOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周五", nil);
            return head;
        }
        else if (section == 7) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = sixOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周六", nil);
            return head;
        }
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (isEveryDay) {
        return nil;
    }
    else {
        if (section == 1) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
        else if (section == 2) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
        else if (section == 3) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
        else if (section == 4) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
        else if (section == 5) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
        else if (section == 6) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
        else if (section == 7) {
            KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            return head;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJDefensTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJDefensTimeCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJDefensTimeCell" owner:nil options:nil][0];
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - KHJAlarmConfFootViewDelegate

- (void)clickFootWith:(NSInteger)index
{
    CLog(@"点击第 %ld 个底部",index);
    switch (index) {
        case 1:
            // 周日
            break;
        case 2:
            // 周一
            break;
        case 3:
            // 周二
            break;
        case 4:
            // 周三
            break;
        case 5:
            // 周四
            break;
        case 6:
            // 周五
            break;
        case 7:
            // 周六
            break;
        default:
            break;
    }
}

#pragma mark - KHJAlarmConfHeadViewDelegate

- (void)clickHeadWith:(NSInteger)index
{
    CLog(@"点击第 %ld 个头部",index);
    switch (index) {
        case 0:
        {
            // 每天
            isEveryDay = !isEveryDay;
        }
            break;
        case 1:
        {
            // 周日
            sevenOn = !sevenOn;
        }
            break;
        case 2:
        {
            // 周一
            firstOn = !firstOn;
        }
            break;
        case 3:
        {
            // 周二
            secondOn = !secondOn;
        }
            break;
        case 4:
        {
            // 周三
            thirdOn = !thirdOn;
        }
            break;
        case 5:
        {
            // 周四
            fourOn = !fourOn;
        }
            break;
        case 6:
        {
            // 周五
            fiveOn = !fiveOn;
        }
            break;
        case 7:
        {
            // 周六
            sixOn = !sixOn;
        }
            break;
        default:
            break;
    }
    [contentTBV reloadData];
}

#pragma mark - KHJDefensTimeCellDelegate

- (void)closeWith:(NSInteger)row
{
    CLog(@"删除第 %ld 个cell",row);
}

@end
