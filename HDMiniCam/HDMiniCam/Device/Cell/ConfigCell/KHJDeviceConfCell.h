//
//  KHJDeviceConfCell.h
//  HDMiniCam
//
//  Created by kevin on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJDeviceConfCellBlock)(NSInteger);

@interface KHJDeviceConfCell : KHJBaseCell

@property (nonatomic, copy) KHJDeviceConfCellBlock block;

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *lab;

@end

NS_ASSUME_NONNULL_END
