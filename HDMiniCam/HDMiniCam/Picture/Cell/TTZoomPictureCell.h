//
//  TTZoomPictureCell.h
//  SuperIPC
//
//  Created by kevin on 2020/1/15.
//  Copyright © 2020 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TTZoomPictureCellDelegate <NSObject>

- (void)longPressWith:(NSString *)path;

@end

typedef void(^TTZoomPictureCellBlock)(NSString *);

@interface TTZoomPictureCell : UICollectionViewCell

@property (nonatomic, copy) NSString *imagePath;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;

@property (nonatomic, copy) TTZoomPictureCellBlock block;
@property (nonatomic, strong) id<TTZoomPictureCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
