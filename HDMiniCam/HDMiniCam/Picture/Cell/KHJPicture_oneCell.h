//
//  KHJPicture_oneCell.h
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KHJPicture_oneCellDelegate <NSObject>

- (void)longPressWith:(NSString *)path;

@end

typedef void(^KHJPictureCellBlock)(NSString *);

@interface KHJPicture_oneCell : UICollectionViewCell

@property (nonatomic, copy) NSString *path;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (nonatomic, copy) KHJPictureCellBlock block;
@property (nonatomic, strong) id<KHJPicture_oneCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
