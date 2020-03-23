//
//  KHJAlarmConfVC_2.m
//  HDMiniCam
//
//  Created by 王涛 on 2020/3/22.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAlarmConfVC_2.h"
#import "KHJAlarmConfCell.h"
#import "KHJAlarmConfHeadView.h"
#import "KHJAlarmTriggerVC.h"
#import "KHJDefensTimeVC.h"

@interface KHJAlarmConfVC_2 ()<KHJAlarmConfHeadViewDelegate, KHJAlarmConfCellDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL firstOn;
    BOOL secondOn;
    BOOL thirdOn;
    __weak IBOutlet UITableView *contentTBV;
    
    NSArray *moveArr;
    NSString *moveLmd;
    NSString *moveTime;
    NSArray *bodyArr;
    NSString *bodyTime;
    NSArray *cryArr;
    NSString *cryTime;
    NSString *cryLmd;
}
@end

@implementation KHJAlarmConfVC_2

- (void)viewDidLoad
{
    [super viewDidLoad];
    moveLmd = KHJLocalizedString(@"中", nil);
    moveTime = KHJLocalizedString(@"每天", nil);
    moveArr = @[KHJLocalizedString(@"灵敏度", nil),
                KHJLocalizedString(@"侦测区域设置", nil),
                KHJLocalizedString(@"布防时间", nil),
                KHJLocalizedString(@"触发操作", nil)];
    bodyTime = KHJLocalizedString(@"每天", nil);
    bodyArr = @[KHJLocalizedString(@"侦测区域设置", nil),
                KHJLocalizedString(@"布防时间", nil),
                KHJLocalizedString(@"触发操作", nil)];
    cryTime = KHJLocalizedString(@"每天", nil);
    cryLmd = KHJLocalizedString(@"中", nil);
    cryArr = @[KHJLocalizedString(@"灵敏度", nil),
               KHJLocalizedString(@"布防时间", nil),
               KHJLocalizedString(@"触发操作", nil)];
    self.titleLab.text = KHJLocalizedString(@"alarSet_", nil);
    [self.leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return firstOn == YES ? 4 : 0;
    }
    else if (section == 1) {
        return secondOn == YES ? 3 : 0;
    }
    else if (section == 2) {
        return thirdOn == YES ? 3 : 0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
        head.tag = section + FLAG_TAG;
        head.delegate = self;
        head.switchBtn.on = firstOn;
        head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
        head.nameLab.text = KHJLocalizedString(@"开启移动侦测", nil);
        return head;
    }
    else if (section == 1) {
        KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
        head.tag = section + FLAG_TAG;
        head.delegate = self;
        head.switchBtn.on = secondOn;
        head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
        head.nameLab.text = KHJLocalizedString(@"人形识别报警", nil);
        return head;
    }
    else if (section == 2) {
        KHJAlarmConfHeadView *head = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfHeadView" owner:nil options:nil][0];
        head.tag = section + FLAG_TAG;
        head.delegate = self;
        head.switchBtn.on = thirdOn;
        head.switchBtn.transform = CGAffineTransformMakeScale(0.8, 0.8);
        head.nameLab.text = KHJLocalizedString(@"哭声识别报警", nil);
        return head;
    }
    return nil;
}

#pragma mark - KHJAlarmConfHeadViewDelegate

- (void)clickHeadWith:(NSInteger)index
{
    if (index == 0) {
        CLog(@"第一行 = %ld",index);
        firstOn = !firstOn;
        [UIView performWithoutAnimation:^{
            [self->contentTBV reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else if (index == 1) {
        CLog(@"第二行 = %ld",index);
        secondOn = !secondOn;
        [UIView performWithoutAnimation:^{
            [self->contentTBV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else if (index == 2) {
        CLog(@"第三行 = %ld",index);
        thirdOn = !thirdOn;
        [UIView performWithoutAnimation:^{
            [self->contentTBV reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJAlarmConfCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJAlarmConfCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJAlarmConfCell" owner:nil options:nil][0];
    }
    cell.delegate = self;
    if (indexPath.section == 0) {
        cell.tag = 100 + indexPath.row + FLAG_TAG;
        if (indexPath.row == 0) {
            cell.subNameLab.text = moveLmd;
        }
        else if (indexPath.row == 2) {
            cell.subNameLab.text = moveTime;
        }
        cell.nameLab.text = moveArr[indexPath.row];
    }
    else if (indexPath.section == 1) {
        cell.tag = 200 + indexPath.row + FLAG_TAG;
        if (indexPath.row == 1) {
            cell.subNameLab.text = bodyTime;
        }
        cell.nameLab.text = bodyArr[indexPath.row];
    }
    else if (indexPath.section == 2) {
        cell.tag = 300 + indexPath.row + FLAG_TAG;
        if (indexPath.row == 0) {
            cell.subNameLab.text = cryLmd;
        }
        else if (indexPath.row == 1) {
            cell.subNameLab.text = cryTime;
        }
        cell.nameLab.text = cryArr[indexPath.row];
    }
    return cell;
}

#pragma mark - KHJAlarmConfCellDelegate

- (void)clickWith:(NSInteger)row
{
    if (row == 100) {
        CLog(@"移动侦测 灵敏度 = %ld",row);
        [self chooseLmdWith:0];
    }
    else if (row == 101) {
        // 移动侦测 侦测区域设置
    }
    else if (row == 102) {
        CLog(@"移动侦测 布防时间 = %ld",row);
        KHJDefensTimeVC *vc = [[KHJDefensTimeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 103) {
        // 移动侦测 触发操作
        KHJAlarmTriggerVC *vc = [[KHJAlarmTriggerVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 200) {
        // 人形侦测 侦测区域设置
    }
    else if (row == 201) {
        CLog(@"人形 布防时间 = %ld",row);
        KHJDefensTimeVC *vc = [[KHJDefensTimeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 202) {
        // 人形侦测 触发操作
        KHJAlarmTriggerVC *vc = [[KHJAlarmTriggerVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 300) {
        CLog(@"灵敏度 = %ld",row);
        [self chooseLmdWith:2];
    }
    else if (row == 301) {
        CLog(@"布防时间 = %ld",row);
        KHJDefensTimeVC *vc = [[KHJDefensTimeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 302) {
        // 哭声侦测 触发操作
        KHJAlarmTriggerVC *vc = [[KHJAlarmTriggerVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 选择灵敏度
- (void)chooseTimeWith:(NSInteger)index
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"选择灵敏度", nil)
                                                                       message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"高", nil)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (index == 0) {
            self->moveLmd = KHJLocalizedString(@"高", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (index == 2) {
            self->cryLmd = KHJLocalizedString(@"高", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"中", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (index == 0) {
            self->moveLmd = KHJLocalizedString(@"中", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (index == 2) {
            self->cryLmd = KHJLocalizedString(@"中", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"低", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (index == 0) {
            self->moveLmd = KHJLocalizedString(@"低", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (index == 2) {
            self->cryLmd = KHJLocalizedString(@"低", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];

    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}


// 选择灵敏度
- (void)chooseLmdWith:(NSInteger)index
{
    UIAlertController *alertview = [UIAlertController alertControllerWithTitle:KHJLocalizedString(@"选择灵敏度", nil)
                                                                       message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *config = [UIAlertAction actionWithTitle:KHJLocalizedString(@"高", nil)
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (index == 0) {
            self->moveLmd = KHJLocalizedString(@"高", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (index == 2) {
            self->cryLmd = KHJLocalizedString(@"高", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    UIAlertAction *config1 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"中", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (index == 0) {
            self->moveLmd = KHJLocalizedString(@"中", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (index == 2) {
            self->cryLmd = KHJLocalizedString(@"中", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    
    UIAlertAction *config2 = [UIAlertAction actionWithTitle:KHJLocalizedString(@"低", nil)
                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (index == 0) {
            self->moveLmd = KHJLocalizedString(@"低", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (index == 2) {
            self->cryLmd = KHJLocalizedString(@"低", nil);
            [self->contentTBV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:KHJLocalizedString(@"cancel_", nil) style:UIAlertActionStyleCancel handler:nil];

    [alertview addAction:config];
    [alertview addAction:config1];
    [alertview addAction:config2];
    [alertview addAction:cancel];
    [self presentViewController:alertview animated:YES completion:nil];
}

@end
