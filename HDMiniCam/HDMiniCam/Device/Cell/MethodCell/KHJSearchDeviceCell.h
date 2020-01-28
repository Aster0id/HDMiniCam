//
//  KHJSearchDeviceCell.h
//  HDMiniCam
//
//  Created by khj888 on 2020/1/17.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJSearchDeviceCellBlock)(NSInteger);

@interface KHJSearchDeviceCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UILabel *idd;
@property (nonatomic, copy) KHJSearchDeviceCellBlock block;

@end

NS_ASSUME_NONNULL_END
