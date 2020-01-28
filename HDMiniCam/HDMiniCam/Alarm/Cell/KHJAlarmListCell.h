//
//  KHJAlarmListCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJAlarmListCellBlock)(NSInteger);

@interface KHJAlarmListCell : KHJBaseCell


@property (weak, nonatomic) IBOutlet UILabel *idd;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (nonatomic, copy) KHJAlarmListCellBlock block;

@end

NS_ASSUME_NONNULL_END
