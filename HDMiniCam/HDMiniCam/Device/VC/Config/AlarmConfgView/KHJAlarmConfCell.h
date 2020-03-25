//
//  KHJAlarmConfCell.h
//  HDMiniCam
//
//  Created by kevin on 2020/3/23.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

@protocol KHJAlarmConfCellDelegate <NSObject>

- (void)clickWith:(NSInteger)row;

@end
NS_ASSUME_NONNULL_BEGIN

@interface KHJAlarmConfCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *subNameLab;
@property (nonatomic, strong) id<KHJAlarmConfCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
