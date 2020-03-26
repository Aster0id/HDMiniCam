//
//  KHJBackPlayListCell.h
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJBackPlayListCellDelegate <NSObject>

- (void)chooseItemWith:(NSInteger)index;

@end

@interface KHJBackPlayListCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *detailsLab;
@property (nonatomic, strong) id<KHJBackPlayListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
