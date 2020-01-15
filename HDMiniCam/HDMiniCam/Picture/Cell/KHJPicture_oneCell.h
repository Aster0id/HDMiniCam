//
//  KHJPicture_oneCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/15.
//  Copyright © 2020 王涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJPictureCellBlock)(NSInteger);

@interface KHJPicture_oneCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (nonatomic, assign) KHJPictureCellBlock block;

@end

NS_ASSUME_NONNULL_END
