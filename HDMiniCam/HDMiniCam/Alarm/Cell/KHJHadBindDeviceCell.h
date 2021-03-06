//
//  KHJHadBindDeviceCell.h
//  HDMiniCam
//
//  Created by kevin on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KHJHadBindDeviceCellBlock)(NSInteger);

@interface KHJHadBindDeviceCell : KHJBaseCell

@property (weak, nonatomic) IBOutlet UILabel *lab;
@property (nonatomic, copy) KHJHadBindDeviceCellBlock block;

@end

NS_ASSUME_NONNULL_END
