//
//  KHJAlarmAreaCell.h
//  SuperIPC
//
//  Created by kevin on 2020/3/24.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHJAlarmAreaCellDelegate <NSObject>

- (void)clickCellWith:(NSInteger)row select:(BOOL)select;

@end

NS_ASSUME_NONNULL_BEGIN

@interface KHJAlarmAreaCell : UICollectionViewCell

@property (nonatomic, strong) id<KHJAlarmAreaCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
