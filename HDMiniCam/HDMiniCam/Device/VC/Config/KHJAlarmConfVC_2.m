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
#import "KHJAlarmAreaCell.h"

@interface KHJAlarmConfVC_2 ()
<
KHJAlarmConfHeadViewDelegate, KHJAlarmConfCellDelegate,
KHJAlarmAreaCellDelegate,UICollectionViewDelegate,UICollectionViewDataSource,
UITableViewDelegate, UITableViewDataSource>
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
    
    BOOL hadLine;
    __weak IBOutlet UIView *areaBgView;
    __weak IBOutlet UIView *areaContentView;
    __weak IBOutlet UICollectionView *areaCollectionView;
}
@end

@implementation KHJAlarmConfVC_2

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstOn = YES;
    secondOn = YES;
    thirdOn = YES;
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
    
    areaContentView.layer.cornerRadius = 2;
    areaContentView.layer.masksToBounds = YES;
    areaContentView.layer.borderWidth = 1;
    areaContentView.layer.borderColor = UIColorFromRGB(0xD5D5D5).CGColor;
    [self addCollectionView];
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
        firstOn = !firstOn;
        [UIView performWithoutAnimation:^{
            [self->contentTBV reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else if (index == 1) {
        secondOn = !secondOn;
        [UIView performWithoutAnimation:^{
            [self->contentTBV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else if (index == 2) {
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
        [self chooseLmdWith:0];
    }
    else if (row == 101) {
        // 移动侦测 侦测区域设置
        [self showCollectionView];
    }
    else if (row == 102) {
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
        [self showCollectionView];
    }
    else if (row == 201) {
        KHJDefensTimeVC *vc = [[KHJDefensTimeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 202) {
        // 人形侦测 触发操作
        KHJAlarmTriggerVC *vc = [[KHJAlarmTriggerVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (row == 300) {
        [self chooseLmdWith:2];
    }
    else if (row == 301) {
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

#pragma mark - 区域侦测

- (void)showCollectionView
{
    if (!hadLine) {
        float sizeWith      = (SCREEN_WIDTH - 24 - 15)/16;
        float sizeHeight    = ((SCREEN_WIDTH - 24)*12/16 - 11)/12;
        for (int i = 0; i < 12; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, sizeHeight*i + i - 1, SCREEN_WIDTH - 24, 1)];
                view.backgroundColor = UIColor.greenColor;
                view.alpha = 0.45;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->areaContentView addSubview:view];
                });
            });
        }
        for (int i = 0; i < 16; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(sizeWith*i + i - 1, 0, 1, (SCREEN_WIDTH - 24)*12/16)];
                view.backgroundColor = UIColor.greenColor;
                view.alpha = 0.45;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->areaContentView addSubview:view];
                });
            });
        }
        [UIView animateWithDuration:0.25 animations:^{
            self->areaBgView.alpha = 1;
            self->areaContentView.alpha = 1;
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self->areaBgView.alpha = 1;
            self->areaContentView.alpha = 1;
        }];
    }
    
}

- (void)hiddenCollectionView
{
    areaBgView.alpha = 0;
    areaContentView.alpha = 0;
}

- (void)addCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    float sizeWith      = (SCREEN_WIDTH - 24 - 15)/16;
    float sizeHeight    = ((SCREEN_WIDTH - 24)*12/16 - 11)/12;
    layout.itemSize     = CGSizeMake(sizeWith, sizeHeight);
    areaCollectionView.collectionViewLayout = layout;
    [areaCollectionView registerNib:[UINib nibWithNibName:@"KHJAlarmAreaCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"KHJAlarmAreaCell"];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 192;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

// 这个是两行cell之间的间距（上下行cell的间距）
 - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierCell = @"KHJAlarmAreaCell";
    KHJAlarmAreaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCell forIndexPath:indexPath];
    cell.tag = indexPath.row + FLAG_TAG;
    cell.delegate = self;
    return cell;
}

#pragma mark - KHJAlarmAreaCellDelegate

- (void)clickCellWith:(NSInteger)row select:(BOOL)select
{
    if (select) {
        CLog(@"row = %ld 被选择",(long)row);
    }
    else {
        CLog(@"row = %ld 取消",(long)row);
    }
}

- (IBAction)areaBtnActoin:(UIButton *)sender
{
    if (sender.tag == 10) {
        // 清理
    }
    else if (sender.tag == 20) {
        // 全选
    }
    else if (sender.tag == 30) {
        // 确定
    }
}


@end
