//
//  KHJBackPlayListCell.h
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KHJBackPlayListCellDelegate <NSObject>

- (void)chooseItemWith:(NSInteger)index;

@end

@interface KHJBackPlayListCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *detailsLab;
@property (nonatomic, strong) id<KHJBackPlayListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
