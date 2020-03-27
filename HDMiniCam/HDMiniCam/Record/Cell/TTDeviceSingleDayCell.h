//
//  TTDeviceSingleDayCell.h
//  SuperIPC
//
//  Created by kevin on 2020/3/4.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TTDeviceSingleDayCellDelegate <NSObject>

- (void)chooseItemWith:(NSInteger)row;
- (void)deleteItemWith:(NSInteger)row;

@end

@interface TTDeviceSingleDayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLab;
@property (weak, nonatomic) IBOutlet UIImageView *videoImgView;
@property (nonatomic, strong) id<TTDeviceSingleDayCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
