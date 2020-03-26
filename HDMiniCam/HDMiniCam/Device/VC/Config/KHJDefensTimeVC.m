//
//  KHJDefensTimeVC.m
//  SuperIPC
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJDefensTimeVC.h"
#import "KHJAlarmConfHeadView.h"
#import "KHJAlarmConfFootView.h"
#import "KHJDefensTimeCell.h"
#import "KHJAddDTVC.h"

@interface KHJDefensTimeVC ()<UITableViewDelegate, UITableViewDataSource, KHJAlarmConfHeadViewDelegate, KHJAlarmConfFootViewDelegate, KHJDefensTimeCellDelegate, KHJAddDTVCDelegate>
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

@property (nonatomic, strong) NSMutableArray *everyDayArr;
@property (nonatomic, strong) NSMutableArray *sevenArr;
@property (nonatomic, strong) NSMutableArray *oneArr;
@property (nonatomic, strong) NSMutableArray *twoArr;
@property (nonatomic, strong) NSMutableArray *threeArr;
@property (nonatomic, strong) NSMutableArray *fourArr;
@property (nonatomic, strong) NSMutableArray *fiveArr;
@property (nonatomic, strong) NSMutableArray *sixArr;

@end

@implementation KHJDefensTimeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    isEveryDay = NO;
    self.titleLab.text = KHJLocalizedString(@"定时设置", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!isEveryDay) {
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
//            if (isEveryDay)
//                return self.everyDayArr.count;
            return 0;
        }
            break;
        case 1:
        {
            // 周日
            if (sevenOn)
                return 0;
            return self.sevenArr.count;
        }
            break;
        case 2:
        {
            // 周一
            if (firstOn)
                return 0;
            return self.oneArr.count;
        }
            break;
        case 3:
        {
            // 周二
            if (secondOn)
                return 0;
            return self.twoArr.count;
        }
            break;
        case 4:
        {
            // 周三
            if (thirdOn)
                return 0;
            return self.threeArr.count;
        }
            break;
        case 5:
        {
            // 周四
            if (fourOn)
                return 0;
            return self.fourArr.count;
        }
            break;
        case 6:
        {
            // 周五
            if (fiveOn)
                return 0;
            return self.fiveArr.count;
        }
            break;
        case 7:
        {
            // 周六
            if (sixOn)
                return 0;
            return self.sixArr.count;
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!isEveryDay) {
        if (section == 0) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !isEveryDay;
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
            head.switchBtn.on = !isEveryDay;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"每天", nil);
            return head;
        }
        else if (section == 1) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !sevenOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周日", nil);
            return head;
        }
        else if (section == 2) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !firstOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周一", nil);
            return head;
        }
        else if (section == 3) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !secondOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周二", nil);
            return head;
        }
        else if (section == 4) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !thirdOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周三", nil);
            return head;
        }
        else if (section == 5) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !fourOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周四", nil);
            return head;
        }
        else if (section == 6) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !fiveOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周五", nil);
            return head;
        }
        else if (section == 7) {
            KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
            head.tag = section + FLAG_TAG;
            head.delegate = self;
            head.switchBtn.on = !sixOn;
            head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
            head.nameLab.text = KHJLocalizedString(@"周六", nil);
            return head;
        }
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!isEveryDay) {
        KHJAlarmConfFootView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfFootView" owner:nil options:nil][0];
        head.tag = FLAG_TAG * 2;
        head.delegate = self;
        return head;
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
    cell.tag = FLAG_TAG + indexPath.row;
    cell.section = indexPath.section;
    cell.delegate = self;
    return cell;
}

#pragma mark - KHJAlarmConfFootViewDelegate

- (void)clickFootWith:(NSInteger)index
{
    KHJAddDTVC *vc = [[KHJAddDTVC alloc] init];
    vc.delegate = self;
    if (index == 1)
        vc.timeArr = [self.sevenArr copy];
    else if (index == 2)
        vc.timeArr = [self.oneArr copy];
    else if (index == 3)
        vc.timeArr = [self.twoArr copy];
    else if (index == 4)
        vc.timeArr = [self.threeArr copy];
    else if (index == 5)
        vc.timeArr = [self.fourArr copy];
    else if (index == 6)
        vc.timeArr = [self.fiveArr copy];
    else if (index == 7)
        vc.timeArr = [self.sixArr copy];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KHJAddDTVCDelegate

- (void)addDefinesTime:(NSString *)time
{
    TLog(@"time ====================== %@",time);
}

#pragma mark - KHJAlarmConfHeadViewDelegate

- (void)clickHeadWith:(NSInteger)index
{
    if (index == 0)
        isEveryDay = !isEveryDay;
    else if (index == 1)
        sevenOn = !sevenOn;
    else if (index == 2)
        firstOn = !firstOn;
    else if (index == 3)
        secondOn = !secondOn;
    else if (index == 4)
        thirdOn = !thirdOn;
    else if (index == 5)
        fourOn = !fourOn;
    else if (index == 6)
        fiveOn = !fiveOn;
    else if (index == 7)
        sixOn = !sixOn;
    [contentTBV reloadData];
}

#pragma mark - KHJDefensTimeCellDelegate

- (void)closeWithSection:(NSInteger)section row:(NSInteger)row
{
    TLog(@"删除第 %ld 个cell",(long)row);
    if (section == 0)
        [self.everyDayArr removeObjectAtIndex:row];
    else if (section == 1)
        [self.sevenArr removeObjectAtIndex:row];
    else if (section == 2)
        [self.oneArr removeObjectAtIndex:row];
    else if (section == 3)
        [self.twoArr removeObjectAtIndex:row];
    else if (section == 4)
        [self.threeArr removeObjectAtIndex:row];
    else if (section == 5)
        [self.fourArr removeObjectAtIndex:row];
    else if (section == 6)
        [self.fiveArr removeObjectAtIndex:row];
    else if (section == 7)
        [self.sixArr removeObjectAtIndex:row];
    [contentTBV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -

- (NSMutableArray *)everyDayArr
{
    if (!_everyDayArr) {
        _everyDayArr = [NSMutableArray array];
    }
    return _everyDayArr;
}

- (NSMutableArray *)sevenArr
{
    if (!_sevenArr) {
        _sevenArr = [NSMutableArray array];
    }
    return _sevenArr;
}

- (NSMutableArray *)oneArr
{
    if (!_oneArr) {
        _oneArr = [NSMutableArray array];
    }
    return _oneArr;
}

- (NSMutableArray *)twoArr
{
    if (!_twoArr) {
        _twoArr = [NSMutableArray array];
    }
    return _twoArr;
}

- (NSMutableArray *)threeArr
{
    if (!_threeArr) {
        _threeArr = [NSMutableArray array];
    }
    return _threeArr;
}

- (NSMutableArray *)fourArr
{
    if (!_fourArr) {
        _fourArr = [NSMutableArray array];
    }
    return _fourArr;
}

- (NSMutableArray *)fiveArr
{
    if (!_fiveArr) {
        _fiveArr = [NSMutableArray array];
    }
    return _fiveArr;
}

- (NSMutableArray *)sixArr
{
    if (!_sixArr) {
        _sixArr = [NSMutableArray array];
    }
    return _sixArr;
}

@end
