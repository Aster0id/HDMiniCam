//
//  KHJCollectionViewCell_three.h
//  HDMiniCam
//
//  Created by khj888 on 2020/3/4.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KHJCollectionViewCell_threeDelegate <NSObject>

- (void)chooseItemWith:(NSInteger)row;
- (void)deleteItemWith:(NSInteger)row;

@end

@interface KHJCollectionViewCell_three : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLab;
@property (weak, nonatomic) IBOutlet UIImageView *videoImgView;
@property (nonatomic, strong) id<KHJCollectionViewCell_threeDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
