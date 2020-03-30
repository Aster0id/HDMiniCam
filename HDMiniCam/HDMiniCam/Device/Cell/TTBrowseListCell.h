//
//  TTBrowseListCell.h
//  SuperIPC
//
//  Created by kevin on 2020/2/23.
//  Copyright © 2020 kevin. All rights reserved.
//

#import "TTBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTBrowseListCellDelegate <NSObject>

- (void)chooseItemWith:(NSInteger)index;

@end

@interface TTBrowseListCell : TTBaseCell

@property (weak, nonatomic) IBOutlet UILabel *firstLab;
@property (weak, nonatomic) IBOutlet UILabel *secondLab;
@property (nonatomic, strong) id<TTBrowseListCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
